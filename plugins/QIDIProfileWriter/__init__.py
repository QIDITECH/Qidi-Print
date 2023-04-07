# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import QIDIProfileWriter

from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

def getMetaData():
    return {
        "profile_writer": [
            {
                "extension": "qidiprofile",
                "description": catalog.i18nc("@item:inlistbox", "QIDI Profile")
            }
        ]
    }

def register(app):
    return { "profile_writer": QIDIProfileWriter.QIDIProfileWriter() }
