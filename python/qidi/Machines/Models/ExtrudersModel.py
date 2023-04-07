# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import Qt, pyqtSignal, pyqtProperty, QTimer
from typing import Iterable, TYPE_CHECKING

from QD.i18n import i18nCatalog
from QD.Qt.ListModel import ListModel
from QD.Application import Application
import QD.FlameProfiler
from QD.Logger import Logger
if TYPE_CHECKING:
    from qidi.Settings.ExtruderStack import ExtruderStack  # To listen to changes on the extruders.

catalog = i18nCatalog("qidi")


class ExtrudersModel(ListModel):
    """Model that holds extruders.

    This model is designed for use by any list of extruders, but specifically intended for drop-down lists of the
    current machine's extruders in place of settings.
    """

    # The ID of the container stack for the extruder.
    IdRole = Qt.UserRole + 1

    NameRole = Qt.UserRole + 2
    """Human-readable name of the extruder."""

    ColorRole = Qt.UserRole + 3
    """Colour of the material loaded in the extruder."""

    IndexRole = Qt.UserRole + 4
    """Index of the extruder, which is also the value of the setting itself.

    An index of 0 indicates the first extruder, an index of 1 the second one, and so on. This is the value that will 
    be saved in instance containers. """

    # The ID of the definition of the extruder.
    DefinitionRole = Qt.UserRole + 5

    # The material of the extruder.
    MaterialRole = Qt.UserRole + 6

    # The variant of the extruder.
    VariantRole = Qt.UserRole + 7
    StackRole = Qt.UserRole + 8

    MaterialBrandRole = Qt.UserRole + 9
    ColorNameRole = Qt.UserRole + 10

    EnabledRole = Qt.UserRole + 11
    """Is the extruder enabled?"""

    defaultColors = ["#ffc924", "#86ec21", "#22eeee", "#245bff", "#9124ff", "#ff24c8"]
    """List of colours to display if there is no material or the material has no known colour. """

    def __init__(self, parent = None):
        """Initialises the extruders model, defining the roles and listening for changes in the data.

        :param parent: Parent QtObject of this list.
        """

        super().__init__(parent)

        self.addRoleName(self.IdRole, "id")
        self.addRoleName(self.NameRole, "name")
        self.addRoleName(self.EnabledRole, "enabled")
        self.addRoleName(self.ColorRole, "color")
        self.addRoleName(self.IndexRole, "index")
        self.addRoleName(self.DefinitionRole, "definition")
        self.addRoleName(self.MaterialRole, "material")
        self.addRoleName(self.VariantRole, "variant")
        self.addRoleName(self.StackRole, "stack")
        self.addRoleName(self.MaterialBrandRole, "material_brand")
        self.addRoleName(self.ColorNameRole, "color_name")
        self._update_extruder_timer = QTimer()
        self._update_extruder_timer.setInterval(100)
        self._update_extruder_timer.setSingleShot(True)
        self._update_extruder_timer.timeout.connect(self.__updateExtruders)

        self._active_machine_extruders = []  # type: Iterable[ExtruderStack]
        self._add_optional_extruder = False

        # Listen to changes
        Application.getInstance().globalContainerStackChanged.connect(self._extrudersChanged)  # When the machine is swapped we must update the active machine extruders
        Application.getInstance().getExtruderManager().extrudersChanged.connect(self._extrudersChanged)  # When the extruders change we must link to the stack-changed signal of the new extruder
        Application.getInstance().getContainerRegistry().containerMetaDataChanged.connect(self._onExtruderStackContainersChanged)  # When meta data from a material container changes we must update
        self._extrudersChanged()  # Also calls _updateExtruders

    addOptionalExtruderChanged = pyqtSignal()

    def setAddOptionalExtruder(self, add_optional_extruder):
        if add_optional_extruder != self._add_optional_extruder:
            self._add_optional_extruder = add_optional_extruder
            self.addOptionalExtruderChanged.emit()
            self._updateExtruders()

    @pyqtProperty(bool, fset = setAddOptionalExtruder, notify = addOptionalExtruderChanged)
    def addOptionalExtruder(self):
        return self._add_optional_extruder

    def _extrudersChanged(self, machine_id = None):
        """Links to the stack-changed signal of the new extruders when an extruder is swapped out or added in the
         current machine.

        :param machine_id: The machine for which the extruders changed. This is filled by the
        ExtruderManager.extrudersChanged signal when coming from that signal. Application.globalContainerStackChanged
        doesn't fill this signal; it's assumed to be the current printer in that case.
        """

        machine_manager = Application.getInstance().getMachineManager()
        if machine_id is not None:
            if machine_manager.activeMachine is None:
                # No machine, don't need to update the current machine's extruders
                return
            if machine_id != machine_manager.activeMachine.getId():
                # Not the current machine
                return

        # Unlink from old extruders
        for extruder in self._active_machine_extruders:
            extruder.containersChanged.disconnect(self._onExtruderStackContainersChanged)
            extruder.enabledChanged.disconnect(self._updateExtruders)

        # Link to new extruders
        self._active_machine_extruders = []
        extruder_manager = Application.getInstance().getExtruderManager()
        for extruder in extruder_manager.getActiveExtruderStacks():
            if extruder is None: #This extruder wasn't loaded yet. This happens asynchronously while this model is constructed from QML.
                continue
            extruder.containersChanged.connect(self._onExtruderStackContainersChanged)
            extruder.enabledChanged.connect(self._updateExtruders)
            self._active_machine_extruders.append(extruder)

        self._updateExtruders()  # Since the new extruders may have different properties, update our own model.

    def _onExtruderStackContainersChanged(self, container):
        # Update when there is an empty container or material or variant change
        if container.getMetaDataEntry("type") in ["material", "variant", None]:
            # The ExtrudersModel needs to be updated when the material-name or -color changes, because the user identifies extruders by material-name
            self._updateExtruders()

    modelChanged = pyqtSignal()

    def _updateExtruders(self):
        self._update_extruder_timer.start()

    @QD.FlameProfiler.profile
    def __updateExtruders(self):
        """Update the list of extruders.

        This should be called whenever the list of extruders changes.
        """

        extruders_changed = False

        if self.count != 0:
            extruders_changed = True

        items = []

        global_container_stack = Application.getInstance().getGlobalContainerStack()
        if global_container_stack:

            # get machine extruder count for verification
            machine_extruder_count = global_container_stack.getProperty("machine_extruder_count", "value")
            tempextruder = ""
            for extruder in Application.getInstance().getExtruderManager().getActiveExtruderStacks():
                position = extruder.getMetaDataEntry("position", default = "0")
                try:
                    position = int(position)
                except ValueError:
                    # Not a proper int.
                    position = -1
                if position >= machine_extruder_count:
                    continue

                default_color = self.defaultColors[position] if 0 <= position < len(self.defaultColors) else self.defaultColors[0]
                if Application.getInstance().getPreferences().getValue("view/use_extruder_color") and machine_extruder_count > 1:
                    if Application.getInstance().getPreferences().getValue("color/extruder" + str(position)):
                        color = Application.getInstance().getPreferences().getValue("color/extruder" + str(position))
                    else:
                        default_color
                else:
                    color = extruder.material.getMetaDataEntry("color_code", default = default_color) if extruder.material else default_color
                    #Logger.log("e",position)
                    #Logger.log("e",color)
                    #Logger.log("e",self.defaultColors[0])
                    #Logger.log("e",self.defaultColors[1])
                    if position == 1 and (tempextruder.material== extruder.material):
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
                        #Logger.log("e",color)
                if tempextruder =="":
                    tempextruder = extruder
                material_brand = extruder.material.getMetaDataEntry("brand", default = "generic")
                color_name = extruder.material.getMetaDataEntry("color_name")
                # construct an item with only the relevant information
                item = {
                    "id": extruder.getId(),
                    "name": extruder.getName(),
                    "enabled": extruder.isEnabled,
                    "color": color,
                    "index": position,
                    "definition": extruder.getBottom().getId(),
                    "material": extruder.material.getName() if extruder.material else "",
                    "variant": extruder.variant.getName() if extruder.variant else "",  # e.g. print core
                    "stack": extruder,
                    "material_brand": material_brand,
                    "color_name": color_name
                }

                items.append(item)
                extruders_changed = True

        if extruders_changed:
            # sort by extruder index
            items.sort(key = lambda i: i["index"])

            # We need optional extruder to be last, so add it after we do sorting.
            # This way we can simply interpret the -1 of the index as the last item (which it now always is)
            if self._add_optional_extruder:
                item = {
                    "id": "",
                    "name": catalog.i18nc("@menuitem", "Not overridden"),
                    "enabled": True,
                    "color": "#ffffff",
                    "index": -1,
                    "definition": "",
                    "material": "",
                    "variant": "",
                    "stack": None,
                    "material_brand": "",
                    "color_name": "",
                }
                items.append(item)
            if self._items != items:
                self.setItems(items)
                self.modelChanged.emit()
