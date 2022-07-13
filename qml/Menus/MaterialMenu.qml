// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4

import UM 1.2 as UM
import Cura 1.0 as Cura

Menu
{
    id: menu
    title: "Material"

    property int extruderIndex: 0

    Instantiator
    {
        model: genericMaterialsModel
        MenuItem
        {
            text: model.name
            checkable: true
            checked: model.root_material_id == Cura.MachineManager.currentRootMaterialId[extruderIndex]
            exclusiveGroup: group
            onTriggered:
            {
                Cura.MachineManager.setMaterial(extruderIndex, model.container_node);
            }
        }
        onObjectAdded: menu.insertItem(index, object)
        onObjectRemoved: menu.removeItem(object)
    }

    Cura.GenericMaterialsModel
    {
        id: genericMaterialsModel
        extruderPosition: menu.extruderIndex
    }

    Cura.BrandMaterialsModel
    {
        id: brandModel
        extruderPosition: menu.extruderIndex
    }

    ExclusiveGroup { id: group }

    UM.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStackId: Cura.MachineManager.activeMachineId
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }
}
