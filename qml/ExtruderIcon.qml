// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.1
import QD 1.2 as QD

Item
{
    id: extruderIconItem

    implicitWidth: 30 * QD.Theme.getSize("size").width
    implicitHeight: 30 * QD.Theme.getSize("size").height
	property var extruderIndex
    property bool checked: true
    property color materialColor
    property alias textColor: extruderNumberText.color
    property bool extruderEnabled: true

    QD.RecolorImage
    {
        id: mainIcon
        anchors.fill: parent
        source: QD.Theme.getIcon("Extruder", "medium")
        color: extruderEnabled ? materialColor : QD.Theme.getColor("disabled")
    }

    Item
    {
        id: extruderNumberCircle

        width: height
        height: Math.round(parent.height / 2)

        anchors
        {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: (parent.height - height) / 2
        }

        Label
        {
            id: extruderNumberText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -3 * QD.Theme.getSize("size").height
            text: extruderIndex ? extruderIndex :model.name.replace("Extruder ", "")
            font: QD.Theme.getFont("font5")
            color: QD.Theme.getColor("black_1")
            width: contentWidth
            height: contentHeight
            visible: extruderEnabled
            renderType: Text.NativeRendering
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        QD.RecolorImage
        {
            id: disabledIcon
            anchors.horizontalCenter: extruderNumberText.horizontalCenter
            anchors.verticalCenter: extruderNumberText.verticalCenter
            width: 10 * QD.Theme.getSize("size").height
            height: 10 * QD.Theme.getSize("size").height
            sourceSize.height: width
            source: QD.Theme.getIcon("Cancel")
            visible: !extruderEnabled
            color: QD.Theme.getColor("text")
        }
    }
}
