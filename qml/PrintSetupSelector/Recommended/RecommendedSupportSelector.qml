// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 2.3 as Controls2

import QD 1.2 as QD
import QIDI 1.0 as QIDI


//
//  Enable support
//
Item
{
    id: enableSupportRow
    height: childrenRect.height

    property real labelColumnWidth: Math.round(width / 3)

    QIDI.IconWithText
    {
        id: enableSupportRowTitle
        anchors.top: parent.top
        anchors.left: parent.left
        visible: enableSupportCheckBox.visible
        source: QD.Theme.getIcon("Support")
        text: catalog.i18nc("@label", "Support")
        font: QD.Theme.getFont("medium")
        width: labelColumnWidth
    }

    Item
    {
        id: enableSupportContainer
        height: enableSupportCheckBox.height

        anchors
        {
            left: enableSupportRowTitle.right
            right: parent.right
            verticalCenter: enableSupportRowTitle.verticalCenter
        }

        CheckBox
        {
            id: enableSupportCheckBox
            anchors.verticalCenter: parent.verticalCenter

            property alias _hovered: enableSupportMouseArea.containsMouse

            style: QD.Theme.styles.checkbox
            enabled: recommendedPrintSetup.settingsEnabled

            visible: supportEnabled.properties.enabled == "True"
            checked: supportEnabled.properties.value == "True"

            MouseArea
            {
                id: enableSupportMouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: supportEnabled.setPropertyValue("value", supportEnabled.properties.value != "True")

                onEntered:
                {
                    base.showTooltip(enableSupportCheckBox, Qt.point(-enableSupportContainer.x - QD.Theme.getSize("thick_margin").width, 0),
                        catalog.i18nc("@label", "Generate structures to support parts of the model which have overhangs. Without these structures, such parts would collapse during printing."))
                }
                onExited: base.hideTooltip()
            }
        }

        Controls2.ComboBox
        {
            id: supportExtruderCombobox

            height: QD.Theme.getSize("print_setup_big_item").height
            anchors
            {
                left: enableSupportCheckBox.right
                right: parent.right
                leftMargin: QD.Theme.getSize("thick_margin").width
                rightMargin: QD.Theme.getSize("thick_margin").width
                verticalCenter: parent.verticalCenter
            }

            enabled: recommendedPrintSetup.settingsEnabled
            visible: enableSupportCheckBox.visible && (supportEnabled.properties.value == "True") && (extrudersEnabledCount.properties.value > 1)
            textRole: "name"  // this solves that the combobox isn't populated in the first time QIDI is started

            model: extruderModel

            // knowing the extruder position, try to find the item index in the model
            function getIndexByPosition(position)
            {
                var itemIndex = -1  // if position is not found, return -1
                for (var item_index in model.items)
                {
                    var item = model.getItem(item_index)
                    if (item.index == position)
                    {
                        itemIndex = item_index
                        break
                    }
                }
                return itemIndex
            }

            onActivated:
            {
                if (model.getItem(index).enabled)
                {
                    forceActiveFocus();
                    supportExtruderNr.setPropertyValue("value", model.getItem(index).index);
                } else
                {
                    currentIndex = supportExtruderNr.properties.value;  // keep the old value
                }
            }

            currentIndex: (supportExtruderNr.properties.value !== undefined) ? supportExtruderNr.properties.value : 0

            property string color: "#fff"
            Connections
            {
                target: extruderModel
                function onModelChanged()
                {
                    var maybeColor = supportExtruderCombobox.model.getItem(supportExtruderCombobox.currentIndex).color
                    if (maybeColor)
                    {
                        supportExtruderCombobox.color = maybeColor
                    }
                }
            }
            onCurrentIndexChanged:
            {
                var maybeColor = supportExtruderCombobox.model.getItem(supportExtruderCombobox.currentIndex).color
                if(maybeColor)
                {
                    supportExtruderCombobox.color = maybeColor
                }
            }

            Binding
            {
                target: supportExtruderCombobox
                property: "currentIndex"
                value: supportExtruderCombobox.getIndexByPosition(supportExtruderNr.properties.value)
                // Sometimes when the value is already changed, the model is still being built.
                // The when clause ensures that the current index is not updated when this happens.
                when: supportExtruderCombobox.model.count > 0
            }

            indicator: QD.RecolorImage
            {
                id: downArrow
                x: supportExtruderCombobox.width - width - supportExtruderCombobox.rightPadding
                y: supportExtruderCombobox.topPadding + Math.round((supportExtruderCombobox.availableHeight - height) / 2)

                source: QD.Theme.getIcon("ChevronSingleDown")
                width: QD.Theme.getSize("standard_arrow").width
                height: QD.Theme.getSize("standard_arrow").height
                sourceSize.width: width + 5 * screenScaleFactor
                sourceSize.height: width + 5 * screenScaleFactor

                color: QD.Theme.getColor("setting_control_button")
            }

            background: Rectangle
            {
                color:
                {
                    if (!enabled)
                    {
                        return QD.Theme.getColor("setting_control_disabled")
                    }
                    if (supportExtruderCombobox.hovered || base.activeFocus)
                    {
                        return QD.Theme.getColor("setting_control_highlight")
                    }
                    return QD.Theme.getColor("setting_control")
                }
                radius: QD.Theme.getSize("setting_control_radius").width
                border.width: QD.Theme.getSize("default_lining").width
                border.color:
                {
                    if (!enabled)
                    {
                        return QD.Theme.getColor("setting_control_disabled_border")
                    }
                    if (supportExtruderCombobox.hovered || supportExtruderCombobox.activeFocus)
                    {
                        return QD.Theme.getColor("setting_control_border_highlight")
                    }
                    return QD.Theme.getColor("setting_control_border")
                }
            }

            contentItem: Controls2.Label
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
                anchors.right: downArrow.left
                rightPadding: swatch.width + QD.Theme.getSize("setting_unit_margin").width

                text: supportExtruderCombobox.currentText
                textFormat: Text.PlainText
                renderType: Text.NativeRendering
                font: QD.Theme.getFont("default")
                color: enabled ? QD.Theme.getColor("setting_control_text") : QD.Theme.getColor("setting_control_disabled_text")

                elide: Text.ElideLeft
                verticalAlignment: Text.AlignVCenter

                background: QD.RecolorImage
                {
                    id: swatch
                    height: Math.round(parent.height / 2)
                    width: height
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: QD.Theme.getSize("thin_margin").width

                    sourceSize.width: width
                    sourceSize.height: height
                    source: QD.Theme.getIcon("Extruder", "medium")
                    color: supportExtruderCombobox.color
                }
            }

            popup: Controls2.Popup
            {
                y: supportExtruderCombobox.height - QD.Theme.getSize("default_lining").height
                width: supportExtruderCombobox.width
                implicitHeight: contentItem.implicitHeight + 2 * QD.Theme.getSize("default_lining").width
                padding: QD.Theme.getSize("default_lining").width

                contentItem: ListView
                {
                    clip: true
                    implicitHeight: contentHeight
                    model: supportExtruderCombobox.popup.visible ? supportExtruderCombobox.delegateModel : null
                    currentIndex: supportExtruderCombobox.highlightedIndex

                    Controls2.ScrollIndicator.vertical: Controls2.ScrollIndicator { }
                }

                background: Rectangle
                {
                    color: QD.Theme.getColor("setting_control")
                    border.color: QD.Theme.getColor("setting_control_border")
                }
            }

            delegate: Controls2.ItemDelegate
            {
                width: supportExtruderCombobox.width - 2 * QD.Theme.getSize("default_lining").width
                height: supportExtruderCombobox.height
                highlighted: supportExtruderCombobox.highlightedIndex == index

                contentItem: Controls2.Label
                {
                    anchors.fill: parent
                    anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
                    anchors.rightMargin: QD.Theme.getSize("setting_unit_margin").width

                    text: model.name
                    renderType: Text.NativeRendering
                    color:
                    {
                        if (model.enabled)
                        {
                            QD.Theme.getColor("setting_control_text")
                        }
                        else
                        {
                            QD.Theme.getColor("action_button_disabled_text");
                        }
                    }
                    font: QD.Theme.getFont("default")
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    rightPadding: swatch.width + QD.Theme.getSize("setting_unit_margin").width

                    background: QD.RecolorImage
                    {
                        id: swatch
                        height: Math.round(parent.height / 2)
                        width: height
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: QD.Theme.getSize("thin_margin").width

                        sourceSize.width: width
                        sourceSize.height: height
                        source: QD.Theme.getIcon("Extruder", "medium")
                        color: supportExtruderCombobox.model.getItem(index).color
                    }
                }

                background: Rectangle
                {
                    color: parent.highlighted ? QD.Theme.getColor("setting_control_highlight") : "transparent"
                    border.color: parent.highlighted ? QD.Theme.getColor("setting_control_border_highlight") : "transparent"
                }
            }
        }
    }

    property var extruderModel: QIDIApplication.getExtrudersModel()


    QD.SettingPropertyProvider
    {
        id: supportEnabled
        containerStack: QIDI.MachineManager.activeMachine
        key: "support_enable"
        watchedProperties: [ "value", "enabled", "description" ]
        storeIndex: 0
    }

    QD.SettingPropertyProvider
    {
        id: supportExtruderNr
        containerStack: QIDI.MachineManager.activeMachine
        key: "support_extruder_nr"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    QD.SettingPropertyProvider
    {
        id: machineExtruderCount
        containerStack: QIDI.MachineManager.activeMachine
        key: "machine_extruder_count"
        watchedProperties: ["value"]
        storeIndex: 0
    }
}
