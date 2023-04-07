// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Window 2.2

import QD 1.3 as QD
import QIDI 1.1 as QIDI

Column
{
    id: welcomePage
    spacing: QD.Theme.getSize("wide_margin").height
    width: parent.width
    height: childrenRect.height
    anchors.centerIn: parent

    Label
    {
        id: welcomeTextLabel
        text: catalog.i18nc("@description", "Please sign in to get verified plugins and materials for QIDI TECH Enterprise")
        width: Math.round(parent.width / 2)
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: Label.WordWrap
        renderType: Text.NativeRendering
    }

    QIDI.PrimaryButton
    {
        id: loginButton
        width: QD.Theme.getSize("account_button").width
        height: QD.Theme.getSize("account_button").height
        anchors.horizontalCenter: parent.horizontalCenter
        text: catalog.i18nc("@button", "Sign in")
        onClicked: QIDI.API.account.login()
        fixedWidthMode: true
    }
}

