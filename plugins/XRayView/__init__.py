# Copyright (c) 2015 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import XRayView

from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

def getMetaData():
    return {
        "view": {
            "name": catalog.i18nc("@item:inlistbox", "X-Ray view"),
            "weight": 1
        }
    }

def register(app):
    return { "view": XRayView.XRayView() }
