# Copyright (c) 2015 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import SliceInfo


def getMetaData():
    return {}

def register(app):
    return { "extension": SliceInfo.SliceInfo()}