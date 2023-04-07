// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// QIDI-style TextArea with scrolls
//
ScrollView
{
    property alias textArea: _textArea

    property var back_color: QD.Theme.getColor("main_background")
    property var do_borders: true

    clip: true

    background: Rectangle  // Border
    {
        color: back_color
        border.color: QD.Theme.getColor("thick_lining")
        border.width: do_borders ? QD.Theme.getSize("default_lining").width : 0
    }

    TextArea
    {
        id: _textArea
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        textFormat: TextEdit.PlainText
        renderType: Text.NativeRendering
        selectByMouse: true
    }
}
