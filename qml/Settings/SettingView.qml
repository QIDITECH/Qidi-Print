// Copyright (c) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI

import "../Menus"
Item
{
    id: settingsView
    property QtObject settingVisibilityPresetsModel: QIDIApplication.getSettingVisibilityPresetsModel()
    property Action configureSettings
    property bool findingSettings
	//property var testf: ""
	property var testf: QIDIApplication.parameter_testf()
	
	Timer
	{
		id: testfChangeTimer
		running: QIDIApplication.parameter_testf
		repeat: true
		interval: 200
		onTriggered:
		{
			testf = QIDIApplication.parameter_testf()
		}
	}
	
    QD.RecolorImage
    {
        id: magnifier
        anchors.verticalCenter: filterContainer.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10 * QD.Theme.getSize("size").width
        width: 25 * QD.Theme.getSize("size").width
        height: 25 * QD.Theme.getSize("size").height
        source: QD.Theme.getIcon("Magnifier")
        color: QD.Theme.getColor("black_1")
    }
    
    Rectangle
    {
        id: filterContainer
        visible: true

        radius: QD.Theme.getSize("setting_control_radius").width
        border.width: QD.Theme.getSize("default_lining").width
        border.color:
        {
            if (hoverMouseArea.containsMouse || clearFilterButton.containsMouse)
            {
                return QD.Theme.getColor("setting_control_border_highlight")
            }
            else
            {
                return QD.Theme.getColor("setting_control_border")
            }
        }

        color: QD.Theme.getColor("setting_control")

        anchors
        {
            top: parent.top
            left: magnifier.right
            leftMargin: 10 * QD.Theme.getSize("size").height
            right: settingVisibilityMenu.left
            rightMargin: QD.Theme.getSize("default_margin").width
        }
        height: QD.Theme.getSize("print_setup_big_item").height
        Timer
        {
            id: settingsSearchTimer
            onTriggered: filter.editingFinished()
            interval: 500
            running: false
            repeat: false
        }

        TextField
        {
            id: filter
            height: parent.height
            anchors.left: parent.left
            anchors.right: clearFilterButton.left
            anchors.rightMargin: Math.round(QD.Theme.getSize("thick_margin").width)

            placeholderText: catalog.i18nc("@label:textbox", "Search settings")

            style: TextFieldStyle
            {
                textColor: QD.Theme.getColor("setting_control_text")
                placeholderTextColor: QD.Theme.getColor("setting_filter_field")
                font: QD.Theme.getFont("default_italic")
                background: Item {}
            }

            property var expandedCategories
            property bool lastFindingSettings: false

            onTextChanged:
            {
                settingsSearchTimer.restart()
            }

            onEditingFinished:
            {
				QD.Preferences.setValue("qidi/show_search","")
                definitionsModel.filter = {"i18n_label|i18n_description" : "*" + text}
                findingSettings = (text.length > 0)
                if (findingSettings != lastFindingSettings)
                {
                    updateDefinitionModel()
                    lastFindingSettings = findingSettings
                }
            }

            Keys.onEscapePressed:
            {
                filter.text = ""
            }

            function updateDefinitionModel()
            {
				//QIDIApplication.writeToLog("e",filter.text)
				//QIDIApplication.writeToLog("e",QD.Preferences.getValue("qidi/category_expanded"))
				QIDIApplication.parameter_testf_change("")
                if (findingSettings)
                {
                    expandedCategories = definitionsModel.expanded.slice()
                    definitionsModel.expanded = [""]  // keep categories closed while to prevent render while making settings visible one by one
                    definitionsModel.showAncestors = true
                    definitionsModel.showAll = true
                    definitionsModel.expanded = [ QD.Preferences.getValue("qidi/category_expanded") ]
                }
                else
                {
                    if (expandedCategories)
                    {
                        definitionsModel.expanded = expandedCategories
                    }
                    definitionsModel.showAncestors = false
                    definitionsModel.showAll = false
                    definitionsModel.expanded = [ QD.Preferences.getValue("qidi/category_expanded") ]
                }
				QIDIApplication.parameter_testf_change("Machine")
            }
        }

        MouseArea
        {
            id: hoverMouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.IBeamCursor
        }

        QD.SimpleButton
        {
            id: clearFilterButton
            iconSource: QD.Theme.getIcon("Cancel")
            visible: findingSettings

            height: Math.round(parent.height * 0.4)
            width: visible ? height : 0

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width

            color: QD.Theme.getColor("setting_control_button")
            hoverColor: QD.Theme.getColor("setting_control_button_hover")

            onClicked:
            {
                filter.text = ""
                filter.forceActiveFocus()
            }
        }
    }

    QIDI.ComboBox
    {
        id: settingVisibilityMenu
        anchors.top: filterContainer.top
        anchors.bottom: filterContainer.bottom
        anchors.right: parent.right
        anchors.rightMargin: 10 * QD.Theme.getSize("size").width
        width: 120 * QD.Theme.getSize("size").width

        model: settingVisibilityPresetsModel.items
        textRole: "name"

        currentIndex:
        {
            var idx = -1;
			//testf = ""
			QIDIApplication.parameter_testf_change("")
            for(var i = 0; i < settingVisibilityPresetsModel.items.length; ++i)
            {
                if(settingVisibilityPresetsModel.items[i].presetId == settingVisibilityPresetsModel.activePreset)
                {
                    idx = i;
                    break;
                }
            }
			//testf="Machine"
			QIDIApplication.parameter_testf_change("Machine")
            return idx;
        }

        onActivated:
        {
            var preset_id = settingVisibilityPresetsModel.items[index].presetId
            settingVisibilityPresetsModel.setActivePreset(preset_id)
        }
    }

    // Mouse area that gathers the scroll events to not propagate it to the main view.




    MouseArea
    {
        anchors.fill: scrollView
        acceptedButtons: Qt.AllButtons
        onWheel: 
		{
			wheel.accepted = true
		}
    }





    ListView
    {
        id: categoryListView

        anchors.left: parent.left
        anchors.leftMargin: 5 * QD.Theme.getSize("size").height
        anchors.top: magnifier.bottom 
        topMargin: 5 * QD.Theme.getSize("size").height //* QD.Preferences.getValue("qidi/size")
        anchors.bottom: scrollView.bottom
        width: 45 * QD.Theme.getSize("size").height
        orientation: ListView.Vertical
        spacing: 5 * QD.Theme.getSize("size").height
		clip:true
        model: QD.SettingDefinitionsModel
        {
            id: categoryModel
            containerId: QIDI.MachineManager.activeMachine !== null ? QIDI.MachineManager.activeMachine.definition.id : ""
            visibilityHandler: QD.SettingPreferenceVisibilityHandler { }
            exclude: ["resolution", "shell", "top_bottom", "material", "travel", "dual", "meshfix", "blackmagic",  "command_line_settings"]
            onVisibilityChanged: QIDI.SettingInheritanceManager.scheduleUpdate()
        }
        currentIndex: QD.Preferences.getValue("qidi/category_expanded") == "" ? 0 : model.getIndex(QD.Preferences.getValue("qidi/category_expanded"))
        delegate: Button
        {
			id:base
            width: parent.width
            height: 25 * QD.Theme.getSize("size").height
            checked: ListView.view.currentIndex == index
            onClicked:
            {
                definitionsModel.collapseAllCategories()
                definitionsModel.expandRecursive(model.key)
				
                QD.Preferences.setValue("qidi/category_expanded", model.key)
                ListView.view.currentIndex = index
				scrollView.flickableItem.contentY = 0
            }
			QIDI.ToolTip
			{
				id: tooltip
				tooltipText: model.label
				contentAlignment :  QIDI.ToolTip.ContentAlignment.AlignLeft
				visible: base.hovered
			}
            style: ButtonStyle
            {
                background: Rectangle
                {
                    anchors.fill: parent
                    color: QD.Theme.getColor("blue_4")
                    QIDI.RoundedRectangle
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        color: QD.Theme.getColor("blue_6")
                        width: parent.width + 15 * QD.Theme.getSize("size").height
                        height: parent.height
                        radius: height / 2
                        cornerSide: QIDI.RoundedRectangle.Direction.Left
                        visible: checked
                    }
                    QD.RecolorImage
                    {
                        anchors.verticalCenter: modelicon.verticalCenter
						anchors.left:parent.left
                        source: QD.Theme.getIcon("StarFilled")
                        width: 10 * QD.Theme.getSize("size").height
                        height: 10 * QD.Theme.getSize("size").height
                        color: QD.Theme.getColor("orange_1")
						visible: testf == "Machine" ? findingSettings ? QD.Preferences.getValue("qidi/show_search").search(model.key) != -1 : false :false
                    }
                    QD.RecolorImage
                    {
						id:modelicon
                        anchors.centerIn: parent
                        source: QD.Theme.getIcon(model.icon)
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        color : testf == "Machine" ? QD.Theme.getColor(QIDIApplication.parameter_changed_color(model.key)) : QD.Theme.getColor(QIDIApplication.parameter_changed_color(model.key))
                    }
                }
            }
        }
    }

    ScrollView
    {
        id: scrollView
        anchors
        {
            top: filterContainer.bottom
            topMargin: 5 * QD.Theme.getSize("size").height
            bottom: parent.bottom
            right: parent.right
            left: categoryListView.right
        }
        style: QD.Theme.styles.scrollview
        flickableItem.flickableDirection: Flickable.VerticalFlick
        __wheelAreaScrollSpeed: 75  // Scroll three lines in one scroll event


		
        ListView
        {
            id: contents
            cacheBuffer: 1000000   // Set a large cache to effectively just cache every list item.

            model: QD.SettingDefinitionsModel
            {
                id: definitionsModel
                containerId: QIDI.MachineManager.activeMachine !== null ? QIDI.MachineManager.activeMachine.definition.id: ""
                visibilityHandler: QD.SettingPreferenceVisibilityHandler { }
                exclude: ["command_line_settings", "infill_mesh", "infill_mesh_order", "cutting_mesh", "support_mesh", "anti_overhang_mesh"] 
                expanded: QIDIApplication.expandedCategories
                onExpandedChanged:
                {
                    if (!findingSettings)
                    {
                        // Do not change expandedCategories preference while filtering settings
                        // because all categories are expanded while filtering
                        QIDIApplication.setExpandedCategories(expanded)
                    }
                }
                onVisibilityChanged: QIDI.SettingInheritanceManager.scheduleUpdate()
            }

            property int indexWithFocus: -1
            property double delegateHeight: QD.Theme.getSize("section").height + 2 * QD.Theme.getSize("default_lining").height
            property string activeMachineId: QIDI.MachineManager.activeMachine !== null ? QIDI.MachineManager.activeMachine.id : ""
            delegate: Loader
            {
                id: delegate

                width: scrollView.width
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
                            return 50 * QD.Theme.getSize("size").height
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
                            return "SettingTextField.qml"
                        case "[int]":
                            return "SettingTextField.qml"
                        case "float":
                            return "SettingTextField.qml"
                        case "enum":
                            return "SettingComboBox.qml"
                        case "extruder":
                            return "SettingExtruder.qml"
                        case "bool":
                            return "SettingCheckBox.qml"
                        case "str":
                            return "SettingTextField.qml"
                        case "category":
                            return "SettingCategory.qml"
                        case "optional_extruder":
                            return "SettingOptionalExtruder.qml"
                        default:
                            return "SettingUnknown.qml"
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
                            return contents.activeMachineId
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
                        return contents.activeMachineId
                    }
                }

                // Specialty provider that only watches global_inherits (we cant filter on what property changed we get events
                // so we bypass that to make a dedicated provider).
                QD.SettingPropertyProvider
                {
                    id: inheritStackProvider
                    containerStackId: contents.activeMachineId
                    key: model.key
                    watchedProperties: [ "limit_to_extruder" ]
                }

                QD.SettingPropertyProvider
                {
                    id: provider

                    containerStackId: contents.activeMachineId
                    key: model.key
                    watchedProperties: [ "value", "enabled", "state", "validationState", "settable_per_extruder", "resolve" ]
                    storeIndex: 0
                    removeUnusedValue: model.resolve === undefined
                }

                Connections
                {
                    target: item
                    function onContextMenuRequested()
                    {
                        contextMenu.key = model.key;
                        contextMenu.settingVisible = model.visible;
                        contextMenu.provider = provider
                        contextMenu.popup();
                    }
                    function onShowTooltip(text) { base.showTooltip(delegate, Qt.point(-settingsView.x - QD.Theme.getSize("default_margin").width, 0), text) }
                    function onHideTooltip() { base.hideTooltip() }
                    function onShowAllHiddenInheritedSettings()
                    {
                        var children_with_override = QIDI.SettingInheritanceManager.getChildrenKeysWithOverride(category_id)
                        for(var i = 0; i < children_with_override.length; i++)
                        {
                            definitionsModel.setVisible(children_with_override[i], true)
                        }
                        QIDI.SettingInheritanceManager.manualRemoveOverride(category_id)
                    }
                    function onFocusReceived()
                    {
                        contents.indexWithFocus = index;
                        animateContentY.from = contents.contentY;
                        contents.positionViewAtIndex(index, ListView.Contain);
                        animateContentY.to = contents.contentY;
                        animateContentY.running = true;
                    }
                    function onSetActiveFocusToNextSetting(forward)
                    {
                        if (forward == undefined || forward)
                        {
                            contents.currentIndex = contents.indexWithFocus + 1;
                            while(contents.currentItem && contents.currentItem.height <= 0)
                            {
                                contents.currentIndex++;
                            }
                            if (contents.currentItem)
                            {
                                contents.currentItem.item.focusItem.forceActiveFocus();
                            }
                        }
                        else
                        {
                            contents.currentIndex = contents.indexWithFocus - 1;
                            while(contents.currentItem && contents.currentItem.height <= 0)
                            {
                                contents.currentIndex--;
                            }
                            if (contents.currentItem)
                            {
                                contents.currentItem.item.focusItem.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            NumberAnimation {
                id: animateContentY
                target: contents
                property: "contentY"
                duration: 50
            }

            add: Transition {
                SequentialAnimation {
                    NumberAnimation { properties: "height"; from: 0; duration: 100 }
                    NumberAnimation { properties: "opacity"; from: 0; duration: 100 }
                }
            }
            remove: Transition {
                SequentialAnimation {
                    NumberAnimation { properties: "opacity"; to: 0; duration: 100 }
                    NumberAnimation { properties: "height"; to: 0; duration: 100 }
                }
            }
            addDisplaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 100 }
            }
            removeDisplaced: Transition {
                SequentialAnimation {
                    PauseAnimation { duration: 100; }
                    NumberAnimation { properties: "x,y"; duration: 100 }
                }
            }

            Menu
            {
                id: contextMenu

                property string key
                property var provider
                property bool settingVisible

                MenuItem
                {
                    //: Settings context menu action
                    text: catalog.i18nc("@action:menu", "Copy value to all extruders")
                    visible: machineExtruderCount.properties.value > 1
                    enabled: contextMenu.provider !== undefined && contextMenu.provider.properties.settable_per_extruder !== "False"
                    onTriggered: QIDI.MachineManager.copyValueToExtruders(contextMenu.key)
                }

                MenuItem
                {
                    //: Settings context menu action
                    text: catalog.i18nc("@action:menu", "Copy all changed values to all extruders")
                    visible: machineExtruderCount.properties.value > 1
                    enabled: contextMenu.provider !== undefined
                    onTriggered: QIDI.MachineManager.copyAllValuesToExtruders()
                }

                MenuSeparator
                {
                    visible: machineExtruderCount.properties.value > 1
                }

                Instantiator
                {
                    id: customMenuItems
                    model: QIDI.SidebarCustomMenuItemsModel { }
                    MenuItem
                    {
                        text: model.name
                        iconName: model.icon_name
                        onTriggered:
                        {
                            customMenuItems.model.callMenuItemMethod(name, model.actions, {"key": contextMenu.key})
                        }
                    }
                   onObjectAdded: contextMenu.insertItem(index, object)
                   onObjectRemoved: contextMenu.removeItem(object)
                }

                MenuSeparator
                {
                    visible: customMenuItems.count > 0
                }

                MenuItem
                {
                    //: Settings context menu action
                    visible: !findingSettings
                    text: catalog.i18nc("@action:menu", "Hide this setting");
                    onTriggered:
                    {
                        definitionsModel.hide(contextMenu.key)
                    }
                }
                MenuItem
                {
                    //: Settings context menu action
                    text:
                    {
                        if (contextMenu.settingVisible)
                        {
                            return catalog.i18nc("@action:menu", "Don't show this setting");
                        }
                        else
                        {
                            return catalog.i18nc("@action:menu", "Keep this setting visible");
                        }
                    }
                    visible: findingSettings
                    onTriggered:
                    {
                        if (contextMenu.settingVisible)
                        {
                            definitionsModel.hide(contextMenu.key);
                        }
                        else
                        {
                            definitionsModel.show(contextMenu.key);
                        }
                    }
                }
                MenuItem
                {
                    //: Settings context menu action
                    text: catalog.i18nc("@action:menu", "Configure setting visibility...");

                    onTriggered: settingDialog.show()
                }

                QIDI.PreferencesDialog
                {
                    id: settingDialog
                    title: catalog.i18nc("@title:tab", "Setting Visibility")
                    Component.onCompleted:
                    {
                        setPage(Qt.resolvedUrl("../Preferences/SettingVisibilityPage.qml"))
                    }
                }
            }
			
			
            QD.SettingPropertyProvider
            {
                id: machineExtruderCount

                containerStackId: QIDI.MachineManager.activeMachine !== null ? QIDI.MachineManager.activeMachine.id : ""
                key: "machine_extruder_count"
                watchedProperties: [ "value" ]
                storeIndex: 0
            }
        }
    }
}
