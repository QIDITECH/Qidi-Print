// Copyright (c) 2017 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    id: base
    property string label
    height: childrenRect.height

    Rectangle
    {
        color: QD.Theme.getColor("setting_category")
        width: base.width
        height: QD.Theme.getSize("section").height

        Label
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            text: label
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("setting_category_text")
        }
    }
}
