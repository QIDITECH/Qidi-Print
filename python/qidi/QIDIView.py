# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import pyqtProperty, QUrl

from QD.Resources import Resources
from QD.View.View import View

from qidi.QIDIApplication import QIDIApplication


# Since QIDI has a few pre-defined "space claims" for the locations of certain components, we've provided some structure
# to indicate this.
#   MainComponent works in the same way the MainComponent of a stage.
#   the stageMenuComponent returns an item that should be used somehwere in the stage menu. It's up to the active stage
#   to actually do something with this.
class QIDIView(View):
    def __init__(self, parent = None, use_empty_menu_placeholder: bool = False) -> None:
        super().__init__(parent)

        self._empty_menu_placeholder_url = QUrl.fromLocalFile(Resources.getPath(QIDIApplication.ResourceTypes.QmlFiles,
                                                                                "EmptyViewMenuComponent.qml"))
        self._use_empty_menu_placeholder = use_empty_menu_placeholder

    @pyqtProperty(QUrl, constant = True)
    def mainComponent(self) -> QUrl:
        return self.getDisplayComponent("main")


    @pyqtProperty(QUrl, constant = True)
    def stageMenuComponent(self) -> QUrl:
        url = self.getDisplayComponent("menu")
        if not url.toString() and self._use_empty_menu_placeholder:
            url = self._empty_menu_placeholder_url
        return url
