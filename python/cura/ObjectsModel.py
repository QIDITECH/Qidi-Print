# Copyright (c) 2018 Ultimaker B.V.
# Cura is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import QTimer

from UM.Application import Application
from UM.Qt.ListModel import ListModel
from UM.Scene.Iterator.DepthFirstIterator import DepthFirstIterator
from UM.Scene.SceneNode import SceneNode
from UM.Scene.Selection import Selection
from UM.Preferences import Preferences
from UM.i18n import i18nCatalog

catalog = i18nCatalog("cura")


##  Keep track of all objects in the project
class ObjectsModel(ListModel):
    def __init__(self):
        super().__init__()

        Application.getInstance().getController().getScene().sceneChanged.connect(self._updateDelayed)
        Preferences.getInstance().preferenceChanged.connect(self._updateDelayed)

        self._update_timer = QTimer()
        self._update_timer.setInterval(100)
        self._update_timer.setSingleShot(True)
        self._update_timer.timeout.connect(self._update)

        self._build_plate_number = -1

    def setActiveBuildPlate(self, nr):
        self._build_plate_number = nr
        self._update()

    def _updateDelayed(self, *args):
        self._update_timer.start()

    def _update(self, *args):
        nodes = []
        filter_current_build_plate = Preferences.getInstance().getValue("view/filter_current_build_plate")
        active_build_plate_number = self._build_plate_number
        group_nr = 1
        for node in DepthFirstIterator(Application.getInstance().getController().getScene().getRoot()):
            if not isinstance(node, SceneNode):
                continue
            if (not node.getMeshData() and not node.callDecoration("getLayerData")) and not node.callDecoration("isGroup"):
                continue
            if node.getParent() and node.getParent().callDecoration("isGroup"):
                continue  # Grouped nodes don't need resetting as their parent (the group) is resetted)
            if not node.callDecoration("isSliceable") and not node.callDecoration("isGroup"):
                continue
            node_build_plate_number = node.callDecoration("getBuildPlateNumber")
            if filter_current_build_plate and node_build_plate_number != active_build_plate_number:
                continue

            if not node.callDecoration("isGroup"):
                name = node.getName()
            else:
                name = catalog.i18nc("@label", "Group #{group_nr}").format(group_nr = str(group_nr))
                group_nr += 1

            if hasattr(node, "isOutsideBuildArea"):
                is_outside_build_area = node.isOutsideBuildArea()
            else:
                is_outside_build_area = False

            extruder_position = node.callDecoration("getActiveExtruderPosition")
            if extruder_position is None:
                extruder_number = -1
            else:
                extruder_number = int(extruder_position)
            if node.callDecoration("isGroup"):
                # for anti overhang meshes and groups the extruder nr is irrelevant
                extruder_number = -1
            
            nodes.append({
                "name": node.getName(),
                "isSelected": Selection.isSelected(node),
                "isOutsideBuildArea": is_outside_build_area,
                "buildPlateNumber": node_build_plate_number,
                "extruder_number": extruder_number,
                "node": node
            })
        nodes = sorted(nodes, key=lambda n: n["name"])
        self.setItems(nodes)

        self.itemsChanged.emit()

    @staticmethod
    def createObjectsModel():
        return ObjectsModel()
