# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import Dict, Optional, Tuple, TYPE_CHECKING

from QD.Logger import Logger
from qidi.Backups.Backup import Backup

if TYPE_CHECKING:
    from qidi.QIDIApplication import QIDIApplication


class BackupsManager:
    """
    The BackupsManager is responsible for managing the creating and restoring of
    back-ups.

    Back-ups themselves are represented in a different class.
    """

    def __init__(self, application: "QIDIApplication") -> None:
        self._application = application

    def createBackup(self) -> Tuple[Optional[bytes], Optional[Dict[str, str]]]:
        """
        Get a back-up of the current configuration.

        :return: A tuple containing a ZipFile (the actual back-up) and a dict containing some metadata (like version).
        """

        self._disableAutoSave()
        backup = Backup(self._application)
        backup.makeFromCurrent()
        self._enableAutoSave()
        # We don't return a Backup here because we want plugins only to interact with our API and not full objects.
        return backup.zip_file, backup.meta_data

    def restoreBackup(self, zip_file: bytes, meta_data: Dict[str, str]) -> None:
        """
        Restore a back-up from a given ZipFile.

        :param zip_file: A bytes object containing the actual back-up.
        :param meta_data: A dict containing some metadata that is needed to restore the back-up correctly.
        """

        if not meta_data.get("qidi_release", None):
            # If there is no "qidi_release" specified in the meta data, we don't execute a backup restore.
            Logger.log("w", "Tried to restore a backup without specifying a QIDI version number.")
            return

        self._disableAutoSave()

        backup = Backup(self._application, zip_file = zip_file, meta_data = meta_data)
        restored = backup.restore()
        if restored:
            # At this point, QIDI will need to restart for the changes to take effect.
            # We don't want to store the data at this point as that would override the just-restored backup.
            self._application.windowClosed(save_data = False)

    def _disableAutoSave(self) -> None:
        """Here we (try to) disable the saving as it might interfere with restoring a back-up."""

        self._application.enableSave(False)
        auto_save = self._application.getAutoSave()
        # The auto save is only not created if the application has not yet started.
        if auto_save:
            auto_save.setEnabled(False)
        else:
            Logger.log("e", "Unable to disable the autosave as application init has not been completed")

    def _enableAutoSave(self) -> None:
        """Re-enable auto-save and other saving after we're done."""

        self._application.enableSave(True)
        auto_save = self._application.getAutoSave()
        # The auto save is only not created if the application has not yet started.
        if auto_save:
            auto_save.setEnabled(True)
        else:
            Logger.log("e", "Unable to enable the autosave as application init has not been completed")
