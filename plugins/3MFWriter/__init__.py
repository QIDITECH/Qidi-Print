# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.
import sys

from QD.Logger import Logger
try:
    from . import ThreeMFWriter
except ImportError:
    Logger.log("w", "Could not import ThreeMFWriter; libSavitar may be missing")
from . import ThreeMFWorkspaceWriter

from QD.i18n import i18nCatalog
from QD.Platform import Platform

i18n_catalog = i18nCatalog("qidi")

def getMetaData():
    workspace_extension = "3mf"

    metaData = {}

    if "3MFWriter.ThreeMFWriter" in sys.modules:
        metaData["mesh_writer"] = {
            "output": [{
                "extension": "3mf",
                "description": i18n_catalog.i18nc("@item:inlistbox", "3MF file"),
                "mime_type": "application/vnd.ms-package.3dmanufacturing-3dmodel+xml",
                "mode": ThreeMFWriter.ThreeMFWriter.OutputMode.BinaryMode
            }]
        }
        metaData["workspace_writer"] = {
            "output": [{
                "extension": workspace_extension,
                "description": i18n_catalog.i18nc("@item:inlistbox", "QIDI Project 3MF file"),
                "mime_type": "application/vnd.ms-package.3dmanufacturing-3dmodel+xml",
                "mode": ThreeMFWorkspaceWriter.ThreeMFWorkspaceWriter.OutputMode.BinaryMode
            }]
        }

    return metaData

def register(app):
    if "3MFWriter.ThreeMFWriter" in sys.modules:
        return {"mesh_writer": ThreeMFWriter.ThreeMFWriter(), 
                "workspace_writer": ThreeMFWorkspaceWriter.ThreeMFWorkspaceWriter()}
    else:
        return {}
