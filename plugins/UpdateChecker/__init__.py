# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import UpdateChecker


def getMetaData():
    return {
    }

def register(app):
    return { "extension": UpdateChecker.UpdateChecker() }
