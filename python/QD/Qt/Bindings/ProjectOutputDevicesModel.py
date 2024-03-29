# Copyright (c) 2021 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.
from typing import List

from PyQt5.QtCore import Qt, pyqtSignal
from PyQt5.QtQml import QQmlEngine

from QD.Application import Application
from QD.OutputDevice.OutputDeviceManager import OutputDeviceManager
from QD.OutputDevice.ProjectOutputDevice import ProjectOutputDevice
from QD.Qt.ListModel import ListModel


class ProjectOutputDevicesModel(ListModel):
    """A list model providing a list of all registered OutputDevices that can save projects.

    Exposes the following roles:
    * id - The device ID
    * name - The human-readable name of the device
    * priority - The device priority

    """

    IdRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    PriorityRole = Qt.UserRole + 3
    ShortcutRole = Qt.UserRole + 4

    projectOutputDevicesChanged = pyqtSignal()

    def __init__(self, parent = None):
        super().__init__(parent)
        # Ensure that this model doesn't get garbage collected (Now the bound object is destroyed when the wrapper is)
        QQmlEngine.setObjectOwnership(self, QQmlEngine.CppOwnership)
        self._device_manager = Application.getInstance().getOutputDeviceManager()  # type: OutputDeviceManager

        self.addRoleName(self.IdRole, "id")
        self.addRoleName(self.NameRole, "name")
        self.addRoleName(self.PriorityRole, "priority")
        self.addRoleName(self.ShortcutRole, "shortcut")

        self._device_manager.projectOutputDevicesChanged.connect(self._update)
        self._update()

    def _update(self):

        self.clear()
        items = []

        # Make a copy here, because we could discover devices during iteration.
        devices = [device for device in self._device_manager.getProjectOutputDevices() if device.enabled]  # type: List[ProjectOutputDevice]
        for device in devices:
            items.append({
                "id": device.getId(),
                "name": device.menu_entry_text,
                "priority": device.getPriority(),
                "shortcut": device.shortcut
            })

        items.sort(key = lambda i: -i["priority"])
        self.setItems(items)

        self.projectOutputDevicesChanged.emit()
