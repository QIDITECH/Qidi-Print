// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD


//
// This component places a text on top of an image.
//
Column
{
    leftPadding: QD.Theme.getSize("default_margin").width
    rightPadding: QD.Theme.getSize("default_margin").width
    spacing: QD.Theme.getSize("default_margin").height
    property alias text: label.text
    property alias imageSource: image.source

    Label
    {
        id: label
        width: image.width
        anchors.horizontalCenter: image.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: ""
        wrapMode: Text.WordWrap
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        renderType: Text.NativeRendering
    }

    Image
    {
        id: image
        source: ""
    }
}