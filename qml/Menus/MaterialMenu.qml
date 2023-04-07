//Copyright (c) 2020 QIDI B.V.
//QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2


import QD 1.2 as QD
import QIDI 1.0 as QIDI

Menu
{
    id: menu
    title: catalog.i18nc("@label:category menu label", "Material")
	property var materialManagementModel: QIDIApplication.getMaterialManagementModel()
    property int extruderIndex: 0
	property string newRootMaterialIdToSwitchTo: ""
    property bool toActivateNewMaterial: false
	property bool is_create:false
	
    property string currentRootMaterialId:
    {
        var value = QIDI.MachineManager.currentRootMaterialId[extruderIndex]
        return (value === undefined) ? "" : value
    }
    property string currentRootMaterialIsRead:
    {
        var value = QIDI.MachineManager.currentRootMaterialIsRead[extruderIndex]
        return (value === undefined) ? "" : value
    }
    property var activeExtruder:
    {
        var activeMachine = QIDI.MachineManager.activeMachine
        return (activeMachine === null) ? null : activeMachine.extruderList[extruderIndex]
    }
    property bool isActiveExtruderEnabled: (activeExtruder === null || activeExtruder === undefined) ? false : activeExtruder.isEnabled
    property bool updateModels: true

	property var currentNode:null

    QIDI.GenericMaterialsModel
    {
        id: genericMaterialsModel
        extruderPosition: menu.extruderIndex
        enabled: updateModels
    }
	
    QIDI.MaterialBrandsModel
    {
        id: brandModel
        extruderPosition: menu.extruderIndex
        enabled: updateModels
    }
	
    Instantiator
    {
		id:genericMenu
        model: genericMaterialsModel
        delegate: MenuItem
        {
            text: model.name
            checkable: true
            enabled: isActiveExtruderEnabled
            checked: model.root_material_id === menu.currentRootMaterialId
            exclusiveGroup: group
            onTriggered: 
			{
				//QIDIApplication.writeToLog("e",model.root_material_id)
				//QIDIApplication.writeToLog("e",menu.currentRootMaterialId)
				//generic_pla_175
				QIDI.MachineManager.setMaterial(extruderIndex, model.container_node)
			}
        }
        onObjectAdded: 
		{
			menu.insertItem(index, object)
		}
        onObjectRemoved: menu.removeItem(object)
    }
	
	MenuSeparator { 
		visible:brandModel.count>0
	}
	
    Instantiator
    {
		id:brandMenu
        model: brandModel
        delegate: MenuItem
        {
            text: model.name
            checkable: true
            enabled: isActiveExtruderEnabled
            checked: model.root_material_id === menu.currentRootMaterialId
            exclusiveGroup: group
            onTriggered: {
				QIDI.MachineManager.setMaterial(extruderIndex, model.container_node)
			}
        }
        onObjectAdded: {
			menu.insertItem(index, object)
			if (creatematerialmessage.is_create)
			{
				
				menu.is_create = false
			}

		}
        onObjectRemoved: {
			menu.removeItem(object)
			//QIDI.MachineManager.setMaterial(extruderIndex, genericMenu.model.getItem(0).container_node)
		}
    }
	Connections
	{
		target: brandMenu.model

		function onItemsChanged()
		{
			var itemIndex = -1;

			for (var i = 0; i < brandMenu.model.count; ++i)
			{
				if (brandMenu.model.getItem(i).root_material_id == menu.currentRootMaterialId)
				{
					itemIndex = i;

					break;
				}
			}
			if (itemIndex == -1)
			{
				for (var i = 0; i < genericMenu.model.count; ++i)
				{
					if (genericMenu.model.getItem(i).root_material_id == menu.currentRootMaterialId)
					{
						itemIndex = i;

						break;
					}
				}
				menu.currentNode = itemIndex >= 0 ? genericMenu.model.getItem(itemIndex) : null;

			}
			else
			{
				menu.currentNode = itemIndex >= 0 ? brandMenu.model.getItem(itemIndex) : null;
			}

		}
	}
    ExclusiveGroup
    {
        id: group
    }

	
	MenuSeparator { }
	
	MenuItem
	{
		text:catalog.i18nc("@action:button", "Manage Materials")
		onTriggered:
		{
			forceActiveFocus();
			QIDIApplication.showCreateMaterial()
		}

	}
	

	

	

}
