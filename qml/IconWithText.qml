// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

// Reusable component that holds an (re-colorable) icon on the left with some text on the right.
// This component is also designed to be used with layouts. It will use the width of the text + icon as preferred width
// It sets the icon size + half of the content as its minium width (in which case it will elide the text)
Item
{
    property alias source: icon.source
    property alias iconSize: icon.width
    property alias iconColor: icon.color
    property alias color: label.color
    property alias text: label.text
    property alias font: label.font
    property alias elide: label.elide
    property real margin: QD.Theme.getSize("narrow_margin").width

    // These properties can be used in combination with layouts.
    readonly property real contentWidth: icon.width + margin + label.contentWidth
    readonly property real minContentWidth: Math.round(icon.width + margin + 0.5 * label.contentWidth)

    Layout.minimumWidth: minContentWidth
    Layout.preferredWidth: contentWidth
    Layout.fillHeight: true
    Layout.fillWidth: true

    implicitWidth: icon.width + 100
    implicitHeight: icon.height

    QD.RecolorImage
    {
        id: icon
        width: QD.Theme.getSize("section_icon").width
        height: width

        color: QD.Theme.getColor("icon")

        anchors
        {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
    }

    Label
    {
        id: label
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        renderType: Text.NativeRendering
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter

        anchors
        {
            left: icon.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: 0
            margins: margin
        }
    }
}