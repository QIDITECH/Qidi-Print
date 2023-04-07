// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.3 as QD
import QIDI 1.0 as QIDI

Item
{
    width: parent.width
    height: childrenRect.height

    Label
    {
        id: header
        text: catalog.i18nc("@header", "Configurations")
        font: QD.Theme.getFont("medium")
        color: QD.Theme.getColor("small_button_text")
        height: contentHeight
        renderType: Text.NativeRendering

        anchors
        {
            left: parent.left
            right: parent.right
        }
    }

    ConfigurationListView
    {
        anchors.top: header.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").width
        width: parent.width

        outputDevice: QIDI.MachineManager.printerOutputDevices.length >= 1 ? QIDI.MachineManager.printerOutputDevices[0] : null
    }
}