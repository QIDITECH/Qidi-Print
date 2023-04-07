// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.7 as QIDI


//
// This component gets activated when the user presses the "Add cloud printers" button from the "Add a Printer" page.
// It contains a busy indicator that remains active until the user logs in and adds a cloud printer in his/her account.
// Once a cloud printer is added in mycloud.qidi.com, QIDI discovers it (in a time window of 30 sec) and displays
// the newly added printers in this page.
//
Item
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    property bool searchingForCloudPrinters: true
    property var discoveredCloudPrintersModel: QIDIApplication.getDiscoveredCloudPrintersModel()

    // The area where either the discoveredCloudPrintersScrollView or the busyIndicator will be displayed
    Item
    {
        id: cloudPrintersContent
        width: parent.width
        height: parent.height
        anchors
        {
            top: parent.top
            left: parent.left
            leftMargin: QD.Theme.getSize("default_margin").width
            right: parent.right
            bottom: finishButton.top
            bottomMargin: QD.Theme.getSize("default_margin").height
        }

        Label
        {
            id: titleLabel
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: catalog.i18nc("@label", "Add a Cloud printer")
            color: QD.Theme.getColor("primary_button")
            font: QD.Theme.getFont("huge")
            renderType: Text.NativeRendering
        }

        // Component that contains a busy indicator and a message, while it waits for QIDI to discover a cloud printer
        Item
        {
            id: waitingContent
            width: parent.width
            height: childrenRect.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            BusyIndicator
            {
                id: waitingIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                running: searchingForCloudPrinters
                palette.dark: QD.Theme.getColor("text")
            }
            Label
            {
                id: waitingLabel
                anchors.top: waitingIndicator.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: catalog.i18nc("@label", "Waiting for Cloud response")
                font: QD.Theme.getFont("large")
                renderType: Text.NativeRendering
                color: QD.Theme.getColor("text")
            }
            Label
            {
                id: noPrintersFoundLabel
                anchors.top: waitingLabel.bottom
                anchors.topMargin: 2 * QD.Theme.getSize("wide_margin").height
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: catalog.i18nc("@label", "No printers found in your account?")
                font: QD.Theme.getFont("medium")
                color: QD.Theme.getColor("text")
            }
            Label
            {
                text: "Sign in with a different account"
                anchors.top: noPrintersFoundLabel.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                font: QD.Theme.getFont("medium")
                color: QD.Theme.getColor("text_link")
                MouseArea {
                    anchors.fill: parent;
                    onClicked: QIDI.API.account.login(true)
                    hoverEnabled: true
                    onEntered:
                    {
                        parent.font.underline = true
                    }
                    onExited:
                    {
                        parent.font.underline = false
                    }
                }
            }
            visible: discoveredCloudPrintersModel.count == 0
        }

        // Label displayed when a new cloud printer is discovered
        Label
        {
            anchors.top: titleLabel.bottom
            anchors.topMargin: 2 * QD.Theme.getSize("default_margin").height
            id: cloudPrintersAddedTitle
            font: QD.Theme.getFont("medium")
            text: catalog.i18nc("@label", "The following printers in your account have been added in QIDI:")
            height: contentHeight + 2 * QD.Theme.getSize("default_margin").height
            visible: discoveredCloudPrintersModel.count > 0
            color: QD.Theme.getColor("text")
        }

        // The scrollView that contains the list of newly discovered QIDI Cloud printers. Visible only when
        // there is at least a new cloud printer.
        ScrollView
        {
            id: discoveredCloudPrintersScrollView
            width: parent.width
            clip : true
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            visible: discoveredCloudPrintersModel.count > 0
            anchors
            {
                top: cloudPrintersAddedTitle.bottom
                topMargin: QD.Theme.getSize("default_margin").height
                left: parent.left
                leftMargin: QD.Theme.getSize("default_margin").width
                right: parent.right
                bottom: parent.bottom
            }

            Column
            {
                id: discoveredPrintersColumn
                spacing: 2 * QD.Theme.getSize("default_margin").height

                Repeater
                {
                    id: discoveredCloudPrintersRepeater
                    model: discoveredCloudPrintersModel
                    delegate: Item
                    {
                        width: discoveredCloudPrintersScrollView.width
                        height: contentColumn.height

                        Column
                        {
                            id: contentColumn
                            Label
                            {
                                id: cloudPrinterNameLabel
                                leftPadding: QD.Theme.getSize("default_margin").width
                                text: model.name
                                font: QD.Theme.getFont("large_bold")
                                color: QD.Theme.getColor("text")
                                elide: Text.ElideRight
                            }
                            Label
                            {
                                id: cloudPrinterTypeLabel
                                leftPadding: 2 * QD.Theme.getSize("default_margin").width
                                topPadding: QD.Theme.getSize("thin_margin").height
                                text: {"Type: " + model.machine_type}
                                font: QD.Theme.getFont("medium")
                                color: QD.Theme.getColor("text")
                                elide: Text.ElideRight
                            }
                            Label
                            {
                                id: cloudPrinterFirmwareVersionLabel
                                leftPadding: 2 * QD.Theme.getSize("default_margin").width
                                text: {"Firmware version: " + model.firmware_version}
                                font: QD.Theme.getFont("medium")
                                color: QD.Theme.getColor("text")
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    QIDI.SecondaryButton
    {
        id: backButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: catalog.i18nc("@button", "Add printer manually")
        onClicked:
        {
            discoveredCloudPrintersModel.clear()
            base.showPreviousPage()
        }
        visible: discoveredCloudPrintersModel.count == 0
    }

    QIDI.PrimaryButton
    {
        id: finishButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: base.currentItem.next_page_button_text
        onClicked:
        {
            discoveredCloudPrintersModel.clear()
            base.showNextPage()
        }

        enabled: !waitingContent.visible
    }
}
