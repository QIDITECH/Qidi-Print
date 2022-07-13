# Copyright (c) 2017 Ultimaker B.V.
# Cura is released under the terms of the LGPLv3 or higher.

from UM.Backend.Backend import Backend, BackendState
from UM.Application import Application
from UM.Scene.SceneNode import SceneNode
from UM.Preferences import Preferences
from UM.Signal import Signal
from UM.Logger import Logger
from UM.Message import Message
from UM.PluginRegistry import PluginRegistry
from UM.Resources import Resources
from UM.Settings.Validator import ValidatorState  # To find if a setting is in an error state. We can't slice then.
from UM.Platform import Platform
from UM.Scene.Iterator.DepthFirstIterator import DepthFirstIterator
from UM.Qt.Duration import DurationFormat
from PyQt5.QtCore import QObject, pyqtSlot

from collections import defaultdict
from cura.Settings.ExtruderManager import ExtruderManager
from . import ProcessSlicedLayersJob
from . import StartSliceJob
from . import StartSliceJob,cprsImage
from . import OozePrevention

import os
import sys
from time import time

from PyQt5.QtCore import QTimer

import Arcus

from UM.i18n import i18nCatalog
catalog = i18nCatalog("cura")

import re
import shutil
from cura.CuraConf import *
from UM.Job import Job
import math
from cura.Scene.CuraSceneNode import CuraSceneNode
from UM.Math.AxisAlignedBox import AxisAlignedBox
from UM.Math.Polygon import Polygon

def getValue(line, key, default=None):
    if not key in line:
        return default
    subPart = line[line.find(key) + len(key):]
    m = re.search('^-?[0-9]+\.?[0-9]*', subPart)
    if m is None:
        return default
    try:
        return float(m.group(0))
    except:
        return default

class CuraEngineBackend(QObject, Backend):

    backendError = Signal()

    ##  Starts the back-end plug-in.
    #
    #   This registers all the signal listeners and prepares for communication
    #   with the back-end in general.
    #   CuraEngineBackend is exposed to qml as well.
    def __init__(self, parent = None):
        super().__init__(parent = parent)
        # Find out where the engine is located, and how it is called.
        # This depends on how Cura is packaged and which OS we are running on.
        executable_name = "CuraEngine"
        if Platform.isWindows():
            executable_name += ".exe"
        default_engine_location = executable_name
        if os.path.exists(os.path.join(Application.getInstallPrefix(), "bin", executable_name)):
            default_engine_location = os.path.join(Application.getInstallPrefix(), "bin", executable_name)
        if hasattr(sys, "frozen"):
            default_engine_location = os.path.join(os.path.dirname(os.path.abspath(sys.executable)), executable_name)
        if Platform.isLinux() and not default_engine_location:
            if not os.getenv("PATH"):
                raise OSError("There is something wrong with your Linux installation.")
            for pathdir in os.getenv("PATH").split(os.pathsep):
                execpath = os.path.join(pathdir, executable_name)
                if os.path.exists(execpath):
                    default_engine_location = execpath
                    break

        self._application = Application.getInstance()
        self._multi_build_plate_model = None
        self._machine_error_checker = None

        if not default_engine_location:
            raise EnvironmentError("Could not find CuraEngine")

        Logger.log("i", "Found CuraEngine at: %s", default_engine_location)

        default_engine_location = os.path.abspath(default_engine_location)
        Preferences.getInstance().addPreference("backend/location", default_engine_location)

        # Workaround to disable layer view processing if layer view is not active.
        self._layer_view_active = False
        self._onActiveViewChanged()

        self._stored_layer_data = []
        self._stored_optimized_layer_data = {}  # key is build plate number, then arrays are stored until they go to the ProcessSlicesLayersJob

        self._scene = self._application.getController().getScene()
        self._scene.sceneChanged.connect(self._onSceneChanged)

        # Triggers for auto-slicing. Auto-slicing is triggered as follows:
        #  - auto-slicing is started with a timer
        #  - whenever there is a value change, we start the timer
        #  - sometimes an error check can get scheduled for a value change, in that case, we ONLY want to start the
        #    auto-slicing timer when that error check is finished
        # If there is an error check, stop the auto-slicing timer, and only wait for the error check to be finished
        # to start the auto-slicing timer again.
        #
        self._global_container_stack = None

        # Listeners for receiving messages from the back-end.
        self._message_handlers["cura.proto.Layer"] = self._onLayerMessage
        self._message_handlers["cura.proto.LayerOptimized"] = self._onOptimizedLayerMessage
        self._message_handlers["cura.proto.Progress"] = self._onProgressMessage
        self._message_handlers["cura.proto.GCodeLayer"] = self._onGCodeLayerMessage
        self._message_handlers["cura.proto.GCodePrefix"] = self._onGCodePrefixMessage
        self._message_handlers["cura.proto.PrintTimeMaterialEstimates"] = self._onPrintTimeMaterialEstimates
        self._message_handlers["cura.proto.SlicingFinished"] = self._onSlicingFinishedMessage

        self._start_slice_job = None
        self._start_slice_job_build_plate = None
        self._slicing = False  # Are we currently slicing?
        self._restart = False  # Back-end is currently restarting?
        self._tool_active = False  # If a tool is active, some tasks do not have to do anything
        self._always_restart = True  # Always restart the engine when starting a new slice. Don't keep the process running. TODO: Fix engine statelessness.
        self._process_layers_job = None  # The currently active job to process layers, or None if it is not processing layers.
        self._build_plates_to_be_sliced = []  # what needs slicing?
        self._engine_is_fresh = True  # Is the newly started engine used before or not?

        self._backend_log_max_lines = 20000  # Maximum number of lines to buffer
        self._error_message = None  # Pop-up message that shows errors.
        self._last_num_objects = defaultdict(int)  # Count number of objects to see if there is something changed
        self._postponed_scene_change_sources = []  # scene change is postponed (by a tool)

        self._slice_start_time = None
        self._is_disabled = False

        Preferences.getInstance().addPreference("general/auto_slice", False)

        self._use_timer = False
        # When you update a setting and other settings get changed through inheritance, many propertyChanged signals are fired.
        # This timer will group them up, and only slice for the last setting changed signal.
        # TODO: Properly group propertyChanged signals by whether they are triggered by the same user interaction.
        self._change_timer = QTimer()
        self._change_timer.setSingleShot(True)
        self._change_timer.setInterval(500)
        self.determineAutoSlicing()
        Preferences.getInstance().preferenceChanged.connect(self._onPreferencesChanged)
        
        self._screenshotImages = ()

        self._application.initializationFinished.connect(self.initialize)

    def initialize(self):
        self._multi_build_plate_model = self._application.getMultiBuildPlateModel()

        self._application.getController().activeViewChanged.connect(self._onActiveViewChanged)
        self._multi_build_plate_model.activeBuildPlateChanged.connect(self._onActiveViewChanged)

        self._application.globalContainerStackChanged.connect(self._onGlobalStackChanged)
        self._onGlobalStackChanged()

        # extruder enable / disable. Actually wanted to use machine manager here, but the initialization order causes it to crash
        ExtruderManager.getInstance().extrudersChanged.connect(self._extruderChanged)

        self.backendQuit.connect(self._onBackendQuit)
        self.backendConnected.connect(self._onBackendConnected)

        # When a tool operation is in progress, don't slice. So we need to listen for tool operations.
        self._application.getController().toolOperationStarted.connect(self._onToolOperationStarted)
        self._application.getController().toolOperationStopped.connect(self._onToolOperationStopped)

        self._machine_error_checker = self._application.getMachineErrorChecker()
        self._machine_error_checker.errorCheckFinished.connect(self._onStackErrorCheckFinished)

    ##  Terminate the engine process.
    #
    #   This function should terminate the engine process.
    #   Called when closing the application.
    def close(self):
        # Terminate CuraEngine if it is still running at this point
        self._terminate()

    ##  Get the command that is used to call the engine.
    #   This is useful for debugging and used to actually start the engine.
    #   \return list of commands and args / parameters.
    def getEngineCommand(self):
        json_path = Resources.getPath(Resources.DefinitionContainers, "fdmprinter.def.json")
        return [Preferences.getInstance().getValue("backend/location"), "connect", "127.0.0.1:{0}".format(self._port), "-j", json_path, ""]

    ##  Emitted when we get a message containing print duration and material amount.
    #   This also implies the slicing has finished.
    #   \param time The amount of time the print will take.
    #   \param material_amount The amount of material the print will use.
    printDurationMessage = Signal()

    ##  Emitted when the slicing process starts.
    slicingStarted = Signal()

    ##  Emitted when the slicing process is aborted forcefully.
    slicingCancelled = Signal()

    @pyqtSlot()
    def stopSlicing(self):
        self.backendStateChange.emit(BackendState.NotStarted)
        if self._slicing:  # We were already slicing. Stop the old job.
            self._terminate()
            self._createSocket()

        if self._process_layers_job:  # We were processing layers. Stop that, the layers are going to change soon.
            Logger.log("d", "Aborting process layers job...")
            self._process_layers_job.abort()
            self._process_layers_job = None

        if self._error_message:
            self._error_message.hide()
            
    #########################截屏数据，从cura.qml中传过来，会在切片完成之后，进行计算########################################
    @pyqtSlot("QVariantList")
    def setScreenshotImages(self, images):
        self._screenshotImages = images

    ##  Manually triggers a reslice
    @pyqtSlot()
    def forceSlice(self):
        self.markSliceAll()
        self.slice()

    @pyqtSlot()
    def getOozePrevention(self):
        OozePrevention.OozePrevention().oozePrevention()

    @pyqtSlot()
    def setPrimeTowerPositionAuto(self):
        stack = Application.getInstance().getGlobalContainerStack()
        if stack.getProperty("prime_tower_position_auto", "value") and stack.getProperty("prime_tower_enable", "value") and stack.getProperty("extruders_enabled_count", "value") > 1:
            Logger.log("d", "Start set prime tower position.")
            
            scene_bounding_box = None
            for node in DepthFirstIterator(self._scene.getRoot()):
                if not node.callDecoration("isSliceable"):
                    continue
                if not scene_bounding_box:
                    scene_bounding_box = node.getBoundingBox()
                else:
                    other_bb = node.getBoundingBox()
                    if other_bb is not None:
                        scene_bounding_box = scene_bounding_box + node.getBoundingBox()
            if not scene_bounding_box:
                scene_bounding_box = AxisAlignedBox.Null
            
            machine_width = stack.getProperty("machine_width", "value")
            machine_depth = stack.getProperty("machine_depth", "value")
            prime_tower_radius = stack.getProperty("prime_tower_size", "value") / 2
            
            prime_tower_x = machine_width/2 + prime_tower_radius
            prime_tower_y = machine_depth/2 - scene_bounding_box.center.z - scene_bounding_box.depth/2 - prime_tower_radius*2 - 5
            
            if stack.getProperty("ooze_shield_enabled", "value"):
                prime_tower_y -= stack.getProperty("ooze_shield_dist", "value")
            if stack.getProperty("draft_shield_enabled", "value"):
                prime_tower_y -= stack.getProperty("draft_shield_dist", "value")
            if prime_tower_y <= 20:
                prime_tower_y = 25

                while True:
                    set_position_x = False
                    for node in DepthFirstIterator(self._scene.getRoot()):
                        if node.callDecoration("isSliceable"):
                            prime_tower_area = Polygon.approximatedCircle(prime_tower_radius)
                            prime_tower_area = prime_tower_area.translate(prime_tower_x - prime_tower_radius - machine_width/2, machine_depth/2 - prime_tower_y - prime_tower_radius)
                            prime_tower_area = prime_tower_area.getMinkowskiHull(Polygon.approximatedCircle(0))
                            if node.collidesWithArea([prime_tower_area]):
                                if prime_tower_x <= 50:
                                    prime_tower_x = machine_width/2 + prime_tower_radius + 25
                                elif 50 < prime_tower_x <= machine_width/2 + prime_tower_radius:
                                    prime_tower_x -= 25
                                elif machine_width/2 + prime_tower_radius < prime_tower_x < machine_width - 50:
                                    prime_tower_x += 25
                                else:
                                    Logger.log("d", "Didn't set prime tower.")
                                    set_position_x = False
                                    break
                                set_position_x = True
                                break
                    if not set_position_x:
                        break
                        
            stack.setProperty("prime_tower_position_x", "value", prime_tower_x)
            stack.setProperty("prime_tower_position_y", "value", prime_tower_y)

    ##  Perform a slice of the scene.
    def slice(self):
        Logger.log("d", "Starting to slice...")
        self.setScreenshotImages(Application.getInstance().getMainWindow().screenshotImages())
        self._slice_start_time = time()
        if not self._build_plates_to_be_sliced:
            self.processingProgress.emit(1.0)
            Logger.log("w", "Slice unnecessary, nothing has changed that needs reslicing.")
            return

        if self._process_layers_job:
            Logger.log("d", "Process layers job still busy, trying later.")
            return

        if not hasattr(self._scene, "gcode_dict"):
            self._scene.gcode_dict = {}

        # see if we really have to slice
        active_build_plate = Application.getInstance().getMultiBuildPlateModel().activeBuildPlate
        build_plate_to_be_sliced = self._build_plates_to_be_sliced.pop(0)
        Logger.log("d", "Going to slice build plate [%s]!" % build_plate_to_be_sliced)
        num_objects = self._numObjectsPerBuildPlate()

        self._stored_layer_data = []
        self._stored_optimized_layer_data[build_plate_to_be_sliced] = []

        if build_plate_to_be_sliced not in num_objects or num_objects[build_plate_to_be_sliced] == 0:
            self._scene.gcode_dict[build_plate_to_be_sliced] = []
            Logger.log("d", "Build plate %s has no objects to be sliced, skipping", build_plate_to_be_sliced)
            if self._build_plates_to_be_sliced:
                self.slice()
            return

        if Application.getInstance().getPrintInformation() and build_plate_to_be_sliced == active_build_plate:
            Application.getInstance().getPrintInformation().setToZeroPrintInformation(build_plate_to_be_sliced)

        if self._process is None:
            self._createSocket()
        self.stopSlicing()
        self._engine_is_fresh = False  # Yes we're going to use the engine

        self.processingProgress.emit(0.0)
        self.backendStateChange.emit(BackendState.NotStarted)

        self._scene.gcode_dict[build_plate_to_be_sliced] = []  #[] indexed by build plate number
        self._slicing = True
        self.slicingStarted.emit()

        self.determineAutoSlicing()  # Switch timer on or off if appropriate

        slice_message = self._socket.createMessage("cura.proto.Slice")
        self._start_slice_job = StartSliceJob.StartSliceJob(slice_message)
        self._start_slice_job_build_plate = build_plate_to_be_sliced
        self._start_slice_job.setBuildPlate(self._start_slice_job_build_plate)
        self._start_slice_job.start()
        self._start_slice_job.finished.connect(self._onStartSliceCompleted)

    ##  Terminate the engine process.
    #   Start the engine process by calling _createSocket()
    def _terminate(self):
        self._slicing = False
        self._stored_layer_data = []
        if self._start_slice_job_build_plate in self._stored_optimized_layer_data:
            del self._stored_optimized_layer_data[self._start_slice_job_build_plate]
        if self._start_slice_job is not None:
            self._start_slice_job.cancel()

        self.slicingCancelled.emit()
        self.processingProgress.emit(0)
        Logger.log("d", "Attempting to kill the engine process")

        if Application.getInstance().getCommandLineOption("external-backend", False):
            return

        if self._process is not None:
            Logger.log("d", "Killing engine process")
            try:
                self._process.terminate()
                Logger.log("d", "Engine process is killed. Received return code %s", self._process.wait())
                self._process = None

            except Exception as e:  # terminating a process that is already terminating causes an exception, silently ignore this.
                Logger.log("d", "Exception occurred while trying to kill the engine %s", str(e))

    ##  Event handler to call when the job to initiate the slicing process is
    #   completed.
    #
    #   When the start slice job is successfully completed, it will be happily
    #   slicing. This function handles any errors that may occur during the
    #   bootstrapping of a slice job.
    #
    #   \param job The start slice job that was just finished.
    def _onStartSliceCompleted(self, job):
        if self._error_message:
            self._error_message.hide()

        # Note that cancelled slice jobs can still call this method.
        if self._start_slice_job is job:
            self._start_slice_job = None

        if job.isCancelled() or job.getError() or job.getResult() == StartSliceJob.StartJobResult.Error:
            self.backendStateChange.emit(BackendState.Error)
            self.backendError.emit(job)
            return

        if job.getResult() == StartSliceJob.StartJobResult.MaterialIncompatible:
            if Application.getInstance().platformActivity:
                self._error_message = Message(catalog.i18nc("@info:status",
                                            "Unable to slice with the current material as it is incompatible with the selected machine or configuration."), title = catalog.i18nc("@info:title", "Unable to slice"))
                self._error_message.show()
                self.backendStateChange.emit(BackendState.Error)
                self.backendError.emit(job)
            else:
                self.backendStateChange.emit(BackendState.NotStarted)
            return

        if job.getResult() == StartSliceJob.StartJobResult.SettingError:
            if Application.getInstance().platformActivity:
                extruders = list(ExtruderManager.getInstance().getMachineExtruders(self._global_container_stack.getId()))
                error_keys = []
                for extruder in extruders:
                    error_keys.extend(extruder.getErrorKeys())
                if not extruders:
                    error_keys = self._global_container_stack.getErrorKeys()
                error_labels = set()
                for key in error_keys:
                    for stack in [self._global_container_stack] + extruders: #Search all container stacks for the definition of this setting. Some are only in an extruder stack.
                        definitions = stack.getBottom().findDefinitions(key = key)
                        if definitions:
                            break #Found it! No need to continue search.
                    else: #No stack has a definition for this setting.
                        Logger.log("w", "When checking settings for errors, unable to find definition for key: {key}".format(key = key))
                        continue
                    error_labels.add(definitions[0].label)

                error_labels = ", ".join(error_labels)
                self._error_message = Message(catalog.i18nc("@info:status", "Unable to slice with the current settings. The following settings have errors: {0}").format(error_labels),
                                              title = catalog.i18nc("@info:title", "Unable to slice"))
                self._error_message.show()
                self.backendStateChange.emit(BackendState.Error)
                self.backendError.emit(job)
            else:
                self.backendStateChange.emit(BackendState.NotStarted)
            return

        elif job.getResult() == StartSliceJob.StartJobResult.ObjectSettingError:
            errors = {}
            for node in DepthFirstIterator(Application.getInstance().getController().getScene().getRoot()):
                stack = node.callDecoration("getStack")
                if not stack:
                    continue
                for key in stack.getErrorKeys():
                    definition = self._global_container_stack.getBottom().findDefinitions(key = key)
                    if not definition:
                        Logger.log("e", "When checking settings for errors, unable to find definition for key {key} in per-object stack.".format(key = key))
                        continue
                    definition = definition[0]
                    errors[key] = definition.label
            error_labels = ", ".join(errors.values())
            self._error_message = Message(catalog.i18nc("@info:status", "Unable to slice due to some per-model settings. The following settings have errors on one or more models: {error_labels}").format(error_labels = error_labels),
                                          title = catalog.i18nc("@info:title", "Unable to slice"))
            self._error_message.show()
            self.backendStateChange.emit(BackendState.Error)
            self.backendError.emit(job)
            return

        if job.getResult() == StartSliceJob.StartJobResult.BuildPlateError:
            if Application.getInstance().platformActivity:
                self._error_message = Message(catalog.i18nc("@info:status", "Unable to slice because the prime tower or prime position(s) are invalid."),
                                              title = catalog.i18nc("@info:title", "Unable to slice"))
                self._error_message.show()
                self.backendStateChange.emit(BackendState.Error)
                self.backendError.emit(job)
            else:
                self.backendStateChange.emit(BackendState.NotStarted)

        if job.getResult() == StartSliceJob.StartJobResult.NothingToSlice:
            if Application.getInstance().platformActivity:
                self._error_message = Message(catalog.i18nc("@info:status", "Nothing to slice because none of the models fit the build volume. Please scale or rotate models to fit."),
                                              title = catalog.i18nc("@info:title", "Unable to slice"))
                self._error_message.show()
                self.backendStateChange.emit(BackendState.Error)
                self.backendError.emit(job)
            else:
                self.backendStateChange.emit(BackendState.NotStarted)
            self._invokeSlice()
            return

        # Preparation completed, send it to the backend.
        self._socket.sendMessage(job.getSliceMessage())

        # Notify the user that it's now up to the backend to do it's job
        self.backendStateChange.emit(BackendState.Processing)

        Logger.log("d", "Sending slice message took %s seconds", time() - self._slice_start_time )

    ##  Determine enable or disable auto slicing. Return True for enable timer and False otherwise.
    #   It disables when
    #   - preference auto slice is off
    #   - decorator isBlockSlicing is found (used in g-code reader)
    def determineAutoSlicing(self):
        enable_timer = True
        self._is_disabled = False

        if not Preferences.getInstance().getValue("general/auto_slice"):
            enable_timer = False
        for node in DepthFirstIterator(self._scene.getRoot()):
            if node.callDecoration("isBlockSlicing"):
                enable_timer = False
                self.backendStateChange.emit(BackendState.Disabled)
                self._is_disabled = True
            gcode_list = node.callDecoration("getGCodeList")
            if gcode_list is not None:
                self._scene.gcode_dict[node.callDecoration("getBuildPlateNumber")] = gcode_list

        if self._use_timer == enable_timer:
            return self._use_timer
        if enable_timer:
            self.backendStateChange.emit(BackendState.NotStarted)
            self.enableTimer()
            return True
        else:
            self.disableTimer()
            return False

    ##  Return a dict with number of objects per build plate
    def _numObjectsPerBuildPlate(self):
        num_objects = defaultdict(int)
        for node in DepthFirstIterator(self._scene.getRoot()):
            # Only count sliceable objects
            if node.callDecoration("isSliceable"):
                build_plate_number = node.callDecoration("getBuildPlateNumber")
                num_objects[build_plate_number] += 1
        return num_objects

    ##  Listener for when the scene has changed.
    #
    #   This should start a slice if the scene is now ready to slice.
    #
    #   \param source The scene node that was changed.
    def _onSceneChanged(self, source):
        if not isinstance(source, SceneNode):
            return

        # This case checks if the source node is a node that contains GCode. In this case the
        # current layer data is removed so the previous data is not rendered - CURA-4821
        if source.callDecoration("isBlockSlicing") and source.callDecoration("getLayerData"):
            self._stored_optimized_layer_data = {}

        build_plate_changed = set()
        source_build_plate_number = source.callDecoration("getBuildPlateNumber")
        if source == self._scene.getRoot():
            # we got the root node
            num_objects = self._numObjectsPerBuildPlate()
            for build_plate_number in list(self._last_num_objects.keys()) + list(num_objects.keys()):
                if build_plate_number not in self._last_num_objects or num_objects[build_plate_number] != self._last_num_objects[build_plate_number]:
                    self._last_num_objects[build_plate_number] = num_objects[build_plate_number]
                    build_plate_changed.add(build_plate_number)
        else:
            # we got a single scenenode
            if not source.callDecoration("isGroup"):
                if source.getMeshData() is None:
                    return
                if source.getMeshData().getVertices() is None:
                    return

            build_plate_changed.add(source_build_plate_number)

        build_plate_changed.discard(None)
        build_plate_changed.discard(-1)  # object not on build plate
        if not build_plate_changed:
            return

        if self._tool_active:
            # do it later, each source only has to be done once
            if source not in self._postponed_scene_change_sources:
                self._postponed_scene_change_sources.append(source)
            return

        self.stopSlicing()
        for build_plate_number in build_plate_changed:
            if build_plate_number not in self._build_plates_to_be_sliced:
                self._build_plates_to_be_sliced.append(build_plate_number)
            self.printDurationMessage.emit(source_build_plate_number, {}, [])
        self.processingProgress.emit(0.0)
        self.backendStateChange.emit(BackendState.NotStarted)
        # if not self._use_timer:
            # With manually having to slice, we want to clear the old invalid layer data.
        self._clearLayerData(build_plate_changed)

        self._invokeSlice()

    ##  Called when an error occurs in the socket connection towards the engine.
    #
    #   \param error The exception that occurred.
    def _onSocketError(self, error):
        if Application.getInstance().isShuttingDown():
            return

        super()._onSocketError(error)
        if error.getErrorCode() == Arcus.ErrorCode.Debug:
            return

        self._terminate()
        self._createSocket()

        if error.getErrorCode() not in [Arcus.ErrorCode.BindFailedError, Arcus.ErrorCode.ConnectionResetError, Arcus.ErrorCode.Debug]:
            Logger.log("w", "A socket error caused the connection to be reset")

    ##  Remove old layer data (if any)
    def _clearLayerData(self, build_plate_numbers = set()):
        for node in DepthFirstIterator(self._scene.getRoot()):
            if node.callDecoration("getLayerData"):
                if not build_plate_numbers or node.callDecoration("getBuildPlateNumber") in build_plate_numbers:
                    node.getParent().removeChild(node)

    def markSliceAll(self):
        for build_plate_number in range(Application.getInstance().getMultiBuildPlateModel().maxBuildPlate + 1):
            if build_plate_number not in self._build_plates_to_be_sliced:
                self._build_plates_to_be_sliced.append(build_plate_number)

    ##  Convenient function: mark everything to slice, emit state and clear layer data
    def needsSlicing(self):
        self.stopSlicing()
        self.markSliceAll()
        self.processingProgress.emit(0.0)
        self.backendStateChange.emit(BackendState.NotStarted)
        if not self._use_timer:
            # With manually having to slice, we want to clear the old invalid layer data.
            self._clearLayerData()

    ##  A setting has changed, so check if we must reslice.
    # \param instance The setting instance that has changed.
    # \param property The property of the setting instance that has changed.
    def _onSettingChanged(self, instance, property):
        if property == "value":  # Only reslice if the value has changed.
            self.needsSlicing()
            self._onChanged()

        elif property == "validationState":
            if self._use_timer:
                self._change_timer.stop()

    def _onStackErrorCheckFinished(self):
        self.determineAutoSlicing()
        if self._is_disabled:
            return

        if not self._slicing and self._build_plates_to_be_sliced:
            self.needsSlicing()
            self._onChanged()

    ##  Called when a sliced layer data message is received from the engine.
    #
    #   \param message The protobuf message containing sliced layer data.
    def _onLayerMessage(self, message):
        self._stored_layer_data.append(message)

    ##  Called when an optimized sliced layer data message is received from the engine.
    #
    #   \param message The protobuf message containing sliced layer data.
    def _onOptimizedLayerMessage(self, message):
        if self._start_slice_job_build_plate not in self._stored_optimized_layer_data:
            self._stored_optimized_layer_data[self._start_slice_job_build_plate] = []
        self._stored_optimized_layer_data[self._start_slice_job_build_plate].append(message)

    ##  Called when a progress message is received from the engine.
    #
    #   \param message The protobuf message containing the slicing progress.
    def _onProgressMessage(self, message):
        self.processingProgress.emit(message.amount)
        self.backendStateChange.emit(BackendState.Processing)

    def _invokeSlice(self):
        if self._use_timer:
            # if the error check is scheduled, wait for the error check finish signal to trigger auto-slice,
            # otherwise business as usual
            if self._machine_error_checker is None:
                self._change_timer.stop()
                return

            if self._machine_error_checker.needToWaitForResult:
                self._change_timer.stop()
            else:
                self._change_timer.start()

    ##  Called when the engine sends a message that slicing is finished.
    #
    #   \param message The protobuf message signalling that slicing is finished.
    def _onSlicingFinishedMessage(self, message):
        self.backendStateChange.emit(BackendState.Done)
        self.processingProgress.emit(1.0)

        gcode_list = self._scene.gcode_dict[self._start_slice_job_build_plate]
        for index, line in enumerate(gcode_list):
            replaced = line.replace("{print_time}", str(Application.getInstance().getPrintInformation().currentPrintTime.getDisplayString(DurationFormat.Format.ISO8601)))
            replaced = replaced.replace("{filament_amount}", str(Application.getInstance().getPrintInformation().materialLengths))
            replaced = replaced.replace("{filament_weight}", str(Application.getInstance().getPrintInformation().materialWeights))
            replaced = replaced.replace("{filament_cost}", str(Application.getInstance().getPrintInformation().materialCosts))
            replaced = replaced.replace("{jobname}", str(Application.getInstance().getPrintInformation().jobName))

            gcode_list[index] = replaced
###########对gcode进行加工 需要先获取打印参数
        stack = Application.getInstance().getGlobalContainerStack()####只能控制不随喷头变化的参数
        stack0 = Application.getInstance().getExtruderManager().getExtruderStacks()[0]####喷头1的参数
        try:
            stack1 = Application.getInstance().getExtruderManager().getExtruderStacks()[1]####喷头2的参数
        except:
            stack1 = Application.getInstance().getExtruderManager().getExtruderStacks()[0]
#########one2时间显示不正常需要加M2100
        if gcode_list[0].count(";TIME:") > 0:
            print_time = gcode_list[0].split(";TIME:")[1].split("\n")[0]
            gcode_list[0] = gcode_list[0] + "M2100 T" + print_time + "\n"
#########LAYER_COUNT有时候会和LAYER:0合并成一项，需要提前拆分开来
        if gcode_list[1].count(";LAYER:0") > 0:
            layer_count = gcode_list[1].split(";LAYER:0")[0]
            gcode_list2 = gcode_list[1].split(";LAYER:0")[1]
            gcode_list[1] = ";LAYER:0" + gcode_list2
            gcode_list.insert(1, layer_count)
###########Z轴偏移 4
        if stack.getProperty("z_offset", "value") != 0:
            gcode_list[1] = re.sub("Z0.3", "Z" + str(round(0.3 + stack.getProperty("z_offset", "value"), 5)), gcode_list[1])
            for count4, gcode4 in enumerate(gcode_list[:-2]):
                if count4 > 1:
                    a4 = gcode4.split("\n")
                    for i4, row4 in enumerate(a4):
                        if row4.count("Z") > 0:
                            zoffset = str(round(getValue(row4,"Z",0) + stack.getProperty("z_offset", "value"), 5))
                            row4 = re.sub(r"Z-?[0-9]+\.?[0-9]*", "Z" + zoffset, row4)
                        a4[i4] = row4
                    gcode4 = "\n".join(a4).rstrip("\n")
                gcode_list[count4] = gcode4 + "\n"
#########双喷头
        first_extruder = "0"
        double_extruder_list = ["i-fast", "X-pro", "QIDI I"]
        machine_name = stack.getProperty("machine_name", "value")
        if machine_name in double_extruder_list:
            first_extruder = str(int(getValue(gcode_list[1], "T", 0)))
            extruder_count = stack.getProperty("machine_extruder_count", "value")
            used_extruder_count = len(Application.getInstance().getExtruderManager().getUsedExtruderStacks())
############单个喷头打印时温度控制
            if used_extruder_count == 1:
                if first_extruder == "1":
                    gcode_list[1] = re.sub("M104 T0", ";M104 T0", gcode_list[1])
                    gcode_list[1] = re.sub("M109 T0", ";M109 T0", gcode_list[1])
                    gcode_list[1] = re.sub("A.*? F2400\n", "A0 F2400\n", gcode_list[1])
                else:
                    gcode_list[1] = re.sub("M104 T1", ";M104 T1", gcode_list[1])
                    gcode_list[1] = re.sub("M109 T1", ";M109 T1", gcode_list[1])
                    gcode_list[1] = re.sub("B.*? F2400\n", "B0 F2400\n", gcode_list[1])
###############双喷头定位
            if extruder_count > 1:
                if machine_name in ["i-fast"]:
                    gcode_list[1] = re.sub("\nT", "\n;T", gcode_list[1], 1)
                else:
                    gcode_list[1] = re.sub("T.*?\nM82 ;absolute extrusion mode", "T0\nM82 ;absolute extrusion mode", gcode_list[1], 1)
                if first_extruder == "1":
                    gcode_list[1] = re.sub("G0 X5 F2400", "T1\nG0 X5 F2400", gcode_list[1])#######fast
############3.6.0换喷头时会有M105指令，去掉5
                for count5, gcode5 in enumerate(gcode_list):
                    gcode5 = re.sub("M105", ";M105", gcode5)
                    gcode_list[count5] = gcode5
#########fast
            if machine_name in double_extruder_list:
#########fast双喷头模式
                if extruder_count > 1:
                    if used_extruder_count > 1:
###############切换喷头时，在加热完成前开始降温
                        standby_temperature_0 = str(stack0.getProperty("material_standby_temperature", "value"))
                        standby_temperature_1 = str(stack1.getProperty("material_standby_temperature", "value"))
                        for count1, gcode1 in enumerate(gcode_list[2:]):
                            if gcode1.count("M104 T1 S") > 0:
                                gcode1 = re.sub("\nT0\n", "\nM104 T1 S" + standby_temperature_1 + "\nT0\n", gcode1)
                                gcode_list[count1 + 2] = gcode1
                            elif gcode1.count("M104 T0 S") > 0:
                                gcode1 = re.sub("\nT1\n", "\nM104 T0 S" + standby_temperature_0 + "\nT1\n", gcode1)
                                gcode_list[count1 + 2] = gcode1
#########fast单喷头模式不需要左右定位和B0
                else:
                    gcode_list[1] = re.sub("\nT0\n", "\n;T0\n", gcode_list[1])
                    gcode_list[1] = re.sub("\nT1\n", "\n;T1\n", gcode_list[1])
                    gcode_list[1] = re.sub(" B0", "", gcode_list[1])
#########预挤出
        if stack.getProperty("print_in_advance", "value"):
            try:
                gcode_first = gcode_list[2].split("G0 ")[1].split("\n")[0]
                _diffX = getValue(gcode_first, "X", 0)
                _diffY = getValue(gcode_first, "Y", 0)
                if _diffY != 0 and _diffX != 0:
                    if first_extruder == "1":
                        print_width = stack1.getProperty("line_width", "value") * stack1.getProperty("material_flow_layer_0", "value") / 100 * stack1.getProperty("initial_layer_line_width_factor", "value") / 100
                    else:
                        print_width = stack0.getProperty("line_width", "value") * stack0.getProperty("material_flow_layer_0", "value") / 100 * stack1.getProperty("initial_layer_line_width_factor", "value") / 100
                    _diffE =  math.sqrt((_diffX-5)*(_diffX-5) + (_diffY-5)*(_diffY-5)) * stack.getProperty("layer_height_0", "value") * print_width * 0.54
                    if first_extruder == "0":
                        retraction_speed = str(stack0.getProperty("retraction_speed", "value") * 60)
                        retraction_enable = stack0.getProperty("retraction_enable", "value")
                    else:
                        retraction_speed = str(stack1.getProperty("retraction_speed", "value") * 60)
                        retraction_enable = stack1.getProperty("retraction_enable", "value")
                    gcode_list[1] = gcode_list[1] + ";Print in advance\nG1 F" + retraction_speed + " E0\n" + "G1 F2400 X" + str(_diffX) +" Y" + str(_diffY) + " E" + str(round(_diffE, 5)) + "\nG92 E0\n\n"
################预挤出前去掉第一次回抽
                if retraction_enable:
                    gcode_list[1] = re.sub("G92 E0\nG1 F", ";G92 E0\n;G1 F", gcode_list[1], 1)
            except:
                Logger.log("d", "Can't add print_adcance.")
##############回抽空驶补偿 6
        if stack.getProperty("enable_travel_prime", "value"):
            travel_speed_all = str(int(stack0.getProperty("speed_travel", "value") * 60))
            travel_speed_layer0 = str(int(stack0.getProperty("speed_travel_layer_0", "value") * 60))
            max_travel_time = stack.getProperty("max_travel_prime", "value") / stack0.getProperty("speed_travel", "value")
            min_travel_time = stack.getProperty("min_travel_prime", "value") / stack0.getProperty("speed_travel", "value")
            retraction_speed = str(stack0.getProperty("retraction_speed", "value") * 60)
            cost_E = "0"
            for count6, gcode6 in enumerate(gcode_list):
                if count6 == 2:
                    travel_speed = travel_speed_layer0
                    travel_prime_rate = stack.getProperty("travel_prime_rate_layer_0", "value") / 120
                else:
                    travel_speed = travel_speed_all
                    travel_prime_rate = stack.getProperty("travel_prime_rate", "value") / 190
                if gcode6.count("\nG0 F" + travel_speed_all) > 0 or gcode6.count("\nG0 F" + travel_speed_layer0) > 0:
                    type6_1 = gcode6.split("G0 F" + travel_speed)
                    notAddTravelPrime = False
                    for count6_1, gcode6_1 in enumerate(type6_1):
                        if gcode6_1.count(";TYPE:") > 0:
                            notAddTravelPrime = False
                        if gcode6_1.count(";TYPE:SUPPORT") > 0:
                            notAddTravelPrime = True
                        if notAddTravelPrime:
                            if gcode6_1.count(" X") > 0:
                                last_point = gcode6_1.split(" X")[-1]
                                last_X = float(last_point.split()[0])
                                last_Y = getValue(last_point, "Y", 0)
                            if gcode6_1.count(" E") > 0:
                                cost_E = gcode6_1.split(" E")[-1].split("\n")[0]
                            continue
                        if count6_1 > 0:
                            type6_1_1 = gcode6_1.split("\nG1 F", 1)
                            travel_distance = 0
                            type6_1_1_1 = type6_1_1[0].split("\n")
                            for count6_1_1_1, gcode6_1_1_1 in enumerate(type6_1_1_1):
                                if gcode6_1_1_1.count(" X") > 0:
                                    next_X = getValue(gcode6_1_1_1, "X", 0)
                                    next_Y = getValue(gcode6_1_1_1, "Y", 0)
                                    try:
                                        travel_distance += math.sqrt((next_X - last_X) * (next_X - last_X) + (next_Y - last_Y) * (next_Y - last_Y))
                                    except:
                                        travel_distance = 0
                                    last_X = next_X 
                                    last_Y = next_Y
                            travel_time = travel_distance / stack0.getProperty("speed_travel", "value")
                            if travel_time > min_travel_time:
                                if travel_time > max_travel_time:
                                    prime_e = max_travel_time * travel_prime_rate
                                else:
                                    prime_e = travel_time * travel_prime_rate
                                if type6_1_1[0].count("G92 E0") > 0:
                                    prime_gcode = "G1 F" + retraction_speed + " E" + str(round(prime_e, 5)) + "\nG92 E0"
                                else:
                                    prime_gcode = "G1 F" + retraction_speed + " E" + str(round(prime_e + float(cost_E), 5)) + "\nG92 E" + cost_E
                                if gcode6_1.count("\nG1 F") > 0:
                                    type6_1[count6_1] = ("\n" + prime_gcode + "\nG1 F").join(type6_1_1)
                                else:
                                    type6_1[count6_1] = gcode6_1 + prime_gcode + "\n"
                        if gcode6_1.count(" X") > 0:
                            last_point = gcode6_1.split(" X")[-1]
                            last_X = float(last_point.split()[0])
                            last_Y = getValue(last_point, "Y", 0)
                        if gcode6_1.count(" E") > 0:
                            cost_E = gcode6_1.split(" E")[-1].split("\n")[0]
                    gcode_list[count6] = ("G0 F" + travel_speed).join(type6_1)
                else:
                    if gcode6.count(" E") > 0:
                        cost_E = gcode6.split(" E")[-1].split("\n")[0]
############循环风扇
        if stack.getProperty("cooling_chamber", "value"):
            gcode_list[2] = gcode_list[2] + "M106 T-2 S255\n"
            gcode_list[-2] = gcode_list[-2] + "M107 T-2\n"
#############打印完关机
        if stack.getProperty("shutdown_after_printing", "value"):
            gcode_list[-1] = gcode_list[-1] + "M4003;shutdown\n"
#########
        self._slicing = False
        Logger.log("d", "Slicing took %s seconds", time() - self._slice_start_time )
        Logger.log("d", "Number of models per buildplate: %s", dict(self._numObjectsPerBuildPlate()))

        # See if we need to process the sliced layers job.
        active_build_plate = Application.getInstance().getMultiBuildPlateModel().activeBuildPlate
        if (
            self._layer_view_active and
            (self._process_layers_job is None or not self._process_layers_job.isRunning()) and
            active_build_plate == self._start_slice_job_build_plate and
            active_build_plate not in self._build_plates_to_be_sliced):

            self._startProcessSlicedLayersJob(active_build_plate)
        # self._onActiveViewChanged()
        self._start_slice_job_build_plate = None

        Logger.log("d", "See if there is more to slice...")
        # Somehow this results in an Arcus Error
        # self.slice()
        # Call slice again using the timer, allowing the backend to restart
        if self._build_plates_to_be_sliced:
            self.enableTimer()  # manually enable timer to be able to invoke slice, also when in manual slice mode
            self._invokeSlice()
        #####################################################################################
        if self._screenshotImages:#and Preferences.getInstance().getValue("cura/enablePreview"):  # 如果有截屏，把截屏数据弄进去
            # from plugins.CuraEngineBackend import cprsImage
            startX, startY, endX, endY = cprsImage.detectImageValidRange(self._screenshotImages[1])
            gcode_list.insert(0, cprsImage.genImageGcode(self._screenshotImages[0], startX, startY, endX,endY))
            #####################################################################################
#######切片后打开分层视图
        if Preferences.getInstance().getValue("view/switch_layer_view"):
            Application.getInstance().getController().setActiveView("SimulationView")

    ##  Called when a g-code message is received from the engine.
    #
    #   \param message The protobuf message containing g-code, encoded as UTF-8.
    def _onGCodeLayerMessage(self, message):
        self._scene.gcode_dict[self._start_slice_job_build_plate].append(message.data.decode("utf-8", "replace"))

    ##  Called when a g-code prefix message is received from the engine.
    #
    #   \param message The protobuf message containing the g-code prefix,
    #   encoded as UTF-8.
    def _onGCodePrefixMessage(self, message):
        self._scene.gcode_dict[self._start_slice_job_build_plate].insert(0, message.data.decode("utf-8", "replace"))

    ##  Creates a new socket connection.
    def _createSocket(self):
        super()._createSocket(os.path.abspath(os.path.join(PluginRegistry.getInstance().getPluginPath(self.getPluginId()), "Cura.proto")))
        self._engine_is_fresh = True

    ##  Called when anything has changed to the stuff that needs to be sliced.
    #
    #   This indicates that we should probably re-slice soon.
    def _onChanged(self, *args, **kwargs):
        self.needsSlicing()
        if self._use_timer:
            # if the error check is scheduled, wait for the error check finish signal to trigger auto-slice,
            # otherwise business as usual
            if self._machine_error_checker is None:
                self._change_timer.stop()
                return

            if self._machine_error_checker.needToWaitForResult:
                self._change_timer.stop()
            else:
                self._change_timer.start()

    ##  Called when a print time message is received from the engine.
    #
    #   \param message The protobuf message containing the print time per feature and
    #   material amount per extruder
    def _onPrintTimeMaterialEstimates(self, message):
        material_amounts = []
        for index in range(message.repeatedMessageCount("materialEstimates")):
            material_amounts.append(message.getRepeatedMessage("materialEstimates", index).material_amount)

        times = self._parseMessagePrintTimes(message)
        self.printDurationMessage.emit(self._start_slice_job_build_plate, times, material_amounts)

    ##  Called for parsing message to retrieve estimated time per feature
    #
    #   \param message The protobuf message containing the print time per feature
    def _parseMessagePrintTimes(self, message):
        result = {
            "inset_0": message.time_inset_0,
            "inset_x": message.time_inset_x,
            "skin": message.time_skin,
            "infill": message.time_infill,
            "support_infill": message.time_support_infill,
            "support_interface": message.time_support_interface,
            "support": message.time_support,
            "skirt": message.time_skirt,
            "travel": message.time_travel,
            "retract": message.time_retract,
            "none": message.time_none
        }
        return result

    ##  Called when the back-end connects to the front-end.
    def _onBackendConnected(self):
        if self._restart:
            self._restart = False
            self._onChanged()

    ##  Called when the user starts using some tool.
    #
    #   When the user starts using a tool, we should pause slicing to prevent
    #   continuously slicing while the user is dragging some tool handle.
    #
    #   \param tool The tool that the user is using.
    def _onToolOperationStarted(self, tool):
        self._tool_active = True  # Do not react on scene change
        self.disableTimer()
        # Restart engine as soon as possible, we know we want to slice afterwards
        if not self._engine_is_fresh:
            self._terminate()
            self._createSocket()

    ##  Called when the user stops using some tool.
    #
    #   This indicates that we can safely start slicing again.
    #
    #   \param tool The tool that the user was using.
    def _onToolOperationStopped(self, tool):
        self._tool_active = False  # React on scene change again
        self.determineAutoSlicing()  # Switch timer on if appropriate
        # Process all the postponed scene changes
        while self._postponed_scene_change_sources:
            source = self._postponed_scene_change_sources.pop(0)
            self._onSceneChanged(source)

    def _startProcessSlicedLayersJob(self, build_plate_number):
        self._process_layers_job = ProcessSlicedLayersJob.ProcessSlicedLayersJob(self._stored_optimized_layer_data[build_plate_number])
        self._process_layers_job.setBuildPlate(build_plate_number)
        self._process_layers_job.finished.connect(self._onProcessLayersFinished)
        self._process_layers_job.start()

    ##  Called when the user changes the active view mode.
    def _onActiveViewChanged(self):
        application = Application.getInstance()
        view = application.getController().getActiveView()
        if view:
            active_build_plate = application.getMultiBuildPlateModel().activeBuildPlate
            if view.getPluginId() == "SimulationView":  # If switching to layer view, we should process the layers if that hasn't been done yet.
                self._layer_view_active = True
                # There is data and we're not slicing at the moment
                # if we are slicing, there is no need to re-calculate the data as it will be invalid in a moment.
                # TODO: what build plate I am slicing
                if (active_build_plate in self._stored_optimized_layer_data and
                    not self._slicing and
                    not self._process_layers_job and
                    active_build_plate not in self._build_plates_to_be_sliced):

                    self._startProcessSlicedLayersJob(active_build_plate)
            else:
                self._layer_view_active = False

    ##  Called when the back-end self-terminates.
    #
    #   We should reset our state and start listening for new connections.
    def _onBackendQuit(self):
        if not self._restart:
            if self._process:
                Logger.log("d", "Backend quit with return code %s. Resetting process and socket.", self._process.wait())
                self._process = None

    ##  Called when the global container stack changes
    def _onGlobalStackChanged(self):
        if self._global_container_stack:
            self._global_container_stack.propertyChanged.disconnect(self._onSettingChanged)
            self._global_container_stack.containersChanged.disconnect(self._onChanged)
            extruders = list(self._global_container_stack.extruders.values())

            for extruder in extruders:
                extruder.propertyChanged.disconnect(self._onSettingChanged)
                extruder.containersChanged.disconnect(self._onChanged)

        self._global_container_stack = Application.getInstance().getGlobalContainerStack()

        if self._global_container_stack:
            self._global_container_stack.propertyChanged.connect(self._onSettingChanged)  # Note: Only starts slicing when the value changed.
            self._global_container_stack.containersChanged.connect(self._onChanged)
            extruders = list(self._global_container_stack.extruders.values())
            for extruder in extruders:
                extruder.propertyChanged.connect(self._onSettingChanged)
                extruder.containersChanged.connect(self._onChanged)
            self._onChanged()

    def _onProcessLayersFinished(self, job):
        del self._stored_optimized_layer_data[job.getBuildPlate()]
        self._process_layers_job = None
        Logger.log("d", "See if there is more to slice(2)...")
        self._invokeSlice()

    ##  Connect slice function to timer.
    def enableTimer(self):
        if not self._use_timer:
            self._change_timer.timeout.connect(self.slice)
            self._use_timer = True

    ##  Disconnect slice function from timer.
    #   This means that slicing will not be triggered automatically
    def disableTimer(self):
        if self._use_timer:
            self._use_timer = False
            self._change_timer.timeout.disconnect(self.slice)

    def _onPreferencesChanged(self, preference):
        if preference != "general/auto_slice":
            return
        auto_slice = self.determineAutoSlicing()
        if auto_slice:
            self._change_timer.start()

    ##   Tickle the backend so in case of auto slicing, it starts the timer.
    def tickle(self):
        if self._use_timer:
            self._change_timer.start()

    def _extruderChanged(self):
        for build_plate_number in range(self._multi_build_plate_model.maxBuildPlate + 1):
            if build_plate_number not in self._build_plates_to_be_sliced:
                self._build_plates_to_be_sliced.append(build_plate_number)
        self._invokeSlice()
