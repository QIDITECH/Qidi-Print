// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

// Header of the popup
QIDI.RoundedRectangle
{
    id: header

    property alias headerTitle: headerLabel.text
    property alias xPosCloseButton: closeButton.left

    height: QD.Theme.getSize("expandable_component_content_header").height
    color: QD.Theme.getColor("secondary")
    cornerSide: QIDI.RoundedRectangle.Direction.Up
    border.width: QD.Theme.getSize("default_lining").width
    border.color: QD.Theme.getColor("lining")
    radius: QD.Theme.getSize("default_radius").width

    Label
    {
        id: headerLabel
        text: ""
        font: QD.Theme.getFont("medium")
        renderType: Text.NativeRendering
        verticalAlignment: Text.AlignVCenter
        color: QD.Theme.getColor("small_button_text")
        height: parent.height

        anchors
        {
            topMargin: QD.Theme.getSize("default_margin").height
            left: parent.left
            leftMargin: QD.Theme.getSize("default_margin").height
        }
    }

    Button
    {
        id: closeButton
        width: QD.Theme.getSize("message_close").width
        height: QD.Theme.getSize("message_close").height
        hoverEnabled: true

        anchors
        {
            right: parent.right
            rightMargin: QD.Theme.getSize("default_margin").width
            verticalCenter: parent.verticalCenter
        }

        contentItem: QD.RecolorImage
        {
            anchors.fill: parent
            sourceSize.width: width
            color: closeButton.hovered ? QD.Theme.getColor("small_button_text_hover") : QD.Theme.getColor("small_button_text")
            source: QD.Theme.getIcon("Cancel")
        }

        background: Item {}

        onClicked: toggleContent() // Will hide the popup item
    }
}
