# Copyright (c) 2020 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import pyqtSignal, pyqtProperty, QObject, QVariant  # For communicating data and events to Qt.
from QD.FlameProfiler import pyqtSlot

import qidi.QIDIApplication # To get the global container stack to find the current machine.
from qidi.Settings.GlobalStack import GlobalStack
from QD.Logger import Logger
from QD.Scene.Iterator.DepthFirstIterator import DepthFirstIterator
from QD.Scene.SceneNode import SceneNode
from QD.Scene.Selection import Selection
from QD.Scene.Iterator.BreadthFirstIterator import BreadthFirstIterator
from QD.Settings.ContainerRegistry import ContainerRegistry  # Finding containers by ID.
from QD.Application import Application

from typing import Any, cast, Dict, List, Optional, TYPE_CHECKING, Union

if TYPE_CHECKING:
    from qidi.Settings.ExtruderStack import ExtruderStack


class ExtruderManager(QObject):
    """Manages all existing extruder stacks.

    This keeps a list of extruder stacks for each machine.
    """

    def __init__(self, parent = None):
        """Registers listeners and such to listen to changes to the extruders."""

        if ExtruderManager.__instance is not None:
            raise RuntimeError("Try to create singleton '%s' more than once" % self.__class__.__name__)
        ExtruderManager.__instance = self

        super().__init__(parent)

        self._application = qidi.QIDIApplication.QIDIApplication.getInstance()

        # Per machine, a dictionary of extruder container stack IDs. Only for separately defined extruders.
        self._extruder_trains = {}  # type: Dict[str, Dict[str, "ExtruderStack"]]
        self._active_extruder_index = -1  # Indicates the index of the active extruder stack. -1 means no active extruder stack

        # TODO; I have no idea why this is a union of ID's and extruder stacks. This needs to be fixed at some point.
        self._selected_object_extruders = []  # type: List[Union[str, "ExtruderStack"]]

        Selection.selectionChanged.connect(self.resetSelectedObjectExtruders)

    extrudersChanged = pyqtSignal(QVariant)
    """Signal to notify other components when the list of extruders for a machine definition changes."""

    activeExtruderChanged = pyqtSignal()
    """Notify when the user switches the currently active extruder."""

    @pyqtProperty(str, notify = activeExtruderChanged)
    def activeExtruderStackId(self) -> Optional[str]:
        """Gets the unique identifier of the currently active extruder stack.

        The currently active extruder stack is the stack that is currently being
        edited.

        :return: The unique ID of the currently active extruder stack.
        """

        if not self._application.getGlobalContainerStack():
            return None  # No active machine, so no active extruder.
        try:
            return self._extruder_trains[self._application.getGlobalContainerStack().getId()][str(self.activeExtruderIndex)].getId()
        except KeyError:  # Extruder index could be -1 if the global tab is selected, or the entry doesn't exist if the machine definition is wrong.
            return None

    @pyqtProperty("QVariantMap", notify = extrudersChanged)
    def extruderIds(self) -> Dict[str, str]:
        """Gets a dict with the extruder stack ids with the extruder number as the key."""

        extruder_stack_ids = {}  # type: Dict[str, str]

        global_container_stack = self._application.getGlobalContainerStack()
        if global_container_stack:
            extruder_stack_ids = {extruder.getMetaDataEntry("position", ""): extruder.id for extruder in global_container_stack.extruderList}

        return extruder_stack_ids

    @pyqtSlot(int)
    def setActiveExtruderIndex(self, index: int) -> None:
        """Changes the active extruder by index.

        :param index: The index of the new active extruder.
        """

        if self._active_extruder_index != index:
            self._active_extruder_index = index
            self.activeExtruderChanged.emit()

    @pyqtProperty(str, notify = activeExtruderChanged)
    def icon_color_for_setting(self) -> str:
        global_container_stack = Application.getInstance().getGlobalContainerStack()
        if global_container_stack:
            machine_extruder_count = global_container_stack.getProperty("machine_extruder_count", "value")
            defaultColors = ["#ffc924", "#86ec21", "#22eeee", "#245bff", "#9124ff", "#ff24c8"]
            position = ExtruderManager.getInstance().activeExtruderIndex
            default_color = defaultColors[position]
            if Application.getInstance().getPreferences().getValue("view/use_extruder_color") and machine_extruder_count > 1:
                if Application.getInstance().getPreferences().getValue("color/extruder" + str(position)):
                    color = Application.getInstance().getPreferences().getValue("color/extruder" + str(position))
                else:
                    color = default_color
            else:
                extruder =Application.getInstance().getExtruderManager().getActiveExtruderStack()
                color = extruder.material.getMetaDataEntry("color_code", default = default_color) if extruder.material else default_color
                #Logger.log("e",color)
                #Logger.log("e",self.defaultColors[0])
                #Logger.log("e",self.defaultColors[1])
                if position == 1 and (Application.getInstance().getExtruderManager().getExtruderStack(0).material== extruder.material):
                    #Logger.log("e",color[5:7])
                    temcolor = int(color[5:7],16)
                    temcolor = temcolor - 50
                    if temcolor <0:
                        temcolor = 0
                    temcolor = str(hex(temcolor)) 
                    if len(temcolor.split("0x")[1]) ==1:
                        temcolor = "0"+temcolor.split("0x")[1]
                    else:
                        temcolor = temcolor.split("0x")[1]
                    #Logger.log("e",color[3:5])
                    temcolor2 = int(color[3:5],16)
                    temcolor2 = temcolor2 - 50
                    if temcolor2 <0:
                        temcolor2 = 0
                    temcolor2 = str(hex(temcolor2)) 
                    if len(temcolor2.split("0x")[1]) ==1:
                        temcolor2 = "0"+temcolor2.split("0x")[1]
                    else:
                        temcolor2 = temcolor2.split("0x")[1]
                    #Logger.log("e",color[1:3])
                    temcolor3 = int(color[1:3],16)
                    temcolor3 = temcolor3 - 50
                    if temcolor3 <0:
                        temcolor3 = 0
                    temcolor3 = str(hex(temcolor3)) 
                    if len(temcolor3.split("0x")[1]) ==1:
                        temcolor3 = "0"+temcolor3.split("0x")[1]
                    else:
                        temcolor3 = temcolor3.split("0x")[1]
                    color = color[0:1] +temcolor3 + temcolor2 + temcolor   
        else:
            color = "#ffc924"
        return color



    @pyqtProperty(int, notify = activeExtruderChanged)
    def activeExtruderIndex(self) -> int:
        return self._active_extruder_index

    selectedObjectExtrudersChanged = pyqtSignal()
    """Emitted whenever the selectedObjectExtruders property changes."""

    @pyqtProperty("QVariantList", notify = selectedObjectExtrudersChanged)
    def selectedObjectExtruders(self) -> List[Union[str, "ExtruderStack"]]:
        """Provides a list of extruder IDs used by the current selected objects."""

        if not self._selected_object_extruders:
            object_extruders = set()

            # First, build a list of the actual selected objects (including children of groups, excluding group nodes)
            selected_nodes = []  # type: List["SceneNode"]
            for node in Selection.getAllSelectedObjects():
                if node.callDecoration("isGroup"):
                    for grouped_node in BreadthFirstIterator(node):
                        if grouped_node.callDecoration("isGroup"):
                            continue

                        selected_nodes.append(grouped_node)
                else:
                    selected_nodes.append(node)

            # Then, figure out which nodes are used by those selected nodes.
            current_extruder_trains = self.getActiveExtruderStacks()
            for node in selected_nodes:
                extruder = node.callDecoration("getActiveExtruder")
                if extruder:
                    object_extruders.add(extruder)
                elif current_extruder_trains:
                    object_extruders.add(current_extruder_trains[0].getId())

            self._selected_object_extruders = list(object_extruders)

        return self._selected_object_extruders

    def resetSelectedObjectExtruders(self) -> None:
        """Reset the internal list used for the selectedObjectExtruders property

        This will trigger a recalculation of the extruders used for the
        selection.
        """

        self._selected_object_extruders = []
        self.selectedObjectExtrudersChanged.emit()

    @pyqtSlot(result = QObject)
    def getActiveExtruderStack(self) -> Optional["ExtruderStack"]:
        return self.getExtruderStack(self.activeExtruderIndex)

    def getExtruderStack(self, index) -> Optional["ExtruderStack"]:
        """Get an extruder stack by index"""

        global_container_stack = self._application.getGlobalContainerStack()
        if global_container_stack:
            if global_container_stack.getId() in self._extruder_trains:
                if str(index) in self._extruder_trains[global_container_stack.getId()]:
                    return self._extruder_trains[global_container_stack.getId()][str(index)]
        return None

    def getAllExtruderSettings(self, setting_key: str, prop: str) -> List[Any]:
        """Gets a property of a setting for all extruders.

        :param setting_key:  :type{str} The setting to get the property of.
        :param prop:  :type{str} The property to get.
        :return: :type{List} the list of results
        """

        result = []

        for extruder_stack in self.getActiveExtruderStacks():
            result.append(extruder_stack.getProperty(setting_key, prop))

        return result

    def extruderValueWithDefault(self, value: str) -> str:
        machine_manager = self._application.getMachineManager()
        if value == "-1":
            return machine_manager.defaultExtruderPosition
        else:
            return value

    def getUsedExtruderStacks(self) -> List["ExtruderStack"]:
        """Gets the extruder stacks that are actually being used at the moment.

        An extruder stack is being used if it is the extruder to print any mesh
        with, or if it is the support infill extruder, the support interface
        extruder, or the bed adhesion extruder.

        If there are no extruders, this returns the global stack as a singleton
        list.

        :return: A list of extruder stacks.
        """

        global_stack = self._application.getGlobalContainerStack()
        container_registry = ContainerRegistry.getInstance()

        used_extruder_stack_ids = set()

        # Get the extruders of all meshes in the scene
        support_enabled = False
        support_bottom_enabled = False
        support_roof_enabled = False

        scene_root = self._application.getController().getScene().getRoot()

        # If no extruders are registered in the extruder manager yet, return an empty array
        if len(self.extruderIds) == 0:
            return []
        number_active_extruders = len([extruder for extruder in self.getActiveExtruderStacks() if extruder.isEnabled])

        # Get the extruders of all printable meshes in the scene
        nodes = [node for node in DepthFirstIterator(scene_root) if node.isSelectable() and not node.callDecoration("isAntiOverhangMesh") and not  node.callDecoration("isSupportMesh")] #type: ignore #Ignore type error because iter() should get called automatically by Python syntax.

        for node in nodes:
            extruder_stack_id = node.callDecoration("getActiveExtruder")
            if not extruder_stack_id:
                # No per-object settings for this node
                extruder_stack_id = self.extruderIds["0"]
            used_extruder_stack_ids.add(extruder_stack_id)

            if len(used_extruder_stack_ids) == number_active_extruders:
                # We're already done. Stop looking.
                # Especially with a lot of models on the buildplate, this will speed up things rather dramatically.
                break

            # Get whether any of them use support.
            stack_to_use = node.callDecoration("getStack")  # if there is a per-mesh stack, we use it
            if not stack_to_use:
                # if there is no per-mesh stack, we use the build extruder for this mesh
                stack_to_use = container_registry.findContainerStacks(id = extruder_stack_id)[0]

            if not support_enabled:
                support_enabled |= stack_to_use.getProperty("support_enable", "value")
            if not support_bottom_enabled:
                support_bottom_enabled |= stack_to_use.getProperty("support_bottom_enable", "value")
            if not support_roof_enabled:
                support_roof_enabled |= stack_to_use.getProperty("support_roof_enable", "value")

        # Check limit to extruders
        limit_to_extruder_feature_list = ["wall_0_extruder_nr",
                                          "wall_x_extruder_nr",
                                          "roofing_extruder_nr",
                                          "top_bottom_extruder_nr",
                                          "infill_extruder_nr",
                                          ]
        for extruder_nr_feature_name in limit_to_extruder_feature_list:
            extruder_nr = int(global_stack.getProperty(extruder_nr_feature_name, "value"))
            if extruder_nr == -1:
                continue
            if str(extruder_nr) not in self.extruderIds:
                extruder_nr = int(self._application.getMachineManager().defaultExtruderPosition)
            used_extruder_stack_ids.add(self.extruderIds[str(extruder_nr)])

        # Check support extruders
        if support_enabled:
            used_extruder_stack_ids.add(self.extruderIds[self.extruderValueWithDefault(str(global_stack.getProperty("support_infill_extruder_nr", "value")))])
            used_extruder_stack_ids.add(self.extruderIds[self.extruderValueWithDefault(str(global_stack.getProperty("support_extruder_nr_layer_0", "value")))])
            if support_bottom_enabled:
                used_extruder_stack_ids.add(self.extruderIds[self.extruderValueWithDefault(str(global_stack.getProperty("support_bottom_extruder_nr", "value")))])
            if support_roof_enabled:
                used_extruder_stack_ids.add(self.extruderIds[self.extruderValueWithDefault(str(global_stack.getProperty("support_roof_extruder_nr", "value")))])

        # The platform adhesion extruder. Not used if using none.
        if global_stack.getProperty("adhesion_type", "value") != "none" or (
                global_stack.getProperty("prime_tower_brim_enable", "value") and
                global_stack.getProperty("adhesion_type", "value") != 'raft'):
            extruder_str_nr = str(global_stack.getProperty("adhesion_extruder_nr", "value"))
            if extruder_str_nr == "-1":
                extruder_str_nr = self._application.getMachineManager().defaultExtruderPosition
            if extruder_str_nr in self.extruderIds:
                used_extruder_stack_ids.add(self.extruderIds[extruder_str_nr])

        try:
            return [container_registry.findContainerStacks(id = stack_id)[0] for stack_id in used_extruder_stack_ids]
        except IndexError:  # One or more of the extruders was not found.
            Logger.log("e", "Unable to find one or more of the extruders in %s", used_extruder_stack_ids)
            return []

    def getInitialExtruderNr(self) -> int:
        """Get the extruder that the print will start with.

        This should mirror the implementation in CuraEngine of
        ``FffGcodeWriter::getStartExtruder()``.
        """

        application = qidi.QIDIApplication.QIDIApplication.getInstance()
        global_stack = application.getGlobalContainerStack()


        # Starts with the adhesion extruder.
        adhesion_type = global_stack.getProperty("adhesion_type", "value")
        if adhesion_type in {"skirt", "brim"}:
            return max(0, int(global_stack.getProperty("adhesion_extruder_nr", "value")))  # optional skirt/brim extruder defaults to zero
        if adhesion_type == "raft":
            return global_stack.getProperty("raft_base_extruder_nr", "value")

        # No adhesion? Well maybe there is still support brim.
        if (global_stack.getProperty("support_enable", "value") or global_stack.getProperty("support_structure", "value") == "tree") and global_stack.getProperty("support_brim_enable", "value"):
            return global_stack.getProperty("support_infill_extruder_nr", "value")

        # REALLY no adhesion? Use the first used extruder.
        return self.getUsedExtruderStacks()[0].getProperty("extruder_nr", "value")






    def removeMachineExtruders(self, machine_id: str) -> None:
        """Removes the container stack and user profile for the extruders for a specific machine.

        :param machine_id: The machine to remove the extruders for.
        """

        for extruder in self.getMachineExtruders(machine_id):
            ContainerRegistry.getInstance().removeContainer(extruder.userChanges.getId())
            ContainerRegistry.getInstance().removeContainer(extruder.definitionChanges.getId())
            ContainerRegistry.getInstance().removeContainer(extruder.getId())
        if machine_id in self._extruder_trains:
            del self._extruder_trains[machine_id]

    def getMachineExtruders(self, machine_id: str) -> List["ExtruderStack"]:
        """Returns extruders for a specific machine.

        :param machine_id: The machine to get the extruders of.
        """

        if machine_id not in self._extruder_trains:
            return []
        return [self._extruder_trains[machine_id][name] for name in self._extruder_trains[machine_id]]

    def getActiveExtruderStacks(self) -> List["ExtruderStack"]:
        """Returns the list of active extruder stacks, taking into account the machine extruder count.

        :return: :type{List[ContainerStack]} a list of
        """

        global_stack = self._application.getGlobalContainerStack()
        if not global_stack:
            return []
        return global_stack.extruderList

    def _globalContainerStackChanged(self) -> None:
        # If the global container changed, the machine changed and might have extruders that were not registered yet
        self._addCurrentMachineExtruders()

        self.resetSelectedObjectExtruders()

    def addMachineExtruders(self, global_stack: GlobalStack) -> None:
        """Adds the extruders to the selected machine."""

        extruders_changed = False
        container_registry = ContainerRegistry.getInstance()
        global_stack_id = global_stack.getId()

        # Gets the extruder trains that we just created as well as any that still existed.
        extruder_trains = container_registry.findContainerStacks(type = "extruder_train", machine = global_stack_id)

        # Make sure the extruder trains for the new machine can be placed in the set of sets
        if global_stack_id not in self._extruder_trains:
            self._extruder_trains[global_stack_id] = {}
            extruders_changed = True

        # Register the extruder trains by position
        for extruder_train in extruder_trains:
            extruder_position = extruder_train.getMetaDataEntry("position")
            self._extruder_trains[global_stack_id][extruder_position] = extruder_train

            # regardless of what the next stack is, we have to set it again, because of signal routing. ???
            extruder_train.setParent(global_stack)
            extruder_train.setNextStack(global_stack)
            extruders_changed = True

        self.fixSingleExtrusionMachineExtruderDefinition(global_stack)
        if extruders_changed:
            self.extrudersChanged.emit(global_stack_id)

    # After 3.4, all single-extrusion machines have their own extruder definition files instead of reusing
    # "fdmextruder". We need to check a machine here so its extruder definition is correct according to this.
    def fixSingleExtrusionMachineExtruderDefinition(self, global_stack: "GlobalStack") -> None:
        container_registry = ContainerRegistry.getInstance()
        expected_extruder_definition_0_id = global_stack.getMetaDataEntry("machine_extruder_trains")["0"]
        try:
            extruder_stack_0 = global_stack.extruderList[0]
        except IndexError:
            extruder_stack_0 = None

        # At this point, extruder stacks for this machine may not have been loaded yet. In this case, need to look in
        # the container registry as well.
        if not global_stack.extruderList:
            extruder_trains = container_registry.findContainerStacks(type = "extruder_train",
                                                                     machine = global_stack.getId())
            if extruder_trains:
                for extruder in extruder_trains:
                    if extruder.getMetaDataEntry("position") == "0":
                        extruder_stack_0 = extruder
                        break

        if extruder_stack_0 is None:
            Logger.log("i", "No extruder stack for global stack [%s], create one", global_stack.getId())
            # Single extrusion machine without an ExtruderStack, create it
            from qidi.Settings.QIDIStackBuilder import QIDIStackBuilder
            QIDIStackBuilder.createExtruderStackWithDefaultSetup(global_stack, 0)

        elif extruder_stack_0.definition.getId() != expected_extruder_definition_0_id:
            Logger.log("e", "Single extruder printer [{printer}] expected extruder [{expected}], but got [{got}]. I'm making it [{expected}].".format(
                printer = global_stack.getId(), expected = expected_extruder_definition_0_id, got = extruder_stack_0.definition.getId()))
            try:
                extruder_definition = container_registry.findDefinitionContainers(id = expected_extruder_definition_0_id)[0]
            except IndexError:
                # It still needs to break, but we want to know what extruder ID made it break.
                msg = "Unable to find extruder definition with the id [%s]" % expected_extruder_definition_0_id
                Logger.logException("e", msg)
                raise IndexError(msg)
            extruder_stack_0.definition = extruder_definition

    @pyqtSlot(str, result="QVariant")
    def getInstanceExtruderValues(self, key: str) -> List:
        """Get all extruder values for a certain setting.

        This is exposed to qml for display purposes

        :param key: The key of the setting to retrieve values for.

        :return: String representing the extruder values
        """

        return self._application.getQIDIFormulaFunctions().getValuesInAllExtruders(key)

    @staticmethod
    def getResolveOrValue(key: str) -> Any:
        """Get the resolve value or value for a given key

        This is the effective value for a given key, it is used for values in the global stack.
        This is exposed to SettingFunction to use in value functions.
        :param key: The key of the setting to get the value of.

        :return: The effective value
        """

        global_stack = cast(GlobalStack, qidi.QIDIApplication.QIDIApplication.getInstance().getGlobalContainerStack())
        resolved_value = global_stack.getProperty(key, "value")

        return resolved_value

    __instance = None   # type: ExtruderManager

    @classmethod
    def getInstance(cls, *args, **kwargs) -> "ExtruderManager":
        return cls.__instance
