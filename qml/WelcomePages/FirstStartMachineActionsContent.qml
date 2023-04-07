// Copyright (c) 2019 QIDI B.V.
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

    property var machineActionsModel: QIDIApplication.getFirstStartMachineActionsModel()

    Component.onCompleted:
    {
        // Reset the action to start from the beginning when it is shown.
        machineActionsModel.reset()
    }

    // Go to the next page when all machine actions have been finished
    Connections
    {
        target: machineActionsModel
        function onAllFinished()
        {
            if (visible)
            {
                base.showNextPage()
            }
        }
    }

    Label
    {
        id: titleLabel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: machineActionsModel.currentItem.title == undefined ? "" : machineActionsModel.currentItem.title
        color: QD.Theme.getColor("primary_button")
        font: QD.Theme.getFont("huge")
        renderType: Text.NativeRendering
    }

    Item
    {
        anchors
        {
            top: titleLabel.bottom
            topMargin: QD.Theme.getSize("default_margin").height
            bottom: nextButton.top
            bottomMargin: QD.Theme.getSize("default_margin").height
            left: parent.left
            right: parent.right
        }

        data: machineActionsModel.currentItem.content == undefined ? emptyItem : machineActionsModel.currentItem.content
    }

    // An empty item in case there's no currentItem.content to show
    Item
    {
        id: emptyItem
    }

    QIDI.PrimaryButton
    {
        id: nextButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: catalog.i18nc("@button", "Next")
        onClicked: machineActionsModel.goToNextAction()
    }
}
