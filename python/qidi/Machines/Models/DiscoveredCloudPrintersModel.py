from typing import Optional, TYPE_CHECKING, List, Dict

from PyQt5.QtCore import QObject, pyqtSlot, Qt, pyqtSignal, pyqtProperty

from QD.Qt.ListModel import ListModel

if TYPE_CHECKING:
    from qidi.QIDIApplication import QIDIApplication


class DiscoveredCloudPrintersModel(ListModel):
    """Model used to inform the application about newly added cloud printers, which are discovered from the user's
     account """

    DeviceKeyRole = Qt.UserRole + 1
    DeviceNameRole = Qt.UserRole + 2
    DeviceTypeRole = Qt.UserRole + 3
    DeviceFirmwareVersionRole = Qt.UserRole + 4

    cloudPrintersDetectedChanged = pyqtSignal(bool)

    def __init__(self, application: "QIDIApplication", parent: Optional["QObject"] = None) -> None:
        super().__init__(parent)

        self.addRoleName(self.DeviceKeyRole, "key")
        self.addRoleName(self.DeviceNameRole, "name")
        self.addRoleName(self.DeviceTypeRole, "machine_type")
        self.addRoleName(self.DeviceFirmwareVersionRole, "firmware_version")

        self._discovered_cloud_printers_list = []  # type: List[Dict[str, str]]
        self._application = application  # type: QIDIApplication

    def addDiscoveredCloudPrinters(self, new_devices: List[Dict[str, str]]) -> None:


        self._discovered_cloud_printers_list.extend(new_devices)
        self._update()

        # Inform whether new cloud printers have been detected. If they have, the welcome wizard can close.
        self.cloudPrintersDetectedChanged.emit(len(new_devices) > 0)

    @pyqtSlot()
    def clear(self) -> None:
        """Clears the contents of the DiscoveredCloudPrintersModel.

        :return: None
        """

        self._discovered_cloud_printers_list = []
        self._update()
        self.cloudPrintersDetectedChanged.emit(False)

    def _update(self) -> None:
        """Sorts the newly discovered cloud printers by name and then updates the ListModel.

        :return: None
        """

        items = self._discovered_cloud_printers_list[:]
        items.sort(key = lambda k: k["name"])
        self.setItems(items)
