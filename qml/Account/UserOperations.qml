// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.4 as QD
import QIDI 1.1 as QIDI

Column
{
    spacing: QD.Theme.getSize("narrow_margin").height
    topPadding: QD.Theme.getSize("default_margin").height
    bottomPadding: QD.Theme.getSize("default_margin").height
    width: childrenRect.width

    Item
    {
        id: accountInfo
        width: childrenRect.width
        height: childrenRect.height
        anchors.left: parent.left
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        AvatarImage
        {
            id: avatar
            anchors.verticalCenter: parent.verticalCenter

            width: QD.Theme.getSize("main_window_header").height
            height: QD.Theme.getSize("main_window_header").height

            source: profile["profile_image_url"] ? profile["profile_image_url"] : ""
            outlineColor: QD.Theme.getColor("main_background")
        }
        Rectangle
        {
            id: initialCircle
            width: avatar.width
            height: avatar.height
            radius: width
            anchors.verticalCenter: parent.verticalCenter
            color: QD.Theme.getColor("action_button_disabled")
            visible: !avatar.hasAvatar
            Label
            {
                id: initialLabel
                anchors.centerIn: parent
                text: profile["username"].charAt(0).toUpperCase()
                font: QD.Theme.getFont("large_bold")
                color: QD.Theme.getColor("text")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
            }
        }

        Column
        {
            anchors.left: avatar.right
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            spacing: QD.Theme.getSize("narrow_margin").height
            width: childrenRect.width
            height: childrenRect.height
            Label
            {
                id: username
                renderType: Text.NativeRendering
                text: profile.username
                font: QD.Theme.getFont("large_bold")
                color: QD.Theme.getColor("text")
            }

            SyncState
            {
                id: syncRow
            }
            Label
            {
                id: lastSyncLabel
                renderType: Text.NativeRendering
                text: catalog.i18nc("@label The argument is a timestamp", "Last update: %1").arg(QIDI.API.account.lastSyncDateTime)
                font: QD.Theme.getFont("default")
                color: QD.Theme.getColor("text_medium")
            }
        }
    }

    Rectangle
    {
        width: parent.width
        color: QD.Theme.getColor("lining")
        height: QD.Theme.getSize("default_lining").height
    }
    QIDI.TertiaryButton
    {
        id: cloudButton
        width: QD.Theme.getSize("account_button").width
        height: QD.Theme.getSize("account_button").height
        text: "QIDI Digital Factory"
        onClicked: Qt.openUrlExternally(QIDIApplication.qidiDigitalFactoryUrl)
        fixedWidthMode: false
    }

    QIDI.TertiaryButton
    {
        id: accountButton
        width: QD.Theme.getSize("account_button").width
        height: QD.Theme.getSize("account_button").height
        text: catalog.i18nc("@button", "QIDI Account")
        onClicked: Qt.openUrlExternally(QIDIApplication.qidiCloudAccountRootUrl)
        fixedWidthMode: false
    }

    Rectangle
    {
        width: parent.width
        color: QD.Theme.getColor("lining")
        height: QD.Theme.getSize("default_lining").height
    }

    QIDI.TertiaryButton
    {
        id: signOutButton
        onClicked: QIDI.API.account.logout()
        text: catalog.i18nc("@button", "Sign Out")
    }
}
