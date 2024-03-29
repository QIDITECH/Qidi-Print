// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.1 as QD
import QIDI 1.0 as QIDI

Item
{
    id: footer
    width: parent.width
    anchors.bottom: parent.bottom
    height: visible ? QD.Theme.getSize("toolbox_footer").height : 0

    Label
    {
        text: catalog.i18nc("@info", "You will need to restart QIDI before changes in packages have effect.")
        color: QD.Theme.getColor("text")
        height: QD.Theme.getSize("toolbox_footer_button").height
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        anchors
        {
            top: restartButton.top
            left: parent.left
            leftMargin: QD.Theme.getSize("wide_margin").width
            right: restartButton.left
            rightMargin: QD.Theme.getSize("default_margin").width
        }
        renderType: Text.NativeRendering
    }

    QIDI.PrimaryButton
    {
        id: restartButton
        anchors
        {
            top: parent.top
            topMargin: QD.Theme.getSize("default_margin").height
            right: parent.right
            rightMargin: QD.Theme.getSize("wide_margin").width
        }
        height: QD.Theme.getSize("toolbox_footer_button").height
        text: catalog.i18nc("@info:button, %1 is the application name", "Quit %1").arg(QIDIApplication.applicationDisplayName)
        onClicked:
        {
            base.hide()
            toolbox.restart()
        }
    }

    ToolboxShadow
    {
        visible: footer.visible
        anchors.bottom: footer.top
        reversed: true
    }
}
