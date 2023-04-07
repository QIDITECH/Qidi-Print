// Copyright (c) 2017 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    property string label: ""
    property string value: ""
    height: childrenRect.height;

    property var connectedPrinter: QIDI.MachineManager.printerOutputDevices.length >= 1 ? QIDI.MachineManager.printerOutputDevices[0] : null

    Row
    {
        height: QD.Theme.getSize("setting_control").height
        width: Math.floor(base.width - 2 * QD.Theme.getSize("default_margin").width)
        anchors.left: parent.left
        anchors.leftMargin: QD.Theme.getSize("default_margin").width

        Label
        {
            width: Math.floor(parent.width * 0.4)
            anchors.verticalCenter: parent.verticalCenter
            text: label
            color: connectedPrinter != null && connectedPrinter.acceptsCommands ? QD.Theme.getColor("setting_control_text") : QD.Theme.getColor("setting_control_disabled_text")
            font: QD.Theme.getFont("default")
            elide: Text.ElideRight
        }
        Label
        {
            width: Math.floor(parent.width * 0.6)
            anchors.verticalCenter: parent.verticalCenter
            text: value
            color: connectedPrinter != null && connectedPrinter.acceptsCommands ? QD.Theme.getColor("setting_control_text") : QD.Theme.getColor("setting_control_disabled_text")
            font: QD.Theme.getFont("default")
            elide: Text.ElideRight
        }
    }
}