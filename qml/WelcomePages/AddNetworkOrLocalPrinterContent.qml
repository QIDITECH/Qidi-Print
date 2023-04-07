// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This component contains the content for the "Add a printer" (network) page of the welcome on-boarding process.
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
        text: catalog.i18nc("@label", "Add a printer")
        color: QD.Theme.getColor("primary_button")
        font: QD.Theme.getFont("huge")
        renderType: Text.NativeRendering
    }

    AddLocalPrinterScrollView
    {
        id: localPrinterView

        anchors.top: titleLabel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: QD.Theme.getSize("default_margin").height
    }

    QIDI.PrimaryButton
    {
        id: nextButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        backgroundRadius: Math.round(height / 2)
        text: base.currentItem.next_page_button_text
        onClicked:
        {
            const localPrinterItem = localPrinterView.currentItem
            const printerName = localPrinterView.currentItem.name
            if(QIDI.MachineManager.addMachine(localPrinterItem.id, printerName))
            {
                base.showNextPage()
            }
        }
    }
}
