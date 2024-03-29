// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI

QD.Dialog
{
    id: base
    title: catalog.i18nc("@title:window", "Save Project")

    minimumWidth: 500 * screenScaleFactor
    minimumHeight: 400 * screenScaleFactor
    width: minimumWidth
    height: minimumHeight

    property int spacerHeight: 10 * screenScaleFactor

    property bool dontShowAgain: true

    signal yes();

    function accept() {  // pressing enter will call this function
        close();
        yes();
    }

    onClosing:
    {
        QD.Preferences.setValue("qidi/dialog_on_project_save", !dontShowAgainCheckbox.checked)
    }

    onVisibleChanged:
    {
        if(visible)
        {
            dontShowAgain = !QD.Preferences.getValue("qidi/dialog_on_project_save")
        }
    }

    Item
    {
        anchors.fill: parent

        QD.SettingDefinitionsModel
        {
            id: definitionsModel
            containerId: base.visible ? QIDI.MachineManager.activeMachine != null ? QIDI.MachineManager.activeMachine.definition.id: "" : ""
            showAll: true
            exclude: ["command_line_settings"]
            showAncestors: true
            expanded: ["*"]
            visibilityHandler: QD.SettingPreferenceVisibilityHandler { }
        }

        SystemPalette
        {
            id: palette
        }
        Label
        {
            id: mainHeading
            width: parent.width
            text: catalog.i18nc("@action:title", "Summary - QIDI Project")
            font.pointSize: 18
            anchors.top: parent.top
        }
        ScrollView
        {
            id: scroll
            width: parent.width
            anchors
            {
                top: mainHeading.bottom
                topMargin: QD.Theme.getSize("default_margin").height
                bottom: controls.top
                bottomMargin: QD.Theme.getSize("default_margin").height
            }
            style: QD.Theme.styles.scrollview
            ColumnLayout
            {
                spacing: QD.Theme.getSize("default_margin").height
                Column
                {
                    Label
                    {
                        id: settingsHeading
                        text: catalog.i18nc("@action:label", "Printer settings")
                        font.bold: true
                    }
                    Row
                    {
                        width: parent.width
                        height: childrenRect.height
                        Label
                        {
                            text: catalog.i18nc("@action:label", "Type")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: (QIDI.MachineManager.activeMachine == null) ? "" : QIDI.MachineManager.activeMachine.definition.name
                            width: Math.floor(scroll.width / 3) | 0
                        }
                    }
                    Row
                    {
                        width: parent.width
                        height: childrenRect.height
                        Label
                        {
                            text: QIDI.MachineManager.activeMachineNetworkGroupName != "" ? catalog.i18nc("@action:label", "Printer Group") : catalog.i18nc("@action:label", "Name")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text:
                            {
                                if(QIDI.MachineManager.activeMachineNetworkGroupName != "")
                                {
                                    return QIDI.MachineManager.activeMachineNetworkGroupName
                                }
                                if(QIDI.MachineManager.activeMachine)
                                {
                                    return QIDI.MachineManager.activeMachine.name
                                }
                                return ""
                            }
                            width: Math.floor(scroll.width / 3) | 0
                        }
                    }
                }
                Repeater
                {
                    width: parent.width
                    height: childrenRect.height
                    model: QIDI.MachineManager.activeMachine ? QIDI.MachineManager.activeMachine.extruderList : null
                    delegate: Column
                    {
                        height: childrenRect.height
                        width: parent.width
                        property string variantName:
                        {
                            var extruder = modelData
                            var variant_name = extruder.variant.name
                            return (variant_name !== undefined) ? variant_name : ""
                        }
                        property string materialName:
                        {
                            var extruder = modelData
                            var material_name = extruder.material.name
                            return (material_name !== undefined) ? material_name : ""
                        }
                        Label
                        {
                            text: {
                                var extruder = Number(modelData.position)
                                var extruder_id = ""
                                if(!isNaN(extruder))
                                {
                                    extruder_id = extruder + 1 // The extruder counter start from One and not Zero
                                }
                                else
                                {
                                    extruder_id = modelData.position
                                }

                                return catalog.i18nc("@action:label", "Extruder %1").arg(extruder_id)
                            }
                            font.bold: true
                            enabled: modelData.isEnabled
                        }
                        Row
                        {
                            width: parent.width
                            height: childrenRect.height

                            Label
                            {
                                text:
                                {
                                    if(variantName !== "" && materialName !== "")
                                    {
                                        return catalog.i18nc("@action:label", "%1 & material").arg(QIDI.MachineManager.activeDefinitionVariantsName)
                                    }
                                    return catalog.i18nc("@action:label", "Material")
                                }
                                width: Math.floor(scroll.width / 3) | 0
                                enabled: modelData.isEnabled
                            }
                            Label
                            {
                                text:
                                {
                                    if(variantName !== "" && materialName !== "")
                                    {
                                        return variantName + ", " + materialName
                                    }
                                    return materialName
                                }
                                enabled: modelData.isEnabled
                                width: Math.floor(scroll.width / 3) | 0
                            }
                        }
                    }
                }
                Column
                {
                    width: parent.width
                    height: childrenRect.height
                    Label
                    {
                        text: catalog.i18nc("@action:label", "Profile settings")
                        font.bold: true
                    }
                    Row
                    {
                        width: parent.width
                        Label
                        {
                            text: catalog.i18nc("@action:label", "Not in profile")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: catalog.i18ncp("@action:label", "%1 override", "%1 overrides", QIDI.MachineManager.numUserSettings).arg(QIDI.MachineManager.numUserSettings)
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        visible: QIDI.MachineManager.numUserSettings
                    }
                    Row
                    {
                        width: parent.width
                        height: childrenRect.height
                        Label
                        {
                            text: catalog.i18nc("@action:label", "Name")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: QIDI.MachineManager.activeQualityOrQualityChangesName
                            width: Math.floor(scroll.width / 3) | 0
                        }
                    }

                    // Intent
                    Row
                    {
                        width: parent.width
                        height: childrenRect.height
                        Label
                        {
                            text: catalog.i18nc("@action:label", "Intent")
                            width: Math.floor(scroll.width / 3) | 0
                        }
                        Label
                        {
                            text: QIDI.MachineManager.activeIntentCategory
                            width: Math.floor(scroll.width / 3) | 0
                        }
                    }
                }
            }
        }
        Item
        {
            id: controls
            width: parent.width
            height: childrenRect.height
            anchors.bottom: parent.bottom
            CheckBox
            {
                id: dontShowAgainCheckbox
                anchors.left: parent.left
                text: catalog.i18nc("@action:label", "Don't show project summary on save again")
                checked: dontShowAgain
            }
            Button
            {
                id: cancel_button
                anchors
                {
                    right: ok_button.left
                    rightMargin: QD.Theme.getSize("default_margin").width
                }
                text: catalog.i18nc("@action:button","Cancel");
                enabled: true
                onClicked: close()
            }
            Button
            {
                id: ok_button
                anchors.right: parent.right
                text: catalog.i18nc("@action:button","Save");
                enabled: true
                onClicked:
                {
                    close()
                    yes()
                }
            }
        }
    }
}
