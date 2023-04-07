from QD.Application import Application
from QD.Logger import Logger
from . import SettingVisibilityHandler


class SettingPreferenceVisibilityHandlerForBasic(SettingVisibilityHandler.SettingVisibilityHandler):
    def __init__(self, parent = None, *args, **kwargs):
        super().__init__(parent = parent, *args, **kwargs)

        Application.getInstance().getPreferences().preferenceChanged.connect(self._onPreferencesChanged)
        self._onPreferencesChanged("general/visible_settings")

        self.visibilityChanged.connect(self._onVisibilityChanged)

    def _onPreferencesChanged(self, name):
        #if name != "general/visible_settings":
        #    return

        new_visible = set()
        visibility_string = "line_width;" \
                            "layer_height;" \
                            "infill_sparse_density;" \
                            "z_seam_type;" \
                            "extruder_tower_enable;" \
                            "ooze_wall_enabled;" \
                            "speed_print;" \
                            "speed_travel;" \
                            "material_print_temperature;" \
                            "material_bed_temperature;" \
                            "cool_fan_enabled;" \
                            "support_enable;" \
                            "support_extruder_nr;" \
                            "adhesion_type;" \
                            "adhesion_extruder_nr;"
        if visibility_string is None:
            return
        for key in visibility_string.split(";"):
            new_visible.add(key.strip())

        self.setVisible(new_visible)

    def _onVisibilityChanged(self):
        preference = ";".join(self.getVisible())
        #Application.getInstance().getPreferences().setValue("general/visible_settings", preference)
