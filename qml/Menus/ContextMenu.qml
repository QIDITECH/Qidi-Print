// Copyright (c) 2016 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Menu
{
    id: base

    property bool shouldShowExtruders: machineExtruderCount.properties.value > 1;

    property var multiBuildPlateModel: QIDIApplication.getMultiBuildPlateModel()

    // Selection-related actions.
    MenuItem { action: QIDI.Actions.centerSelection; }
    MenuItem { action: QIDI.Actions.deleteSelection; }
    MenuItem { action: QIDI.Actions.multiplySelection; }

    // Extruder selection - only visible if there is more than 1 extruder
    MenuSeparator { visible: base.shouldShowExtruders }
    MenuItem { id: extruderHeader; text: catalog.i18ncp("@label", "Print Selected Model With:", "Print Selected Models With:", QD.Selection.selectionCount); enabled: false; visible: base.shouldShowExtruders }
    Instantiator
    {
        model: QIDIApplication.getExtrudersModel()
        MenuItem {
            text: "%1: %2 - %3".arg(model.name).arg(model.material).arg(model.variant)
            visible: base.shouldShowExtruders
            enabled: QD.Selection.hasSelection && model.enabled
            checkable: true
            checked: QIDI.ExtruderManager.selectedObjectExtruders.indexOf(model.id) != -1
            onTriggered: QIDIActions.setExtruderForSelection(model.id)
            shortcut: "Ctrl+" + (model.index + 1)
        }
        onObjectAdded: base.insertItem(index, object)
        onObjectRemoved: base.removeItem(object)
    }

    MenuSeparator {
        visible: QD.Preferences.getValue("qidi/use_multi_build_plate")
    }

    Instantiator
    {
        model: base.multiBuildPlateModel
        MenuItem {
            enabled: QD.Selection.hasSelection
            text: base.multiBuildPlateModel.getItem(index).name;
            onTriggered: QIDIActions.setBuildPlateForSelection(base.multiBuildPlateModel.getItem(index).buildPlateNumber);
            checkable: true
            checked: base.multiBuildPlateModel.selectionBuildPlates.indexOf(base.multiBuildPlateModel.getItem(index).buildPlateNumber) != -1;
            visible: QD.Preferences.getValue("qidi/use_multi_build_plate")
        }
        onObjectAdded: base.insertItem(index, object);
        onObjectRemoved: base.removeItem(object);
    }

    MenuItem {
        enabled: QD.Selection.hasSelection
        text: "New build plate";
        onTriggered: {
            QIDIActions.setBuildPlateForSelection(base.multiBuildPlateModel.maxBuildPlate + 1);
            checked = false;
        }
        checkable: true
        checked: false
        visible: QD.Preferences.getValue("qidi/use_multi_build_plate")
    }

    // Global actions
    MenuSeparator {}
    MenuItem { action: QIDI.Actions.selectAll; }
    MenuItem { action: QIDI.Actions.arrangeAll; }
    MenuItem { action: QIDI.Actions.deleteAll; }
    MenuItem { action: QIDI.Actions.reloadAll; }
    MenuItem { action: QIDI.Actions.resetAllTranslation; }
    MenuItem { action: QIDI.Actions.resetAll; }

    // Group actions
    MenuSeparator {}
    MenuItem { action: QIDI.Actions.groupObjects; }
    MenuItem { action: QIDI.Actions.mergeObjects; }
    MenuItem { action: QIDI.Actions.unGroupObjects; }

    Connections
    {
        target: QD.Controller
        function onContextMenuRequested() { base.popup(); }
    }

    Connections
    {
        target: QIDI.Actions.multiplySelection
        function onTriggered() { multiplyDialog.open() }
    }
	
    Connections
    {
        target: QIDIApplication
        function onCopyFile()
        {
			multiplyDialog.open()
        }
    }
	
    QD.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStack: QIDI.MachineManager.activeMachine
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
    }

    Dialog
    {
        id: multiplyDialog
        modality: Qt.ApplicationModal

        title: catalog.i18ncp("@title:window", "Multiply Selected Model", "Multiply Selected Models", QD.Selection.selectionCount)

        onAccepted: 
		{
			copiesField.value = copiesField.text
			spacingField.value = spacingField.text
			//QIDIApplication.set_copy_splicing(spacingField.value)
			QIDIActions.multiplySelection(copiesField.value,spacingField.value,copiesCheckBox.checked)
		}
        signal reset()
        onReset:
        {
            copiesField.value = 1;
            spacingField.value = 15;
			copiesCheckBox.checked = true
        }
        standardButtons: StandardButton.Ok | StandardButton.Cancel
		Column
		{
			spacing: 2*QD.Theme.getSize("default_margin").height
			Row
			{
				spacing: QD.Theme.getSize("default_margin").width

				Label
				{
					text: catalog.i18nc("@label", "Number of Copies")
					anchors.verticalCenter: copiesField.verticalCenter
					width: 120 * QD.Theme.getSize("size").height
				}

				QIDI.SpinBox
				{
					id: copiesField
					width: 80 * QD.Theme.getSize("size").height
					value: 1
					to: 99
					from: 1
					stepSize: 1
					text : value
					unit: ""
				}
			}
			Row
			{
				spacing: QD.Theme.getSize("default_margin").width
				Label
				{
					text: catalog.i18nc("@label", "Spacing of Copies")
					anchors.verticalCenter: spacingField.verticalCenter
					width: 120 * QD.Theme.getSize("size").height
				}
				QIDI.SpinBox
				{
					id: spacingField
					width: 80 * QD.Theme.getSize("size").height
					value: 1
					to: 99
					from: 1
					stepSize: 1
					text : value
					unit: "mm"
				}
			}
			Row
			{
				spacing: QD.Theme.getSize("default_margin").width+40*QD.Theme.getSize("size").height
				Label
				{
					text: catalog.i18nc("@label", "Automatic rotation")
					anchors.verticalCenter: copiesField.verticalCenter
					width: 120 * QD.Theme.getSize("size").height
				}
				CheckBox
				{
					id: copiesCheckBox
					width: 18 * QD.Theme.getSize("size").height
					height: 18 * QD.Theme.getSize("size").height
					checked: true
					/*onCheckedChanged: {
							QIDIApplication.set_automatic_rotation(copiesCheckBox.checked)
					}*/
				}
			}
		}
    }

    // Find the index of an item in the list of child items of this menu.
    //
    // This is primarily intended as a helper function so we do not have to
    // hard-code the position of the extruder selection actions.
    //
    // \param item The item to find the index of.
    //
    // \return The index of the item or -1 if it was not found.
    function findItemIndex(item)
    {
        for(var i in base.items)
        {
            if(base.items[i] == item)
            {
                return i;
            }
        }
        return -1;
    }

    QD.I18nCatalog { id: catalog; name: "qidi" }
}
