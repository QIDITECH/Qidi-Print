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
    QD.I18nCatalog { id: catalog; name: "qidi" }

    // Arrange the items vertically and put everything in the center
    Column
    {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: QD.Theme.getSize("thick_margin").height
        width:parent.width


        // Filler item
        Item
        {
            height: QD.Theme.getSize("thick_margin").width
            width: parent.width
        }

        Image
        {
            id: qidiImage
            anchors.horizontalCenter: parent.horizontalCenter
            source: QD.Theme.getImage("welcome_qidi")
            fillMode: Image.PreserveAspectFit
            width: QD.Theme.getSize("welcome_wizard_content_image_big").width
            sourceSize.width: width
            sourceSize.height: height
        }

        // Filler item
        Item
        {
            height: QD.Theme.getSize("thick_margin").width
            width: parent.width
        }

        Label
        {
            id: titleLabel
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            text: catalog.i18nc("@label", "Welcome to QIDI Print")
            color: QD.Theme.getColor("primary_button")
            font: QD.Theme.getFont("huge_bold")
            renderType: Text.NativeRendering
        }

        Label
        {
            id: textLabel
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            width: titleLabel.width + 2 * QD.Theme.getSize("thick_margin").width
            text: catalog.i18nc("@text", "Please follow these steps to set up QIDI Print. This will only take a few moments.")
            wrapMode: Text.Wrap
            font: QD.Theme.getFont("medium")
            color: QD.Theme.getColor("text")
            renderType: Text.NativeRendering
        }

        // Filler item
        Item
        {
            height: QD.Theme.getSize("thick_margin").height
            width: parent.width
        }

        QIDI.PrimaryButton
        {
            id: getStartedButton
            anchors.horizontalCenter: parent.horizontalCenter
            backgroundRadius: Math.round(height / 2)
            text: catalog.i18nc("@button", "Get started")
            onClicked: base.showNextPage()
        }

        // Filler item
        Item
        {
            height: QD.Theme.getSize("thick_margin").height
            width: parent.width
        }
    }
}
