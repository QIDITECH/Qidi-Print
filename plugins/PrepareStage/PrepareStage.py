# Copyright (c) 2019 Ultimaker B.V.
# Cura is released under the terms of the LGPLv3 or higher.

import os.path
from QD.Application import Application
from QD.PluginRegistry import PluginRegistry
from qidi.Stages.QIDIStage import QIDIStage


class PrepareStage(QIDIStage):
    """Stage for preparing model (slicing)."""

    def __init__(self, parent = None):
        super().__init__(parent)
        Application.getInstance().engineCreatedSignal.connect(self._engineCreated)

    def _engineCreated(self):
        menu_component_path = os.path.join(PluginRegistry.getInstance().getPluginPath("PrepareStage"), "PrepareMenu.qml")
        main_component_path = os.path.join(PluginRegistry.getInstance().getPluginPath("PrepareStage"), "PrepareMain.qml")
        self.addDisplayComponent("menu", menu_component_path)
        self.addDisplayComponent("main", main_component_path)