// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Window 2.2

import QD 1.3 as QD
import QIDI 1.1 as QIDI


Window
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    id: baseDialog
    title: catalog.i18nc("@title:window", "More information on anonymous data collection")
    visible: false

    modality: Qt.ApplicationModal

    minimumWidth: 500 * screenScaleFactor
    minimumHeight: 400 * screenScaleFactor
    width: minimumWidth
    height: minimumHeight

    color: QD.Theme.getColor("main_background")

    property bool allowSendData: true  // for saving the user's choice

    onVisibilityChanged:
    {
        if (visible)
        {
            baseDialog.allowSendData = QD.Preferences.getValue("info/send_slice_info")
            if (baseDialog.allowSendData)
            {
                allowSendButton.checked = true
            }
            else
            {
                dontSendButton.checked = true
            }
        }
    }

    // Main content area
    Item
    {
        anchors.fill: parent
        anchors.margins: QD.Theme.getSize("default_margin").width

        Item  // Text part
        {
            id: textRow
            anchors
            {
                top: parent.top
                bottom: radioButtonsRow.top
                bottomMargin: QD.Theme.getSize("default_margin").height
                left: parent.left
                right: parent.right
            }

            Label
            {
                id: headerText
                anchors
                {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                text: catalog.i18nc("@text:window", "QIDI TECH collects anonymous data in order to improve the print quality and user experience. Below is an example of all the data that is shared:")
                color: QD.Theme.getColor("text")
                wrapMode: Text.WordWrap
                renderType: Text.NativeRendering
            }

            QIDI.ScrollableTextArea
            {
                anchors
                {
                    top: headerText.bottom
                    topMargin: QD.Theme.getSize("default_margin").height
                    bottom: parent.bottom
                    bottomMargin: QD.Theme.getSize("default_margin").height
                    left: parent.left
                    right: parent.right
                }

                textArea.text: (manager === null) ? "" : manager.getExampleData()
                textArea.textFormat: Text.RichText
                textArea.wrapMode: Text.Wrap
                textArea.readOnly: true
            }
        }

        Column  // Radio buttons for agree and disagree
        {
            id: radioButtonsRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: buttonRow.top
            anchors.bottomMargin: QD.Theme.getSize("default_margin").height

            QIDI.RadioButton
            {
                id: dontSendButton
                text: catalog.i18nc("@text:window", "I don't want to send anonymous data")
                onClicked:
                {
                    baseDialog.allowSendData = !checked
                }
            }
            QIDI.RadioButton
            {
                id: allowSendButton
                text: catalog.i18nc("@text:window", "Allow sending anonymous data")
                onClicked:
                {
                    baseDialog.allowSendData = checked
                }
            }
        }

        Item  // Bottom buttons
        {
            id: buttonRow
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            height: childrenRect.height

            QIDI.PrimaryButton
            {
                anchors.right: parent.right
                text: catalog.i18nc("@action:button", "OK")
                onClicked:
                {
                    manager.setSendSliceInfo(allowSendData)
                    baseDialog.hide()
                }
            }

            QIDI.SecondaryButton
            {
                anchors.left: parent.left
                text: catalog.i18nc("@action:button", "Cancel")
                onClicked:
                {
                    baseDialog.hide()
                }
            }
        }
    }
}
