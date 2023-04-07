// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0 as Controls2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.1

import QD 1.4 as QD
import QIDI 1.0 as QIDI
import QtGraphicalEffects 1.0

import "../Account"

Item
{
    id: base

    implicitHeight: QD.Theme.getSize("main_window_header").height
    implicitWidth: QD.Theme.getSize("main_window_header").width

    Image
    {
        id: logo
        anchors.left: parent.left
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        anchors.verticalCenter: parent.verticalCenter

        source: QD.Theme.getImage("logo")
        width: QD.Theme.getSize("logo").width
        height: QD.Theme.getSize("logo").height
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width
        sourceSize.height: height
    }

    Row
    {
        id: stagesListContainer
        spacing: Math.round(QD.Theme.getSize("default_margin").width / 2)

        anchors
        {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
            leftMargin: QD.Theme.getSize("default_margin").width
        }

        // The main window header is dynamically filled with all available stages
        Repeater
        {
            id: stagesHeader

            model: QD.StageModel { }

            delegate: Button
            {
                id: stageSelectorButton
                text: model.name.toUpperCase()
                checkable: true
                checked: QD.Controller.activeStage !== null && model.id == QD.Controller.activeStage.stageId

                anchors.verticalCenter: parent.verticalCenter
                exclusiveGroup: mainWindowHeaderMenuGroup
                style: QD.Theme.styles.main_window_header_tab
                height: QD.Theme.getSize("main_window_header_button").height
                iconSource: model.stage.iconSource

                property color overlayColor: "transparent"
                property string overlayIconSource: ""
                // This id is required to find the stage buttons through Squish
                property string stageId: model.id

                // This is a trick to assure the activeStage is correctly changed. It doesn't work propertly if done in the onClicked (see QIDI-6028)
                MouseArea
                {
                    anchors.fill: parent
                    onClicked: QD.Controller.setActiveStage(model.id)
                }
            }
        }

        ExclusiveGroup { id: mainWindowHeaderMenuGroup }
    }

    // Shortcut button to quick access the Toolbox
    Controls2.Button
    {
        id: marketplaceButton
        text: catalog.i18nc("@action:button", "Marketplace")
        height: Math.round(0.5 * QD.Theme.getSize("main_window_header").height)
        onClicked: QIDI.Actions.browsePackages.trigger()

        hoverEnabled: true

        background: Rectangle
        {
            radius: QD.Theme.getSize("action_button_radius").width
            color: marketplaceButton.hovered ? QD.Theme.getColor("primary_text") : QD.Theme.getColor("main_window_header_background")
            border.width: QD.Theme.getSize("default_lining").width
            border.color: QD.Theme.getColor("primary_text")
        }

        contentItem: Label
        {
            id: label
            text: marketplaceButton.text
            font: QD.Theme.getFont("default")
            color: marketplaceButton.hovered ? QD.Theme.getColor("main_window_header_background") : QD.Theme.getColor("primary_text")
            width: contentWidth
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }

        anchors
        {
            right: accountWidget.left
            rightMargin: QD.Theme.getSize("default_margin").width
            verticalCenter: parent.verticalCenter
        }

        QIDI.NotificationIcon
        {
            id: marketplaceNotificationIcon
            anchors
            {
                top: parent.top
                right: parent.right
                rightMargin: (-0.5 * width) | 0
                topMargin: (-0.5 * height) | 0
            }
            visible: QIDIApplication.getPackageManager().packagesWithUpdate.length > 0

            labelText:
            {
                const itemCount = QIDIApplication.getPackageManager().packagesWithUpdate.length
                return itemCount > 9 ? "9+" : itemCount
            }
        }
    }

    AccountWidget
    {
        id: accountWidget
        anchors
        {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: QD.Theme.getSize("default_margin").width
        }
    }
}
