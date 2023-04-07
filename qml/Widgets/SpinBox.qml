import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.1 as QD
import QIDI 1.1 as QIDI

SpinBox
{
    id: root

    property alias unit: unitLabel.text
	property alias text: content.text
    implicitWidth: 70 * QD.Theme.getSize("size").height
    implicitHeight: 20 * QD.Theme.getSize("size").height

    // 注意：contentItem的宽度和Spinbox的宽度成正比，比例是1：0.45
    contentItem: TextInput
    {
        id: content
        anchors.left: parent.left
        anchors.leftMargin: 5 * QD.Theme.getSize("size").height
        anchors.right: downIndicator.left
        text: ""
        font: QD.Theme.getFont("font1")
        color:root.enabled ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
        autoScroll: false //是否滚动，占据一定的宽度和高度
        verticalAlignment: Qt.AlignCenter
		validator: RegExpValidator{regExp:/(?=(\b|\D))(((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))\.){1}((\d{1,2})|(1\d{1,2})|(2[0-4]\d)|(25[0-5]))(?=(\b|\D))/}
    }

    Label
    {
        id: unitLabel
        anchors.right: downIndicator.left
        anchors.rightMargin: 3 * QD.Theme.getSize("size").height
        anchors.verticalCenter: parent.verticalCenter
        text: unit
		color: root.enabled ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
        font: QD.Theme.getFont("font1")
    }

    up.indicator: Rectangle
    {
        id: upIndicator
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 10 * QD.Theme.getSize("size").height
        implicitHeight: 20 * QD.Theme.getSize("size").height
        color: root.up.pressed ? QD.Theme.getColor("blue_1") : root.enabled ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
        radius: 3 * QD.Theme.getSize("size").height

        Rectangle
        {
            anchors.left: parent.left
            width: 3 * QD.Theme.getSize("size").height
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: root.up.pressed ? QD.Theme.getColor("blue_1") : root.enabled ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
        }

        QD.RecolorImage
        {
            source: QD.Theme.getIcon("ChevronSingleRight")
            width: 8 * QD.Theme.getSize("size").height
            height: 10 * QD.Theme.getSize("size").height
            anchors.centerIn: parent
            color: QD.Theme.getColor("white_1")
        }
    }

    down.indicator: Rectangle
    {
        id: downIndicator
        anchors.right: upIndicator.left
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: 10 * QD.Theme.getSize("size").height
        implicitHeight: 20 * QD.Theme.getSize("size").height
        color: root.down.pressed ? QD.Theme.getColor("blue_1") : root.enabled ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")

        QD.RecolorImage
        {
            source: QD.Theme.getIcon("ChevronSingleLeft")
            width: 8 * QD.Theme.getSize("size").height
            height: 10 * QD.Theme.getSize("size").height
            anchors.centerIn: parent
            color: QD.Theme.getColor("white_1")
        }
    }

    background: Rectangle
    {
        anchors.fill: parent
        border.color: QD.Theme.getColor("gray_2")
        radius: 3 * QD.Theme.getSize("size").height
    }
}
