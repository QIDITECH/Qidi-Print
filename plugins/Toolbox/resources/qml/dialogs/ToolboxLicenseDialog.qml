// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

import QD 1.1 as QD
import QIDI 1.6 as QIDI

QD.Dialog
{
    id: licenseDialog
    title: licenseModel.dialogTitle
    minimumWidth: QD.Theme.getSize("license_window_minimum").width
    minimumHeight: QD.Theme.getSize("license_window_minimum").height
    width: minimumWidth
    height: minimumHeight
    backgroundColor: QD.Theme.getColor("main_background")
    margin: screenScaleFactor * 10

    ColumnLayout
    {
        anchors.fill: parent
        spacing: QD.Theme.getSize("thick_margin").height

        QD.I18nCatalog{id: catalog; name: "qidi"}

        Label
        {
            id: licenseHeader
            Layout.fillWidth: true
            text: catalog.i18nc("@label", "You need to accept the license to install the package")
            color: QD.Theme.getColor("text")
            wrapMode: Text.Wrap
            renderType: Text.NativeRendering
        }

        Row {
            id: packageRow

            Layout.fillWidth: true
            height: childrenRect.height
            spacing: QD.Theme.getSize("default_margin").width
            leftPadding: QD.Theme.getSize("narrow_margin").width

            Image
            {
                id: icon
                width: 30 * screenScaleFactor
                height: width
                sourceSize.width: width
                sourceSize.height: height
                fillMode: Image.PreserveAspectFit
                source: licenseModel.iconUrl || "../../images/placeholder.svg"
                mipmap: true
            }

            Label
            {
                id: packageName
                text: licenseModel.packageName
                color: QD.Theme.getColor("text")
                font.bold: true
                anchors.verticalCenter: icon.verticalCenter
                height: contentHeight
                wrapMode: Text.Wrap
                renderType: Text.NativeRendering
            }


        }

        QIDI.ScrollableTextArea
        {

            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.topMargin: QD.Theme.getSize("default_margin").height

            textArea.text: licenseModel.licenseText
            textArea.readOnly: true
        }

    }
    rightButtons:
    [
        QIDI.PrimaryButton
        {
            leftPadding: QD.Theme.getSize("dialog_primary_button_padding").width
            rightPadding: QD.Theme.getSize("dialog_primary_button_padding").width

            text: licenseModel.acceptButtonText
            onClicked: { handler.onLicenseAccepted() }
        }
    ]

    leftButtons:
    [
        QIDI.SecondaryButton
        {
            id: declineButton
            text: licenseModel.declineButtonText
            onClicked: { handler.onLicenseDeclined() }
        }
    ]
}
