# Copyright (c) 2018 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from QD.Application import Application
from QD.OutputDevice.OutputDevicePlugin import OutputDevicePlugin
from QD.i18n import i18nCatalog
from .LocalFileOutputDevice import LocalFileOutputDevice

catalog = i18nCatalog("qdtech")


class LocalFileOutputDevicePlugin(OutputDevicePlugin):
    """Implements an OutputDevicePlugin that provides a single instance of LocalFileOutputDevice"""

    def __init__(self):
        super().__init__()

        Application.getInstance().getPreferences().addPreference("local_file/last_used_type", "")
        Application.getInstance().getPreferences().addPreference("local_file/dialog_save_path", "")

    def start(self):
        self.getOutputDeviceManager().addProjectOutputDevice(LocalFileOutputDevice(add_to_output_devices = True))

    def stop(self):
        self.getOutputDeviceManager().removeProjectOutputDevice("local_file")