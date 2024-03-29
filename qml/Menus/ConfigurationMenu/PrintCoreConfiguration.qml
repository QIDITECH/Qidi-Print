// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    id: extruderInfo
    property var printCoreConfiguration

    height: information.height

    //Extruder icon.
    QIDI.ExtruderIcon
    {
        id: icon
        materialColor: printCoreConfiguration !== null ? printCoreConfiguration.material.color : ""
        anchors.verticalCenter: parent.verticalCenter
        extruderEnabled: printCoreConfiguration !== null && printCoreConfiguration.material.brand !== "" && printCoreConfiguration.hotendID !== ""
    }

    Column
    {
        id: information
        anchors
        {
            left: icon.right
            right: parent.right
            margins: QD.Theme.getSize("default_margin").width
        }

        Label
        {
            text: (printCoreConfiguration !== null && printCoreConfiguration.material.brand) ? printCoreConfiguration.material.brand : " " //Use space so that the height is still correct.
            renderType: Text.NativeRendering
            elide: Text.ElideRight
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("text_inactive")
            width: parent.width
        }
        Label
        {
            text: (printCoreConfiguration !== null && printCoreConfiguration.material.brand) ? printCoreConfiguration.material.name : " " //Use space so that the height is still correct.
            renderType: Text.NativeRendering
            elide: Text.ElideRight
            font: QD.Theme.getFont("medium")
            color: QD.Theme.getColor("text")
            width: parent.width
        }
        Label
        {
            text: (printCoreConfiguration !== null && printCoreConfiguration.hotendID) ? printCoreConfiguration.hotendID : " " //Use space so that the height is still correct.
            renderType: Text.NativeRendering
            elide: Text.ElideRight
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("text_inactive")
            width: parent.width
        }
    }
}
