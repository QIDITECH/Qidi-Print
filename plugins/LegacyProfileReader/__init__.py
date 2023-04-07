# Copyright (c) 2015 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import LegacyProfileReader

from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

def getMetaData():
    return {
        "profile_reader": [
            {
                "extension": "ini",
                "description": catalog.i18nc("@item:inlistbox", "QIDI 15.04 profiles")
            }
        ]
    }

def register(app):
    return { "profile_reader": LegacyProfileReader.LegacyProfileReader() }
