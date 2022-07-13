// Copyright (c) 2017 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Window 2.2

import UM 1.2 as UM
import Cura 1.0 as Cura
import ".."

Item {
    id: base;

    UM.I18nCatalog { id: catalog; name: "cura"; }

    width: childrenRect.width;
    height: childrenRect.height;

    property var all_categories_except_support: [ "machine_settings", "resolution", "shell", "infill", "material", "speed",
                                    "travel", "cooling", "platform_adhesion", "dual", "meshfix", "blackmagic", "experimental"]

    Column
    {
        id: items
        anchors.top: parent.top;
        anchors.left: parent.left;

        spacing: UM.Theme.getSize("default_margin").height

        Column
        {
            // This is to ensure that the panel is first increasing in size up to 200 and then shows a scrollbar.
            // It kinda looks ugly otherwise (big panel, no content on it)
            id: currentSettings
            property int maximumHeight: 200 * screenScaleFactor
            height: Math.min(contents.count * (UM.Theme.getSize("section").height + UM.Theme.getSize("default_lining").height), maximumHeight)

            ScrollView
            {
                height: parent.height
                width: UM.Theme.getSize("setting").width + UM.Theme.getSize("default_margin").width
                style: UM.Theme.styles.scrollview

                ListView
                {
                    id: contents
                    spacing: UM.Theme.getSize("default_lining").height

                    model: UM.SettingDefinitionsModel
                    {
                        id: addedSettingsModel;
                        containerId: Cura.MachineManager.activeDefinitionId
                        expanded: [ "*" ]
                        /*filter:
                        {
                            if (printSequencePropertyProvider.properties.value == "one_at_a_time")
                            {
                                return {"settable_per_meshgroup": true};
                            }
                            return {"settable_per_mesh": true};
                        }*/
                        showAll: true
                        exclude: ["shell","infill","material","speed","travel","cooling","resolution","platform_adhesion","dual","meshfix","blackmagic","experimental","machine_settings","command_line_settings",
                        "support_infill_extruder_nr","support_extruder_nr_layer_0","support_interface_extruder_nr","zig_zaggify_support","support_connect_zigzags","support_line_distance","support_top_distance",
                        "support_bottom_distance","support_xy_distance","support_xy_overrides_z","support_xy_distance_overhang","support_bottom_stair_step_height","support_bottom_stair_step_width","support_join_distance",
                        "support_infill_sparse_thickness","gradual_support_infill_steps","gradual_support_infill_step_height","support_roof_enable","support_bottom_enable","support_roof_height","support_bottom_height",
                        "support_roof_density","support_bottom_density","support_roof_pattern","support_bottom_pattern","support_use_towers","support_tower_diameter","support_minimal_diameter","support_tower_roof_angle",
                        "support_mesh_drop_down","support_tree_wall_count","support_skip_some_zags","support_skip_zag_per_mm","infill_hollow","support_enable","support_angle",
                        "support_xy_distance","support_interface_height","support_offset","support_interface_skip_height","support_interface_density","support_tree_enable","support_tree_angle","support_tree_branch_distance",
                        "support_tree_branch_diameter","support_tree_branch_diameter_angle","support_tree_collision_resolution","support_tree_wall_thickness","support_conical_enabled","support_conical_angle","support_conical_min_width",
                        "support_interface_enable","support_interface_pattern","support_type","support_wall_count","support_initial_layer_line_distance","support_infill_angle","support_brim_enable",
                        "support_brim_width","support_brim_line_count","brim_replaces_support","support_fan_enable","support_supported_skin_fan_speed","minimum_roof_area","minimum_bottom_area",
                        "support_interface_offset","support_interface_angles","support_infill_angles","minimum_support_area","minimum_interface_area","support_tower_maximum_supported_diameter",
                        "support_bottom_stair_step_min_slope","support_meshes_present","support_structure"]

                        visibilityHandler: Cura.PerObjectSettingVisibilityHandler
                        {
                            selectedObjectId: UM.ActiveTool.properties.getValue("SelectedObjectId")
                        }
                    }

                    delegate: Row
                    {
                        spacing: UM.Theme.getSize("default_margin").width
                        Loader
                        {
                            id: settingLoader
                            width: UM.Theme.getSize("setting").width + 25 * UM.Theme.getSize("default_margin").width/10
                            height: model.type != "category" ? UM.Theme.getSize("section").height : -5 * UM.Theme.getSize("default_margin").width/10
                            opacity: model.type != "category" ? 1 : 0
                            enabled:
                            {
                                if (model.type == "extruder" && machineExtruderCount.properties.value < 2)
                                {
                                    return false
                                }
                                return true
                            }

                            property var definition: model
                            property var settingDefinitionsModel: addedSettingsModel
                            property var propertyProvider: provider
                            property var globalPropertyProvider: inheritStackProvider
                            property var externalResetHandler: false

                            //Qt5.4.2 and earlier has a bug where this causes a crash: https://bugreports.qt.io/browse/QTBUG-35989
                            //In addition, while it works for 5.5 and higher, the ordering of the actual combo box drop down changes,
                            //causing nasty issues when selecting different options. So disable asynchronous loading of enum type completely.
                            asynchronous: model.type != "enum" && model.type != "extruder"

                            onLoaded: {
                                settingLoader.item.showRevertButton = false
                                settingLoader.item.showInheritButton = false
                                settingLoader.item.showLinkedSettingIcon = false
                                settingLoader.item.doDepthIndentation = false
                                settingLoader.item.doQualityUserSettingEmphasis = false
                            }

                            sourceComponent:
                            {
                                switch(model.type)
                                {
                                    case "int":
                                        return settingTextField
                                    case "[int]":
                                        return settingTextField
                                    case "float":
                                        return settingTextField
                                    case "enum":
                                        return settingComboBox
                                    case "extruder":
                                        return settingExtruder
                                    case "optional_extruder":
                                        return settingOptionalExtruder
                                    case "bool":
                                        return settingCheckBox
                                    case "str":
                                        return settingTextField
                                    case "category":
                                        return settingCategory
                                    default:
                                        return settingUnknown
                                }
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
                            target: inheritStackProvider
                            onPropertiesChanged:
                            {
                                provider.forcePropertiesChanged();
                            }
                        }

                        Connections
                        {
                            target: UM.ActiveTool
                            onPropertiesChanged:
                            {
                                // the values cannot be bound with UM.ActiveTool.properties.getValue() calls,
                                // so here we connect to the signal and update the those values.
                                if (typeof UM.ActiveTool.properties.getValue("SelectedObjectId") !== "undefined")
                                {
                                    const selectedObjectId = UM.ActiveTool.properties.getValue("SelectedObjectId");
                                    if (addedSettingsModel.visibilityHandler.selectedObjectId != selectedObjectId)
                                    {
                                        addedSettingsModel.visibilityHandler.selectedObjectId = selectedObjectId;
                                    }
                                }
                                if (typeof UM.ActiveTool.properties.getValue("ContainerID") !== "undefined")
                                {
                                    const containerId = UM.ActiveTool.properties.getValue("ContainerID");
                                    if (provider.containerStackId != containerId)
                                    {
                                        provider.containerStackId = containerId;
                                    }
                                    if (inheritStackProvider.containerStackId != containerId)
                                    {
                                        inheritStackProvider.containerStackId = containerId;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Button
    {
        id: clearSupport
        anchors.top: items.bottom
        anchors.left: items.left
        anchors.topMargin: -15 * UM.Theme.getSize("default_margin").width/10
        //anchors.leftMargin: 5
        //width: 85//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
        height: 23 * UM.Theme.getSize("default_margin").width/10
        text: catalog.i18nc("@label", "Clear All Support")
        style: UM.Theme.styles.parameterbutton
        onClicked: removeAllSupportMesh.setPropertyValue("value", "True")
    }

    Button
    {
        id: rightButton
        anchors.top: items.bottom
        anchors.right: items.right
        anchors.topMargin: -15 * UM.Theme.getSize("default_margin").width/10
        anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
        //width: 85//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
        height: 23 * UM.Theme.getSize("default_margin").width/10
        text: catalog.i18nc("@label", "Done")
        style: UM.Theme.styles.parameterbutton
        onClicked: UM.Controller.setActiveTool(null)
    }

    UM.SettingPropertyProvider
    {
        id: removeAllSupportMesh
        containerStackId: Cura.MachineManager.activeMachineId
        key: "remove_all_support_mesh"
        watchedProperties: [ "value", "enabled", "description" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStackId: Cura.MachineManager.activeMachineId
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: printSequencePropertyProvider

        containerStackId: Cura.MachineManager.activeMachineId
        key: "print_sequence"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    SystemPalette { id: palette; }

    Component
    {
        id: settingTextField;

        Cura.SettingTextField { }
    }

    Component
    {
        id: settingComboBox;

        Cura.SettingComboBox { }
    }

    Component
    {
        id: settingExtruder;

        Cura.SettingExtruder { }
    }

    Component
    {
        id: settingOptionalExtruder

        Cura.SettingOptionalExtruder { }
    }

    Component
    {
        id: settingCheckBox;

        Cura.SettingCheckBox { }
    }

    Component
    {
        id: settingCategory;

        Cura.SettingCategory { }
    }

    Component
    {
        id: settingUnknown;

        Cura.SettingUnknown { }
    }
}
