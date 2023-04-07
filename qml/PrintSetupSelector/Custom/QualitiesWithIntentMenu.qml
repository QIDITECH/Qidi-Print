// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.6 as QIDI

Popup
{
    id: popup
    implicitWidth: 400
    property var dataModel: QIDI.IntentCategoryModel {}

    property int defaultMargin: QD.Theme.getSize("default_margin").width
    property color backgroundColor: QD.Theme.getColor("main_background")
    property color borderColor: QD.Theme.getColor("lining")

    topPadding: QD.Theme.getSize("narrow_margin").height
    rightPadding: QD.Theme.getSize("default_lining").width
    leftPadding: QD.Theme.getSize("default_lining").width

    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: QIDI.RoundedRectangle
    {
        color: backgroundColor
        border.width: QD.Theme.getSize("default_lining").width
        border.color: borderColor
        cornerSide: QIDI.RoundedRectangle.Direction.Down
    }

    ButtonGroup
    {
        id: buttonGroup
        exclusive: true
        onClicked: popup.visible = false
    }

    contentItem: Column
    {
        // This repeater adds the intent labels
        ScrollView
        {
            property real maximumHeight: screenScaleFactor * 400
            contentHeight: dataColumn.height
            height: Math.min(contentHeight, maximumHeight)
            clip: true

            ScrollBar.vertical.policy: height == maximumHeight ? ScrollBar.AlwaysOn: ScrollBar.AlwaysOff

            Column
            {
                id: dataColumn
                width: parent.width
                Repeater
                {
                    model: dataModel
                    delegate: Item
                    {
                        // We need to set it like that, otherwise we'd have to set the sub model with model: model.qualities
                        // Which obviously won't work due to naming conflicts.
                        property variant subItemModel: model.qualities

                        height: childrenRect.height
                        width: popup.contentWidth

                        Label
                        {
                            id: headerLabel
                            text: model.name
                            color: QD.Theme.getColor("text_inactive")
                            renderType: Text.NativeRendering
                            width: parent.width
                            height: visible ? contentHeight: 0
                            visible: qualitiesList.visibleChildren.length > 0
                            anchors.left: parent.left
                            anchors.leftMargin: QD.Theme.getSize("default_margin").width

                            MouseArea // tooltip hover area
                            {
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: model.description !== undefined
                                acceptedButtons: Qt.NoButton // react to hover only, don't steal clicks

                                onEntered:
                                {
                                    base.showTooltip(
                                        headerLabel,
                                        Qt.point(- QD.Theme.getSize("default_margin").width, 0),
                                        model.description
                                    )
                                }
                                onExited: base.hideTooltip()
                            }
                        }

                        Column
                        {
                            id: qualitiesList
                            anchors.top: headerLabel.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right

                            // Add the qualities that belong to the intent
                            Repeater
                            {
                                visible: false
                                model: subItemModel
                                MenuButton
                                {
                                    id: button

                                    onClicked: QIDI.IntentManager.selectIntent(model.intent_category, model.quality_type)

                                    width: parent.width
                                    checkable: true
                                    visible: model.available
                                    text: model.name + " - " + model.layer_height + " mm"
                                    checked:
                                    {
                                        if (QIDI.MachineManager.hasCustomQuality)
                                        {
                                            // When user created profile is active, no quality tickbox should be active.
                                            return false;
                                        }
                                        return QIDI.MachineManager.activeQualityType == model.quality_type && QIDI.MachineManager.activeIntentCategory == model.intent_category;
                                    }
                                    ButtonGroup.group: buttonGroup
                                }
                            }
                        }
                    }
                }
                //Another "intent category" for custom profiles.
                Item
                {
                    height: childrenRect.height
                    width: popup.contentWidth

                    Label
                    {
                        id: customProfileHeader
                        text: catalog.i18nc("@label:header", "Custom profiles")
                        renderType: Text.NativeRendering
                        height: visible ? contentHeight: 0
                        enabled: false
                        visible: profilesList.visibleChildren.length > 1
                        anchors.left: parent.left
                        anchors.leftMargin: QD.Theme.getSize("default_margin").width
                        color: QD.Theme.getColor("text_inactive")
                    }

                    Column
                    {
                        id: profilesList
                        anchors
                        {
                            top: customProfileHeader.bottom
                            left: parent.left
                            right: parent.right
                        }

                        //We set it by means of a binding, since then we can use the
                        //"when" condition, which we need to prevent a binding loop.
                        Binding
                        {
                            target: parent
                            property: "height"
                            value: parent.childrenRect.height
                            when: parent.visibleChildren.length > 1
                        }

                        //Add all the custom profiles.
                        Repeater
                        {
                            model: QIDI.CustomQualityProfilesDropDownMenuModel
                            MenuButton
                            {
                                onClicked: QIDI.MachineManager.setQualityChangesGroup(model.quality_changes_group)
                                width: parent.width
                                checkable: true
                                visible: model.available
                                text: model.name
                                checked:
                                {
                                    var active_quality_group = QIDI.MachineManager.activeQualityChangesGroup

                                    if (active_quality_group != null)
                                    {
                                        return active_quality_group.name == model.quality_changes_group.name
                                    }
                                    return false
                                }
                                ButtonGroup.group: buttonGroup
                            }
                        }
                    }
                }
            }
        }

        Rectangle
        {
            height: QD.Theme.getSize("default_lining").height
            anchors.left: parent.left
            anchors.right: parent.right
            color: borderColor
        }

        MenuButton
        {
            text: catalog.i18nc("@action:button", "Create a new setting")
            anchors.left: parent.left
            anchors.right: parent.right
            onClicked:
            {
                popup.visible = false
                createQualityDialog.object = QIDI.ContainerManager.makeUniqueName("Default")
                createQualityDialog.open()
                createQualityDialog.selectText()
            }
        }
        MenuButton
        {
            labelText: QIDI.Actions.updateProfile.text
            anchors.left: parent.left
            anchors.right: parent.right
            enabled: QIDI.Actions.updateProfile.enabled
            onClicked:
            {
                popup.visible = false
                QIDI.Actions.updateProfile.trigger()
            }
        }
        MenuButton
        {
            text: catalog.i18nc("@action:button", "Discard current changes")
            anchors.left: parent.left
            anchors.right: parent.right
            enabled: QIDI.MachineManager.hasUserSettings
            onClicked:
            {
                popup.visible = false
				QIDIApplication.parameter_testf_change("")
				//QIDIApplication.writeToLog("e",QIDI.MachineManager.activeMachine.name)
				//QIDIApplication.parameter_cahnged_clear()
				//QIDIApplication.parameter_changed_color_remove()
                QIDI.ContainerManager.clearUserContainers()
				QIDIApplication.parameter_testf_change("Machine")
            }
        }

        Rectangle
        {
            height: QD.Theme.getSize("default_lining").width
            anchors.left: parent.left
            anchors.right: parent.right
            color: borderColor
        }

        MenuButton
        {
            text: catalog.i18nc("@action:button", "Remove current setting")
            anchors.left: parent.left
            anchors.right: parent.right
            enabled: QIDI.MachineManager.activeQualityChangesGroup != null
            onClicked:
            {
                popup.visible = false
                QIDIApplication.getQualityManagementModel().removeQualityChangesGroup(QIDI.MachineManager.activeQualityChangesGroup)
                QIDI.IntentManager.selectIntent("default", "normal")
            }
        }
        // spacer
        Item
        {
            width: 2
            height: QD.Theme.getSize("default_radius").width 
        }

        QD.RenameDialog
        {
            id: createQualityDialog
            title: catalog.i18nc("@title:window", "Create Profile")
            object: "<new name>"
            explanation: catalog.i18nc("@info:info", "Please provide a name for this profilea.")
            onAccepted: QIDIApplication.getQualityManagementModel().createQualityChanges(newName)
        }
    }
}
