# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import Dict, Set

from PyQt5.QtCore import Qt, QTimer, pyqtSignal, pyqtProperty

from QD.Qt.ListModel import ListModel
from QD.Logger import Logger

import qidi.QIDIApplication  # Imported like this to prevent a circular reference.
from qidi.Machines.ContainerTree import ContainerTree
from qidi.Machines.MaterialNode import MaterialNode
from qidi.Settings.QIDIContainerRegistry import QIDIContainerRegistry

class BaseMaterialsModel(ListModel):
    """This is the base model class for GenericMaterialsModel and MaterialBrandsModel.

    Those 2 models are used by the material drop down menu to show generic materials and branded materials
    separately. The extruder position defined here is being used to bound a menu to the correct extruder. This is
    used in the top bar menu "Settings" -> "Extruder nr" -> "Material" -> this menu
    """

    extruderPositionChanged = pyqtSignal()
    enabledChanged = pyqtSignal()

    def __init__(self, parent = None):
        super().__init__(parent)
        from qidi.QIDIApplication import QIDIApplication

        self._application = QIDIApplication.getInstance()

        self._available_materials = {}  # type: Dict[str, MaterialNode]
        self._favorite_ids = set()  # type: Set[str]

        # Make these managers available to all material models
        self._container_registry = self._application.getInstance().getContainerRegistry()
        self._machine_manager = self._application.getMachineManager()

        self._extruder_position = 0
        self._extruder_stack = None
        self._enabled = True

        # QIDI-6904
        # Updating the material model requires information from material nodes and containers. We use a timer here to
        # make sure that an update function call will not be directly invoked by an event. Because the triggered event
        # can be caused in the middle of a XMLMaterial loading, and the material container we try to find may not be
        # in the system yet. This will cause an infinite recursion of (1) trying to load a material, (2) trying to
        # update the material model, (3) cannot find the material container, load it, (4) repeat #1.
        self._update_timer = QTimer(self)
        self._update_timer.setInterval(100)
        self._update_timer.setSingleShot(True)
        self._update_timer.timeout.connect(self._update)

        # Update the stack and the model data when the machine changes
        self._machine_manager.globalContainerChanged.connect(self._updateExtruderStack)
        self._updateExtruderStack()

        # Update this model when switching machines or tabs, when adding materials or changing their metadata.
        self._machine_manager.activeStackChanged.connect(self._onChanged)
        ContainerTree.getInstance().materialsChanged.connect(self._materialsListChanged)
        self._application.getMaterialManagementModel().favoritesChanged.connect(self._onChanged)

        self.addRoleName(Qt.UserRole + 1, "root_material_id")
        self.addRoleName(Qt.UserRole + 2, "id")
        self.addRoleName(Qt.UserRole + 3, "GUID")
        self.addRoleName(Qt.UserRole + 4, "name")
        self.addRoleName(Qt.UserRole + 5, "brand")
        self.addRoleName(Qt.UserRole + 6, "description")
        self.addRoleName(Qt.UserRole + 7, "material")
        self.addRoleName(Qt.UserRole + 8, "color_name")
        self.addRoleName(Qt.UserRole + 9, "color_code")
        self.addRoleName(Qt.UserRole + 10, "density")
        self.addRoleName(Qt.UserRole + 11, "diameter")
        self.addRoleName(Qt.UserRole + 12, "approximate_diameter")
        self.addRoleName(Qt.UserRole + 13, "adhesion_info")
        self.addRoleName(Qt.UserRole + 14, "is_read_only")
        self.addRoleName(Qt.UserRole + 15, "container_node")
        self.addRoleName(Qt.UserRole + 16, "is_favorite")
        self.addRoleName(Qt.UserRole + 17, "humidity")
        self.addRoleName(Qt.UserRole + 18, "water_resistant")
        self.addRoleName(Qt.UserRole + 19, "chemically_resistant")
        self.addRoleName(Qt.UserRole + 20, "anneal")
        self.addRoleName(Qt.UserRole + 21, "HDT_0.45")
        self.addRoleName(Qt.UserRole + 22, "HDT_1.80")
        self.addRoleName(Qt.UserRole + 23, "tensile_strength")
        self.addRoleName(Qt.UserRole + 24, "tensile_modulus")
        self.addRoleName(Qt.UserRole + 25, "elongation_at_break")
        self.addRoleName(Qt.UserRole + 26, "flexural_strength")
        self.addRoleName(Qt.UserRole + 27, "flexural_modulus")
        self.addRoleName(Qt.UserRole + 28, "impact_strength")
        self.addRoleName(Qt.UserRole + 29, "creep_resistant")

    def _onChanged(self) -> None:
        self._update_timer.start()

    def _updateExtruderStack(self):
        global_stack = self._machine_manager.activeMachine
        if global_stack is None:
            return

        if self._extruder_stack is not None:
            self._extruder_stack.pyqtContainersChanged.disconnect(self._onChanged)
            self._extruder_stack.approximateMaterialDiameterChanged.disconnect(self._onChanged)

        try:
            self._extruder_stack = global_stack.extruderList[self._extruder_position]
        except IndexError:
            self._extruder_stack = None

        if self._extruder_stack is not None:
            self._extruder_stack.pyqtContainersChanged.connect(self._onChanged)
            self._extruder_stack.approximateMaterialDiameterChanged.connect(self._onChanged)
        # Force update the model when the extruder stack changes
        self._onChanged()

    def setExtruderPosition(self, position: int):
        if self._extruder_stack is None or self._extruder_position != position:
            self._extruder_position = position
            self._updateExtruderStack()
            self.extruderPositionChanged.emit()

    @pyqtProperty(int, fset = setExtruderPosition, notify = extruderPositionChanged)
    def extruderPosition(self) -> int:
        return self._extruder_position

    def setEnabled(self, enabled):
        if self._enabled != enabled:
            self._enabled = enabled
            if self._enabled:
                # ensure the data is there again.
                self._onChanged()
            self.enabledChanged.emit()

    @pyqtProperty(bool, fset = setEnabled, notify = enabledChanged)
    def enabled(self):
        return self._enabled

    def _materialsListChanged(self, material: MaterialNode) -> None:
        """Triggered when a list of materials changed somewhere in the container

        tree. This change may trigger an _update() call when the materials changed for the configuration that this
        model is looking for.
        """

        if self._extruder_stack is None:
            return
        if material.variant.container_id != self._extruder_stack.variant.getId():
            return
        global_stack = qidi.QIDIApplication.QIDIApplication.getInstance().getGlobalContainerStack()
        if not global_stack:
            return
        if material.variant.machine.container_id != global_stack.definition.getId():
            return
        self._onChanged()

    def _favoritesChanged(self, material_base_file: str) -> None:
        """Triggered when the list of favorite materials is changed."""

        if material_base_file in self._available_materials:
            self._onChanged()

    def _update(self):
        """This is an abstract method that needs to be implemented by the specific models themselves. """

        self._favorite_ids = set(qidi.QIDIApplication.QIDIApplication.getInstance().getPreferences().getValue("qidi/favorite_materials").split(";"))

        # Update the available materials (ContainerNode) for the current active machine and extruder setup.
        global_stack = qidi.QIDIApplication.QIDIApplication.getInstance().getGlobalContainerStack()
        if not global_stack or not global_stack.hasMaterials:
            return  # There are no materials for this machine, so nothing to do.
        extruder_list = global_stack.extruderList
        if self._extruder_position > len(extruder_list):
            return
        extruder_stack = extruder_list[self._extruder_position]
        nozzle_name = extruder_stack.variant.getName()
        machine_node = ContainerTree.getInstance().machines[global_stack.definition.getId()]
        if nozzle_name not in machine_node.variants:
            Logger.log("w", "Unable to find variant %s in container tree", nozzle_name)
            self._available_materials = {}
            return
        materials = machine_node.variants[nozzle_name].materials
        approximate_material_diameter = extruder_stack.getApproximateMaterialDiameter()
        self._available_materials = {key: material for key, material in materials.items() if float(material.getMetaDataEntry("approximate_diameter", -1)) == approximate_material_diameter}

    def _canUpdate(self):
        """This method is used by all material models in the beginning of the _update() method in order to prevent
        errors. It's the same in all models so it's placed here for easy access. """

        global_stack = self._machine_manager.activeMachine
        if global_stack is None or not self._enabled:
            return False

        if self._extruder_position >= len(global_stack.extruderList):
            return False

        return True

    def _createMaterialItem(self, root_material_id, container_node):
        """This is another convenience function which is shared by all material models so it's put here to avoid having
         so much duplicated code. """

        metadata_list = QIDIContainerRegistry.getInstance().findContainersMetadata(id = container_node.container_id)
        if not metadata_list:
            return None
        metadata = metadata_list[0]
        item = {
            "root_material_id":     root_material_id,
            "id":                   metadata["id"],
            "container_id":         metadata["id"], # TODO: Remove duplicate in material manager qml
            "GUID":                 metadata["GUID"],
            "name":                 metadata["name"],
            "brand":                metadata["brand"],
            "description":          metadata["description"],
            "material":             metadata["material"],
            "color_name":           metadata["color_name"],
            "color_code":           metadata.get("color_code", ""),
            "density":              metadata.get("properties", {}).get("density", ""),
            "diameter":             metadata.get("properties", {}).get("diameter", ""),
            "approximate_diameter": metadata["approximate_diameter"],
            "adhesion_info":        metadata["adhesion_info"],
            "is_read_only":         self._container_registry.isReadOnly(metadata["id"]),
            "container_node":       container_node,
            "is_favorite":          root_material_id in self._favorite_ids,
            "humidity":             metadata.get("properties", {}).get("humidity", "Cannot find this"),
            "water_resistant":      metadata.get("properties", {}).get("water_resistant", "Cannot find this"),
            "chemically_resistant": metadata.get("properties", {}).get("chemically_resistant", "Cannot find this"),
            "anneal":               metadata.get("properties", {}).get("anneal", "Cannot find this"),
            "hdt_045":             metadata.get("properties", {}).get("HDT_0.45", "Cannot find this"),
            "hdt_180":             metadata.get("properties", {}).get("HDT_1.80", "Cannot find this"),
            "tensile_strength":     metadata.get("properties", {}).get("tensile_strength", "Cannot find this"),
            "tensile_modulus":      metadata.get("properties", {}).get("tensile_modulus", "Cannot find this"),
            "elongation_at_break":  metadata.get("properties", {}).get("elongation_at_break", "Cannot find this"),
            "flexural_strength":    metadata.get("properties", {}).get("flexural_strength", "Cannot find this"),
            "flexural_modulus":     metadata.get("properties", {}).get("flexural_modulus", "Cannot find this"),
            "impact_strength":      metadata.get("properties", {}).get("impact_strength", "Cannot find this"),
            "creep_resistant":      metadata.get("properties", {}).get("creep_resistant", "Cannot find this")

        }
        return item
