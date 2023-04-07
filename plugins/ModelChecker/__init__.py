# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import ModelChecker


def getMetaData():
    return {}

def register(app):
    return { "extension": ModelChecker.ModelChecker() }
