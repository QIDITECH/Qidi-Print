
from PyQt5.QtCore import QUrl
from PyQt5.QtGui import QDesktopServices

from QD.Application import Application
from QD.Extension import Extension
from QD.i18n import i18nCatalog
from .UpdateCheckerJob import UpdateCheckerJob

i18n_catalog = i18nCatalog("qdtech")


class UpdateChecker(Extension):

    url = "http://www.qd3dprinter.com/qidiprint/latest.txt"

    def __init__(self):
        super().__init__()
        self.setMenuName(i18n_catalog.i18nc("@item:inmenu", "Update Checker"))
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Check for Updates"), self.checkNewVersion)

        Application.getInstance().getPreferences().addPreference("info/automatic_update_check", True)
        if Application.getInstance().getPreferences().getValue("info/automatic_update_check"):
            self.checkNewVersion(silent = True, display_same_version = False)

        self._download_url = None

        # Which version was the latest shown in the version upgrade dialog. Don't show these updates twice.
        Application.getInstance().getPreferences().addPreference("info/latest_update_version_shown", "0.0.0")

    def checkNewVersion(self, silent = False, display_same_version = True):

        self._download_url = None
        job = UpdateCheckerJob(silent, display_same_version, self.url, self._onActionTriggered, self._onSetDownloadUrl)
        job.start()

    def _onSetDownloadUrl(self, download_url):
        self._download_url = download_url

    def _onActionTriggered(self, message, action):
        """Callback function for the "download" button on the update notification.

        This function is here is because the custom Signal in QDTECH keeps a list of weak references to its
        connections, so the callback functions need to be long-lived. The UpdateCheckerJob is short-lived so
        this function cannot be there.
        """
        if action == "download":
            if self._download_url is not None:
                QDesktopServices.openUrl(QUrl(self._download_url))
        elif action == "next_time":
            Application.getInstance().getPreferences().setValue("info/latest_update_version_shown", "0.0.0")
            message.hide()
            #QDesktopServices.openUrl(QUrl(Application.getInstance().change_log_url))
