# Copyright (c) 2017 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import QObject, pyqtSignal, pyqtProperty

from QD.Application import Application


class SimpleModeSettingsManager(QObject):

    def __init__(self, parent = None):
        super().__init__(parent)

        self._machine_manager = Application.getInstance().getMachineManager()
        self._is_profile_customized = False  # True when default profile has user changes
        self._is_profile_user_created = False  # True when profile was custom created by user

        self._machine_manager.activeStackValueChanged.connect(self._updateIsProfileCustomized)

        # update on create as the activeQualityChanged signal is emitted before this manager is created when QIDI starts
        self._updateIsProfileCustomized()

    isProfileCustomizedChanged = pyqtSignal()

    @pyqtProperty(bool, notify = isProfileCustomizedChanged)
    def isProfileCustomized(self):
        return self._is_profile_customized

    def _updateIsProfileCustomized(self):
        user_setting_keys = set()

        if not self._machine_manager.activeMachine:
            return False

        global_stack = self._machine_manager.activeMachine

        # check user settings in the global stack
        user_setting_keys.update(global_stack.userChanges.getAllKeys())

        # check user settings in the extruder stacks
        if global_stack.extruderList:
            for extruder_stack in global_stack.extruderList:
                user_setting_keys.update(extruder_stack.userChanges.getAllKeys())

        # remove settings that are visible in recommended (we don't show the reset button for those)
        for skip_key in self.__ignored_custom_setting_keys:
            if skip_key in user_setting_keys:
                user_setting_keys.remove(skip_key)

        has_customized_user_settings = len(user_setting_keys) > 0

        if has_customized_user_settings != self._is_profile_customized:
            self._is_profile_customized = has_customized_user_settings
            self.isProfileCustomizedChanged.emit()

    # These are the settings included in the Simple ("Recommended") Mode, so only when the other settings have been
    # changed, we consider it as a user customized profile in the Simple ("Recommended") Mode.
    __ignored_custom_setting_keys = ["support_enable",
                                     "infill_sparse_density",
                                     "gradual_infill_steps",
                                     "adhesion_type",
                                     "support_extruder_nr"]
