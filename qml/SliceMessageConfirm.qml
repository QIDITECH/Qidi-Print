// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3
import QtQuick.Controls 1.4 as OldControls

import QD 1.3 as QD
import QIDI 1.0 as QIDI
import QtQuick.Controls.Styles 1.3

Rectangle
{
    id: base
    property bool multipleExtruders: extrudersModel.count > 1

    property var extrudersModel: QIDIApplication.getExtrudersModel()
	
    color: QD.Theme.getColor("white_1")
    radius: 5 * QD.Theme.getSize("size").height
    border.width: QD.Theme.getSize("size").height
    border.color: QD.Theme.getColor("gray_1")
    height: childrenRect.height + 20 * QD.Theme.getSize("size").width
    width: 360 * QD.Theme.getSize("size").width

    Label
    {
        id: sliceMessageLabel
        anchors.top: parent.top
        anchors.topMargin: 10 * QD.Theme.getSize("size").height
        anchors.horizontalCenter: parent.horizontalCenter
        text: catalog.i18nc("@label", "Basic print parameters")
        color: QD.Theme.getColor("black_1")
        font: QD.Theme.getFont("font2")
        renderType: Text.NativeRendering
    }

    QD.TabRow
    {
        id: tabBar

        visible: QIDIApplication.getExtrudersModel().count > 1
        anchors.top: sliceMessageLabel.bottom
        anchors.topMargin: 10 * QD.Theme.getSize("size").height
        anchors.left: listViewBack.left
        anchors.right: listViewBack.right
        height: 35 * QD.Theme.getSize("size").height
        z: 1

        contentItem: ListView
        {
            model: tabBar.contentModel
            currentIndex: tabBar.currentIndex 

            spacing: tabBar.spacing
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds
            //flickableDirection: tabBar.flickableDirection
            snapMode: ListView.SnapToItem
            rotation: 180

            highlightMoveDuration: 0
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: 40
            preferredHighlightEnd: width - 40
        }

        Repeater
        {
            id: repeater
            model: QIDIApplication.getExtrudersModel()
            delegate: QD.TabRowButton
            {
                rotation: 180
                contentItem: Item
                {
                    QIDI.ExtruderIcon
                    {
                        id: extruderIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: parent.verticalCenter
                        materialColor: model.color
                        extruderEnabled: model.enabled
                    }
                    OldControls.ToolButton
                    {
                        id: materialSelection
                        anchors.left: extruderIcon.right
                        anchors.right: parent.right
                        anchors.margins: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.material
                        tooltip: text
                        height: parent.height
                        style: QD.Theme.styles.print_setup_header_button
                        activeFocusOnPress: true
                        QIDI.MaterialMenu
                        {
                            id: materialsMenu
                            extruderIndex: model.index
                            updateModels: materialSelection.visible
                        }
                        onClicked:
                        {
                            materialsMenu.popup()
                        }
                    }
                }
                onClicked:
                {
                    QIDI.ExtruderManager.setActiveExtruderIndex(tabBar.currentIndex)
                }
            }
        }

        //When active extruder changes for some other reason, switch tabs.
        //Don't directly link currentIndex to QIDI.ExtruderManager.activeExtruderIndex!
        //This causes a segfault in Qt 5.11. Something with VisualItemModel removing index -1. We have to use setCurrentIndex instead.
		
        Connections
        {
            target: QIDI.ExtruderManager
            function onActiveExtruderChanged()
            {
                tabBar.setCurrentIndex(QIDI.ExtruderManager.activeExtruderIndex);
            }
        }

        //When the model of the extruders is rebuilt, the list of extruders is briefly emptied and rebuilt.
        //This causes the currentIndex of the tab to be in an invalid position which resets it to 0.
        //Therefore we need to change it back to what it was: The active extruder index.
		
        Connections
        {
            target: repeater.model
            function onModelChanged()
            {
                tabBar.setCurrentIndex(QIDI.ExtruderManager.activeExtruderIndex)
            }
        }
    }
	
	/*Rectangle
	{
		anchors.top : tabBar.bottom
		anchors.bottom: listViewBack.top
		anchors.left: listViewBack.left
		//anchors.right: parent.right
		width:parent.width/2 //163*QD.Theme.getSize("default_lining").width
		//height: 2*QD.Theme.getSize("size").height
		color: QD.Theme.getColor("blue_2")
	}*/
	
    Rectangle
    {
        id: listViewBack
        anchors.top: tabBar.visible ? tabBar.bottom : sliceMessageLabel.bottom
        anchors.topMargin: tabBar.visible ? -1.5 * QD.Theme.getSize("size").height : 10 * QD.Theme.getSize("size").height
        anchors.horizontalCenter: parent.horizontalCenter
        height: sliceMessageListView.count * 25 * QD.Theme.getSize("size").width + 5 * QD.Theme.getSize("size").width
        width: 320 * QD.Theme.getSize("size").height
        color: QD.Theme.getColor("white_1")
        border.width: 2*QD.Theme.getSize("size").width
        border.color: QD.Theme.getColor("blue_2")

		/*Rectangle
        {
            anchors.top: parent.top
            anchors.left: parent.left
            //anchors.right: parent.right
			width:parent.width/2 //163*QD.Theme.getSize("default_lining").width
            height: 2*QD.Theme.getSize("size").height
            color: QD.Theme.getColor("blue_2")
			border.width: 2*QD.Theme.getSize("size").width
			border.color: QD.Theme.getColor("blue_2")
            visible: QIDI.ExtruderManager.activeExtruderIndex ==0  || !multipleExtruders
        }
        Rectangle
        {
			id : line
            anchors.top: parent.top
            anchors.right: parent.right
            //anchors.right: parent.right
			width:parent.width/2 -  //163*QD.Theme.getSize("default_lining").width
            height: 2*QD.Theme.getSize("size").height
            color: QD.Theme.getColor("blue_2")
			border.width: 2*QD.Theme.getSize("size").width
			border.color: QD.Theme.getColor("blue_2")
            visible: QIDI.ExtruderManager.activeExtruderIndex ==1  || !multipleExtruders
        }*/
		
		/*Rectangle
		{
            anchors.bottom: parent.bottom
            anchors.left: parent.left
			//anchors.right: parent.right
			width:2*QD.Theme.getSize("size").height
			height: listViewBack.height + QD.Theme.getSize("size").height
			color: QD.Theme.getColor("blue_2")
			visible: true
		}
		
        Rectangle
        {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            //anchors.right: parent.right
			width:2*QD.Theme.getSize("size").height 
            height: parent.height + 2*QD.Theme.getSize("size").height
            color: QD.Theme.getColor("blue_2")
            visible: true
        }
		
        Rectangle
        {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
			//width:163*QD.Theme.getSize("default_lining").width
            height: 2*QD.Theme.getSize("size").height
            color: QD.Theme.getColor("blue_2")
            visible: true
        }*/
		
        ListView
        {
            id: sliceMessageListView
            cacheBuffer: 1000000   // Set a large cache to effectively just cache every list item.
            anchors.fill: parent
			//anchors.top:line.bottom
			//anchors.topMargin:10 * QD.Theme.getSize("size").height
			//anchors.left: parent.left
			//anchors.right: parent.right
			//anchors.bottom: parent.bottom
            model: QD.SettingDefinitionsModel
            {
                id: definitionsModel
                containerId: QIDI.MachineManager.activeMachine !== null ?  QIDI.MachineManager.activeMachine.definition.id: ""
                visibilityHandler: QD.SettingPreferenceVisibilityHandlerForBasic { }
                exclude: ["machine_settings", "resolution", "shell", "top_bottom", "material", "travel", "advanced", "dual", "meshfix", "blackmagic", "experimental", "other", "command_line_settings"]
                showAll: false
				//expanded: [ "*" ] 
                expanded: ['extruder','layer','infill','additions','speed','temperature','cooling','support','platform_adhesion','advanced']
            }

            property string activeMachineId: QIDI.MachineManager.activeMachine !== null ? QIDI.MachineManager.activeMachine.id : ""
            delegate: Loader
            {
                id: delegate

                width: parent.width
                height:
                {
                    if (enabled && visible)
                    {
                        if (model.type != "category")
                        {
                            return 25 * QD.Theme.getSize("size").height
                        }
                        else
                        {
                            return 30 * QD.Theme.getSize("size").height
                        }
                    }
                    return 0
                }
                Behavior on height { NumberAnimation { duration: 100 } }
                opacity: enabled ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 100 } }
                enabled: provider.properties.enabled === "True"
                visible: model.type != "category" || model.expanded

                property var definition: model
                property var settingDefinitionsModel: definitionsModel
                property var propertyProvider: provider
                property var globalPropertyProvider: inheritStackProvider
                property bool externalResetHandler: false

                //Qt5.4.2 and earlier has a bug where this causes a crash: https://bugreports.qt.io/browse/QTBUG-35989
                //In addition, while it works for 5.5 and higher, the ordering of the actual combo box drop down changes,
                //causing nasty issues when selecting different options. So disable asynchronous loading of enum type completely.
                asynchronous: model.type !== "enum" && model.type !== "extruder" && model.type !== "optional_extruder"
                active: model.type !== undefined

                source:
                {
                    switch(model.type)
                    {
                        case "int":
                            return "Settings/SettingTextField.qml"
                        case "[int]":
                            return "Settings/SettingTextField.qml"
                        case "float":
                            return "Settings/SettingTextField.qml"
                        case "enum":
                            return "Settings/SettingComboBox.qml"
                        case "extruder":
                            return "Settings/SettingExtruder.qml"
                        case "bool":
                            return "Settings/SettingCheckBox.qml"
                        case "str":
                            return "Settings/SettingTextField.qml"
                        case "category":
                            return "Settings/SettingCategory.qml"
                        case "optional_extruder":
                            return "Settings/SettingOptionalExtruder.qml"
                        default:
                            return "Settings/SettingUnknown.qml"
                    }
                }

                // Binding to ensure that the right containerstack ID is set for the provider.
                // This ensures that if a setting has a limit_to_extruder id (for instance; Support speed points to the
                // extruder that actually prints the support, as that is the setting we need to use to calculate the value)
                Binding
                {
                    target: provider
                    property: "containerStackId"
                    when: model.settable_per_extruder || (inheritStackProvider.properties.limit_to_extruder !== null && inheritStackProvider.properties.limit_to_extruder >= 0);
                    value:
                    {
                        // Associate this binding with QIDI.MachineManager.activeMachine.id in the beginning so this
                        // binding will be triggered when activeMachineId is changed too.
                        // Otherwise, if this value only depends on the extruderIds, it won't get updated when the
                        // machine gets changed.

                        if (!model.settable_per_extruder)
                        {
                            //Not settable per extruder or there only is global, so we must pick global.
                            return sliceMessageListView.activeMachineId
                        }
                        if (inheritStackProvider.properties.limit_to_extruder !== null && inheritStackProvider.properties.limit_to_extruder >= 0)
                        {
                            //We have limit_to_extruder, so pick that stack.
                            return QIDI.ExtruderManager.extruderIds[String(inheritStackProvider.properties.limit_to_extruder)];
                        }
                        if (QIDI.ExtruderManager.activeExtruderStackId)
                        {
                            //We're on an extruder tab. Pick the current extruder.
                            return QIDI.ExtruderManager.activeExtruderStackId;
                        }
                        //No extruder tab is selected. Pick the global stack. Shouldn't happen any more since we removed the global tab.
                        return sliceMessageListView.activeMachineId
                    }
                }

                // Specialty provider that only watches global_inherits (we cant filter on what property changed we get events
                // so we bypass that to make a dedicated provider).
                QD.SettingPropertyProvider
                {
                    id: inheritStackProvider
                    containerStackId: sliceMessageListView.activeMachineId
                    key: model.key
                    watchedProperties: [ "limit_to_extruder" ]
                }

                QD.SettingPropertyProvider
                {
                    id: provider

                    containerStackId: sliceMessageListView.activeMachineId
                    key: model.key
                    watchedProperties: [ "value", "enabled", "state", "validationState", "settable_per_extruder", "resolve" ]
                    storeIndex: 0
                    removeUnusedValue: model.resolve === undefined
                }
            }
        }
    }

    QIDI.PrimaryButton
    {
        id: sliceButton
        fixedWidthMode: true
        height: 25 * QD.Theme.getSize("size").height
        width: 100 * QD.Theme.getSize("size").height
        backgroundRadius: Math.round(height / 2)
        anchors.right: listViewBack.right
        anchors.top: listViewBack.bottom
        anchors.topMargin: 10 * QD.Theme.getSize("size").height
        text: catalog.i18nc("@button", "Slice")
        onClicked:
        {
            base.visible = false
            QIDIApplication.backend.getOozePrevention()
            sliceTimer.start()
        }
    }

    QIDI.SecondaryButton
    {
        id: cancelButton
        fixedWidthMode: true
        height: 25 * QD.Theme.getSize("size").height
        width: 110 * QD.Theme.getSize("size").height
        backgroundRadius: Math.round(height / 2)
        anchors.left: listViewBack.left
        anchors.top: listViewBack.bottom
        anchors.topMargin: 10 * QD.Theme.getSize("size").height
        //text: catalog.i18nc("@button", "Cancel")
		text:catalog.i18nc("@action:button", "No prompt")
        onClicked:{
			base.visible = false
			QD.Preferences.setValue("view/show_slice_confirm", false)
		}
    }
	OldControls.Button
	{
		id: closeButton
		width: 2*QD.Theme.getSize("message_close").width
		height: 2*QD.Theme.getSize("message_close").height

		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: 10
		style: ButtonStyle
		{
			background: QD.RecolorImage
			{
				width: QD.Theme.getSize("message_close").width
				sourceSize.width: width
				color: control.hovered ? QD.Theme.getColor("message_close_hover") : QD.Theme.getColor("message_close")
				source: QD.Theme.getIcon("Cancel")
			}

			label: Item {}
		}

		onClicked: base.visible = false
	}
    Timer
    {
        id: sliceTimer
        repeat: false
        interval: 200
        onTriggered: QIDIApplication.backend.forceSlice()
    }
}
