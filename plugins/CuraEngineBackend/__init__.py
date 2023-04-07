# Copyright (c) 2015 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

#Shoopdawoop
from . import CuraEngineBackend

from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

def getMetaData():
    return {}

def register(app):
    return { "backend": CuraEngineBackend.CuraEngineBackend() }

