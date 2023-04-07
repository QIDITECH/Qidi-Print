# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

#Shoopdawoop
from . import ConsoleLogger


def getMetaData():
    return {}


def register(app):
    return { "logger": ConsoleLogger.ConsoleLogger() }
