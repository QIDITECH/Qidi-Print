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

        Row
        {
            spacing: UM.Theme.getSize("default_margin").width

            Label
            {
                text: catalog.i18nc("@label","Mesh Type")
                font: UM.Theme.getFont("font1")
                color: UM.Theme.getColor("color4")
                height: UM.Theme.getSize("setting").height
                verticalAlignment: Text.AlignVCenter
            }

            UM.SettingPropertyProvider
            {
                id: meshTypePropertyProvider
                containerStackId: Cura.MachineManager.activeMachineId
                watchedProperties: [ "enabled" ]
            }

            ComboBox
            {
                id: meshTypeSelection
                style: UM.Theme.styles.combobox
                onActivated: {
                    UM.ActiveTool.setProperty("MeshType", model.get(index).type)
                }
                model: ListModel
                {
                    id: meshTypeModel
                    Component.onCompleted: meshTypeSelection.populateModel()
                }

                function populateModel()
                {
                    meshTypeModel.append({
                        type:  "",
                        text: catalog.i18nc("@label", "Normal model")
                    });
                    meshTypePropertyProvider.key = "support_mesh";
                    if(meshTypePropertyProvider.properties.enabled == "True")
                    {
                        meshTypeModel.append({
                            type:  "support_mesh",
                            text: catalog.i18nc("@label", "Print as support")
                        });
                    }
                    meshTypePropertyProvider.key = "anti_overhang_mesh";
                    if(meshTypePropertyProvider.properties.enabled == "True")
                    {
                        meshTypeModel.append({
                            type:  "anti_overhang_mesh",
                            text: catalog.i18nc("@label", "Don't support overlap with other models")
                        });
                    }
                    meshTypePropertyProvider.key = "cutting_mesh";
                    if(meshTypePropertyProvider.properties.enabled == "True")
                    {
                        meshTypeModel.append({
                            type:  "cutting_mesh",
                            text: catalog.i18nc("@label", "Modify settings for overlap with other models")
                        });
                    }
                    meshTypePropertyProvider.key = "infill_mesh";
                    if(meshTypePropertyProvider.properties.enabled == "True")
                    {
                        meshTypeModel.append({
                            type:  "infill_mesh",
                            text: catalog.i18nc("@label", "Modify settings for infill of other models")
                        });
                    }

                    meshTypeSelection.updateCurrentIndex();
                }

                function updateCurrentIndex()
                {
                    var mesh_type = UM.ActiveTool.properties.getValue("MeshType");
                    meshTypeSelection.currentIndex = -1;
                    for(var index=0; index < meshTypeSelection.model.count; index++)
                    {
                        if(meshTypeSelection.model.get(index).type == mesh_type)
                        {
                            meshTypeSelection.currentIndex = index;
                            return;
                        }
                    }
                    meshTypeSelection.currentIndex = 0;
                }
            }

            Connections
            {
                target: Cura.MachineManager
                onGlobalContainerChanged:
                {
                    meshTypeSelection.model.clear();
                    meshTypeSelection.populateModel();
                }
            }

            Connections
            {
                target: UM.Selection
                onSelectionChanged: meshTypeSelection.updateCurrentIndex()
            }

        }

        Column
        {
            // This is to ensure that the panel is first increasing in size up to 200 and then shows a scrollbar.
            // It kinda looks ugly otherwise (big panel, no content on it)
            id: currentSettings
            property int maximumHeight: 200 * screenScaleFactor
            height: Math.min(contents.count * (UM.Theme.getSize("section").height + UM.Theme.getSize("default_lining").height), maximumHeight)
            visible: meshTypeSelection.model.get(meshTypeSelection.currentIndex).type != "anti_overhang_mesh"

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
                        filter:
                        {
                            if (printSequencePropertyProvider.properties.value == "one_at_a_time")
                            {
                                return {"settable_per_meshgroup": true};
                            }
                            return {"settable_per_mesh": true};
                        }
                        exclude:
                        {
                            var excluded_settings = [ "support_mesh", "anti_overhang_mesh", "cutting_mesh", "infill_mesh" ];

                            if(meshTypeSelection.model.get(meshTypeSelection.currentIndex).type == "support_mesh")
                            {
                                excluded_settings = excluded_settings.concat(base.all_categories_except_support);
                            }
                            return excluded_settings;
                        }

                        visibilityHandler: Cura.PerObjectSettingVisibilityHandler
                        {
                            selectedObjectId: UM.ActiveTool.properties.getValue("SelectedObjectId")
                        }
                    }

                    delegate: Row
                    {
                        spacing: - UM.Theme.getSize("default_margin").width
                        Loader
                        {
                            id: settingLoader
                            width: UM.Theme.getSize("setting").width
                            height: UM.Theme.getSize("section").height

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

                        Button
                        {
                            width: Math.round(UM.Theme.getSize("setting").height / 2)
                            height: UM.Theme.getSize("setting").height

                            onClicked: addedSettingsModel.setVisible(model.key, false)

                            style: ButtonStyle
                            {
                                background: Item
                                {
                                    UM.RecolorImage
                                    {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        height: width
                                        sourceSize.width: width
                                        sourceSize.height: width
                                        color: control.hovered ? UM.Theme.getColor("setting_control_button_hover") : UM.Theme.getColor("setting_control_button")
                                        source: UM.Theme.getIcon("minus")
                                    }
                                }
                            }
                        }

                        // Specialty provider that only watches global_inherits (we cant filter on what property changed we get events
                        // so we bypass that to make a dedicated provider).
                        UM.SettingPropertyProvider
                        {
                            id: provider

                            containerStackId: UM.ActiveTool.properties.getValue("ContainerID")
                            key: model.key
                            watchedProperties: [ "value", "enabled", "validationState" ]
                            storeIndex: 0
                            removeUnusedValue: false
                        }

                        UM.SettingPropertyProvider
                        {
                            id: inheritStackProvider
                            containerStackId: UM.ActiveTool.properties.getValue("ContainerID")
                            key: model.key
                            watchedProperties: [ "limit_to_extruder" ]
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

        Button
        {
            id: customiseSettingsButton;
            height: UM.Theme.getSize("setting_control").height;
            visible: currentSettings.visible

            text: catalog.i18nc("@action:button", "Select settings");

            style: UM.Theme.styles.savebutton
            /*style: ButtonStyle
            {
                background: Rectangle
                {
                    width: control.width;
                    height: control.height;
                    border.width: UM.Theme.getSize("default_lining").width;
                    border.color: control.pressed ? UM.Theme.getColor("action_button_active_border") :
                                  control.hovered ? UM.Theme.getColor("action_button_hovered_border") : UM.Theme.getColor("action_button_border")
                    color: control.pressed ? UM.Theme.getColor("action_button_active") :
                           control.hovered ? UM.Theme.getColor("action_button_hovered") : UM.Theme.getColor("action_button")
                }
                label: Label
                {
                    text: control.text;
                    color: UM.Theme.getColor("setting_control_text");
                    font: UM.Theme.getFont("default")
                    anchors.centerIn: parent
                }
            }*/

            onClicked:
            {
                settingPickDialog.visible = true;
                if (meshTypeSelection.model.get(meshTypeSelection.currentIndex).type == "support_mesh")
                {
                    settingPickDialog.additional_excluded_settings = base.all_categories_except_support;
                }
                else
                {
                    settingPickDialog.additional_excluded_settings = []
                }
            }
        }
    }


    UM.Dialog {
        id: settingPickDialog

        title: catalog.i18nc("@title:window", "Select Settings to Customize for this model")
        width: screenScaleFactor * 430
        height: screenScaleFactor * 400

        property var additional_excluded_settings

        onVisibilityChanged:
        {
            // force updating the model to sync it with addedSettingsModel
            if(visible)
            {
                // Set skip setting, it will prevent from resetting selected mesh_type
                contents.model.visibilityHandler.addSkipResetSetting(meshTypeSelection.model.get(meshTypeSelection.currentIndex).type)
                listview.model.forceUpdate()

                updateFilter()
            }
        }

        function updateFilter()
        {
            var new_filter = {};
            if (printSequencePropertyProvider.properties.value == "one_at_a_time")
            {
                new_filter["settable_per_meshgroup"] = true;
            }
            else
            {
                new_filter["settable_per_mesh"] = true;
            }

            if(filterInput.text != "")
            {
                new_filter["i18n_label"] = "*" + filterInput.text;
            }

            listview.model.filter = new_filter;
        }

        TextField {
            id: filterInput

            anchors {
                top: parent.top
                topMargin: 8 * UM.Theme.getSize("default_margin").width/10
                left: parent.left
                leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
                right: toggleShowAll.left
                rightMargin: UM.Theme.getSize("default_margin").width
            }
            height: 20 * UM.Theme.getSize("default_margin").width/10
            style: UM.Theme.styles.text_field

            placeholderText: catalog.i18nc("@label:textbox", "Filter...");

            onTextChanged: settingPickDialog.updateFilter()
        }

        CheckBox
        {
            id: toggleShowAll

            anchors {
                top: filterInput.top
                right: parent.right
                rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
            }
            style: UM.Theme.styles.checkbox

            text: catalog.i18nc("@label:checkbox", "Show all")
            checked: listview.model.showAll
            onClicked:
            {
                listview.model.showAll = checked;
            }
        }

        ScrollView
        {
            id: scrollView

            anchors
            {
                top: filterInput.bottom;
                topMargin: 3 * UM.Theme.getSize("default_margin").width/10
                left: parent.left;
                leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
                right: parent.right;
                rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
                bottom: parent.bottom;
            }
            style: UM.Theme.styles.scrollview;
            ListView
            {
                id:listview
                model: UM.SettingDefinitionsModel
                {
                    id: definitionsModel;
                    containerId: Cura.MachineManager.activeDefinitionId
                    visibilityHandler: UM.SettingPreferenceVisibilityHandler {}
                    expanded: [ "*" ]
                    exclude:
                    {
                        var excluded_settings = [ "machine_settings", "command_line_settings", "support_mesh", "anti_overhang_mesh", "cutting_mesh", "infill_mesh","experimental","platform_adhesion","dual","travel","cooling" ];
                        excluded_settings = excluded_settings.concat(settingPickDialog.additional_excluded_settings);
                        return excluded_settings;
                    }
                }
                delegate:Loader
                {
                    id: loader

                    width: parent.width
                    height: model.type != undefined ? UM.Theme.getSize("section").height : 0;

                    property var definition: model
                    property var settingDefinitionsModel: definitionsModel

                    asynchronous: true
                    source:
                    {
                        switch(model.type)
                        {
                            case "category":
                                return "PerObjectCategory.qml"
                            default:
                                return "PerObjectItem.qml"
                        }
                    }
                }
                Component.onCompleted: settingPickDialog.updateFilter()
            }
        }

        rightButtons: [
            Button {
                text: catalog.i18nc("@action:button", "Close");
                onClicked: {
                    settingPickDialog.visible = false;
                }
                style: UM.Theme.styles.parameterbutton
                height: 22 * UM.Theme.getSize("default_margin").width/10
            }
        ]
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
