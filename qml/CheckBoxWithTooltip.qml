// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1

import QD 1.3 as QD

CheckBox
{
    id: checkbox
    hoverEnabled: true

    property alias tooltip: tooltip.text

    indicator: Rectangle
    {
        implicitWidth: QD.Theme.getSize("checkbox").width
        implicitHeight: QD.Theme.getSize("checkbox").height
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        color: QD.Theme.getColor("main_background")
        radius: QD.Theme.getSize("checkbox_radius").width
        border.width: QD.Theme.getSize("default_lining").width
        border.color: checkbox.hovered ? QD.Theme.getColor("checkbox_border_hover") : QD.Theme.getColor("checkbox_border")

        QD.RecolorImage
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(parent.width / 2.5)
            height: Math.round(parent.height / 2.5)
            sourceSize.height: width
            color: QD.Theme.getColor("checkbox_mark")
            source: QD.Theme.getIcon("Check")
            opacity: checkbox.checked
            Behavior on opacity { NumberAnimation { duration: 100; } }
        }
    }

    contentItem: Label
    {
        anchors
        {
            left: checkbox.indicator.right
            leftMargin: QD.Theme.getSize("narrow_margin").width
        }
        text: checkbox.text
        color: QD.Theme.getColor("checkbox_text")
        font: QD.Theme.getFont("default")
        renderType: Text.NativeRendering
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    ToolTip
    {
        id: tooltip
        text: ""
        delay: 500
        visible: text != "" && checkbox.hovered
    }
}
