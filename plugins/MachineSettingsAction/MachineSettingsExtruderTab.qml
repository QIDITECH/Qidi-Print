// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This component contains the content for the "Welcome" page of the welcome on-boarding process.
//
Item
{
    id: base
    QD.I18nCatalog { id: catalog; name: "qidi" }

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top

    property int labelWidth: 210 * screenScaleFactor
    property int controlWidth: (QD.Theme.getSize("setting_control").width * 3 / 4) | 0
    property var labelFont: QD.Theme.getFont("default")

    property int columnWidth: ((parent.width - 2 * QD.Theme.getSize("default_margin").width) / 2) | 0
    property int columnSpacing: 3 * screenScaleFactor
    property int propertyStoreIndex: manager ? manager.storeContainerIndex : 1  // definition_changes

    property string extruderStackId: ""
    property int extruderPosition: 0
    property var forceUpdateFunction: manager.forceUpdate

    function updateMaterialDiameter()
    {
        manager.updateMaterialForDiameter(extruderPosition)
    }

    Item
    {
        id: upperBlock
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("default_margin").width

        height: childrenRect.height

        // =======================================
        // Left-side column "Nozzle Settings"
        // =======================================
        Column
        {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width * 2 / 3

            spacing: base.columnSpacing

            Label   // Title Label
            {
                text: catalog.i18nc("@title:label", "Nozzle Settings")
                font: QD.Theme.getFont("medium_bold")
                renderType: Text.NativeRendering
            }

            QIDI.NumericTextFieldWithUnit  // "Nozzle size"
            {
                id: extruderNozzleSizeField
                visible: !QIDI.MachineManager.activeMachine.hasVariants
                containerStackId: base.extruderStackId
                settingKey: "machine_nozzle_size"
                settingStoreIndex: propertyStoreIndex
                labelText: catalog.i18nc("@label", "Nozzle size")
                labelFont: base.labelFont
                labelWidth: base.labelWidth
                controlWidth: base.controlWidth
                unitText: catalog.i18nc("@label", "mm")
                forceUpdateOnChangeFunction: forceUpdateFunction
            }

            QIDI.NumericTextFieldWithUnit  // "Compatible material diameter"
            {
                id: extruderCompatibleMaterialDiameterField
                containerStackId: base.extruderStackId
                settingKey: "material_diameter"
                settingStoreIndex: propertyStoreIndex
                labelText: catalog.i18nc("@label", "Compatible material diameter")
                labelFont: base.labelFont
                labelWidth: base.labelWidth
                controlWidth: base.controlWidth
                unitText: catalog.i18nc("@label", "mm")
                forceUpdateOnChangeFunction: forceUpdateFunction
                // Other modules won't automatically respond after the user changes the value, so we need to force it.
                afterOnEditingFinishedFunction: updateMaterialDiameter
            }

            QIDI.NumericTextFieldWithUnit  // "Nozzle offset X"
            {
                id: extruderNozzleOffsetXField
                containerStackId: base.extruderStackId
                settingKey: "machine_nozzle_offset_x"
                settingStoreIndex: propertyStoreIndex
                labelText: catalog.i18nc("@label", "Nozzle offset X")
                labelFont: base.labelFont
                labelWidth: base.labelWidth
                controlWidth: base.controlWidth
                unitText: catalog.i18nc("@label", "mm")
                minimum: Number.NEGATIVE_INFINITY
                forceUpdateOnChangeFunction: forceUpdateFunction
            }

            QIDI.NumericTextFieldWithUnit  // "Nozzle offset Y"
            {
                id: extruderNozzleOffsetYField
                containerStackId: base.extruderStackId
                settingKey: "machine_nozzle_offset_y"
                settingStoreIndex: propertyStoreIndex
                labelText: catalog.i18nc("@label", "Nozzle offset Y")
                labelFont: base.labelFont
                labelWidth: base.labelWidth
                controlWidth: base.controlWidth
                unitText: catalog.i18nc("@label", "mm")
                minimum: Number.NEGATIVE_INFINITY
                forceUpdateOnChangeFunction: forceUpdateFunction
            }

            QIDI.NumericTextFieldWithUnit  // "Cooling Fan Number"
            {
                id: extruderNozzleCoolingFanNumberField
                containerStackId: base.extruderStackId
                settingKey: "machine_extruder_cooling_fan_number"
                settingStoreIndex: propertyStoreIndex
                labelText: catalog.i18nc("@label", "Cooling Fan Number")
                labelFont: base.labelFont
                labelWidth: base.labelWidth
                controlWidth: base.controlWidth
                unitText: ""
                decimals: 0
                forceUpdateOnChangeFunction: forceUpdateFunction
            }
        }
    }

    Item  // Extruder Start and End G-code
    {
        id: lowerBlock
        anchors.top: upperBlock.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("default_margin").width

        QIDI.GcodeTextArea   // "Extruder Start G-code"
        {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: QD.Theme.getSize("default_margin").height
            anchors.left: parent.left
            width: base.columnWidth - QD.Theme.getSize("default_margin").width

            labelText: catalog.i18nc("@title:label", "Extruder Start G-code")
            containerStackId: base.extruderStackId
            settingKey: "machine_extruder_start_code"
            settingStoreIndex: propertyStoreIndex
        }

        QIDI.GcodeTextArea   // "Extruder End G-code"
        {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.bottomMargin: QD.Theme.getSize("default_margin").height
            anchors.right: parent.right
            width: base.columnWidth - QD.Theme.getSize("default_margin").width

            labelText: catalog.i18nc("@title:label", "Extruder End G-code")
            containerStackId: base.extruderStackId
            settingKey: "machine_extruder_end_code"
            settingStoreIndex: propertyStoreIndex
        }
    }
}
