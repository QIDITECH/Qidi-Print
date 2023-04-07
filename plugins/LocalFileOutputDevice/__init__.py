# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import LocalFileOutputDevicePlugin


def getMetaData():
    return {
    }

def register(app):
    return { "output_device": LocalFileOutputDevicePlugin.LocalFileOutputDevicePlugin() }
