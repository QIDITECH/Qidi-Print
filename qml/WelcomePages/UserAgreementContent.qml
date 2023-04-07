// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI

//
// This component contains the content for the "User Agreement" page of the welcome on-boarding process.
//
Item
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    Label
    {
        id: titleLabel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: catalog.i18nc("@label", "User Agreement")
        color: QD.Theme.getColor("primary_button")
        font: QD.Theme.getFont("huge")
        renderType: Text.NativeRendering
    }

    Label
    {
        id: disclaimerLineLabel
        anchors
        {
            top: titleLabel.bottom
            topMargin: QD.Theme.getSize("wide_margin").height
            left: parent.left
            right: parent.right
        }

        text: "<p><b>Disclaimer by QIDI</b></p>"
            + "<p>Please read this disclaimer carefully.</p>"
            + "<p>Except when otherwise stated in writing, QIDI provides any QIDI software or third party software \"As is\" without warranty of any kind. The entire risk as to the quality and performance of QIDI software is with you.</p>"
            + "<p>Unless required by applicable law or agreed to in writing, in no event will QIDI be liable to you for damages, including any general, special, incidental, or consequential damages arising out of the use or inability to use any QIDI software or third party software.</p>"
        textFormat: Text.RichText
        wrapMode: Text.WordWrap
        font: QD.Theme.getFont("medium")
        color: QD.Theme.getColor("text")
        renderType: Text.NativeRendering
    }

    QIDI.PrimaryButton
    {
        id: agreeButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        backgroundRadius: Math.round(height / 2)
        text: catalog.i18nc("@button", "Agree")
        onClicked:
        {
            QIDIApplication.writeToLog("i", "User accepted the User-Agreement.")
            QIDIApplication.setNeedToShowUserAgreement(false)
            base.showNextPage()
        }
    }

    QIDI.SecondaryButton
    {
        id: declineButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        backgroundRadius: Math.round(height / 2)
        text: catalog.i18nc("@button", "Decline and close")
        onClicked:
        {
            QIDIApplication.writeToLog("i", "User declined the User Agreement.")
            QIDIApplication.closeApplication() // NOTE: Hard exit, don't use if anything needs to be saved!
        }
    }
}
