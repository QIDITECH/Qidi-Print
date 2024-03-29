# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.
from typing import Optional, TYPE_CHECKING

from PyQt5.QtCore import QObject, pyqtProperty

from qidi.API.Backups import Backups
from qidi.API.ConnectionStatus import ConnectionStatus
from qidi.API.Interface import Interface
from qidi.API.Account import Account

if TYPE_CHECKING:
    from qidi.QIDIApplication import QIDIApplication


class QIDIAPI(QObject):
    """The official QIDI API that plug-ins can use to interact with QIDI.

    Python does not technically prevent talking to other classes as well, but this API provides a version-safe
    interface with proper deprecation warnings etc. Usage of any other methods than the ones provided in this API can
    cause plug-ins to be unstable.
    """


    # For now we use the same API version to be consistent.
    __instance = None  # type: "QIDIAPI"
    _application = None  # type: QIDIApplication

    #   This is done to ensure that the first time an instance is created, it's forced that the application is set.
    #   The main reason for this is that we want to prevent consumers of API to have a dependency on QIDIApplication.
    #   Since the API is intended to be used by plugins, the qidi application should have already created this.
    def __new__(cls, application: Optional["QIDIApplication"] = None):
        if cls.__instance is not None:
            raise RuntimeError("Tried to create singleton '{class_name}' more than once.".format(class_name = QIDIAPI.__name__))
        if application is None:
            raise RuntimeError("Upon first time creation, the application must be set.")
        cls.__instance = super(QIDIAPI, cls).__new__(cls)
        cls._application = application
        return cls.__instance

    def __init__(self, application: Optional["QIDIApplication"] = None) -> None:
        super().__init__(parent = QIDIAPI._application)

        self._account = Account(self._application)

        self._backups = Backups(self._application)

        self._connectionStatus = ConnectionStatus()

        # Interface API
        self._interface = Interface(self._application)

    def initialize(self) -> None:
        self._account.initialize()

    @pyqtProperty(QObject, constant = True)
    def account(self) -> "Account":
        """Accounts API"""

        return self._account

    @pyqtProperty(QObject, constant = True)
    def connectionStatus(self) -> "ConnectionStatus":
        return self._connectionStatus

    @property
    def backups(self) -> "Backups":
        """Backups API"""

        return self._backups

    @property
    def interface(self) -> "Interface":
        """Interface API"""

        return self._interface
