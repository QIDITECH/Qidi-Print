# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import Optional, TYPE_CHECKING
from PyQt5.QtCore import QObject, pyqtSlot

from QD.i18n import i18nCatalog

from qidi.Machines.ContainerTree import ContainerTree

if TYPE_CHECKING:
    from qidi.QIDIApplication import QIDIApplication


#
# This manager provides (convenience) functions to the Machine Settings Dialog QML to update certain machine settings.
#
class MachineSettingsManager(QObject):

    def __init__(self, application: "QIDIApplication", parent: Optional["QObject"] = None) -> None:
        super().__init__(parent)
        self._i18n_catalog = i18nCatalog("qidi")

        self._application = application

    # Force rebuilding the build volume by reloading the global container stack. This is a bit of a hack, but it seems
    # quite enough.
    @pyqtSlot()
    def forceUpdate(self) -> None:
        self._application.getMachineManager().globalContainerChanged.emit()

    # Function for the Machine Settings panel (QML) to update the compatible material diameter after a user has changed
    # an extruder's compatible material diameter. This ensures that after the modification, changes can be notified
    # and updated right away.
    @pyqtSlot(int)
    def updateMaterialForDiameter(self, extruder_position: int) -> None:
        # Updates the material container to a material that matches the material diameter set for the printer
        self._application.getMachineManager().updateMaterialWithVariant(str(extruder_position))

    @pyqtSlot(int)
    def setMachineExtruderCount(self, extruder_count: int) -> None:
        # Note: this method was in this class before, but since it's quite generic and other plugins also need it
        # it was moved to the machine manager instead. Now this method just calls the machine manager.
        self._application.getMachineManager().setActiveMachineExtruderCount(extruder_count)

    @pyqtSlot()
    def updateHasMaterialsMetadata(self):
        machine_manager = self._application.getMachineManager()
        global_stack = machine_manager.activeMachine

        definition = global_stack.definition
        if definition.getProperty("machine_gcode_flavor", "value") != "UltiGCode" or definition.getMetaDataEntry(
                "has_materials", False):
            # In other words: only continue for the QD2 (extended), but not for the QD2+
            return

        has_materials = global_stack.getProperty("machine_gcode_flavor", "value") != "UltiGCode"

        material_node = None
        if has_materials:
            global_stack.setMetaDataEntry("has_materials", True)
        else:
            # The metadata entry is stored in an ini, and ini files are parsed as strings only.
            # Because any non-empty string evaluates to a boolean True, we have to remove the entry to make it False.
            if "has_materials" in global_stack.getMetaData():
                global_stack.removeMetaDataEntry("has_materials")

        # set materials
        for position, extruder in enumerate(global_stack.extruderList):
            if has_materials:
                approximate_diameter = extruder.getApproximateMaterialDiameter()
                variant_node = ContainerTree.getInstance().machines[global_stack.definition.getId()].variants[extruder.variant.getName()]
                material_node = variant_node.preferredMaterial(approximate_diameter)
            machine_manager.setMaterial(str(position), material_node)

        self.forceUpdate()
