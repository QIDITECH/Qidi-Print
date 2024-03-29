# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import Optional, TYPE_CHECKING

from QD.Logger import Logger

import qidi.QIDIApplication  # Imported this way to prevent circular references.
from qidi.Machines.ContainerTree import ContainerTree
from qidi.Machines.Models.QualityProfilesDropDownMenuModel import QualityProfilesDropDownMenuModel

if TYPE_CHECKING:
    from PyQt5.QtCore import QObject
    from QD.Settings.Interfaces import ContainerInterface


class CustomQualityProfilesDropDownMenuModel(QualityProfilesDropDownMenuModel):
    """This model is used for the custom profile items in the profile drop down menu."""

    def __init__(self, parent: Optional["QObject"] = None) -> None:
        super().__init__(parent)

        container_registry = qidi.QIDIApplication.QIDIApplication.getInstance().getContainerRegistry()
        container_registry.containerAdded.connect(self._qualityChangesListChanged)
        container_registry.containerRemoved.connect(self._qualityChangesListChanged)
        container_registry.containerMetaDataChanged.connect(self._qualityChangesListChanged)

    def _qualityChangesListChanged(self, container: "ContainerInterface") -> None:
        if container.getMetaDataEntry("type") == "quality_changes":
            self._update()

    def _update(self) -> None:
        Logger.log("d", "Updating {model_class_name}.".format(model_class_name = self.__class__.__name__))

        active_global_stack = qidi.QIDIApplication.QIDIApplication.getInstance().getMachineManager().activeMachine
        if active_global_stack is None:
            self.setItems([])
            Logger.log("d", "No active GlobalStack, set %s as empty.", self.__class__.__name__)
            return

        quality_changes_list = ContainerTree.getInstance().getCurrentQualityChangesGroups()

        item_list = []
        for quality_changes_group in sorted(quality_changes_list, key = lambda qgc: qgc.name.lower()):
            item = {"name": quality_changes_group.name,
                    "layer_height": "",
                    "layer_height_without_unit": "",
                    "available": quality_changes_group.is_available,
                    "quality_changes_group": quality_changes_group}

            item_list.append(item)

        self.setItems(item_list)
