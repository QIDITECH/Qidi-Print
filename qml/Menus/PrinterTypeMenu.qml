// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4

import QD 1.3 as QD
import QIDI 1.0 as QIDI

Menu
{
    id: menu
    title: "Printer type"
    property var outputDevice: QIDI.MachineManager.printerOutputDevices[0]

    Instantiator
    {
        id: printerTypeInstantiator
        model: outputDevice != null ? outputDevice.connectedPrintersTypeCount : []

        MenuItem
        {
            text: modelData.machine_type
            checkable: true
            checked: QIDI.MachineManager.activeMachine.definition.name == modelData.machine_type
            exclusiveGroup: group
            onTriggered:
            {
                QIDI.MachineManager.switchPrinterType(modelData.machine_type)
            }
        }
        onObjectAdded: menu.insertItem(index, object)
        onObjectRemoved: menu.removeItem(object)
    }

    ExclusiveGroup { id: group }
}
