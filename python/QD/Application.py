# Copyright (c) 2018 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

import argparse
import os
import sys
import threading
import locale

from PyQt5.QtCore import QUrl, pyqtSignal, pyqtProperty, QEvent, Q_ENUMS


from QD.Controller import Controller
from QD.FileProvider import FileProvider
from QD.Message import Message #For typing.
from QD.PackageManager import PackageManager
from QD.PluginRegistry import PluginRegistry
from QD.Qt.Bindings.FileProviderModel import FileProviderModel
from QD.Resources import Resources
from QD.Operations.OperationStack import OperationStack
from QD.Event import CallFunctionEvent
import QD.Settings
import QD.Settings.ContainerStack
import QD.Settings.InstanceContainer
from QD.Settings.ContainerRegistry import ContainerRegistry
from QD.Signal import Signal, signalemitter
from QD.Logger import Logger
from QD.Preferences import Preferences
from QD.View.Renderer import Renderer #For typing.
from QD.OutputDevice.OutputDeviceManager import OutputDeviceManager
from QD.Workspace.WorkspaceMetadataStorage import WorkspaceMetadataStorage
from QD.i18n import i18nCatalog
from QD.Version import Version

from QD.Mesh.MeshData import MeshData


from typing import TYPE_CHECKING, List, Callable, Any, Optional
if TYPE_CHECKING:
    from QD.Backend.Backend import Backend
    from QD.Settings.ContainerStack import ContainerStack
    from QD.Extension import Extension


@signalemitter
class Application:
    """Central object responsible for running the main event loop and creating other central objects.

    The Application object is a central object for accessing other important objects. It is also
    responsible for starting the main event loop. It is passed on to plugins so it can be easily
    used to access objects required for those plugins.
    """

    def __init__(self, name: str, version: str, api_version: str, app_display_name: str = "", build_type: str = "", is_debug_mode: bool = False, **kwargs) -> None:
        """Init method

        :param name: :type{string} The name of the application.
        :param version: :type{string} Version, formatted as major.minor.rev
        :param build_type: Additional version info on the type of build this is, such as "master".
        :param is_debug_mode: Whether to run in debug mode.
        """

        if Application.__instance is not None:
            raise RuntimeError("Try to create singleton '%s' more than once" % self.__class__.__name__)
        Application.__instance = self

        super().__init__()  # Call super to make multiple inheritance work.



        self._api_version = Version(api_version)  # type: Version

        self._app_name = name  # type: str
        self._app_display_name = app_display_name if app_display_name else name  # type: str
        self._version = version  # type: str
        self._build_type = build_type  # type: str
        self._is_debug_mode = is_debug_mode  # type: bool
        self._is_headless = False  # type: bool
        self._use_external_backend = False  # type: bool

        self._just_updated_from_old_version = False  # type: bool

        self._config_lock_filename = "{name}.lock".format(name = self._app_name)  # type: str

        self._cli_args = None  # type: argparse.Namespace
        self._cli_parser = argparse.ArgumentParser(prog = self._app_name, add_help = False)  # type: argparse.ArgumentParser

        self._main_thread = threading.current_thread()  # type: threading.Thread

        self.default_theme = self._app_name  # type: str # Default theme is the application name
        self._default_language = "en_US"  # type: str

        self.change_log_url = "https://github.com/QIDI/QDTECH"  # Where to find a more detailed description of the recent updates.

        self._preferences_filename = None  # type: str
        self._preferences = None  # type: Preferences

        self._extensions = []  # type: List[Extension]
        self._file_providers = []  # type: List[FileProvider]
        self._required_plugins = []  # type: List[str]

        self._package_manager_class = PackageManager  # type: type
        self._package_manager = None  # type: PackageManager

        self._plugin_registry = None  # type: PluginRegistry
        self._container_registry_class = ContainerRegistry  # type: type
        self._container_registry = None  # type: ContainerRegistry
        self._global_container_stack = None  # type: Optional[ContainerStack]

        self._file_provider_model = FileProviderModel(application = self)  # type: Optional[FileProviderModel]

        self._controller = None  # type: Controller
        self._backend = None  # type: Backend
        self._output_device_manager = None  # type: OutputDeviceManager
        self._operation_stack = None  # type: OperationStack

        self._visible_messages = []  # type: List[Message]
        self._message_lock = threading.Lock()  # type: threading.Lock

        self._app_install_dir = self.getInstallPrefix()  # type: str

        # Intended for keeping plugin workspace metadata that is going to be saved in and retrieved from workspace files.
        # When the workspace is stored, all workspace readers will need to ensure that the workspace metadata is correctly
        # stored to the output file. The same also holds when loading a workspace; the existing data will be cleared
        # and replaced with the data recovered from the file (if any).
        self._workspace_metadata_storage = WorkspaceMetadataStorage()  # type: WorkspaceMetadataStorage

        # Intended for keeping plugin workspace information that is only temporary. The information added in this structure
        # is NOT saved to and retrieved from workspace files.
        self._current_workspace_information = WorkspaceMetadataStorage()  # type: WorkspaceMetadataStorage

        self._button_mesh = None
        # self._button_mesh1 = None

    def getAPIVersion(self) -> "Version":
        return self._api_version

    def getWorkspaceMetadataStorage(self) -> WorkspaceMetadataStorage:
        return self._workspace_metadata_storage

    def getCurrentWorkspaceInformation(self) -> WorkspaceMetadataStorage:
        return self._current_workspace_information

    # Adds the command line options that can be parsed by the command line parser.
    # Can be overridden to add additional command line options to the parser.
    def addCommandLineOptions(self) -> None:
        self._cli_parser.add_argument("--version",
                                      action = "version",
                                      version = "%(prog)s version: {0}".format(self._version))
        self._cli_parser.add_argument("--external-backend",
                                      action = "store_true",
                                      default = False,
                                      help = "Use an externally started backend instead of starting it automatically. This is a debug feature to make it possible to run the engine with debug options enabled.")
        self._cli_parser.add_argument('--headless',
                                      action = 'store_true',
                                      default = False,
                                      help = "Hides all GUI elements.")
        self._cli_parser.add_argument("--debug",
                                      action = "store_true",
                                      default = False,
                                      help = "Turn on the debug mode by setting this option.")

    def parseCliOptions(self) -> None:
        self._cli_args = self._cli_parser.parse_args()

        self._is_headless = self._cli_args.headless
        self._is_debug_mode = self._cli_args.debug or self._is_debug_mode
        self._use_external_backend = self._cli_args.external_backend

    # Performs initialization that must be done before start.
    def initialize(self) -> None:
        Logger.log("d", "Initializing %s", self._app_display_name)
        Logger.log("d", "App Version %s", self._version)
        Logger.log("d", "Api Version %s", self._api_version)
        Logger.log("d", "Build type %s", self._build_type or "None")
        # For Ubuntu Unity this makes Qt use its own menu bar rather than pass it on to Unity.
        os.putenv("UBUNTU_MENUPROXY", "0")

        # Custom signal handling
        Signal._app = self
        Signal._signalQueue = self

        # Initialize Resources. Set the application name and version here because we can only know the actual info
        # after the __init__() has been called.
        Resources.ApplicationIdentifier = self._app_name
        Resources.ApplicationVersion = self._version

        app_root = os.path.abspath(os.path.join(os.path.dirname(sys.executable)))
        Resources.addSearchPath(os.path.join(app_root, "share", "qdtech", "resources"))

        Resources.addSearchPath(os.path.join(os.path.dirname(sys.executable), "resources"))
        Resources.addSearchPath(os.path.join(self._app_install_dir, "share", "qdtech", "resources"))
        Resources.addSearchPath(os.path.join(self._app_install_dir, "Resources", "qdtech", "resources"))
        Resources.addSearchPath(os.path.join(self._app_install_dir, "Resources", self._app_name, "resources"))

        if not hasattr(sys, "frozen"):
            Resources.addSearchPath(os.path.join(os.path.abspath(os.path.dirname(__file__)), "..", "resources"))

        i18nCatalog.setApplication(self)

        PluginRegistry.addType("backend", self.setBackend)
        PluginRegistry.addType("logger", Logger.addLogger)
        PluginRegistry.addType("extension", self.addExtension)
        PluginRegistry.addType("file_provider", self.addFileProvider)

        self._preferences = Preferences()
        self._preferences.addPreference("general/language", self._default_language)
        self._preferences.addPreference("qidi/fontsize", 1)
        self._preferences.addPreference("qidi/imagesize", 1)
        self._preferences.addPreference("qidi/show_search", "")
        #self._preferences.addPreference("view/show_ip_warning", True)
        self._preferences.addPreference("general/ip", "")
        self._preferences.addPreference("general/inputip", "")
        self._preferences.addPreference("general/visible_settings", "")
        self._preferences.addPreference("general/plugins_to_remove", "")
        self._preferences.addPreference("general/disabled_plugins", "")

        self._controller = Controller(self)
        self._output_device_manager = OutputDeviceManager()

        self._operation_stack = OperationStack(self._controller)

        self._plugin_registry = PluginRegistry(self)

        self._plugin_registry.addPluginLocation(os.path.join(app_root, "share", "qdtech", "plugins"))
        self._plugin_registry.addPluginLocation(os.path.join(app_root, "share", "qidi", "plugins"))

        self._plugin_registry.addPluginLocation(os.path.join(self._app_install_dir, "lib", "qdtech"))
        self._plugin_registry.addPluginLocation(os.path.join(self._app_install_dir, "lib64", "qdtech"))
        self._plugin_registry.addPluginLocation(os.path.join(self._app_install_dir, "lib32", "qdtech"))
        self._plugin_registry.addPluginLocation(os.path.join(os.path.dirname(sys.executable), "plugins"))
        self._plugin_registry.addPluginLocation(os.path.join(self._app_install_dir, "Resources", "qdtech", "plugins"))
        self._plugin_registry.addPluginLocation(os.path.join(self._app_install_dir, "Resources", self._app_name, "plugins"))
        # Locally installed plugins
        local_path = os.path.join(Resources.getStoragePath(Resources.Resources), "plugins")
        # Ensure the local plugins directory exists
        try:
            os.makedirs(local_path)
        except OSError:
            pass
        self._plugin_registry.addPluginLocation(local_path)

        if not hasattr(sys, "frozen"):
            self._plugin_registry.addPluginLocation(os.path.join(os.path.abspath(os.path.dirname(__file__)), "..", "plugins"))

        self._container_registry = self._container_registry_class(self)

        QD.Settings.InstanceContainer.setContainerRegistry(self._container_registry)
        QD.Settings.ContainerStack.setContainerRegistry(self._container_registry)

        self.showMessageSignal.connect(self.showMessage)
        self.hideMessageSignal.connect(self.hideMessage)

    def startSplashWindowPhase(self) -> None:
        pass

    def startPostSplashWindowPhase(self) -> None:
        pass

    # Indicates if we have just updated from an older application version.
    def hasJustUpdatedFromOldVersion(self) -> bool:
        return self._just_updated_from_old_version

    def run(self):
        """Run the main event loop.
        This method should be re-implemented by subclasses to start the main event loop.
        :exception NotImplementedError:
        """

        self.addCommandLineOptions()
        self.parseCliOptions()
        self.initialize()

        self.startSplashWindowPhase()
        self.startPostSplashWindowPhase()

    def getContainerRegistry(self) -> ContainerRegistry:
        return self._container_registry

    def getApplicationLockFilename(self) -> str:
        """Get the lock filename"""

        return self._config_lock_filename

    applicationShuttingDown = Signal()
    """Emitted when the application window was closed and we need to shut down the application"""

    showMessageSignal = Signal()

    hideMessageSignal = Signal()

    globalContainerStackChanged = Signal()

    workspaceLoaded = Signal()

    def setGlobalContainerStack(self, stack: Optional["ContainerStack"]) -> None:
        if self._global_container_stack != stack:
            self._global_container_stack = stack
            self.globalContainerStackChanged.emit()

    def getGlobalContainerStack(self) -> Optional["ContainerStack"]:
        return self._global_container_stack

    def hideMessage(self, message: Message) -> None:
        raise NotImplementedError

    def showMessage(self, message: Message) -> None:
        raise NotImplementedError

    def showToastMessage(self, title: str, message: str) -> None:
        raise NotImplementedError

    def getVersion(self) -> str:
        """Get the version of the application"""

        return self._version

    def getBuildType(self) -> str:
        """Get the build type of the application"""

        return self._build_type

    def getIsDebugMode(self) -> bool:
        return self._is_debug_mode

    def getIsHeadLess(self) -> bool:
        return self._is_headless

    def getUseExternalBackend(self) -> bool:
        return self._use_external_backend

    visibleMessageAdded = Signal()

    def hideMessageById(self, message_id: int) -> None:
        """Hide message by ID (as provided by built-in id function)"""

        # If a user and the application tries to close same message dialog simultaneously, message_id could become an empty
        # string, and then the application will raise an error when trying to do "int(message_id)".
        # So we check the message_id here.
        if not message_id:
            return

        found_message = None
        with self._message_lock:
            for message in self._visible_messages:
                if id(message) == int(message_id):
                    found_message = message
        if found_message is not None:
            self.hideMessageSignal.emit(found_message)

    visibleMessageRemoved = Signal()

    def getVisibleMessages(self) -> List[Message]:
        """Get list of all visible messages"""

        with self._message_lock:
            return self._visible_messages

    def _loadPlugins(self) -> None:
        """Function that needs to be overridden by child classes with a list of plugins it needs."""

        pass

    def getApplicationName(self) -> str:
        """Get name of the application.
        :returns: app_name
        """

        return self._app_name

    def getApplicationDisplayName(self) -> str:
        return self._app_display_name

    def getPreferences(self) -> Preferences:
        """Get the preferences.
        :return: preferences
        """

        return self._preferences

    def savePreferences(self) -> None:
        if self._preferences_filename:
            self._preferences.writeToFile(self._preferences_filename)
        else:
            Logger.log("i", "Preferences filename not set. Unable to save file.")

    def getApplicationLanguage(self) -> str:
        """Get the currently used IETF language tag.
        The returned tag is during runtime used to translate strings.
        :returns: Language tag.
        """

        language = os.getenv("QDTECH_LANGUAGE")
        if self._preferences.getValue("general/accepted_user_agreement") is None:
            locale_lang = locale.getdefaultlocale()
            self._preferences.setValue("general/language", locale_lang[0])
        if not language:
            language = self._preferences.getValue("general/language")
        if not language:
            language = os.getenv("LANGUAGE")
        if not language:
            language = self._default_language

        return language

    def getRequiredPlugins(self) -> List[str]:
        """Application has a list of plugins that it *must* have. If it does not have these, it cannot function.
        These plugins can not be disabled in any way.
        """

        return self._required_plugins

    def setRequiredPlugins(self, plugin_names: List[str]) -> None:
        """Set the plugins that the application *must* have in order to function.
        :param plugin_names: List of strings with the names of the required plugins
        """

        self._required_plugins = plugin_names

    def setBackend(self, backend: "Backend") -> None:
        """Set the backend of the application (the program that does the heavy lifting)."""

        self._backend = backend

    def getBackend(self) -> "Backend":
        """Get the backend of the application (the program that does the heavy lifting).
        :returns: Backend
        """

        return self._backend

    def getPluginRegistry(self) -> PluginRegistry:
        """Get the PluginRegistry of this application.
        :returns: PluginRegistry
        """

        return self._plugin_registry

    def getController(self) -> Controller:
        """Get the Controller of this application.
        :returns: Controller
        """

        return self._controller

    def getOperationStack(self) -> OperationStack:
        return self._operation_stack

    def getOutputDeviceManager(self) -> OutputDeviceManager:
        return self._output_device_manager

    def getRenderer(self) -> Renderer:
        """Return an application-specific Renderer object.
        :exception NotImplementedError
        """

        raise NotImplementedError("getRenderer must be implemented by subclasses.")

    def functionEvent(self, event: CallFunctionEvent) -> None:
        """Post a function event onto the event loop.

        This takes a CallFunctionEvent object and puts it into the actual event loop.
        :exception NotImplementedError
        """

        raise NotImplementedError("functionEvent must be implemented by subclasses.")

    def callLater(self, func: Callable[..., Any], *args, **kwargs) -> None:
        """Call a function the next time the event loop runs.

        You can't get the result of this function directly. It won't block.
        :param func: The function to call.
        :param args: The positional arguments to pass to the function.
        :param kwargs: The keyword arguments to pass to the function.
        """

        event = CallFunctionEvent(func, args, kwargs)
        self.functionEvent(event)

    def getMainThread(self) -> threading.Thread:
        """Get the application's main thread."""

        return self._main_thread

    def addExtension(self, extension: "Extension") -> None:
        self._extensions.append(extension)

    def getExtensions(self) -> List["Extension"]:
        return self._extensions

    def addFileProvider(self, file_provider: "FileProvider") -> None:
        self._file_providers.append(file_provider)

    def getFileProviders(self) -> List["FileProvider"]:
        return self._file_providers

    # def getButtonMesh1(self) -> Optional[MeshData]:
    #     return self._button_mesh1

    # def setButtonMesh1(self, mesh: MeshData) -> None:
    #     self._button_mesh1 = mesh

    def getButtonMesh(self) -> Optional[MeshData]:
        return self._button_mesh

    def setButtonMesh(self, mesh: MeshData) -> None:
        self._button_mesh = mesh



    # Returns the path to the folder of the app itself, e.g.: '/root/blah/programs/QIDI'.
    @staticmethod
    def getAppFolderPrefix() -> str:
        if "python" in os.path.basename(sys.executable):
            executable = sys.argv[0]
        else:
            executable = sys.executable
        return os.path.dirname(os.path.realpath(executable))

    # Returns the path to the folder the app is installed _in_, e.g.: '/root/blah/programs'
    @staticmethod
    def getInstallPrefix() -> str:
        return os.path.abspath(os.path.join(Application.getAppFolderPrefix(), ".."))

    __instance = None   # type: Application

    @classmethod
    def getInstance(cls, *args, **kwargs) -> "Application":
        return cls.__instance
