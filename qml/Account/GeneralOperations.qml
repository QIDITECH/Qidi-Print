// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.4 as QD
import QIDI 1.1 as QIDI

Column
{
    spacing: QD.Theme.getSize("default_margin").width
    padding: QD.Theme.getSize("default_margin").width

    Label
    {
        id: title
        anchors.horizontalCenter: parent.horizontalCenter
        renderType: Text.NativeRendering
        text: catalog.i18nc("@label",  "Sign in to the QIDI platform")
        font: QD.Theme.getFont("large_bold")
        color: QD.Theme.getColor("text")
    }

    Image
    {
        id: machinesImage
        anchors.horizontalCenter: parent.horizontalCenter
        source: QD.Theme.getImage("welcome_qidi")
        width: parent.width / 2
        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter
    }

    Label
    {
        id: generalInformationPoints
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignLeft
        renderType: Text.NativeRendering
        text: catalog.i18nc("@text", "- Add material profiles and plug-ins from the Marketplace\n- Back-up and sync your material profiles and plug-ins\n- Share ideas and get help from 48,000+ users in the QIDI community")
        lineHeight: 1.4
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
    }

    QIDI.PrimaryButton
    {
        anchors.horizontalCenter: parent.horizontalCenter
        width: QD.Theme.getSize("account_button").width
        height: QD.Theme.getSize("account_button").height
        text: catalog.i18nc("@button", "Sign in")
        onClicked: QIDI.API.account.login()
        fixedWidthMode: true
    }

    QIDI.TertiaryButton
    {
        anchors.horizontalCenter: parent.horizontalCenter
        height: QD.Theme.getSize("account_button").height
        text: catalog.i18nc("@button", "Create a free QIDI account")
        onClicked: Qt.openUrlExternally(QIDIApplication.qidiCloudAccountRootUrl + "/app/create")
    }
}
