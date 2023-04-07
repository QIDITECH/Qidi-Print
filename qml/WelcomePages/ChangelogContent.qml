// Copyright (c) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This component contains the content for the "What's new in QIDI QIDI" page of the welcome on-boarding process.
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
        text: catalog.i18nc("@label", "Release Notes")
        color: QD.Theme.getColor("primary_button")
        font: QD.Theme.getFont("huge")
        renderType: Text.NativeRendering
    }

    QIDI.ScrollableTextArea
    {
        id: changelogTextArea

        anchors.top: titleLabel.bottom
        anchors.bottom: getStartedButton.top
        anchors.topMargin: QD.Theme.getSize("wide_margin").height
        anchors.bottomMargin: QD.Theme.getSize("wide_margin").height
        anchors.left: parent.left
        anchors.right: parent.right

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        textArea.text: QIDIApplication.getTextManager().getChangeLogText()
        textArea.textFormat: Text.RichText
        textArea.wrapMode: Text.WordWrap
        textArea.readOnly: true
        textArea.font: QD.Theme.getFont("default")
        textArea.onLinkActivated: Qt.openUrlExternally(link)
    }

    QIDI.PrimaryButton
    {
        id: getStartedButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        backgroundRadius: Math.round(height / 2)
        text: base.currentItem.next_page_button_text
        onClicked: base.showNextPage()
    }
}
