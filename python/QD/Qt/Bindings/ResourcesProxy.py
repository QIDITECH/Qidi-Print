# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import QObject, QUrl, Q_ENUMS
from QD.FlameProfiler import pyqtSlot

import QD.Resources
from QD.Logger import Logger

class ResourcesProxy(QObject):
    class Type:
        Resources = QD.Resources.Resources.Resources
        Preferences = QD.Resources.Resources.Preferences
        Themes = QD.Resources.Resources.Themes
        Images = QD.Resources.Resources.Images
        Meshes = QD.Resources.Resources.Meshes
        i18n = QD.Resources.Resources.i18n
        Shaders = QD.Resources.Resources.Shaders
        UserType = QD.Resources.Resources.UserType
    Q_ENUMS(Type)

    def __init__(self, parent = None):
        super().__init__(parent)

    @pyqtSlot(int, str, result = str)
    def getPath(self, type, name):
        try:
            return QD.Resources.Resources.getPath(type, name)
        except:
            Logger.log("w", "Could not find the requested resource: %s", name)
            return ""
