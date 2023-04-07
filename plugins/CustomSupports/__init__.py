
from . import CustomSupports

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qidi")

def getMetaData():
    return {
        "tool": {
            "name": i18n_catalog.i18nc("@label", "Custom Supports"),
            "description": i18n_catalog.i18nc("@info:tooltip", "Add custom supports"),
            "icon": "Support.svg",
            "tool_panel": "CustomSupports.qml",
            "weight": 4
        }
    }

def register(app):
    return { "tool": CustomSupports.CustomSupports() }
