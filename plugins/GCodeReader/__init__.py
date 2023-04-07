# Copyright (c) 2016 Aleph Objects, Inc.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import GCodeReader

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qidi")

def getMetaData():
    return {
        "mesh_reader": [
            {
                "extension": "gcode",
                "description": i18n_catalog.i18nc("@item:inlistbox", "G-code File")
            },
            {
                "extension": "g",
                "description": i18n_catalog.i18nc("@item:inlistbox", "G File")
            }
        ]
    }


def register(app):
    app.addNonSliceableExtension(".gcode")
    app.addNonSliceableExtension(".g")
    return {"mesh_reader": GCodeReader.GCodeReader()}
