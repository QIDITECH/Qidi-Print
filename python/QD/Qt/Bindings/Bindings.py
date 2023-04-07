# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from PyQt5.QtQml import qmlRegisterType, qmlRegisterSingletonType, qmlRegisterUncreatableType

from QD.Qt.Bindings import StageModel, FileProviderModel, ProjectOutputDevicesModel
from QD.Qt.Duration import Duration, DurationFormat

from . import MainWindow
from . import ViewModel
from . import ToolModel
from . import ApplicationProxy
from . import ControllerProxy

from . import BackendProxy
from . import ResourcesProxy
from . import OperationStackProxy
from QD.Mesh.MeshFileHandler import MeshFileHandler
from QD.Workspace.WorkspaceFileHandler import WorkspaceFileHandler
from . import PreferencesProxy
from . import Theme
from . import OpenGLContextProxy
from . import PointingRectangle
from . import ActiveToolProxy
from . import OutputDevicesModel
from . import SelectionProxy
from . import OutputDeviceManagerProxy
from . import i18nCatalogProxy
from . import ExtensionModel
from . import VisibleMessagesModel
from . import Utilities

from QD.Settings.Models.SettingDefinitionsModel import SettingDefinitionsModel
from QD.Settings.Models.DefinitionContainersModel import DefinitionContainersModel
from QD.Settings.Models.InstanceContainersModel import InstanceContainersModel
from QD.Settings.Models.ContainerStacksModel import ContainerStacksModel
from QD.Settings.Models.SettingPropertyProvider import SettingPropertyProvider
from QD.Settings.Models.SettingPreferenceVisibilityHandler import SettingPreferenceVisibilityHandler
from QD.Settings.Models.SettingPreferenceVisibilityHandlerForBasic import SettingPreferenceVisibilityHandlerForBasic
from QD.Settings.Models.ContainerPropertyProvider import ContainerPropertyProvider


class Bindings:
    @classmethod
    def createControllerProxy(self, engine, script_engine):
        return ControllerProxy.ControllerProxy()



    @classmethod
    def createApplicationProxy(self, engine, script_engine):
        return ApplicationProxy.ApplicationProxy()

    @classmethod
    def createBackendProxy(self, engine, script_engine):
        return BackendProxy.BackendProxy()

    @classmethod
    def createResourcesProxy(cls, engine, script_engine):
        return ResourcesProxy.ResourcesProxy()

    @classmethod
    def createOperationStackProxy(cls, engine, script_engine):
        return OperationStackProxy.OperationStackProxy()

    @classmethod
    def createOpenGLContextProxy(cls, engine, script_engine):
        return OpenGLContextProxy.OpenGLContextProxy()

    @classmethod
    def register(self):
        qmlRegisterType(MainWindow.MainWindow, "QD", 1, 0, "MainWindow")
        qmlRegisterType(ViewModel.ViewModel, "QD", 1, 0, "ViewModel")
        qmlRegisterType(ToolModel.ToolModel, "QD", 1, 0, "ToolModel")
        qmlRegisterType(PointingRectangle.PointingRectangle, "QD", 1, 0, "PointingRectangle")
        qmlRegisterType(ExtensionModel.ExtensionModel, "QD", 1, 0, "ExtensionModel")
        qmlRegisterType(VisibleMessagesModel.VisibleMessagesModel, "QD", 1, 0, "VisibleMessagesModel")

        # Singleton proxy objects

        qmlRegisterSingletonType(ControllerProxy.ControllerProxy, "QD", 1, 0, "Controller", Bindings.createControllerProxy)
        qmlRegisterSingletonType(ApplicationProxy.ApplicationProxy, "QD", 1, 0, "Application", Bindings.createApplicationProxy)
        qmlRegisterSingletonType(BackendProxy.BackendProxy, "QD", 1, 0, "Backend", Bindings.createBackendProxy)
        qmlRegisterSingletonType(ResourcesProxy.ResourcesProxy, "QD", 1, 0, "Resources", Bindings.createResourcesProxy)
        qmlRegisterSingletonType(OperationStackProxy.OperationStackProxy, "QD", 1, 0, "OperationStack", Bindings.createOperationStackProxy)
        qmlRegisterSingletonType(MeshFileHandler, "QD", 1, 0, "MeshFileHandler", MeshFileHandler.getInstance)
        qmlRegisterSingletonType(PreferencesProxy.PreferencesProxy, "QD", 1, 0, "Preferences", PreferencesProxy.createPreferencesProxy)
        qmlRegisterSingletonType(Theme.Theme, "QD", 1, 0, "Theme", Theme.createTheme)
        qmlRegisterSingletonType(ActiveToolProxy.ActiveToolProxy, "QD", 1, 0, "ActiveTool", ActiveToolProxy.createActiveToolProxy)
        qmlRegisterSingletonType(SelectionProxy.SelectionProxy, "QD", 1, 0, "Selection", SelectionProxy.createSelectionProxy)

        qmlRegisterUncreatableType(Duration, "QD", 1, 0, "Duration", "")
        qmlRegisterUncreatableType(DurationFormat, "QD", 1, 0, "DurationFormat", "")

        # Additions after 15.06. Uses API version 1.1 so should be imported with "import QD 1.1"
        qmlRegisterType(OutputDevicesModel.OutputDevicesModel, "QD", 1, 1, "OutputDevicesModel")
        qmlRegisterType(i18nCatalogProxy.i18nCatalogProxy, "QD", 1, 1, "I18nCatalog")

        qmlRegisterSingletonType(OutputDeviceManagerProxy.OutputDeviceManagerProxy, "QD", 1, 1, "OutputDeviceManager", OutputDeviceManagerProxy.createOutputDeviceManagerProxy)

        # Additions after 2.1. Uses API version 1.2
        qmlRegisterType(SettingDefinitionsModel, "QD", 1, 2, "SettingDefinitionsModel")
        qmlRegisterType(DefinitionContainersModel, "QD", 1, 2, "DefinitionContainersModel")
        qmlRegisterType(InstanceContainersModel, "QD", 1, 2, "InstanceContainersModel")
        qmlRegisterType(ContainerStacksModel, "QD", 1, 2, "ContainerStacksModel")
        qmlRegisterType(SettingPropertyProvider, "QD", 1, 2, "SettingPropertyProvider")
        qmlRegisterType(SettingPreferenceVisibilityHandler, "QD", 1, 2, "SettingPreferenceVisibilityHandler")
        qmlRegisterType(SettingPreferenceVisibilityHandlerForBasic, "QD", 1, 2, "SettingPreferenceVisibilityHandlerForBasic")
        qmlRegisterType(ContainerPropertyProvider, "QD", 1, 2, "ContainerPropertyProvider")

        # Additions after 2.3;
        qmlRegisterSingletonType(WorkspaceFileHandler, "QD", 1, 3, "WorkspaceFileHandler", WorkspaceFileHandler.getInstance)
        qmlRegisterSingletonType(OpenGLContextProxy.OpenGLContextProxy, "QD", 1, 3, "OpenGLContextProxy", Bindings.createOpenGLContextProxy)

        # Additions after 3.1
        qmlRegisterType(StageModel.StageModel, "QD", 1, 4, "StageModel")

        # Additions after 4.6
        qmlRegisterSingletonType(Utilities.UrlUtil, "QD", 1, 5, "UrlUtil", Utilities.createUrlUtil)

        # Additions after 4.9
        qmlRegisterType(FileProviderModel.FileProviderModel, "QD", 1, 6, "FileProviderModel")
        qmlRegisterType(ProjectOutputDevicesModel.ProjectOutputDevicesModel, "QD", 1, 6, "ProjectOutputDevicesModel")

    @staticmethod
    def addRegisterType(class_type: type, qml_import_name: str, major_version: int, minor_version: int, class_name: str) -> None:
        qmlRegisterType(class_type, qml_import_name, major_version, minor_version, class_name)
