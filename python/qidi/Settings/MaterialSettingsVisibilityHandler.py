# Copyright (c) 2017 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

import QD.Settings.Models.SettingVisibilityHandler


class MaterialSettingsVisibilityHandler(QD.Settings.Models.SettingVisibilityHandler.SettingVisibilityHandler):
    def __init__(self, parent = None, *args, **kwargs):
        super().__init__(parent = parent, *args, **kwargs)

        material_settings = {
            #"material_print_temperature",
            "default_material_print_temperature",
            "build_volume_temperature",
            "default_material_bed_temperature",
            #"material_bed_temperature",
            "material_standby_temperature",
            "material_bed_temperature_layer_0",
            #"material_initial_print_temperature",
            #"material_flow_temp_graph",
            "cool_fan_speed",
            "retraction_amount",
            "retraction_speed",
        }

        self.setVisible(material_settings)
