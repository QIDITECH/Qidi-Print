# Copyright (c) 2020 Jaime van Kessel, QIDI B.V.
# The PostProcessingPlugin is released under the terms of the AGPLv3 or higher.

from . import PostProcessingPlugin


def getMetaData():
    return {}

def register(app):
    return {"extension": PostProcessingPlugin.PostProcessingPlugin()}