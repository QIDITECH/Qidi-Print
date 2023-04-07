# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import STLReader

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")

def getMetaData():
    return {
        "mesh_reader": [
            {
                "extension": "stl",
                "description": i18n_catalog.i18nc("@item:inlistbox", "STL File")
            }
        ]
    }


def register(app):
    return {"mesh_reader": STLReader.STLReader()}
