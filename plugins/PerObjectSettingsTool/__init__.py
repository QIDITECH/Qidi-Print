# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import PerObjectSettingsTool
from . import PerObjectSettingVisibilityHandler
from PyQt5.QtQml import qmlRegisterType

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qidi")

def getMetaData():
    return {
        "tool": {
            "name": i18n_catalog.i18nc("@label", "Per Model Settings"),
            "description": i18n_catalog.i18nc("@info:tooltip", "Configure Per Model Settings"),
            "icon": "MeshType",
            "tool_panel": "PerObjectSettingsPanel.qml",
            "weight": 3
        },
    }

def register(app):
    qmlRegisterType(PerObjectSettingVisibilityHandler.PerObjectSettingVisibilityHandler, "QIDI", 1, 0,
                    "PerObjectSettingVisibilityHandler")
    return { "tool": PerObjectSettingsTool.PerObjectSettingsTool() }
