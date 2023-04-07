# Copyright (c) 2021 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import CameraTool


def getMetaData():
    return {
        "tool": {
            "visible": False
        }
    }


def register(app):
    return {"tool": CameraTool.CameraTool()}
