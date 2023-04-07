// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QD 1.1 as QD

ButtonStyle
{
    background: Rectangle
    {
        implicitWidth: QD.Theme.getSize("toolbox_action_button").width
        implicitHeight: QD.Theme.getSize("toolbox_action_button").height
        color: "transparent"
        border
        {
            width: QD.Theme.getSize("default_lining").width
            color: QD.Theme.getColor("lining")
        }
    }
    label: Label
    {
        text: control.text
        color: QD.Theme.getColor("text")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}