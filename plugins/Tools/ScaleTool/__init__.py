# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import ScaleTool

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")

def getMetaData():
    return {
        "tool": {
            "name": i18n_catalog.i18nc("@label", "Scale"),
            "description": i18n_catalog.i18nc("@info:tooltip", "Scale Model"),
            "icon": "Scale",
            "tool_panel": "ScaleTool.qml",
            "weight": 0
        }
    }

def register(app):
    return { "tool": ScaleTool.ScaleTool() }
