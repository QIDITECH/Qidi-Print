// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2

import QD 1.4 as QD
import QIDI 1.1 as QIDI


QIDI.ActionButton
{
    shadowEnabled: true
    shadowColor: enabled ? QD.Theme.getColor("secondary_button_shadow"): QD.Theme.getColor("action_button_disabled_shadow")
    color: "transparent"
    textColor: QD.Theme.getColor("text_link")
    outlineColor: "transparent"
    disabledColor: QD.Theme.getColor("action_button_disabled")
    textDisabledColor: QD.Theme.getColor("action_button_disabled_text")
    hoverColor: "transparent"
    underlineTextOnHover: true
}
