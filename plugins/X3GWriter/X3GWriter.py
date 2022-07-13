# Copyright (c) 2015 Malyan
# Cura is released under the terms of the AGPLv3 or higher.

from UM.Mesh.MeshWriter import MeshWriter
from UM.Logger import Logger
from UM.Application import Application
import io
import subprocess
import os
from UM.Platform import Platform

import tempfile
import UM.PluginRegistry

class X3GWriter(MeshWriter):
    def __init__(self):
        super().__init__()
        self._gcode = None

    def write(self, stream, node, mode = MeshWriter.OutputMode.TextMode):
        #Get the g-code.
        scene = Application.getInstance().getController().getScene()
        active_build_plate = Application.getInstance().getMultiBuildPlateModel().activeBuildPlate
        gcode_dict = getattr(scene, "gcode_dict")
        gcode_list = gcode_dict.get(active_build_plate, None)
        if not gcode_list:
            return False

        #Find an unused file name to temporarily write the g-code to.
        file_name = stream.name
        if not file_name: #Not a file stream.
            Logger.log("e", "X3G writer can only write to local files.")
            return False
        file_directory = os.path.dirname(os.path.realpath(file_name)) #Save the tempfile next to the real output file.
        i = 0
        temp_file = os.path.join(file_directory , "output" + str(i) + ".gcode")
        temp_x3g = os.path.join(file_directory , "output" + str(i) + ".x3g")
        while os.path.isfile(temp_file):
            i += 1
            temp_file = os.path.join(file_directory , "output" + str(i) + ".gcode")

        Logger.log("d","temp_file:" + temp_file)
        #Write the g-code to the temporary file.
        try:
            with open(temp_file, "w", -1, "utf-8") as f:
                for gcode in gcode_list:
                    f.write(gcode)
        except:
            Logger.log("e", "Error writing temporary g-code file %s", temp_file)
            _removeTemporary(temp_file)
            return False

        #Call the converter application to convert it to X3G.
        Logger.log("d", "App path: %s", os.getcwd())
        Logger.log("d", "File name: %s", file_name)
        binary_path = os.path.dirname(os.path.realpath(__file__))
        if Platform.isWindows():
            binary_filename = os.path.join(binary_path, "gpx.exe")
        elif Platform.isOSX():
            binary_filename = os.path.join(binary_path, "gpx_MAC")
        else:
            binary_filename = os.path.join(binary_path, "gpx_linux")
        #https://github.com/markwal/GPX
       #

        if Platform.isWindows():
            command = [binary_filename, "-p", "-m", "r2x", "-c",
                       os.path.join(binary_path, "r2x.ini") ,
                        temp_file , temp_x3g ]
            safes = [os.path.expandvars(p) for p in command]
        else:
            command = ['"' + binary_filename + '"', "-p", "-m", "r2x", "-c",
                       '"' + os.path.join(binary_path, "r2x.ini") + '"',
                       '"' + temp_file + '"', '"' + temp_x3g + '"']             #防止文件名称中的空格
            command = ' '.join(command)         #MAC下的subprocess.Popen好像会把list都当成独立的命令来运行，
            safes = [command]
        Logger.log("d", "Command: %s", str(safes))
        stream.close() #Close the file so that the binary can write to it.
        try:
            process = subprocess.Popen(safes, shell=True)
            process.wait()
            output = process.communicate(b'y')
            Logger.log("d", str(output))
        except Exception as e:
            Logger.log("e", "System call to X3G converter application failed: %s", str(e))
            _removeTemporary(temp_file)
            _removeTemporary(temp_x3g)
            return False

        _removeTemporary(temp_file)
        _renameTemporary(temp_x3g,file_name)
        return True

##  Removes the temporary g-code file that is an intermediary result.
#
#   This should be called at the end of the write, also if the write failed.
#
#   \param temp_file The URI of the temporary file.
def _removeTemporary(temp_file):
    try:
        os.remove(temp_file)
    except:
        Logger.log("w", "Couldn't remove temporary file %s", temp_file)

def _renameTemporary(temp_x3g,file_name):
    try:
        _removeTemporary(file_name)
        os.rename(temp_x3g,file_name)
    except:
        Logger.log("w", "Couldn't rename temporary file %s to %s", temp_x3g,file_name)
