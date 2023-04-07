// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This component contains the content for the "QIDI Cloud" page of the welcome on-boarding process.
//
Item
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    signal cloudPrintersDetected(bool newCloudPrintersDetected)

    Component.onCompleted: QIDIApplication.getDiscoveredCloudPrintersModel().cloudPrintersDetectedChanged.connect(cloudPrintersDetected)

    onCloudPrintersDetected:
    {
        // When the user signs in successfully, it will be checked whether he/she has cloud printers connected to
        // the account. If he/she does, then the welcome wizard will show a summary of the Cloud printers linked to the
        // account. If there are no cloud printers, then proceed to the next page (if any)
        if(newCloudPrintersDetected)
        {
            base.goToPage("add_cloud_printers")
        }
        else
        {
            base.showNextPage()
        }
    }

    // Area where the cloud contents can be put. Pictures, texts and such.
    Item
    {
        id: cloudContentsArea
        anchors
        {
            top: parent.top
            bottom: skipButton.top
            left: parent.left
            right: parent.right
        }

        // Pictures and texts are arranged using Columns with spacing. The whole picture and text area is centered in
        // the cloud contents area.
        Column
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: childrenRect.height

            spacing: QD.Theme.getSize("thick_margin").height

            Label
            {
                id: titleLabel
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: catalog.i18nc("@label", "Sign in to the QIDI platform")
                color: QD.Theme.getColor("primary_button")
                font: QD.Theme.getFont("huge")
                renderType: Text.NativeRendering
            }

            // Filler item
            Item
            {
                height: QD.Theme.getSize("default_margin").height
                width: parent.width
            }

            // Cloud image
            Image
            {
                id: cloudImage
                anchors.horizontalCenter: parent.horizontalCenter
                source: QD.Theme.getImage("first_run_qidi_cloud")
                fillMode: Image.PreserveAspectFit
                width: QD.Theme.getSize("welcome_wizard_content_image_big").width
                sourceSize.width: width
                sourceSize.height: height
            }


            // Filler item
            Item
            {
                height: QD.Theme.getSize("default_margin").height
                width: parent.width
            }

            // Motivational icons
            Row
            {
                id: motivationRow
                width: parent.width

                Column
                {
                    id: marketplaceColumn
                    width: Math.round(parent.width / 3)
                    spacing: QD.Theme.getSize("default_margin").height

                    Image
                    {
                        id: marketplaceImage
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        width: QD.Theme.getSize("welcome_wizard_cloud_content_image").width
                        source: QD.Theme.getIcon("Plugin")
                        sourceSize.width: width
                        sourceSize.height: height
                    }
                    Label
                    {
                        id: marketplaceTextLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: catalog.i18nc("@text", "Add material settings and plugins from the Marketplace")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        color: QD.Theme.getColor("text")
                        font: QD.Theme.getFont("default")
                        renderType: Text.NativeRendering
                    }
                }

                Column
                {
                    id: syncColumn
                    width: Math.round(parent.width / 3)
                    spacing: QD.Theme.getSize("default_margin").height

                    Image
                    {
                        id: syncImage
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        width: QD.Theme.getSize("welcome_wizard_cloud_content_image").width
                        source: QD.Theme.getIcon("Spool")
                        sourceSize.width: width
                        sourceSize.height: height
                    }
                    Label
                    {
                        id: syncTextLabel
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: catalog.i18nc("@text", "Backup and sync your material settings and plugins")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        color: QD.Theme.getColor("text")
                        font: QD.Theme.getFont("default")
                        renderType: Text.NativeRendering
                    }
                }

                Column
                {
                    id: communityColumn
                    width: Math.round(parent.width / 3)
                    spacing: QD.Theme.getSize("default_margin").height

                    Image
                    {
                        id: communityImage
                        anchors.horizontalCenter: communityColumn.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        width: QD.Theme.getSize("welcome_wizard_cloud_content_image").width
                        source: QD.Theme.getIcon("PrinterTriple", "medium")
                        sourceSize.width: width
                        sourceSize.height: height
                    }
                    Label
                    {
                        id: communityTextLabel
                        anchors.horizontalCenter: communityColumn.horizontalCenter
                        width: parent.width
                        text: catalog.i18nc("@text", "Share ideas and get help from 48,000+ users in the QIDI Community")
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        color: QD.Theme.getColor("text")
                        font: QD.Theme.getFont("default")
                        renderType: Text.NativeRendering
                    }
                }
            }

            // Sign in Button
            QIDI.PrimaryButton
            {
                id: signInButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: catalog.i18nc("@button", "Sign in")
                onClicked: QIDI.API.account.login()
                // Content Item is used in order to align the text inside the button. Without it, when resizing the
                // button, the text will be aligned on the left
                contentItem: Text {
                    text: signInButton.text
                    font: QD.Theme.getFont("medium")
                    color: QD.Theme.getColor("primary_text")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Create an account button
            QIDI.TertiaryButton
            {
                id: createAccountButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: catalog.i18nc("@text", "Create a free QIDI Account")
                onClicked:  Qt.openUrlExternally(QIDIApplication.qidiCloudAccountRootUrl + "/app/create")
            }
        }
    }

    // The "Skip" button exists on the bottom right
    Label
    {
        id: skipButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        text: catalog.i18nc("@button", "Skip")
        color: QD.Theme.getColor("secondary_button_text")
        font: QD.Theme.getFont("medium")
        renderType: Text.NativeRendering

        MouseArea
        {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: base.showNextPage()
            onEntered: parent.font.underline = true
            onExited: parent.font.underline = false
        }
    }
}
