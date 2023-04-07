# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import SelectionTool


def getMetaData():
    return {
        "tool": {
            "visible": False
        }
    }

def register(app):
    return { "tool": SelectionTool.SelectionTool() }
