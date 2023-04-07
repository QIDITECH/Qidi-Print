# Copyright (c) 2020 Ultimaker B.V.
# Cura is released under the terms of the LGPLv3 or higher.
# Created by Wayne Porter

from ..Script import Script
from qidi.Settings.ExtruderManager import ExtruderManager
from QD.Logger import Logger


class TimeLapse(Script):
    def __init__(self):
        super().__init__()

    def getSettingDataString(self):
        return """{
            "name": "Time Lapse",
            "key": "TimeLapse",
            "metadata": {},
            "version": 2,
            "settings":
            {
                "pause_length":
                {
                    "label": "Pause length",
                    "description": "How long to wait (in ms) after camera was triggered.",
                    "type": "int",
                    "default_value": 700,
                    "minimum_value": 0,
                    "unit": "ms"
                },
                "head_park_x":
                {
                    "label": "Park Print Head X",
                    "description": "What X location does the head move to for photo.",
                    "unit": "mm",
                    "type": "float",
                    "default_value": 10.0
                },
                "head_park_y":
                {
                    "label": "Park Print Head Y",
                    "description": "What Y location does the head move to for photo.",
                    "unit": "mm",
                    "type": "float",
                    "default_value": 10.0
                },
                "park_feed_rate":
                {
                    "label": "Park Feed Rate",
                    "description": "How fast does the head move to the park coordinates.",
                    "unit": "mm/s",
                    "type": "float",
                    "default_value": 6000
                },
                "retract":
                {
                    "label": "Retraction Distance",
                    "description": "Filament retraction distance for camera trigger.",
                    "unit": "mm",
                    "type": "int",
                    "default_value": 3
                },
                "zhop":
                {
                    "label": "Z-Hop Height When Parking",
                    "description": "Z-hop length before parking",
                    "unit": "mm",
                    "type": "float",
                    "default_value": 0
                }
            }
        }"""

    def execute(self, data):
        feed_rate = self.getSettingValueByKey("park_feed_rate")
        x_park = self.getSettingValueByKey("head_park_x")
        y_park = self.getSettingValueByKey("head_park_y")
        pause_length = self.getSettingValueByKey("pause_length")
        retract = int(self.getSettingValueByKey("retract"))
        zhop = self.getSettingValueByKey("zhop")
        limited_stack = ExtruderManager.getInstance().getActiveExtruderStacks()[0]
        retract_speed=limited_stack.getProperty("retraction_speed", "value")
        gcode_to_append = ";TimeLapse Begin\n"
        last_x = 0.0
        last_y = 0.0
        last_z = 0.0
        last_e = 0.0
        
        gcode_to_append += self.putValue(G=1, F=feed_rate,
                                             X=x_park, Y=y_park) + " ;Park print head\n"
        gcode_to_append += self.putValue(G=4, P=pause_length) + " ;Wait for camera\n"


        for idx, layer in enumerate(data):
            for line in layer.split("\n"):
                if self.getValue(line, "G") in {0, 1}:  # Track X,Y,Z location.
                    last_x = self.getValue(line, "X", last_x)
                    last_y = self.getValue(line, "Y", last_y)
                    last_z = self.getValue(line, "Z", last_z)
                    last_e = self.getValue(line, "E", last_e)
            # Check that a layer is being printed
            lines = layer.split("\n")
            for line in lines:
                if ";LAYER:" in line:
                    if retract != 0: # Retract the filament so no stringing happens
                        layer += self.putValue(G=1, E=last_e-retract, F=retract_speed*60) + " ;Retract filament\n"

                    if zhop != 0:
                        layer += self.putValue(G=1, Z=last_z+zhop, F=3000) + " ;Z-Hop\n"

                    layer += gcode_to_append

                    if zhop != 0:
                        layer += self.putValue(G=0, X=last_x, Y=last_y, Z=last_z) + "; Restore position \n"
                    else:
                        layer += self.putValue(G=0, X=last_x, Y=last_y) + "; Restore position \n"

                    if retract != 0:
                        layer += self.putValue(G=1, E=last_e, F=retract_speed*60) + " ;Retract filament\n"

                    data[idx] = layer
                    break
        return data
