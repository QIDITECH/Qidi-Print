# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import Qt, QTimer

from QD.Qt.ListModel import ListModel
from QD.i18n import i18nCatalog
from QD.Util import parseBool

from qidi.PrinterOutput.PrinterOutputDevice import ConnectionType
from qidi.Settings.QIDIContainerRegistry import QIDIContainerRegistry
from qidi.Settings.GlobalStack import GlobalStack


class GlobalStacksModel(ListModel):
    NameRole = Qt.UserRole + 1
    IdRole = Qt.UserRole + 2
    HasRemoteConnectionRole = Qt.UserRole + 3
    ConnectionTypeRole = Qt.UserRole + 4
    MetaDataRole = Qt.UserRole + 5
    DiscoverySourceRole = Qt.UserRole + 6  # For separating local and remote printers in the machine management page
    RemovalWarningRole = Qt.UserRole + 7

    def __init__(self, parent = None) -> None:
        super().__init__(parent)

        self._catalog = i18nCatalog("qidi")

        self.addRoleName(self.NameRole, "name")
        self.addRoleName(self.IdRole, "id")
        self.addRoleName(self.HasRemoteConnectionRole, "hasRemoteConnection")
        self.addRoleName(self.MetaDataRole, "metadata")
        self.addRoleName(self.DiscoverySourceRole, "discoverySource")

        self._change_timer = QTimer()
        self._change_timer.setInterval(200)
        self._change_timer.setSingleShot(True)
        self._change_timer.timeout.connect(self._update)

        # Listen to changes
        QIDIContainerRegistry.getInstance().containerAdded.connect(self._onContainerChanged)
        QIDIContainerRegistry.getInstance().containerMetaDataChanged.connect(self._onContainerChanged)
        QIDIContainerRegistry.getInstance().containerRemoved.connect(self._onContainerChanged)
        self._updateDelayed()

    def _onContainerChanged(self, container) -> None:
        """Handler for container added/removed events from registry"""

        # We only need to update when the added / removed container GlobalStack
        if isinstance(container, GlobalStack):
            self._updateDelayed()

    def _updateDelayed(self) -> None:
        self._change_timer.start()

    def _update(self) -> None:
        items = []

        container_stacks = QIDIContainerRegistry.getInstance().findContainerStacks(type = "machine")
        for container_stack in container_stacks:
            has_remote_connection = False

            for connection_type in container_stack.configuredConnectionTypes:
                has_remote_connection |= connection_type in [ConnectionType.NetworkConnection.value,
                                                             ConnectionType.CloudConnection.value]

            if parseBool(container_stack.getMetaDataEntry("hidden", False)):
                continue

            device_name = container_stack.getMetaDataEntry("group_name", container_stack.getName())
            section_name = "Connected printers" if has_remote_connection else "Preset printers"
            section_name = self._catalog.i18nc("@info:title", section_name)

            default_removal_warning = self._catalog.i18nc(
                "@label {0} is the name of a printer that's about to be deleted.",
                "Are you sure you wish to remove {0}? This cannot be undone!", device_name
            )
            removal_warning = container_stack.getMetaDataEntry("removal_warning", default_removal_warning)

            items.append({"name": device_name,
                          "id": container_stack.getId(),
                          "hasRemoteConnection": has_remote_connection,
                          "metadata": container_stack.getMetaData().copy(),
                          "discoverySource": section_name,
                          "removalWarning": removal_warning})
        items.sort(key=lambda i: (not i["hasRemoteConnection"], i["name"]))
        self.setItems(items)
