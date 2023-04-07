// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.1 as QD
import QIDI 1.0 as QIDI


Button
{
    id: machineSelectorButton

    width: parent.width
    height: QD.Theme.getSize("action_button").height
    leftPadding: QD.Theme.getSize("thick_margin").width
    rightPadding: QD.Theme.getSize("thick_margin").width
    checkable: true
    hoverEnabled: true

    property bool selected: checked
    property bool printerTypeLabelAutoFit: false

    property var outputDevice: null
    property var printerTypesList: []

    // Indicates if only to update the printer types list when this button is checked
    property bool updatePrinterTypesOnlyWhenChecked: true

    property var updatePrinterTypesFunction: updatePrinterTypesList
    // This function converts the printer type string to another string.
    property var printerTypeLabelConversionFunction: QIDI.MachineManager.getAbbreviatedMachineName

    function updatePrinterTypesList()
    {
        var to_update = (updatePrinterTypesOnlyWhenChecked && checked) || !updatePrinterTypesOnlyWhenChecked
        printerTypesList = (to_update && outputDevice != null) ? outputDevice.uniquePrinterTypes : []
    }

    contentItem: Item
    {
        width: machineSelectorButton.width - machineSelectorButton.leftPadding
        height: QD.Theme.getSize("action_button").height

        Label
        {
            id: buttonText
            anchors
            {
                left: parent.left
                right: printerTypes.left
                verticalCenter: parent.verticalCenter
            }
            text: machineSelectorButton.text
            color: enabled ? QD.Theme.getColor("text") : QD.Theme.getColor("small_button_text")
            font: QD.Theme.getFont("medium")
            visible: text != ""
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Row
        {
            id: printerTypes
            width: childrenRect.width

            anchors
            {
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            spacing: QD.Theme.getSize("narrow_margin").width
            visible: (updatePrinterTypesOnlyWhenChecked && machineSelectorButton.checked) || !updatePrinterTypesOnlyWhenChecked

            Repeater
            {
                model: printerTypesList
                delegate: QIDI.PrinterTypeLabel
                {
                    autoFit: printerTypeLabelAutoFit
                    text: printerTypeLabelConversionFunction(modelData)
                }
            }
        }
    }

    background: Rectangle
    {
        id: backgroundRect
        color:
        {
            if (!machineSelectorButton.enabled)
            {
                return QD.Theme.getColor("action_button_disabled")
            }
            return machineSelectorButton.hovered ? QD.Theme.getColor("action_button_hovered") : "transparent"
        }
        radius: QD.Theme.getSize("action_button_radius").width
        border.width: QD.Theme.getSize("default_lining").width
        border.color: machineSelectorButton.selected ? QD.Theme.getColor("primary") : "transparent"
    }

    Connections
    {
        target: outputDevice
        function onUniqueConfigurationsChanged() { updatePrinterTypesFunction() }
    }

    Connections
    {
        target: QIDI.MachineManager
        function onOutputDevicesChanged() { updatePrinterTypesFunction() }
    }

    Component.onCompleted: updatePrinterTypesFunction()
}
