// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2

import QD 1.4 as QD
import QIDI 1.1 as QIDI

QIDI.ActionButtonInControlpanel
{
    shadowEnabled: true
    shadowColor: enabled ? QD.Theme.getColor("gray_2"): QD.Theme.getColor("action_button_disabled_shadow")
    color: QD.Theme.getColor("gray_7")
    textColor: QD.Theme.getColor("secondary_button_text")
    outlineColor: "transparent"
    disabledColor: QD.Theme.getColor("action_button_disabled")
    textDisabledColor: QD.Theme.getColor("action_button_disabled_text")
    hoverColor: QD.Theme.getColor("gray_7")
}