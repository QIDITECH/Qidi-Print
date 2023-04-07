// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

ListView
{
    id: listView
    model: QIDI.GlobalStacksModel {}
    // model: QD.DefinitionContainersModel{ filter: { "visible": true } }
    section.property: "hasRemoteConnection"
    property real contentHeight: childrenRect.height

    // section.delegate: Label
    // {
    //     text: section == "true" ? catalog.i18nc("@label", "Connected printers") : catalog.i18nc("@label", "Preset printers")
    //     width: parent.width
    //     height: QD.Theme.getSize("action_button").height
    //     leftPadding: QD.Theme.getSize("default_margin").width
    //     renderType: Text.NativeRendering
    //     font: QD.Theme.getFont("medium")
    //     color: QD.Theme.getColor("text_medium")
    //     verticalAlignment: Text.AlignVCenter
    // }

    delegate: MachineSelectorButton
    {
        text: model.name ? model.name : ""
        width: listView.width
        outputDevice: QIDI.MachineManager.printerOutputDevices.length >= 1 ? QIDI.MachineManager.printerOutputDevices[0] : null

        checked: 
		{
			QIDI.MachineManager.activeMachine ? QIDI.MachineManager.activeMachine.name == model.name : false
		}

        onClicked:
        {
            toggleContent()
            QIDI.MachineManager.addMachine(model.id, model.name)
			ipComboBox.currentIndex = 0
			QIDI.WifiSend.ip_sort()
			QIDI.WifiSend.setCurrentDeviceIP(QIDI.WifiSend.FullNameIPList[ipComboBox.currentIndex])
        }
    }
}
