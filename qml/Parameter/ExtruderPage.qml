// Copyright (c) 2016 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.2 as UM

import Cura 1.0 as Cura
import "../Menus"

UM.PreferencesPage
{
    property QtObject settingVisibilityPresetsModel: CuraApplication.getSettingVisibilityPresetsModel()

    property int scrollToIndex: 0

    signal scrollToSection( string key )
    onScrollToSection:
    {
        settingsListView.positionViewAtIndex(definitionsModel.getIndex(key), ListView.Beginning)
    }

    function reset()
    {
        UM.Preferences.resetPreference("general/visible_settings")

        // After calling this function update Setting visibility preset combobox.
        // Reset should set default setting preset ("Basic")
        visibilityPreset.currentIndex = 1
    }
    resetEnabled: true;

    Item
    {
        id: base;

        anchors.fill: parent

        ScrollView
        {
            id: scrollView
            anchors.top: parent.top;
            anchors.bottom: parent.bottom;
            anchors.right: parent.right;
            anchors.left: parent.left;
            //anchors.topMargin: filterContainer.visible ? UM.Theme.getSize("sidebar_margin").height : 0
            Behavior on anchors.topMargin { NumberAnimation { duration: 100 } }
            frameVisible: true

            style: UM.Theme.styles.scrollview;
            flickableItem.flickableDirection: Flickable.VerticalFlick;
            __wheelAreaScrollSpeed: 75; // Scroll three lines in one scroll event

            ListView
            {
                id: contents
                spacing: Math.round(UM.Theme.getSize("default_lining").height);
                cacheBuffer: 1000000;   // Set a large cache to effectively just cache every list item.

                model: UM.SettingDefinitionsModel
                {
                    id: definitionsModel;
                    containerId: Cura.MachineManager.activeDefinitionId
                    visibilityHandler: UM.SettingPreferenceVisibilityHandler { }
                    showAll: true
                    exclude: ["shell","infill","material","speed","travel","cooling","support","platform_adhesion","dual","meshfix","experimental","machine_settings","blackmagic",
                        "command_line_settings","roofing_extruder_nr","material_diameter","material_flow_layer_0","travel_retract_before_outer_wall","retraction_retract_speed","retraction_prime_speed",
                    "retraction_extra_prime_amount","retraction_min_travel","retraction_count_max","retraction_extrusion_window","limit_support_retractions",
                    "switch_extruder_retraction_speeds","wall_material_flow","skin_material_flow","roofing_material_flow","infill_material_flow","skirt_brim_material_flow","support_material_flow",
                    "support_interface_material_flow","switch_extruder_extra_prime_amount","max_extrusion_before_wipe","wipe_retraction_enable","wipe_retraction_amount","wipe_retraction_extra_prime_amount",
                    "wipe_retraction_speed","wipe_pause","wipe_hop_enable","wipe_hop_amount","wipe_hop_speed","wipe_brush_pos_x","wipe_repeat_count","wipe_move_distance"]
                    expanded: ["*"]
                    onVisibilityChanged: Cura.SettingInheritanceManager.forceUpdate()
                }

                property var indexWithFocus: -1

                delegate: Loader
                {
                    id: delegate

                    width: Math.round(UM.Theme.getSize("sidebar").width) + 105 * UM.Theme.getSize("default_margin").width/10 + 85 * UM.Theme.getSize("default_margin").width/10;
                    height: model.type != "category" ? UM.Theme.getSize("section").height : - contents.spacing + 5 * UM.Theme.getSize("default_margin").width/10
                    Behavior on height { NumberAnimation { duration: 100 } }
                    opacity: model.type != "category" ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 100 } }

                    property var definition: model
                    property var settingDefinitionsModel: definitionsModel
                    property var propertyProvider: provider
                    property var globalPropertyProvider: inheritStackProvider
                    property var externalResetHandler: false

                    //Qt5.4.2 and earlier has a bug where this causes a crash: https://bugreports.qt.io/browse/QTBUG-35989
                    //In addition, while it works for 5.5 and higher, the ordering of the actual combo box drop down changes,
                    //causing nasty issues when selecting different options. So disable asynchronous loading of enum type completely.
                    asynchronous: model.type != "enum" && model.type != "extruder" && model.type != "optional_extruder"
                    active: model.type != undefined

                    UM.ParameterItem {
                        anchors.top: parent.top
                        anchors.topMargin: 1 * UM.Theme.getSize("default_margin").width/10
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    }

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
                            //case "category":
                                //return "SettingCategory.qml" //需要修改成标题页面
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
                        when: model.settable_per_extruder || (inheritStackProvider.properties.limit_to_extruder != null && inheritStackProvider.properties.limit_to_extruder >= 0);
                        value:
                        {
                            // associate this binding with Cura.MachineManager.activeMachineId in the beginning so this
                            // binding will be triggered when activeMachineId is changed too.
                            // Otherwise, if this value only depends on the extruderIds, it won't get updated when the
                            // machine gets changed.
                            var activeMachineId = Cura.MachineManager.activeMachineId;

                            if(!model.settable_per_extruder)
                            {
                                //Not settable per extruder or there only is global, so we must pick global.
                                return activeMachineId;
                            }
                            if(inheritStackProvider.properties.limit_to_extruder != null && inheritStackProvider.properties.limit_to_extruder >= 0)
                            {
                                //We have limit_to_extruder, so pick that stack.
                                return Cura.ExtruderManager.extruderIds[String(inheritStackProvider.properties.limit_to_extruder)];
                            }
                            if(Cura.ExtruderManager.activeExtruderStackId)
                            {
                                //We're on an extruder tab. Pick the current extruder.
                                return Cura.ExtruderManager.activeExtruderStackId;
                            }
                            //No extruder tab is selected. Pick the global stack. Shouldn't happen any more since we removed the global tab.
                            return activeMachineId;
                        }
                    }

                    // Specialty provider that only watches global_inherits (we cant filter on what property changed we get events
                    // so we bypass that to make a dedicated provider).
                    UM.SettingPropertyProvider
                    {
                        id: inheritStackProvider
                        containerStackId: Cura.MachineManager.activeMachineId
                        key: model.key
                        watchedProperties: [ "limit_to_extruder" ]
                    }

                    UM.SettingPropertyProvider
                    {
                        id: provider

                        containerStackId: Cura.MachineManager.activeMachineId
                        key: model.key ? model.key : ""
                        watchedProperties: [ "value", "enabled", "state", "validationState", "settable_per_extruder", "resolve" ]
                        storeIndex: 0
                        removeUnusedValue: model.resolve == undefined
                    }

                    Connections
                    {
                        target: item
                        onShowAllHiddenInheritedSettings:
                        {
                            var children_with_override = Cura.SettingInheritanceManager.getChildrenKeysWithOverride(category_id)
                            for(var i = 0; i < children_with_override.length; i++)
                            {
                                definitionsModel.setVisible(children_with_override[i], true)
                            }
                            Cura.SettingInheritanceManager.manualRemoveOverride(category_id)
                        }
                        onFocusReceived:
                        {
                            contents.indexWithFocus = index;
                            animateContentY.from = contents.contentY;
                            contents.positionViewAtIndex(index, ListView.Contain);
                            animateContentY.to = contents.contentY;
                            animateContentY.running = true;
                        }
                        onSetActiveFocusToNextSetting:
                        {
                            if(forward == undefined || forward)
                            {
                                contents.currentIndex = contents.indexWithFocus + 1;
                                while(contents.currentItem && contents.currentItem.height <= 0)
                                {
                                    contents.currentIndex++;
                                }
                                if(contents.currentItem)
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
                                if(contents.currentItem)
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

                UM.SettingPropertyProvider
                {
                    id: machineExtruderCount

                    containerStackId: Cura.MachineManager.activeMachineId
                    key: "machine_extruder_count"
                    watchedProperties: [ "value" ]
                    storeIndex: 0
                }
            }
        }

        UM.I18nCatalog { name: "cura"; }
        SystemPalette { id: palette; }

        Component
        {
            id: settingVisibilityCategory;

            UM.SettingVisibilityCategory { }
        }

        Component
        {
            id: settingVisibilityItem;

            UM.SettingVisibilityItem { }
        }
    }
}
