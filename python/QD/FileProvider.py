# Copyright (c) 2021 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import pyqtSignal, QObject

from QD.PluginObject import PluginObject
from typing import Optional


class FileProvider(PluginObject, QObject):
    """Base class for plugins that aim to provide a file to QIDI in an alternate fashion, other than using the local file
    explorer.

    Every new file provider adds an option to the Open File(s) menu.
    """

    enabledChanged = pyqtSignal()
    """Signal which informs whether the file provider has been enabled or disabled, so that it can be removed or added
    in the Open File(s) submenu"""

    def __init__(self) -> None:
        PluginObject.__init__(self)
        QObject.__init__(self)

        self.menu_item_display_text = None  # type: Optional[str]
        """
        Text that will be displayed as an option in the Open File(s) menu.
        """

        self.shortcut = None  # type: Optional[str]
        """
        Shortcut key combination (e.g. "Ctrl+O").
        """

        self.enabled = True
        """
        If the provider is not enabled, it should not be displayed in the interface.
        """

        self.priority = 0
        """
        Where it should be sorted in lists, or which should be tried first.
        """

    def run(self) -> None:
        """Call function associated with the file provider"""
        raise NotImplementedError
