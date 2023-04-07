import QtQuick 2.2

import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import QD 1.2 as QD
import QIDI 1.0 as QIDI


Item
{
    implicitWidth: parent.width
    implicitHeight: Math.floor(childrenRect.height + QD.Theme.getSize("default_margin").height * 2)
    property var outputDevice: null

    Connections
    {
        target: QIDI.MachineManager
        function onGlobalContainerChanged()
        {
            outputDevice = QIDI.MachineManager.printerOutputDevices.length >= 1 ? QIDI.MachineManager.printerOutputDevices[0] : null;
        }
    }

    Rectangle
    {
        height: childrenRect.height
        color: QD.Theme.getColor("setting_category")

        Label
        {
            id: outputDeviceNameLabel
            font: QD.Theme.getFont("large_bold")
            color: QD.Theme.getColor("text")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: QD.Theme.getSize("default_margin").width
            text: outputDevice != null ? outputDevice.activePrinter.name : ""
        }

        Label
        {
            id: outputDeviceAddressLabel
            text: (outputDevice != null && outputDevice.address != null) ? outputDevice.address : ""
            font: QD.Theme.getFont("default_bold")
            color: QD.Theme.getColor("text_inactive")
            anchors.top: outputDeviceNameLabel.bottom
            anchors.left: parent.left
            anchors.margins: QD.Theme.getSize("default_margin").width
        }

        Label
        {
            text: outputDevice != null ? "" : catalog.i18nc("@info:status", "The printer is not connected.")
            color: outputDevice != null && outputDevice.acceptsCommands ? QD.Theme.getColor("setting_control_text") : QD.Theme.getColor("setting_control_disabled_text")
            font: QD.Theme.getFont("default")
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            anchors.right: parent.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            anchors.top: parent.top
            anchors.topMargin: QD.Theme.getSize("default_margin").height
        }
    }
}