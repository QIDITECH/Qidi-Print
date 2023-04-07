// Copyright (c) 2017 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI
import ".."


Item
{
    id: base
    width: childrenRect.width
    height: childrenRect.height
    property var allCategoriesExceptSupport: [ "machine_settings", "resolution", "shell", "infill", "material", "speed",
                                    "travel", "cooling", "platform_adhesion", "dual", "meshfix", "blackmagic", "experimental"]

    readonly property string normalMeshType: ""
    readonly property string supportMeshType: "support_mesh"
    readonly property string cuttingMeshType: "cutting_mesh"
    readonly property string infillMeshType: "infill_mesh"
    readonly property string antiOverhangMeshType: "anti_overhang_mesh"

    property var currentMeshType: QD.ActiveTool.properties.getValue("MeshType")

    // Update the view every time the currentMeshType changes
    onCurrentMeshTypeChanged:
    {
        var type = currentMeshType

        // set checked state of mesh type buttons
        updateMeshTypeCheckedState(type)

        // update active type label
        for (var button in meshTypeButtons.children)
        {
            if (meshTypeButtons.children[button].checked)
            {
                meshTypeLabel.text = catalog.i18nc("@label", "Mesh Type") + ": " + meshTypeButtons.children[button].text
                break
            }
        }
        visibility_handler.addSkipResetSetting(currentMeshType)
    }

    function updateMeshTypeCheckedState(type)
    {
        // set checked state of mesh type buttons
        normalButton.checked = type === normalMeshType
        supportMeshButton.checked = type === supportMeshType
        overlapMeshButton.checked = type === infillMeshType || type === cuttingMeshType
        antiOverhangMeshButton.checked = type === antiOverhangMeshType
    }

    function setMeshType(type)
    {
        QD.ActiveTool.setProperty("MeshType", type)
        updateMeshTypeCheckedState(type)
    }

    QD.I18nCatalog { id: catalog; name: "qidi"}

    Column
    {
        id: items
        anchors.top: parent.top;
        anchors.left: parent.left;

        spacing: QD.Theme.getSize("default_margin").height

        Row // Mesh type buttons
        {
            id: meshTypeButtons
            spacing: QD.Theme.getSize("default_margin").width

            QIDI.ToolbarButton
            {
                id: normalButton
                width: 30 * QD.Theme.getSize("size").width
                height: 30 * QD.Theme.getSize("size").width
                text: catalog.i18nc("@label", "Normal model")
                hasBorderElement: true
                toolItem: QD.RecolorImage
                {
                    source: QD.Theme.getIcon("Infill0")
                    color: QD.Theme.getColor("blue_6")
                    width: normalButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                    height: normalButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                }
                z: 4
                onClicked: setMeshType(normalMeshType)
            }

            QIDI.ToolbarButton
            {
                id: supportMeshButton
                width: 30 * QD.Theme.getSize("size").width
                height: 30 * QD.Theme.getSize("size").width
                text: catalog.i18nc("@label", "Print as support")
                hasBorderElement: true
                toolItem: QD.RecolorImage
                {
                    source: QD.Theme.getIcon("MeshTypeSupport")
                    color: QD.Theme.getColor("blue_6")
                    width: supportMeshButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                    height: supportMeshButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                }
                z: 3
                onClicked: setMeshType(supportMeshType)
            }

            QIDI.ToolbarButton
            {
                id: overlapMeshButton
                width: 30 * QD.Theme.getSize("size").width
                height: 30 * QD.Theme.getSize("size").width
                text: catalog.i18nc("@label", "Modify settings for overlaps")
                hasBorderElement: true
                toolItem: QD.RecolorImage
                {
                    source: QD.Theme.getIcon("MeshTypeIntersect")
                    color: QD.Theme.getColor("blue_6")
                    width: overlapMeshButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                    height: overlapMeshButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                }
                z: 2
                onClicked: setMeshType(infillMeshType)
            }

            QIDI.ToolbarButton
            {
                id: antiOverhangMeshButton
                width: 30 * QD.Theme.getSize("size").width
                height: 30 * QD.Theme.getSize("size").width
                text: catalog.i18nc("@label", "Don't support overlaps")
                hasBorderElement: true
                toolItem: QD.RecolorImage
                {
                    source: QD.Theme.getIcon("BlockSupportOverlaps")
                    color: QD.Theme.getColor("blue_6")
                    width: antiOverhangMeshButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                    height: antiOverhangMeshButton.hovered ? 24 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
                }
                z: 1
                onClicked: setMeshType(antiOverhangMeshType)
            }
        }

        Label
        {
            id: meshTypeLabel
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("text")
            height: QD.Theme.getSize("setting").height
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox
        {
            id: infillOnlyComboBox
            width: parent.width / 2 - QD.Theme.getSize("default_margin").width

            model: ListModel
            {
                id: infillOnlyComboBoxModel

                Component.onCompleted: {
                    append({ text: catalog.i18nc("@item:inlistbox", "Infill mesh only") })
                    append({ text: catalog.i18nc("@item:inlistbox", "Cutting mesh") })
                }
            }

            visible: currentMeshType === infillMeshType || currentMeshType === cuttingMeshType

            onActivated:
            {
                if (index == 0){
                    setMeshType(infillMeshType)
                } else {
                    setMeshType(cuttingMeshType)
                }
            }

            Binding
            {
                target: infillOnlyComboBox
                property: "currentIndex"
                value: currentMeshType === infillMeshType ? 0 : 1
            }
        }

        Column // List of selected Settings to override for the selected object
        {
            // This is to ensure that the panel is first increasing in size up to 200 and then shows a scrollbar.
            // It kinda looks ugly otherwise (big panel, no content on it)
            id: currentSettings
            property int maximumHeight: 200 * screenScaleFactor
            height: Math.min(contents.count * (QD.Theme.getSize("section").height + QD.Theme.getSize("default_lining").height), maximumHeight)
            visible: currentMeshType != "anti_overhang_mesh"

            ScrollView
            {
                height: parent.height
                width: QD.Theme.getSize("setting").width + QD.Theme.getSize("default_margin").width
                style: QD.Theme.styles.scrollview

                ListView
                {
                    id: contents
                    spacing: QD.Theme.getSize("default_lining").height

                    model: QD.SettingDefinitionsModel
                    {
                        id: addedSettingsModel
                        containerId: QIDI.MachineManager.activeMachine != null ? QIDI.MachineManager.activeMachine.definition.id: ""
                        expanded: [ "*" ]
                        filter:
                        {
                            if (printSequencePropertyProvider.properties.value == "one_at_a_time")
                            {
                                return {"settable_per_meshgroup": true}
                            }
                            return {"settable_per_mesh": true}
                        }
                        exclude:
                        {
                            var excluded_settings = [ "support_mesh", "anti_overhang_mesh", "cutting_mesh", "infill_mesh" ]

                            if (currentMeshType == "support_mesh")
                            {
                                excluded_settings = excluded_settings.concat(base.allCategoriesExceptSupport)
                            }
                            return excluded_settings
                        }

                        visibilityHandler: QIDI.PerObjectSettingVisibilityHandler
                        {
                            id: visibility_handler
                            selectedObjectId: QD.ActiveTool.properties.getValue("SelectedObjectId")
                        }

                        // For some reason the model object is updated after removing him from the memory and
                        // it happens only on Windows. For this reason, set the destroyed value manually.
                        Component.onDestruction:
                        {
                            setDestroyed(true)
                        }
                    }

                    delegate: Row
                    {
                        spacing: - QD.Theme.getSize("default_margin").width
                        Loader
                        {
                            id: settingLoader
                            width: QD.Theme.getSize("setting").width
                            height: QD.Theme.getSize("section").height
                            enabled: provider.properties.enabled === "True"
                            property var definition: model
                            property var settingDefinitionsModel: addedSettingsModel
                            property var propertyProvider: provider
                            property var globalPropertyProvider: inheritStackProvider
                            property var externalResetHandler: false

                            //Qt5.4.2 and earlier has a bug where this causes a crash: https://bugreports.qt.io/browse/QTBUG-35989
                            //In addition, while it works for 5.5 and higher, the ordering of the actual combo box drop down changes,
                            //causing nasty issues when selecting different options. So disable asynchronous loading of enum type completely.
                            asynchronous: model.type != "enum" && model.type != "extruder"

                            onLoaded:
                            {
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
                            width: Math.round(QD.Theme.getSize("setting").height / 2)
                            height: QD.Theme.getSize("setting").height

                            onClicked: addedSettingsModel.setVisible(model.key, false)

                            style: ButtonStyle
                            {
                                background: Item
                                {
                                    QD.RecolorImage
                                    {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        height: width
                                        sourceSize.height: width
                                        color: control.hovered ? QD.Theme.getColor("setting_control_button_hover") : QD.Theme.getColor("setting_control_button")
                                        source: QD.Theme.getIcon("Minus")
                                    }
                                }
                            }
                        }

                        // Specialty provider that only watches global_inherits (we cant filter on what property changed we get events
                        // so we bypass that to make a dedicated provider).
                        QD.SettingPropertyProvider
                        {
                            id: provider

                            containerStackId: QD.ActiveTool.properties.getValue("ContainerID")
                            key: model.key
                            watchedProperties: [ "value", "enabled", "validationState" ]
                            storeIndex: 0
                            removeUnusedValue: false
                        }

                        QD.SettingPropertyProvider
                        {
                            id: inheritStackProvider
                            containerStackId: QD.ActiveTool.properties.getValue("ContainerID")
                            key: model.key
                            watchedProperties: [ "limit_to_extruder" ]
                        }

                        Connections
                        {
                            target: inheritStackProvider
                            function onPropertiesChanged() { provider.forcePropertiesChanged() }
                        }

                        Connections
                        {
                            target: QD.ActiveTool
                            function onPropertiesChanged()
                            {
                                // the values cannot be bound with QD.ActiveTool.properties.getValue() calls,
                                // so here we connect to the signal and update the those values.
                                if (typeof QD.ActiveTool.properties.getValue("SelectedObjectId") !== "undefined")
                                {
                                    const selectedObjectId = QD.ActiveTool.properties.getValue("SelectedObjectId")
                                    if (addedSettingsModel.visibilityHandler.selectedObjectId != selectedObjectId)
                                    {
                                        addedSettingsModel.visibilityHandler.selectedObjectId = selectedObjectId
                                    }
                                }
                                if (typeof QD.ActiveTool.properties.getValue("ContainerID") !== "undefined")
                                {
                                    const containerId = QD.ActiveTool.properties.getValue("ContainerID")
                                    if (provider.containerStackId != containerId)
                                    {
                                        provider.containerStackId = containerId
                                    }
                                    if (inheritStackProvider.containerStackId != containerId)
                                    {
                                        inheritStackProvider.containerStackId = containerId
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        QIDI.SecondaryButton
        {
            id: customiseSettingsButton;
            height: 20 * QD.Theme.getSize("size").height;
            visible: currentSettings.visible
            backgroundRadius: height / 2
            text: catalog.i18nc("@action:button", "Select settings");

            onClicked:
            {
                settingPickDialog.visible = true;
                if (currentMeshType == "support_mesh")
                {
                    settingPickDialog.additional_excluded_settings = base.allCategoriesExceptSupport;
                }
                else
                {
                    settingPickDialog.additional_excluded_settings = []
                }
            }
        }

    }

    SettingPickDialog
    {
        id: settingPickDialog
    }

    QD.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStack: QIDI.MachineManager.activeMachine
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    QD.SettingPropertyProvider
    {
        id: printSequencePropertyProvider

        containerStack: QIDI.MachineManager.activeMachine
        key: "print_sequence"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    SystemPalette { id: palette }

    Component
    {
        id: settingTextField

        QIDI.SettingTextField { }
    }

    Component
    {
        id: settingComboBox

        QIDI.SettingComboBox { }
    }

    Component
    {
        id: settingExtruder

        QIDI.SettingExtruder { }
    }

    Component
    {
        id: settingOptionalExtruder

        QIDI.SettingOptionalExtruder { }
    }

    Component
    {
        id: settingCheckBox

        QIDI.SettingCheckBox { }
    }

    Component
    {
        id: settingCategory

        QIDI.SettingCategory { }
    }

    Component
    {
        id: settingUnknown

        QIDI.SettingUnknown { }
    }
}
