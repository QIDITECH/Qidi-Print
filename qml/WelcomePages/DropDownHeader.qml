// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI

import ".."


//
// This is DropDown Header bar of the expandable drop down list. See comments in DropDownWidget for details.
//
QIDI.RoundedRectangle
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    id: base

    border.width: QD.Theme.getSize("default_lining").width
    border.color: QD.Theme.getColor("lining")
    color: QD.Theme.getColor("secondary")
    radius: QD.Theme.getSize("default_radius").width

    cornerSide: contentShown ? QIDI.RoundedRectangle.Direction.Up : QIDI.RoundedRectangle.Direction.All

    property string title: ""
    property url rightIconSource: QD.Theme.getIcon("ChevronSingleDown")

    // If the tab is under hovering state
    property bool hovered: false
    // If the content is shown
    property bool contentShown: false

    signal clicked()

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: base.hovered = true
        onExited: base.hovered = false

        onClicked: base.clicked()
    }

    Label
    {
        id: title
        anchors.left: parent.left
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        text: base.title
        font: QD.Theme.getFont("medium")
        renderType: Text.NativeRendering
        color: base.hovered ? QD.Theme.getColor("small_button_text_hover") : QD.Theme.getColor("small_button_text")
    }

    QD.RecolorImage
    {
        id: rightIcon
        anchors.right: parent.right
        anchors.rightMargin: QD.Theme.getSize("default_margin").width
        anchors.verticalCenter: parent.verticalCenter
        width: QD.Theme.getSize("message_close").width
        height: QD.Theme.getSize("message_close").height
        color: base.hovered ? QD.Theme.getColor("small_button_text_hover") : QD.Theme.getColor("small_button_text")
        source: base.rightIconSource
    }
}
