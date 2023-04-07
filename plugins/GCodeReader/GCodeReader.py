# Copyright (c) 2017 Aleph Objects, Inc.
# Copyright (c) 2020 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import Optional, Union, List, TYPE_CHECKING
from QD.Logger import Logger
from QD.FileHandler.FileReader import FileReader
from QD.Mesh.MeshReader import MeshReader
from QD.i18n import i18nCatalog
from QD.Application import Application
from QD.MimeTypeDatabase import MimeTypeDatabase, MimeType
import os
import stat
import subprocess
import locale
import re
catalog = i18nCatalog("qidi")
from QD.Platform import Platform
from QD.Resources import  Resources

from .FlavorParser import FlavorParser
from . import MarlinFlavorParser, RepRapFlavorParser

if TYPE_CHECKING:
    from QD.Scene.SceneNode import SceneNode
    from qidi.Scene.QIDISceneNode import QIDISceneNode


# Class for loading and parsing G-code files
class GCodeReader(MeshReader):
    _flavor_default = "Marlin"
    _flavor_keyword = ";FLAVOR:"
    _flavor_readers_dict = {"RepRap" : RepRapFlavorParser.RepRapFlavorParser(),
                            "Marlin" : MarlinFlavorParser.MarlinFlavorParser()}

    def __init__(self) -> None:
        super().__init__()
        MimeTypeDatabase.addMimeType(
            MimeType(
                name = "application/x-qidi-gcode-file",
                comment = "QIDI G-code File",
                suffixes = ["gcode"]
            )
        )
        self._supported_extensions = [".gcode", ".g"]
        if Platform.isWindows():
            arcwelder_executable = "bin/win64/ArcStraightener.exe"
        elif Platform.isLinux():
            arcwelder_executable = "bin/linux/ArcStraightener"
        elif Platform.isOSX():
            arcwelder_executable = "bin/osx/ArcStraightener"
        self._arcwelder_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), arcwelder_executable
        )
        if not Platform.isWindows():
            try:
                os.chmod(
                    self._arcwelder_path,
                    stat.S_IXUSR
                    | stat.S_IRUSR
                    | stat.S_IRGRP
                    | stat.S_IROTH
                    | stat.S_IWUSR,
                )  # Make sure we have the rights to run this.
            except:
                Logger.logException("e", "Could modify rights of ArcStraightener executable")
                return

        if Platform.isWindows():
            startupinfo = subprocess.STARTUPINFO()
            startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        else:
            startupinfo = None

        version_output = subprocess.check_output(
            [self._arcwelder_path, "--version"], startupinfo=startupinfo
        ).decode(locale.getpreferredencoding())

        match = re.search("version: (.*)", version_output)
        if match:
            Logger.log("d", "Using ArcStraightener %s" % match.group(1))
        else:
            Logger.log("w", "Could not determine ArcStraightener version")

        self._flavor_reader = None  # type: Optional[FlavorParser]

        Application.getInstance().getPreferences().addPreference("gcodereader/show_caution", True)

    def preReadFromStream(self, stream, *args, **kwargs):
        for line in stream.split("\n"):
            if line[:len(self._flavor_keyword)] == self._flavor_keyword:
                try:
                    self._flavor_reader = self._flavor_readers_dict[line[len(self._flavor_keyword):].rstrip()]
                    return FileReader.PreReadResult.accepted
                except:
                    # If there is no entry in the dictionary for this flavor, just skip and select the by-default flavor
                    break

        # If no flavor is found in the GCode, then we use the by-default
        self._flavor_reader = self._flavor_readers_dict[self._flavor_default]
        return FileReader.PreReadResult.accepted

    # PreRead is used to get the correct flavor. If not, Marlin is set by default
    def preRead(self, file_name, *args, **kwargs):
        with open(file_name, "r", encoding = "utf-8") as file:
            file_data = file.read()
        return self.preReadFromStream(file_data, args, kwargs)

    def readFromStream(self, stream: str, filename: str) -> Optional["QIDISceneNode"]:
        if self._flavor_reader is None:
            return None
        return self._flavor_reader.processGCodeStream(stream, filename)

    def _read(self, file_name: str) -> Union["SceneNode", List["SceneNode"]]:

        command_arguments = [
            self._arcwelder_path,
            "--mm-per-arc-segment=0.5" 
        ]
        command_arguments.append(file_name)
        temp_file_name = Resources.getStoragePath(Resources.Resources, "temp.gcode")
        command_arguments.append(temp_file_name)
        Logger.log(
            "d",
            "Running ArcStraightener with the following options: %s" % command_arguments,
        )
        if Platform.isWindows():
            startupinfo = subprocess.STARTUPINFO()
            startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW
        else:
            startupinfo = None
        process_output = subprocess.check_output(
            command_arguments, startupinfo=startupinfo
        ).decode(locale.getpreferredencoding())

        Logger.log("d", process_output)

        with open(temp_file_name, "r", encoding = "utf-8") as file:
            file_data = file.read()
        os.remove(temp_file_name)
        result = []  # type: List[SceneNode]
        node = self.readFromStream(file_data, file_name)
        if node is not None:
            result.append(node)
        return result
