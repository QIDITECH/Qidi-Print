# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

import re  # For escaping characters in the settings.
import json
import copy
import math

from QD.Mesh.MeshWriter import MeshWriter
from QD.Logger import Logger
from QD.Application import Application
from QD.Settings.InstanceContainer import InstanceContainer
from qidi.Machines.ContainerTree import ContainerTree
from .ModelPreviewWriter import ModelPreviewWriter
from QD.i18n import i18nCatalog
from qidi.QIDIApplication import QIDIApplication

catalog = i18nCatalog("qidi")


class GCodeWriter(MeshWriter):
    """Writes g-code to a file.

    While this poses as a mesh writer, what this really does is take the g-code
    in the entire scene and write it to an output device. Since the g-code of a
    single mesh isn't separable from the rest what with rafts and travel moves
    and all, it doesn't make sense to write just a single mesh.

    So this plug-in takes the g-code that is stored in the root of the scene
    node tree, adds a bit of extra information about the profiles and writes
    that to the output device.
    """

    version = 3
    """The file format version of the serialised g-code.

    It can only read settings with the same version as the version it was
    written with. If the file format is changed in a way that breaks reverse
    compatibility, increment this version number!
    """

    escape_characters = {
        re.escape("\\"): "\\\\",  # The escape character.
        re.escape("\n"): "\\n",   # Newlines. They break off the comment.
        re.escape("\r"): "\\r"    # Carriage return. Windows users may need this for visualisation in their editors.
    }
    """Dictionary that defines how characters are escaped when embedded in
    g-code.

    Note that the keys of this dictionary are regex strings. The values are
    not.
    """

    _setting_keyword = ";SETTING_"

    def __init__(self):
        super().__init__(add_to_recent_files = False)
        self._application = Application.getInstance()

    def write(self, stream, nodes, mode = MeshWriter.OutputMode.TextMode):
        """Writes the g-code for the entire scene to a stream.

        Note that even though the function accepts a collection of nodes, the
        entire scene is always written to the file since it is not possible to
        separate the g-code for just specific nodes.

        :param stream: The stream to write the g-code to.
        :param nodes: This is ignored.
        :param mode: Additional information on how to format the g-code in the
            file. This must always be text mode.
        """

        if mode != MeshWriter.OutputMode.TextMode:
            Logger.log("e", "GCodeWriter does not support non-text mode.")
            self.setInformation(catalog.i18nc("@error:not supported", "GCodeWriter does not support non-text mode."))
            return False

        active_build_plate = Application.getInstance().getMultiBuildPlateModel().activeBuildPlate
        scene = Application.getInstance().getController().getScene()
        if not hasattr(scene, "gcode_dict"):
            self.setInformation(catalog.i18nc("@warning:status", "Please prepare G-code before exporting."))
            return False
        gcode_dict = getattr(scene, "gcode_dict")
        gcode_list = gcode_dict.get(active_build_plate, None)
        if gcode_list is not None:
            if ModelPreviewWriter().write(stream, nodes, mode) :
                gcode_list = self.gcodeListProcessing(gcode_list)
                # gcode_list = gcode_list
            has_settings = False
            for gcode in gcode_list:
                if gcode[:len(self._setting_keyword)] == self._setting_keyword:
                    has_settings = True
                stream.write(gcode)
            # Serialise the current container stack and put it at the end of the file.
            if not has_settings:
                settings = self._serialiseSettings(Application.getInstance().getGlobalContainerStack())
                stream.write(settings)
            return True

        self.setInformation(catalog.i18nc("@warning:status", "Please prepare G-code before exporting."))
        return False

    def gcodeListProcessing(self, gcode_list):
        if gcode_list[0].count(";QIDI TECH") > 0:
            return gcode_list
        gcode_list[0] += ";QIDI TECH\n"
        DEFAULT_QIDI_VERSION ="6.0.0"
        try:
            from qidi.QIDIVersion import QIDIVersion  # type: ignore
            if QIDIVersion == "":
                QIDIVersion = DEFAULT_QIDI_VERSION
            # Logger.log("d","QIDI Version: "+QIDIVersion)
        except ImportError:
            QIDIVersion = DEFAULT_QIDI_VERSION  # [CodeStyle: Reflecting imported value]
        stack = Application.getInstance().getGlobalContainerStack()  ####只能控制不随喷头变化的参数
        stack0 = Application.getInstance().getExtruderManager().getExtruderStack(0)
        stack1 = stack0
        # Logger.log("e",stack0.material.name)

        machine_name = stack.getProperty("machine_name", "value")
        first_extruder = "0"
        extruder_count = stack.getProperty("machine_extruder_count", "value")
        application = QIDIApplication.getInstance()
        gcode_list[0] += ";QIDI Version : "+QIDIVersion+"\n"
        gcode_list[0] += ";QIDI Machine : "+self._application.getGlobalContainerStack().getProperty("machine_name", "value").lower()+"\n"
        gcode_list[0] += ";Filament weight = ."+str(application.getPrintInformation().materialWeights[0])+".\n"
        gcode_list[0] += ";Filament name = "+stack0.material.name+"\n"

        used_extruder_count = len(Application.getInstance().getExtruderManager().getUsedExtruderStacks())
        if used_extruder_count > 1:
            stack1 = Application.getInstance().getExtruderManager().getExtruderStack(1)
            gcode_list[0] += ";QIDI Filament name2="+stack1.material.name+"\n"

        if machine_name in ["i-fast", "X-pro","QIDI I"]:
            first_extruder = str(int(self.getValue(gcode_list[1], "T", 0)))
            gcode_list[1] = self.doubleEStartGcodeProcessing(gcode_list[1], first_extruder, extruder_count, used_extruder_count)
            if used_extruder_count > 1:
                stack1 = Application.getInstance().getExtruderManager().getExtruderStack(1)
                gcode_list = self.annotationM105(gcode_list)
                gcode_list = self.switchEProcessing(gcode_list, stack, stack0, stack1)

        if stack.getProperty("chamber_cooling_fan_speed", "enabled"):
            if stack.getProperty("chamber_cooling_fan_speed", "value") != 0:
                gcode_list = self.chamberCoolingFan(gcode_list, stack)

        if stack.getProperty("rapid_cooling_fan_speed", "enabled"):
            if stack.getProperty("rapid_cooling_fan_speed", "value") != 0:
                gcode_list = self.rapidCoolingFan(gcode_list, stack)

        if stack.getProperty("z_offset", "value") != 0:
            gcode_list[1] = self.zOffset(gcode_list[1], stack.getProperty("z_offset", "value"))

        if stack.getProperty("print_in_advance", "value") and stack.getProperty("print_in_advance", "enabled"):
            gcode_list = self.printAdvance(gcode_list, first_extruder, stack, stack0, stack1)

        if stack.getProperty("abl_before_printing", "value"):
            gcode_list[1] = self.ABLBeforePrinting(gcode_list[1])

        if stack.getProperty("shutdown_after_printing", "value"):
            gcode_list[-1] = self.shutdownPrinter(gcode_list[-1])

        if stack0.getProperty("enable_travel_prime", "value") or stack1.getProperty("enable_travel_prime", "value"):
            gcode_list = self.travelPrime(gcode_list, stack, stack0, stack1, first_extruder)
        return gcode_list


    def getValue(self, line, key, default = None):
        if key not in line:
            return default
        else:
            subPart = line[line.find(key) + len(key):]
            m = re.search('^-?[0-9]+\\.?[0-9]*', subPart)
        try:
            return float(m.group(0))
        except:
            return default

    def travelPrime(self, gcode_list, stack, stack0, stack1, first_extruder = "0"):
        used_extruder = first_extruder
        machine_width = stack.getProperty("machine_width", "value")
        travel_prime_rate = [stack0.getProperty("travel_prime_rate", "value") / stack0.getProperty("speed_travel", "value") / 240,
                             stack1.getProperty("travel_prime_rate", "value") / stack1.getProperty("speed_travel", "value") / 240]
        prime_rate = [stack0.getProperty("travel_prime_rate_layer_0", "value") / stack0.getProperty("speed_travel", "value") / 240,
                      stack1.getProperty("travel_prime_rate_layer_0", "value") / stack1.getProperty("speed_travel", "value") / 240]
        retraction_speed = [str(stack0.getProperty("retraction_speed", "value") * 60), str(stack1.getProperty("retraction_speed", "value") * 60)]
        enable_travel_prime = [stack0.getProperty("enable_travel_prime", "value"), stack1.getProperty("enable_travel_prime", "value")]
        start_count = 0

        for count_layer, gcode_layer in enumerate(gcode_list[2:]):
            if gcode_layer.count(";LAYER:0"):
                start_count = count_layer + 2
                break

        for count_layer, gcode_layer in enumerate(gcode_list[start_count:]):
            if count_layer > 0:
                prime_rate = travel_prime_rate
            gcode_layer_list = gcode_layer.split(";TYPE")
            for count_type, gcode_type in enumerate(gcode_layer_list):
                if any(t in gcode_type for t in ["WALL-OUTER", "WALL-INNER", "SKIN"]) and enable_travel_prime[int(used_extruder)]:
                    gcode_type_list = gcode_type.split("G0")
                    travel_distance = 0
                    if gcode_type_list[0].count(" X") > 0:
                        last_XY_gcode = " X" + gcode_type_list[0].rsplit(" X", 1)[-1]
                        last_X = self.getValue(last_XY_gcode, " X", 0)
                        last_Y = self.getValue(last_XY_gcode, " Y", 0)
                    else:
                        continue

                    if gcode_type_list[0].count(" E") > 0:
                        last_E_gcode = " E" + gcode_type_list[0].rsplit(" E", 1)[-1]
                        last_E = self.getValue(last_E_gcode, " E", 0)
                    else:
                        continue

                    for count_G0_line, gcode_G0_line in enumerate(gcode_type_list[1:]):
                        next_X = self.getValue(gcode_G0_line, " X", 0)
                        next_Y = self.getValue(gcode_G0_line, " Y", 0)
                        travel_distance += math.sqrt((next_X - last_X) * (next_X - last_X) + (next_Y - last_Y) * (next_Y - last_Y))
                        last_X = next_X
                        last_Y = next_Y
                        if gcode_G0_line.count("G1") > 0:
                            if travel_distance > 3 and int(last_X) != 0 and int(last_X) != machine_width and gcode_G0_line.count("G92 E0") == 0:
                                if travel_distance > 275:
                                    travel_distance = 275
                                prime_e = travel_distance * prime_rate[int(used_extruder)]
                                travel_prime_gcode = "G1 E" + str(round(last_E + prime_e, 5)) +" F" + retraction_speed[int(used_extruder)] + "\nG92 E" + str(last_E)
                                gcode_G0_line = re.sub("G1", travel_prime_gcode + "\nG1", gcode_G0_line, 1)
                                gcode_type_list[count_G0_line + 1] = gcode_G0_line
                            travel_distance = 0
                            if gcode_G0_line.count(" X") > 0:
                                last_XY_gcode = " X" + gcode_G0_line.rsplit(" X", 1)[-1]
                                last_X = self.getValue(last_XY_gcode, " X", 0)
                                last_Y = self.getValue(last_XY_gcode, " Y", 0)
                            else:
                                continue

                            if gcode_G0_line.count(" E") > 0:
                                last_E_gcode = " E" + gcode_G0_line.rsplit(" E", 1)[-1]
                                last_E = self.getValue(last_E_gcode, " E", 0)
                            else:
                                continue

                    gcode_type = ("G0").join(gcode_type_list)
                    gcode_layer_list[count_type] = gcode_type

                    if count_type > 0:
                        last_XY_gcode = gcode_layer_list[count_type - 1].rsplit("G1", 1)[-1]
                        if last_XY_gcode.count("G0") > 0:
                            travel_distance = 0
                            last_gcode_list = last_XY_gcode.split("G0")
                            if last_gcode_list[0].count(" X") > 0:
                                last_X = self.getValue(last_gcode_list[0], " X", 0)
                                last_Y = self.getValue(last_gcode_list[0], " Y", 0)
                            else:
                                last_G1_gcode = " X" + gcode_layer_list[count_type - 1].rsplit("G1", 1)[0].rsplit(" X", 1)[-1]
                                last_X = self.getValue(last_G1_gcode, " X", 0)
                                last_Y = self.getValue(last_G1_gcode, " Y", 0)

                            if gcode_layer_list[count_type - 1].count(" E") > 0:
                                last_E_gcode = " E" + gcode_layer_list[count_type - 1].rsplit(" E", 1)[-1]
                                last_E = self.getValue(last_E_gcode, " E", 0)
                            else:
                                continue

                            for count_G0_line, gcode_G0_line in enumerate(last_gcode_list[1:]):
                                next_X = self.getValue(gcode_G0_line, " X", 0)
                                next_Y = self.getValue(gcode_G0_line, " Y", 0)
                                travel_distance += math.sqrt((next_X - last_X) * (next_X - last_X) + (next_Y - last_Y) * (next_Y - last_Y))
                                last_X = next_X
                                last_Y = next_Y
                            if travel_distance > 3:
                                if travel_distance > 275:
                                    travel_distance = 275
                                prime_e = travel_distance * prime_rate[int(used_extruder)]
                                travel_prime_gcode = "G1 E" + str(round(last_E + prime_e, 5)) +" F" + retraction_speed[int(used_extruder)] + "\nG92 E" + str(last_E) + "\n"
                                gcode_layer_list[count_type - 1] += travel_prime_gcode

                if gcode_type.count("\nT0\n") > 0:
                    used_extruder = "0"
                elif gcode_type.count("\nT1\n") > 0:
                    used_extruder = "1"

            gcode_layer = (";TYPE").join(gcode_layer_list)
            gcode_list[count_layer + start_count] = gcode_layer

        return gcode_list

    def doubleEStartGcodeProcessing(self, gcode, first_extruder = "0", extruder_count = 2, used_extruder_count = 2):
        gcode = re.sub("T.*?\nM82", ";T" + first_extruder + "\nM82", gcode)
        if used_extruder_count == 1:
            if first_extruder == "1":
                gcode = re.sub("M104 T0", ";M104 T0", gcode)
                gcode = re.sub("M109 T0", ";M109 T0", gcode)
                gcode = re.sub("T0\nG92 E.*?\n", "T0\nG92 E0\n", gcode)
            else:
                gcode = re.sub("M104 T1", ";M104 T1", gcode)
                gcode = re.sub("M109 T1", ";M109 T1", gcode)
                gcode = re.sub("T1\nG92 E.*?\n", "T1\nG92 E0\n", gcode)
        if first_extruder == "1":
            gcode = re.sub("G1 X5 E0 F2400", "G1 X5 E0 F2400\nT1\nG1 X5 E0 F2400", gcode)
        if extruder_count == 1:
            gcode = re.sub("\nT0\n", "\n;T0\n", gcode)
            gcode = re.sub("\nT1\n", "\n;T1\n", gcode)
        return gcode

    def annotationM105(self, gcode_list):
        for count, gcode in enumerate(gcode_list):
            gcode_list[count] = re.sub("M105", ";M105", gcode)
        return gcode_list

    def switchEProcessing(self, gcode_list, stack, stack0, stack1):
        standby_temperature_0 = str(stack0.getProperty("material_standby_temperature", "value"))
        standby_temperature_1 = str(stack1.getProperty("material_standby_temperature", "value"))
        for count, gcode in enumerate(gcode_list[2:]):
            if gcode.count("M104 T1 S") > 0:
                gcode = re.sub("\nT0\n", "\nM104 T1 S" + standby_temperature_1 + "\nT0\n", gcode)
                gcode_list[count + 2] = gcode
            if gcode.count("M104 T0 S") > 0:
                gcode = re.sub("\nT1\n", "\nM104 T0 S" + standby_temperature_0 + "\nT1\n", gcode)
                gcode_list[count + 2] = gcode
        return gcode_list

    def chamberCoolingFan(self, gcode_list, stack):
        chamber_cooling_fan_speed = str(round(stack.getProperty("chamber_cooling_fan_speed", "value") * 2.55))
        gcode_list[2] = "M106 T-2 S" + chamber_cooling_fan_speed + "\n" + gcode_list[2]
        gcode_list[-2] = gcode_list[-2] + "M106 T-2 S0\n"
        return gcode_list

    def rapidCoolingFan(self, gcode_list, stack):
        rapid_cool_fan_layer = stack.getProperty("cool_fan_full_layer", "value") + 1
        rapid_cooling_fan_speed = str(round(stack.getProperty("rapid_cooling_fan_speed", "value") * 2.55))
        gcode_list[rapid_cool_fan_layer] = "M106 P2 S" + rapid_cooling_fan_speed + "\n" + gcode_list[rapid_cool_fan_layer]
        gcode_list[-2] = gcode_list[-2] + "M106 P2 S0\n"
        return gcode_list

    def zOffset(self, gcode, z_offset):
        first_z = str(0.3 + z_offset)
        gcode = re.sub(" Z0.3", " Z" + first_z, gcode)
        gcode += ";ZOffset\nG92 Z0.3\n"
        return gcode

    def printAdvance(self, gcode_list, first_extruder, stack, stack0, stack1):
        first_gcode = gcode_list[2].split("G1 ", 1)[0]
        XY_code = " " + first_gcode.rsplit("G0 ", 1)[-1]
        _diffX = self.getValue(XY_code, " X", 0)
        _diffY = self.getValue(XY_code, " Y", 0)
        Z_code = " Z" + first_gcode.rsplit(" Z", 1)[-1]
        _diffZ = self.getValue(Z_code, " Z", 0)
        if _diffY != 0 and _diffX != 0:
            if first_extruder == "1":
                print_width = stack1.getProperty("line_width", "value") * stack1.getProperty("material_flow_layer_0", "value") / 100 * stack1.getProperty("initial_layer_line_width_factor", "value") / 100
                retraction_speed = str(stack1.getProperty("retraction_speed", "value") * 60)
                retraction_enable = stack1.getProperty("retraction_enable", "value")
                advance_speed = str(stack1.getProperty("speed_layer_0", "value") * 60)
            else:
                print_width = stack0.getProperty("line_width", "value") * stack0.getProperty("material_flow_layer_0", "value") / 100 * stack0.getProperty("initial_layer_line_width_factor", "value") / 100
                retraction_speed = str(stack0.getProperty("retraction_speed", "value") * 60)
                retraction_enable = stack0.getProperty("retraction_enable", "value")
                advance_speed = str(stack0.getProperty("speed_layer_0", "value") * 60)
            _diffE = math.sqrt((_diffX - 5) * (_diffX - 5) + (_diffY - 5) * (_diffY - 5)) * stack.getProperty("layer_height_0", "value") * print_width * 0.54
            _diffE = str(round(_diffE, 5))
            if stack.getProperty("relative_extrusion", "value"):
                first_print = ";Print in advance\nG1 F" + advance_speed + " X" + str(_diffX) + " Y" + str(_diffY) + " Z" + str(_diffZ) + " E" + _diffE + "\n"
            else:
                first_print = ";Print in advance\nG92 E-" + _diffE + "\nG1 F" + advance_speed + " X" + str(_diffX) + " Y" + str(_diffY) + " Z" + str(_diffZ) + " E0\n"
            first_gcode_list = first_gcode.split("\n", 10)
            for count, gcode in enumerate(first_gcode_list):
                if gcode.count("G0") > 0:
                    first_gcode_list[count] = ";" + gcode
            first_gcode = ("\n").join(first_gcode_list) + first_print
        ################预挤出前去掉第一次回抽
            if retraction_enable:
                gcode_list[1] = re.sub("G92 E0\n", ";G92 E0\n", gcode_list[1], 1)
                gcode_list[1] = re.sub("G1 F", ";G1 F", gcode_list[1], 1)
                first_gcode += ";"
            gcode_list[2] = first_gcode + "G1 " + gcode_list[2].split("G1 ", 1)[1]
        return gcode_list

    def ABLBeforePrinting(self, gcode):
        gcode = re.sub(";G29", "G29", gcode, 1)
        return gcode

    def shutdownPrinter(self, gcode):
        gcode = gcode + "M4003;shutdown\n"
        return gcode

    def _createFlattenedContainerInstance(self, instance_container1, instance_container2):
        """Create a new container with container 2 as base and container 1 written over it."""

        flat_container = InstanceContainer(instance_container2.getName())

        # The metadata includes id, name and definition
        flat_container.setMetaData(copy.deepcopy(instance_container2.getMetaData()))

        if instance_container1.getDefinition():
            flat_container.setDefinition(instance_container1.getDefinition().getId())

        for key in instance_container2.getAllKeys():
            flat_container.setProperty(key, "value", instance_container2.getProperty(key, "value"))

        for key in instance_container1.getAllKeys():
            flat_container.setProperty(key, "value", instance_container1.getProperty(key, "value"))

        return flat_container

    def _serialiseSettings(self, stack):
        """Serialises a container stack to prepare it for writing at the end of the g-code.

        The settings are serialised, and special characters (including newline)
        are escaped.

        :param stack: A container stack to serialise.
        :return: A serialised string of the settings.
        """
        container_registry = self._application.getContainerRegistry()

        prefix = self._setting_keyword + str(GCodeWriter.version) + " "  # The prefix to put before each line.
        prefix_length = len(prefix)

        quality_type = stack.quality.getMetaDataEntry("quality_type")
        container_with_profile = stack.qualityChanges
        machine_definition_id_for_quality = ContainerTree.getInstance().machines[stack.definition.getId()].quality_definition
        if container_with_profile.getId() == "empty_quality_changes":
            # If the global quality changes is empty, create a new one
            quality_name = container_registry.uniqueName(stack.quality.getName())
            quality_id = container_registry.uniqueName((stack.definition.getId() + "_" + quality_name).lower().replace(" ", "_"))
            container_with_profile = InstanceContainer(quality_id)
            container_with_profile.setName(quality_name)
            container_with_profile.setMetaDataEntry("type", "quality_changes")
            container_with_profile.setMetaDataEntry("quality_type", quality_type)
            if stack.getMetaDataEntry("position") is not None:  # For extruder stacks, the quality changes should include an intent category.
                container_with_profile.setMetaDataEntry("intent_category", stack.intent.getMetaDataEntry("intent_category", "default"))
            container_with_profile.setDefinition(machine_definition_id_for_quality)
            container_with_profile.setMetaDataEntry("setting_version", stack.quality.getMetaDataEntry("setting_version"))

        flat_global_container = self._createFlattenedContainerInstance(stack.userChanges, container_with_profile)
        # If the quality changes is not set, we need to set type manually
        if flat_global_container.getMetaDataEntry("type", None) is None:
            flat_global_container.setMetaDataEntry("type", "quality_changes")

        # Ensure that quality_type is set. (Can happen if we have empty quality changes).
        if flat_global_container.getMetaDataEntry("quality_type", None) is None:
            flat_global_container.setMetaDataEntry("quality_type", stack.quality.getMetaDataEntry("quality_type", "normal"))

        # Get the machine definition ID for quality profiles
        flat_global_container.setMetaDataEntry("definition", machine_definition_id_for_quality)

        serialized = flat_global_container.serialize()
        data = {"global_quality": serialized}

        all_setting_keys = flat_global_container.getAllKeys()
        for extruder in stack.extruderList:
            extruder_quality = extruder.qualityChanges
            if extruder_quality.getId() == "empty_quality_changes":
                # Same story, if quality changes is empty, create a new one
                quality_name = container_registry.uniqueName(stack.quality.getName())
                quality_id = container_registry.uniqueName((stack.definition.getId() + "_" + quality_name).lower().replace(" ", "_"))
                extruder_quality = InstanceContainer(quality_id)
                extruder_quality.setName(quality_name)
                extruder_quality.setMetaDataEntry("type", "quality_changes")
                extruder_quality.setMetaDataEntry("quality_type", quality_type)
                extruder_quality.setDefinition(machine_definition_id_for_quality)
                extruder_quality.setMetaDataEntry("setting_version", stack.quality.getMetaDataEntry("setting_version"))

            flat_extruder_quality = self._createFlattenedContainerInstance(extruder.userChanges, extruder_quality)
            # If the quality changes is not set, we need to set type manually
            if flat_extruder_quality.getMetaDataEntry("type", None) is None:
                flat_extruder_quality.setMetaDataEntry("type", "quality_changes")

            # Ensure that extruder is set. (Can happen if we have empty quality changes).
            if flat_extruder_quality.getMetaDataEntry("position", None) is None:
                flat_extruder_quality.setMetaDataEntry("position", extruder.getMetaDataEntry("position"))

            # Ensure that quality_type is set. (Can happen if we have empty quality changes).
            if flat_extruder_quality.getMetaDataEntry("quality_type", None) is None:
                flat_extruder_quality.setMetaDataEntry("quality_type", extruder.quality.getMetaDataEntry("quality_type", "normal"))

            # Change the default definition
            flat_extruder_quality.setMetaDataEntry("definition", machine_definition_id_for_quality)

            extruder_serialized = flat_extruder_quality.serialize()
            data.setdefault("extruder_quality", []).append(extruder_serialized)

            all_setting_keys.update(flat_extruder_quality.getAllKeys())

        # Check if there is any profiles
        if not all_setting_keys:
            Logger.log("i", "No custom settings found, not writing settings to g-code.")
            return ""

        json_string = json.dumps(data)

        # Escape characters that have a special meaning in g-code comments.
        pattern = re.compile("|".join(GCodeWriter.escape_characters.keys()))

        # Perform the replacement with a regular expression.
        escaped_string = pattern.sub(lambda m: GCodeWriter.escape_characters[re.escape(m.group(0))], json_string)

        # Introduce line breaks so that each comment is no longer than 80 characters. Prepend each line with the prefix.
        result = ""

        # Lines have 80 characters, so the payload of each line is 80 - prefix.
        for pos in range(0, len(escaped_string), 80 - prefix_length):
            result += prefix + escaped_string[pos: pos + 80 - prefix_length] + "\n"
        return result
