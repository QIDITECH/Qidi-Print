// Copyright (c) 2018 Ultimaker B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI

import QtGraphicalEffects 1.0 // For the dropshadow

Item
{
    id: prepareMenu

    QD.I18nCatalog
    {
        id: catalog
        name: "QIDI"
    }

    anchors
    {
        left: parent.left
        right: parent.right
        leftMargin: QD.Theme.getSize("wide_margin").width
        rightMargin: QD.Theme.getSize("wide_margin").width
    }

    // Item to ensure that all of the buttons are nicely centered.
    Item
    {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * QD.Theme.getSize("wide_margin").width
        height: parent.height

        RowLayout
        {
            id: itemRow

            anchors.left: openFileButton.right
            anchors.right: parent.right
            anchors.leftMargin: QD.Theme.getSize("default_margin").width

            height: parent.height
            spacing: 0

            QIDI.MachineSelector
            {
                id: machineSelection
                headerCornerSide: QIDI.RoundedRectangle.Direction.Left
                Layout.minimQDWidth: QD.Theme.getSize("machine_selector_widget").width
                Layout.maximQDWidth: QD.Theme.getSize("machine_selector_widget").width
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Separator line
            Rectangle
            {
                height: parent.height
                width: QD.Theme.getSize("default_lining").width
                color: QD.Theme.getColor("lining")
            }

            QIDI.ConfigurationMenu
            {
                id: printerSetup
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: itemRow.width - machineSelection.width - printSetupSelectorItem.width - 2 * QD.Theme.getSize("default_lining").width
            }

            // Separator line
            Rectangle
            {
                height: parent.height
                width: QD.Theme.getSize("default_lining").width
                color: QD.Theme.getColor("lining")
            }

            Item
            {
                id: printSetupSelectorItem
                // This is a work around to prevent the printSetupSelector from having to be re-loaded every time
                // a stage switch is done.
                children: [printSetupSelector]
                height: childrenRect.height
                width: childrenRect.width
            }
        }

        Button
        {
            id: openFileButton
            height: QD.Theme.getSize("stage_menu").height
            width: QD.Theme.getSize("stage_menu").height
            onClicked: QIDI.Actions.open.trigger()
            hoverEnabled: true

            contentItem: Item
            {
                anchors.fill: parent
                QD.RecolorImage
                {
                    id: buttonIcon
                    anchors.centerIn: parent
                    source: QD.Theme.getIcon("Folder")
                    width: QD.Theme.getSize("button_icon").width
                    height: QD.Theme.getSize("button_icon").height
                    color: QD.Theme.getColor("icon")

                    sourceSize.height: height
                }
            }

            background: Rectangle
            {
                id: background
                height: QD.Theme.getSize("stage_menu").height
                width: QD.Theme.getSize("stage_menu").height

                radius: QD.Theme.getSize("default_radius").width
                color: openFileButton.hovered ? QD.Theme.getColor("action_button_hovered") : QD.Theme.getColor("action_button")
            }

            DropShadow
            {
                id: shadow
                // Don't blur the shadow
                radius: 0
                anchors.fill: background
                source: background
                verticalOffset: 2
                visible: true
                color: QD.Theme.getColor("action_button_shadow")
                // Should always be drawn behind the background.
                z: background.z - 1
            }
        }
    }
}
