# Copyright (c) 2015 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from QD.Platform import Platform
from QD.Logger import Logger


def getMetaData():
    return {}

def register(app):
    if Platform.isWindows():
        from . import WindowsRemovableDrivePlugin
        return { "output_device": WindowsRemovableDrivePlugin.WindowsRemovableDrivePlugin() }
    elif Platform.isOSX():
        from . import OSXRemovableDrivePlugin
        return { "output_device": OSXRemovableDrivePlugin.OSXRemovableDrivePlugin() }
    elif Platform.isLinux():
        from . import LinuxRemovableDrivePlugin
        return { "output_device": LinuxRemovableDrivePlugin.LinuxRemovableDrivePlugin() }
    else:
        Logger.log("e", "Unsupported system, thus no removable device hotplugging support available.")
        return { }
