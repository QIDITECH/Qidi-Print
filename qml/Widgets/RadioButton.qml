// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.0 as QIDI


//
// QIDI-style RadioButton.
//
RadioButton
{
    id: radioButton

    font: QD.Theme.getFont("default")

    background: Item
    {
        anchors.fill: parent
    }

    indicator: Rectangle
    {
        implicitWidth: QD.Theme.getSize("radio_button").width
        implicitHeight: QD.Theme.getSize("radio_button").height
        anchors.verticalCenter: parent.verticalCenter
        anchors.alignWhenCentered: false
        radius: width / 2
        border.width: QD.Theme.getSize("default_lining").width
        border.color: radioButton.hovered ? QD.Theme.getColor("small_button_text") : QD.Theme.getColor("small_button_text_hover")

        Rectangle
        {
            width: (parent.width / 2) | 0
            height: width
            anchors.centerIn: parent
            radius: width / 2
            color: radioButton.hovered ? QD.Theme.getColor("primary_button_hover") : QD.Theme.getColor("primary_button")
            visible: radioButton.checked
        }
    }

    contentItem: Label
    {
        verticalAlignment: Text.AlignVCenter
        leftPadding: radioButton.indicator.width + radioButton.spacing
        text: radioButton.text
        font: radioButton.font
        color: QD.Theme.getColor("text")
        renderType: Text.NativeRendering
    }
}
