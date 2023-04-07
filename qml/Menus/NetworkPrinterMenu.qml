// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.4

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Instantiator
{
    model: QIDI.GlobalStacksModel {}
    MenuItem
    {
        property string connectGroupName:
        {
            if("group_name" in model.metadata)
            {
                return model.metadata["group_name"]
            }
            return ""
        }
        text: connectGroupName
        checkable: true
        visible: model.hasRemoteConnection
        checked: QIDI.MachineManager.activeMachineNetworkGroupName == connectGroupName
        exclusiveGroup: group
        onTriggered: QIDI.MachineManager.setActiveMachine(model.id)
    }
    onObjectAdded: menu.insertItem(index, object)
    onObjectRemoved: menu.removeItem(object)
}
