# Copyright (c) 2018 Ultimaker B.V.
# Cura is released under the terms of the LGPLv3 or higher.

from UM.Application import Application
from UM.ConfigurationErrorMessage import ConfigurationErrorMessage

from .QualityGroup import QualityGroup


class QualityChangesGroup(QualityGroup):
    def __init__(self, name: str, quality_type: str, parent = None):
        super().__init__(name, quality_type, parent)
        self._container_registry = Application.getInstance().getContainerRegistry()

    def addNode(self, node: "QualityNode"):
        extruder_position = node.metadata.get("position")

        if extruder_position is None and self.node_for_global is not None or extruder_position in self.nodes_for_extruders: #We would be overwriting another node.
            ConfigurationErrorMessage.getInstance().addFaultyContainers(node.metadata["id"])
            return

        if extruder_position is None: #Then we're a global quality changes profile.
            self.node_for_global = node
        else: #This is an extruder's quality changes profile.
            self.nodes_for_extruders[extruder_position] = node

    def __str__(self) -> str:
        return "%s[<%s>, available = %s]" % (self.__class__.__name__, self.name, self.is_available)
