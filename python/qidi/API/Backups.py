# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.
from typing import Tuple, Optional, TYPE_CHECKING, Dict, Any

from qidi.Backups.BackupsManager import BackupsManager

if TYPE_CHECKING:
    from qidi.QIDIApplication import QIDIApplication


class Backups:
    """The back-ups API provides a version-proof bridge between QIDI's

    BackupManager and plug-ins that hook into it.

    Usage:

    .. code-block:: python

       from qidi.API import QIDIAPI
       api = QIDIAPI()
       api.backups.createBackup()
       api.backups.restoreBackup(my_zip_file, {"qidi_release": "3.1"})
    """

    def __init__(self, application: "QIDIApplication") -> None:
        self.manager = BackupsManager(application)

    def createBackup(self) -> Tuple[Optional[bytes], Optional[Dict[str, Any]]]:
        """Create a new back-up using the BackupsManager.

        :return: Tuple containing a ZIP file with the back-up data and a dict with metadata about the back-up.
        """

        return self.manager.createBackup()

    def restoreBackup(self, zip_file: bytes, meta_data: Dict[str, Any]) -> None:
        """Restore a back-up using the BackupsManager.

        :param zip_file: A ZIP file containing the actual back-up data.
        :param meta_data: Some metadata needed for restoring a back-up, like the QIDI version number.
        """

        return self.manager.restoreBackup(zip_file, meta_data)
