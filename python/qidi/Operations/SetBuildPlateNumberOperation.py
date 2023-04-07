# Copyright (c) 2017 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from QD.Scene.SceneNode import SceneNode
from QD.Operations.Operation import Operation

from qidi.Settings.SettingOverrideDecorator import SettingOverrideDecorator


class SetBuildPlateNumberOperation(Operation):
    """Simple operation to set the buildplate number of a scenenode."""

    def __init__(self, node: SceneNode, build_plate_nr: int) -> None:
        super().__init__()
        self._node = node
        self._build_plate_nr = build_plate_nr
        self._previous_build_plate_nr = None
        self._decorator_added = False

    def undo(self) -> None:
        if self._previous_build_plate_nr:
            self._node.callDecoration("setBuildPlateNumber", self._previous_build_plate_nr)

    def redo(self) -> None:
        stack = self._node.callDecoration("getStack") #Don't try to get the active extruder since it may be None anyway.
        if not stack:
            self._node.addDecorator(SettingOverrideDecorator())

        self._previous_build_plate_nr = self._node.callDecoration("getBuildPlateNumber")
        self._node.callDecoration("setBuildPlateNumber", self._build_plate_nr)
