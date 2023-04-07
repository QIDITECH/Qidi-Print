// Copyright (c) 2017 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Menu
{
    id: menu
    title: "Nozzle"

    property int extruderIndex: 0

    QIDI.NozzleModel
    {
        id: nozzleModel
    }

    Instantiator
    {
        model: nozzleModel

        MenuItem
        {
            text: model.hotend_name
            checkable: true
            checked: {
                var activeMachine = QIDI.MachineManager.activeMachine
                if (activeMachine === null)
                {
                    return false
                }
                var extruder = QIDI.MachineManager.activeMachine.extruderList[extruderIndex]
                return (extruder === undefined) ? false : (extruder.variant.name == model.hotend_name)
            }
            exclusiveGroup: group
            enabled:
            {
                var activeMachine = QIDI.MachineManager.activeMachine
                if (activeMachine === null)
                {
                    return false
                }
                var extruder = QIDI.MachineManager.activeMachine.extruderList[extruderIndex]
                return (extruder === undefined) ? false : extruder.isEnabled
            }
            onTriggered: {
                QIDI.MachineManager.setVariant(menu.extruderIndex, model.container_node);
            }
        }

        onObjectAdded: menu.insertItem(index, object);
        onObjectRemoved: menu.removeItem(object);
    }

    ExclusiveGroup { id: group }
}
