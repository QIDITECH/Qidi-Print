// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.4

import UM 1.2 as UM
import Cura 1.0 as Cura



Item
{
    id: base

    Menu
    {
        id: iSeriesMenu
        title: catalog.i18nc("@title:menu", "i-series")
    }

    Instantiator {
        model: UM.ContainerStacksModel {
            filter: {"type": "machine", "um_network_key": null}
        }
        MenuItem {
            text: model.name.replace("I-", "i-").replace("_", " ")
            visible: text.match("i-")
            checkable: true;
            checked: Cura.MachineManager.activeMachineId == model.id
            exclusiveGroup: group;
            onTriggered:
            {
                Cura.MachineManager.setActiveMachine(model.id);
                Cura.MyWifiSend.scanDeviceThread()
            }
        }
        onObjectAdded: iSeriesMenu.insertItem(index, object)
        onObjectRemoved: iSeriesMenu.removeItem(object)
    }

    Menu
    {
        id: xSeriesMenu
        title: catalog.i18nc("@title:menu", "X-series")
    }


    Instantiator {
        model: UM.ContainerStacksModel {
            filter: {"type": "machine", "um_network_key": null}
        }
        MenuItem {
            text: model.name
            visible: !text.match("I-")
            checkable: true;
            checked: Cura.MachineManager.activeMachineId == model.name
            exclusiveGroup: group;
            onTriggered:
            {
                Cura.MachineManager.setActiveMachine(model.id);
                Cura.MyWifiSend.scanDeviceThread()
            }
        }
        onObjectAdded: xSeriesMenu.insertItem(index, object)
        onObjectRemoved: xSeriesMenu.removeItem(object)
    }
}
