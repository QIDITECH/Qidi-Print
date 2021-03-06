from ..Script import Script
# from cura.Settings.ExtruderManager import ExtruderManager

class PauseAtHeight(Script):
    def __init__(self):
        super().__init__()

    def getSettingDataString(self):
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
                    "options": {"height": "Height", "layer_no": "Layer No."},
                    "default_value": "height"
                },
                "pause_height":
                {
                    "label": "Pause Height",
                    "description": "At what height should the pause occur",
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
                }
            }
        }"""


    '''
    

                "standby_temperature":
                {
                    "label": "Standby Temperature",
                    "description": "Change the temperature during the pause",
                    "unit": "°C",
                    "type": "int",
                    "default_value": 210
                },
                "resume_temperature":
                {
                    "label": "Resume Temperature",
                    "description": "Change the temperature after the pause",
                    "unit": "°C",
                    "type": "int",
                    "default_value": 200
                },

     "retraction_amount":
    {
        "label": "Retraction",
        "description": "How much filament must be retracted at pause.",
        "unit": "mm",
        "type": "float",
        "default_value": 0
    },
    "retraction_speed":
    {
        "label": "Retraction Speed",
        "description": "How fast to retract the filament.",
        "unit": "mm/s",
        "type": "float",
        "default_value": 80
    }
    "extrude_amount":
    {
        "label": "Extrude Amount",
        "description": "How much filament should be extruded after pause. This is needed when doing a material change on Ultimaker2's to compensate for the retraction after the change. In that case 128+ is recommended.",
        "unit": "mm",
        "type": "float",
        "default_value": 0
    },
    "extrude_speed":
    {
        "label": "Extrude Speed",
        "description": "How fast to extrude the material after pause.",
        "unit": "mm/s",
        "type": "float",
        "default_value": 80
    },

 
    '''
    def execute(self, data: list):

        """data is a list. Each index contains a layer"""

        x = 0.
        y = 0.
        current_z = 0.
        pause_at = self.getSettingValueByKey("pause_at")
        pause_height = self.getSettingValueByKey("pause_height")
        pause_layer = self.getSettingValueByKey("pause_layer")

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
        # with open("out.txt", "w") as f:
            # f.write(T)

        # use offset to calculate the current height: <current_height> = <current_z> - <layer_0_z>
        layer_0_z = 0.
        got_first_g_cmd_on_layer_0 = False

        print("=================PauseAtHeight plugin");

        for layer in data:
            lines = layer.split("\n")
            for line in lines:
                # print("================:")
                if ";LAYER:0" in line:
                    layers_started = True
                    continue

                if not layers_started:
                    continue

                if self.getValue(line, "Z") is not None:
                    current_z = self.getValue(line, "Z")

                if line.startswith("T"):
                    currentExtrude = self.getValue(line, "T")

                if self.getValue(line, "G") != 1 and self.getValue(line, "G") != 0:
                    x = self.getValue(line, "X", x)
                    y = self.getValue(line, "Y", y)
                    feedrate = self.getValue(line, "Y", feedrate)
                # print("pause_at:",pause_at)

                if pause_at == "height":
                    if self.getValue(line, "G") != 1 and self.getValue(line, "G") != 0:
                        continue

                    if not got_first_g_cmd_on_layer_0:
                        layer_0_z = current_z
                        got_first_g_cmd_on_layer_0 = True

                    current_height = current_z - layer_0_z
                    if current_height < pause_height:
                        continue
                        # break  # Try the next layer.
                else:  # Pause at layer.
                    # print("line:", line)
                    if not line.startswith(";LAYER:"):
                        continue

                    current_layer = line[len(";LAYER:"):]
                    try:
                        # print("........current_layer:",current_layer)
                        current_layer = int(current_layer)
                    except ValueError:  # Couldn't cast to int. Something is wrong with this g-code data.
                        continue
                    if current_layer < pause_layer:
                        continue
                        # break  # Try the next layer.


                index = data.index(layer)
                prevLayer = data[index - 1]
                prevLines = prevLayer.split("\n")
                current_e = 0.
                for prevLine in reversed(prevLines):
                    current_e = self.getValue(prevLine, 'E', -1)
                    if current_e >= 0:
                        break


                # include a number of previous layers
                # for i in range(1, redo_layers + 1):
                #     prevLayer = data[index - i]
                #     layer = prevLayer + layer

                prepend_gcode = ";TYPE:CUSTOM\n"
                prepend_gcode += ";added code by post processing\n"
                prepend_gcode += ";script: PauseAtHeight.py\n"
                prepend_gcode += ";current z: %f \n" % current_z
                # prepend_gcode += ";current height: %f \n" % current_height

                # Retraction
                # prepend_gcode += "M83\n"
                if False:#retraction_amount != 0:
                    prepend_gcode += "G1 E-%f F%f I0\n" % (retraction_amount, retraction_speed * 60)

                # Move the head away
                # prepend_gcode += "G1 Z%f F300\n" % (current_z + 1)
                if False:
                    prepend_gcode += "G1 X%f Y%f F9000\n" % (park_x, park_y)
                # if current_z < 15:
                #     prepend_gcode += "G1 Z15 F300\n"

                # Disable the E steppers
                if False:
                    prepend_gcode += "M84 E0\n"

                # Set extruder standby temperature
                if standby_temperature :

                    prepend_gcode += "M104 S%d T%d; standby temperature\n" % (standby_temperature,int(currentExtrude))

                # Wait till the user continues printing
                prepend_gcode += "M300 I9000 ;Buzzer sounds\n"
                prepend_gcode += "M0 ;Do the actual pause\n"

                # Set extruder resume temperature
                if resume_temperature and standby_temperature < resume_temperature:
                    prepend_gcode += "G1 X%f Y%f F9000\n" % (park_x, park_y)
                if resume_temperature:
                    prepend_gcode += "M109 S%d T%d; resume temperature\n" % (resume_temperature,int(currentExtrude))

                if resume_temperature and standby_temperature < resume_temperature:
                    # Push the filament back,
                    if False:#retraction_amount != 0:
                        prepend_gcode += "G1 E%f F%f I0\n" % (retraction_amount, retraction_speed * 60)

                    # Optionally extrude material
                    if extrude_amount != 0:
                        prepend_gcode += "G1 E%f F%f I0\n" % (extrude_amount, extrude_speed * 60)

                    # and retract again, the properly primes the nozzle
                    # when changing filament.
                    if retraction_amount != 0:
                        prepend_gcode += "G1 E-%f F%f I0\n" % (retraction_amount, retraction_speed * 60)

                    # Move the head back
                    # prepend_gcode += "G1 Z%f F300\n" % (current_z + 1)
                    prepend_gcode += "G1 X%f Y%f F9000\n" % (x, y)
                    if retraction_amount != 0:
                        prepend_gcode += "G1 E%f F%f I0\n" % (retraction_amount, retraction_speed * 60)

                    prepend_gcode += "G1 F%f\n"%(feedrate)
                    # prepend_gcode += "M82\n"

                    # reset extrude value to pre pause value
                    prepend_gcode += "G92 E%f\n" % (current_e)

                layer = prepend_gcode + layer


                # Override the data of this layer with the
                # modified data
                data[index] = layer
                return data

        return data
