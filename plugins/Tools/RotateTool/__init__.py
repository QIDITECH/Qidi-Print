# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import RotateTool

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")

def getMetaData():
    return {
        "tool": {
            "name": i18n_catalog.i18nc("@label", "Rotate"),
            "description": i18n_catalog.i18nc("@info:tooltip", "Rotate Model"),
            "icon": "Rotate",
            "tool_panel": "RotateTool.qml",
            "weight": 1
        }
    }

def register(app):
    return { "tool": RotateTool.RotateTool() }
