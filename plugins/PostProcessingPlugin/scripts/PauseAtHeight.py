# Copyright (c) 2020 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from ..Script import Script

from QD.Application import Application #To get the current printer's settings.
from QD.Logger import Logger

from typing import List, Tuple

class PauseAtHeight(Script):
    def __init__(self) -> None:
        super().__init__()

    def getSettingDataString(self) -> str:
        return """{
            "name": "Pause at height",
            "key": "PauseAtHeight",
            "metadata": {},
            "version": 2,
            "settings":
            {
                "pause_at":
                {
                    "label": "Pause at",
                    "description": "Whether to pause at a certain height or at a certain layer.",
                    "type": "enum",
                    "options": {"height": "Height", "layer_no": "Layer Number"},
                    "default_value": "height"
                },
                "pause_height":
                {
                    "label": "Pause Height",
                    "description": "At what height should the pause occur?",
                    "unit": "mm",
                    "type": "float",
                    "default_value": 5.0,
                    "minimum_value": "0",
                    "minimum_value_warning": "0.27",
                    "enabled": "pause_at == 'height'"
                },
                "pause_layer":
                {
                    "label": "Pause Layer",
                    "description": "At what layer should the pause occur",
                    "type": "int",
                    "value": "math.floor((pause_height - 0.27) / 0.1) + 1",
                    "minimum_value": "0",
                    "minimum_value_warning": "1",
                    "enabled": "pause_at == 'layer_no'"
                },
                "custom_gcode_before_pause":
                {
                    "label": "G-code Before Pause",
                    "description": "Any custom g-code to run before the pause, for example, M300 S440 P200 to beep.",
                    "type": "str",
                    "default_value": ""
                },
                "custom_gcode_after_pause":
                {
                    "label": "G-code After Pause",
                    "description": "Any custom g-code to run after the pause, for example, M300 S440 P200 to beep.",
                    "type": "str",
                    "default_value": ""
                }
            }
        }"""

    ##  Copy machine name and gcode flavor from global stack so we can use their value in the script stack
    def initialize(self) -> None:
        super().initialize()

        global_container_stack = Application.getInstance().getGlobalContainerStack()
        if global_container_stack is None or self._instance is None:
            return

        for key in ["machine_name", "machine_gcode_flavor"]:
            self._instance.setProperty(key, "value", global_container_stack.getProperty(key, "value"))

    ##  Get the X and Y values for a layer (will be used to get X and Y of the
    #   layer after the pause).
    def getNextXY(self, layer: str) -> Tuple[float, float]:
        """Get the X and Y values for a layer (will be used to get X and Y of the layer after the pause)."""
        lines = layer.split("\n")
        for line in lines:
            if line.startswith(("G0", "G1", "G2", "G3")):
                if self.getValue(line, "X") is not None and self.getValue(line, "Y") is not None:
                    x = self.getValue(line, "X")
                    y = self.getValue(line, "Y")
                    return x, y
        return 0, 0

    def execute(self, data: List[str]) -> List[str]:
        """Inserts the pause commands.

        :param data: List of layers.
        :return: New list of layers.
        """
        pause_at = self.getSettingValueByKey("pause_at")
        pause_height = self.getSettingValueByKey("pause_height")
        pause_layer = self.getSettingValueByKey("pause_layer")
        """
        disarm_timeout = self.getSettingValueByKey("disarm_timeout")
        retraction_amount = self.getSettingValueByKey("retraction_amount")
        retraction_speed = self.getSettingValueByKey("retraction_speed")
        extrude_amount = self.getSettingValueByKey("extrude_amount")
        extrude_speed = self.getSettingValueByKey("extrude_speed")
        park_x = self.getSettingValueByKey("head_park_x")
        park_y = self.getSettingValueByKey("head_park_y")
        move_z = self.getSettingValueByKey("head_move_z")
        layers_started = False
        redo_layer = self.getSettingValueByKey("redo_layer")
        standby_temperature = self.getSettingValueByKey("standby_temperature")
        firmware_retract = Application.getInstance().getGlobalContainerStack().getProperty("machine_firmware_retract", "value")
        control_temperatures = Application.getInstance().getGlobalContainerStack().getProperty("machine_nozzle_temp_enabled", "value")
        initial_layer_height = Application.getInstance().getGlobalContainerStack().getProperty("layer_height_0", "value")
        display_text = self.getSettingValueByKey("display_text")
        pause_method = self.getSettingValueByKey("pause_method")
        pause_command = {
            "marlin": self.putValue(M = 0),
            "griffin": self.putValue(M = 0),
            "bq": self.putValue(M = 25),
            "reprap": self.putValue(M = 226),
            "repetier": self.putValue("@pause now change filament and press continue printing")
        }[pause_method]
        """
        retraction_amount = 3#self.getSettingValueByKey("retraction_amount")
        retraction_speed = 100#self.getSettingValueByKey("retraction_speed")
        extrude_amount = 4#self.getSettingValueByKey("extrude_amount")
        extrude_speed = 4#self.getSettingValueByKey("extrude_speed")
        park_x = 20#self.getSettingValueByKey("head_park_x")
        park_y = 20#self.getSettingValueByKey("head_park_y")
        layers_started = False
        # redo_layers = self.getSettingValueByKey("redo_layers")
        standby_temperature = 0#self.getSettingValueByKey("standby_temperature")
        resume_temperature = 0#self.getSettingValueByKey("resume_temperature")
        currentExtrude = 0
        feedrate = 3600
        # T = ExtruderManager.getInstance().getActiveExtruderStack().getProperty("material_print_temperature", "value")

        # use offset to calculate the current height: <current_height> = <current_z> - <layer_0_z>
        layer_0_z = 0
        current_z = 0
        current_height = 0
        current_layer = 0
        current_extrusion_f = 0
        got_first_g_cmd_on_layer_0 = False
        current_t = 0 #Tracks the current extruder for tracking the target temperature.
        target_temperature = {} #Tracks the current target temperature for each extruder.
        gcode_before = self.getSettingValueByKey("custom_gcode_before_pause")
        gcode_after = self.getSettingValueByKey("custom_gcode_after_pause")

        nbr_negative_layers = 0

        for index, layer in enumerate(data):
            lines = layer.split("\n")

            # Scroll each line of instruction for each layer in the G-code
            for line in lines:
                # Fist positive layer reached
                if ";LAYER:0" in line:
                    layers_started = True
                # Count nbr of negative layers (raft)
                elif ";LAYER:-" in line:
                    nbr_negative_layers += 1

                #Track the latest printing temperature in order to resume at the correct temperature.
                if line.startswith("T"):
                    current_t = self.getValue(line, "T")
                m = self.getValue(line, "M")
                if m is not None and (m == 104 or m == 109) and self.getValue(line, "S") is not None:
                    extruder = current_t
                    if self.getValue(line, "T") is not None:
                        extruder = self.getValue(line, "T")
                    target_temperature[extruder] = self.getValue(line, "S")

                if not layers_started:
                    continue

                # Look for the feed rate of an extrusion instruction
                if self.getValue(line, "F") is not None and self.getValue(line, "E") is not None:
                    current_extrusion_f = self.getValue(line, "F")

                # If a Z instruction is in the line, read the current Z
                if self.getValue(line, "Z") is not None:
                    current_z = self.getValue(line, "Z")

                if pause_at == "height":
                    # Ignore if the line is not G1 or G0
                    if self.getValue(line, "G") != 1 and self.getValue(line, "G") != 0:
                        continue

                    # This block is executed once, the first time there is a G
                    # command, to get the z offset (z for first positive layer)
                    if not got_first_g_cmd_on_layer_0:
                        layer_0_z = current_z
                        got_first_g_cmd_on_layer_0 = True

                    current_height = current_z - layer_0_z
                    if current_height < pause_height:
                        continue  # Scan the enitre layer, z-changes are not always on the same/first line.

                # Pause at layer
                else:
                    if not line.startswith(";LAYER:"):
                        continue
                    current_layer = line[len(";LAYER:"):]
                    try:
                        current_layer = int(current_layer)

                    # Couldn't cast to int. Something is wrong with this
                    # g-code data
                    except ValueError:
                        continue
                    if current_layer < pause_layer - nbr_negative_layers:
                        continue

                prev_layer = data[index - 1]
                prev_lines = prev_layer.split("\n")
                current_e = 0.

                # Access last layer, browse it backwards to find
                # last extruder absolute position
                for prevLine in reversed(prev_lines):
                    current_e = self.getValue(prevLine, "E", -1)
                    if current_e >= 0:
                        break
                # and also find last X,Y
                for prevLine in reversed(prev_lines):
                    if prevLine.startswith(("G0", "G1", "G2", "G3")):
                        if self.getValue(prevLine, "X") is not None and self.getValue(prevLine, "Y") is not None:
                            x = self.getValue(prevLine, "X")
                            y = self.getValue(prevLine, "Y")
                            break

                # Maybe redo the last layer.

                prepend_gcode = ";TYPE:CUSTOM\n"
                prepend_gcode += ";added code by post processing\n"
                prepend_gcode += ";script: PauseAtHeight.py\n"
                if pause_at == "height":
                    prepend_gcode += ";current z: {z}\n".format(z = current_z)
                    prepend_gcode += ";current height: {height}\n".format(height = current_height)
                else:
                    prepend_gcode += ";current layer: {layer}\n".format(layer = current_layer)

                    # Retraction
                  



                # Set the disarm timeout
                #if disarm_timeout > 0:
                #    prepend_gcode += self.putValue(M = 18, S = disarm_timeout) + " ; Set the disarm timeout\n"

                # Set a custom GCODE section before pause
                if gcode_before:
                    prepend_gcode += gcode_before + "\n"

                # Wait till the user continues printing
                prepend_gcode += "M300 I9000 ;Buzzer sounds\n"
                prepend_gcode += "M0" + " ; Do the actual pause\n"

                # Set a custom GCODE section before pause
                if gcode_after:
                    prepend_gcode += gcode_after + "\n"


                layer = prepend_gcode + layer

                # Override the data of this layer with the
                # modified data
                data[index] = layer
                return data
        return data
