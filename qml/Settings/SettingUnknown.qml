// Copyright (c) 2015 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.2 as QD

SettingItem
{
    contents: Label
    {
        anchors.fill: parent
        text: propertyProvider.properties.value + " " + unit
        renderType: Text.NativeRendering
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        verticalAlignment: Text.AlignVCenter
    }
}
