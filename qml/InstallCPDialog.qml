// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.4

import UM 1.3 as UM
import Cura 1.0 as Cura

UM.Dialog
{
    id: baseDialog
    minimumWidth: 320 * UM.Theme.getSize("default_margin").width/10
    minimumHeight: 400 * UM.Theme.getSize("default_margin").width/10
    width: minimumWidth
    height: minimumHeight
    title: catalog.i18nc("@title:window", "Install Control Panel")

    Label{
        id: label
        text: catalog.i18nc("@label", "QIDI Control Panel has not been installed.\nDo you want to install QIDI Control Panel?")
        anchors.top: parent.top
        anchors.topMargin: 5 * UM.Theme.getSize("default_margin").width/10
        anchors.left: parent.left
        anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
        font: UM.Theme.getFont("font1")
    }

    Image {
        id: image
        anchors.top: label.bottom
        anchors.topMargin: 5 * UM.Theme.getSize("default_margin").width/10
        anchors.horizontalCenter: parent.horizontalCenter
        height: 312 * UM.Theme.getSize("default_margin").width/10
        width: 287 * UM.Theme.getSize("default_margin").width/10
        source: UM.Theme.getIcon("Control Panel")
    }

    Item
    {
        id: buttonRow
        anchors.bottom: parent.bottom
        width: parent.width
        anchors.bottomMargin: 20 * UM.Theme.getSize("default_margin").width/10

        UM.I18nCatalog { id: catalog; name:"cura" }

        Button
        {
            anchors.right: parent.right
            anchors.rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@action:button", "Yes")
            style: UM.Theme.styles.savebutton
            height: 23 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                baseDialog.accepted()
            }
        }

        Button
        {
            anchors.left: parent.left
            anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@action:button", "No")
            style: UM.Theme.styles.savebutton
            height: 23 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                baseDialog.rejected()
            }
        }
    }
    onAccepted: manager.installCP(true)
    onRejected: manager.installCP(false)
    onClosing: manager.installCP(false)
}
