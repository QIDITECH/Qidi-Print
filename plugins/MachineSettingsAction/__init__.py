# Copyright (c) 2016 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import MachineSettingsAction


def getMetaData():
    return {}

def register(app):
    return { "machine_action": MachineSettingsAction.MachineSettingsAction() }
