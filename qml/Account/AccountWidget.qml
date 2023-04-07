// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.4 as QD
import QIDI 1.1 as QIDI

Item
{
    property var profile: QIDI.API.account.userProfile
    property var loggedIn: QIDI.API.account.isLoggedIn

    height: signInButton.height > accountWidget.height ? signInButton.height : accountWidget.height
    width: signInButton.width > accountWidget.width ? signInButton.width : accountWidget.width

    Button
    {
        id: signInButton

        anchors.verticalCenter: parent.verticalCenter

        text: catalog.i18nc("@action:button", "Sign in")

        height: Math.round(0.5 * QD.Theme.getSize("main_window_header").height)
        onClicked: popup.opened ? popup.close() : popup.open()
        visible: !loggedIn

        hoverEnabled: true

        background: Rectangle
        {
            radius: QD.Theme.getSize("action_button_radius").width
            color: signInButton.hovered ? QD.Theme.getColor("primary_text") : QD.Theme.getColor("main_window_header_background")
            border.width: QD.Theme.getSize("default_lining").width
            border.color: QD.Theme.getColor("primary_text")
        }

        contentItem: Label
        {
            id: label
            text: signInButton.text
            font: QD.Theme.getFont("default")
            color: signInButton.hovered ? QD.Theme.getColor("main_window_header_background") : QD.Theme.getColor("primary_text")
            width: contentWidth
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
        }
    }

    Button
    {
        id: accountWidget

        anchors.verticalCenter: parent.verticalCenter

        implicitHeight: QD.Theme.getSize("main_window_header").height
        implicitWidth: QD.Theme.getSize("main_window_header").height

        hoverEnabled: true

        visible: loggedIn

        text: (loggedIn && profile["profile_image_url"] == "") ? profile["username"].charAt(0).toUpperCase() : ""

        background: AvatarImage
        {
            id: avatar

            width: Math.round(0.8 * accountWidget.width)
            height: Math.round(0.8 * accountWidget.height)
            anchors.verticalCenter: accountWidget.verticalCenter
            anchors.horizontalCenter: accountWidget.horizontalCenter

            source: (loggedIn && profile["profile_image_url"]) ? profile["profile_image_url"] : ""
            outlineColor: loggedIn ? QD.Theme.getColor("account_widget_outline_active") : QD.Theme.getColor("lining")
        }

        contentItem: Item
        {
            anchors.verticalCenter: accountWidget.verticalCenter
            anchors.horizontalCenter: accountWidget.horizontalCenter
            visible: avatar.source == ""
            Rectangle
            {
                id: initialCircle
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
                radius: width
                color: accountWidget.hovered ? QD.Theme.getColor("primary_text") : "transparent"
                border.width: 1
                border.color: QD.Theme.getColor("primary_text")
            }

            Label
            {
                id: initialLabel
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                text: accountWidget.text
                font: QD.Theme.getFont("large_bold")
                color: accountWidget.hovered ? QD.Theme.getColor("main_window_header_background") : QD.Theme.getColor("primary_text")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                renderType: Text.NativeRendering
            }
        }

        onClicked: {
            if (popup.opened)
            {
                popup.close()
            } else {
                QIDI.API.account.popupOpened()
                popup.open()
            }
        }
    }

    Popup
    {
        id: popup

        y: parent.height + QD.Theme.getSize("default_arrow").height
        x: parent.width - width

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        onOpened: QIDI.API.account.popupOpened()

        opacity: opened ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
        padding: 0
        contentItem: AccountDetails
        {}

        background: QD.PointingRectangle
        {
            color: QD.Theme.getColor("tool_panel_background")
            borderColor: QD.Theme.getColor("lining")
            borderWidth: QD.Theme.getSize("default_lining").width

            target: Qt.point(width - (accountWidget.width / 2), -10)

            arrowSize: QD.Theme.getSize("default_arrow").width
        }
    }
}
