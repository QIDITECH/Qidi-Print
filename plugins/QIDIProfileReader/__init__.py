# Copyright (c) 2015 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import QIDIProfileReader

from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

def getMetaData():
    return {
        "profile_reader": [
            {
                "extension": "qidiprofile",
                "description": catalog.i18nc("@item:inlistbox", "QIDI Profile")
            }
        ]
    }

def register(app):
    return { "profile_reader": QIDIProfileReader.QIDIProfileReader() }
