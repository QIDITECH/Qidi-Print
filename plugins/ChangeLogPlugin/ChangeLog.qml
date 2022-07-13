// Copyright (c) 2015 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import UM 1.1 as UM

UM.Dialog
{
    id: base
    minimumWidth: 450 | 0
    minimumHeight: 350 | 0
    width: minimumWidth
    height: minimumHeight
    title: catalog.i18nc("@label", "Changelog")

    TextArea
    {
        anchors.fill: parent
        anchors.leftMargin: 15 * UM.Theme.getSize("default_margin").width/10
        anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
        anchors.topMargin: 10 * UM.Theme.getSize("default_margin").width/10
        text: manager.getChangeLogString()
        readOnly: true;
        textFormat: TextEdit.RichText
    }

    rightButtons: [
        Button
        {
            UM.I18nCatalog
            {
                id: catalog
                name: "cura"
            }

            text: catalog.i18nc("@action:button", "Close")
            onClicked: base.hide()
        }
    ]
}
