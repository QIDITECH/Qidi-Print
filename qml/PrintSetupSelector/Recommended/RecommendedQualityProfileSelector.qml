// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls 2.3 as Controls2
import QtQuick.Controls.Styles 1.4

import QD 1.2 as QD
import QIDI 1.6 as QIDI
import ".."

Item
{
    id: qualityRow
    height: childrenRect.height

    property real labelColumnWidth: Math.round(width / 3)
    property real settingsColumnWidth: width - labelColumnWidth

    // Here are the elements that are shown in the left column

    Column
    {
        anchors
        {
            left: parent.left
            right: parent.right
        }

        spacing: QD.Theme.getSize("default_margin").height

        Controls2.ButtonGroup
        {
            id: activeProfileButtonGroup
            exclusive: true
            onClicked: QIDI.IntentManager.selectIntent(button.modelData.intent_category, button.modelData.quality_type)
        }

        Item
        {
            height: childrenRect.height
            anchors
            {
                left: parent.left
                right: parent.right
            }
            QIDI.IconWithText
            {
                id: profileLabel
                source: QD.Theme.getIcon("PrintQuality")
                text: catalog.i18nc("@label", "Profiles")
                font: QD.Theme.getFont("medium")
                width: labelColumnWidth
            }
            QD.SimpleButton
            {
                id: resetToDefaultQualityButton

                visible: QIDI.SimpleModeSettingsManager.isProfileCustomized || QIDI.MachineManager.hasCustomQuality
                height: visible ? QD.Theme.getSize("print_setup_icon").height : 0
                width: height
                anchors
                {
                    right: profileLabel.right
                    rightMargin: QD.Theme.getSize("default_margin").width
                    leftMargin: QD.Theme.getSize("default_margin").width
                    verticalCenter: parent.verticalCenter
                }

                color: hovered ? QD.Theme.getColor("setting_control_button_hover") : QD.Theme.getColor("setting_control_button")
                iconSource: QD.Theme.getIcon("ArrowReset")

                onClicked:
                {
                    // if the current profile is user-created, switch to a built-in quality
                    QIDI.MachineManager.resetToUseDefaultQuality()
                }
                onEntered:
                {
                    var tooltipContent = catalog.i18nc("@tooltip","You have modified some profile settings. If you want to change these go to custom mode.")
                    base.showTooltip(qualityRow, Qt.point(-QD.Theme.getSize("thick_margin").width, 0),  tooltipContent)
                }
                onExited: base.hideTooltip()
            }

            QIDI.LabelBar
            {
                id: labelbar
                anchors
                {
                    left: profileLabel.right
                    right: parent.right
                }

                model: QIDI.QualityProfilesDropDownMenuModel
                modelKey: "layer_height"
            }
        }


        Repeater
        {
            model: QIDI.IntentCategoryModel {}
            Item
            {
                anchors
                {
                    left: parent.left
                    right: parent.right
                }
                height: intentCategoryLabel.height

                Label
                {
                    id: intentCategoryLabel
                    text: model.name
                    width: labelColumnWidth - QD.Theme.getSize("section_icon").width
                    anchors.left: parent.left
                    anchors.leftMargin: QD.Theme.getSize("section_icon").width + QD.Theme.getSize("narrow_margin").width
                    font: QD.Theme.getFont("medium")
                    color: QD.Theme.getColor("text")
                    renderType: Text.NativeRendering
                    elide: Text.ElideRight
                }

                QIDI.RadioCheckbar
                {
                    anchors
                    {
                        left: intentCategoryLabel.right
                        right: parent.right
                    }
                    dataModel: model["qualities"]
                    buttonGroup: activeProfileButtonGroup

                    function checkedFunction(modelItem)
                    {
                        if(QIDI.MachineManager.hasCustomQuality)
                        {
                            // When user created profile is active, no quality tickbox should be active.
                            return false
                        }

                        if(modelItem === null)
                        {
                            return false
                        }
                        return QIDI.MachineManager.activeQualityType == modelItem.quality_type && QIDI.MachineManager.activeIntentCategory == modelItem.intent_category
                    }

                    isCheckedFunction: checkedFunction
                }

                MouseArea // Intent description tooltip hover area
                {
                    id: intentDescriptionHoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: model.description !== undefined
                    acceptedButtons: Qt.NoButton // react to hover only, don't steal clicks

                    Timer
                    {
                        id: intentTooltipTimer
                        interval: 500
                        running: false
                        repeat: false
                        onTriggered: base.showTooltip(
                            intentCategoryLabel,
                            Qt.point(-(intentCategoryLabel.x - qualityRow.x) - QD.Theme.getSize("thick_margin").width, 0),
                            model.description
                        )
                    }

                    onEntered: intentTooltipTimer.start()
                    onExited:
                    {
                        base.hideTooltip()
                        intentTooltipTimer.stop()
                    }
                }

                NoIntentIcon // This icon has hover priority over intentDescriptionHoverArea, so draw it above it.
                {
                    affected_extruders: QIDI.MachineManager.extruderPositionsWithNonActiveIntent
                    intent_type: model.name
                    anchors.right: intentCategoryLabel.right
                    anchors.rightMargin: QD.Theme.getSize("narrow_margin").width
                    width: intentCategoryLabel.height * 0.75
                    anchors.verticalCenter: parent.verticalCenter
                    height: width
                    visible: QIDI.MachineManager.activeIntentCategory == model.intent_category && affected_extruders.length
                }


            }

        }
    }
}
