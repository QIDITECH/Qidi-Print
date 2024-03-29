# Copyright (c) 2018 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import STLWriter

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")

def getMetaData():
    return {
        "mesh_writer": {
            "output": [
                {
                    "mime_type": "model/stl",
                    "mode": STLWriter.STLWriter.OutputMode.TextMode,
                    "extension": "stl",
                    "description": i18n_catalog.i18nc("@item:inlistbox", "STL File (ASCII)")
                },
                {
                    "mime_type": "model/stl",
                    "mode": STLWriter.STLWriter.OutputMode.BinaryMode,
                    "extension": "stl",
                    "description": i18n_catalog.i18nc("@item:inlistbox", "STL File (Binary)")
                }
            ]
        }
    }

def register(app):
    return { "mesh_writer": STLWriter.STLWriter() }
