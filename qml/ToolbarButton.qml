// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Button
{
    id: base

    property alias toolItem: contentItemLoader.sourceComponent

    // These two properties indicate whether the toolbar button is at the top of the toolbar column or at the bottom.
    // If it is somewhere in the middle, then both has to be false. If there is only one element in the column, then
    // both properties have to be set to true. This is used to create a rounded corner.
    property bool isTopElement: false
    property bool isBottomElement: false
    property bool hasBorderElement: false
    property var hoverColor: ""

    hoverEnabled: true

    background: Rectangle
    {
        implicitWidth: 50 * QD.Theme.getSize("size").width
        implicitHeight: 50 * QD.Theme.getSize("size").width
        radius: hasBorderElement ? 4 * QD.Theme.getSize("size").width : 0
        border.width: hasBorderElement ? QD.Theme.getSize("size").width : 0
        border.color: base.checked ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("lining")
        color:
        {
            if (base.checked || base.hovered)
            {
                return hoverColor == "" ? QD.Theme.getColor("blue_4") : hoverColor
            }
            return QD.Theme.getColor("white_1")
        }

        Rectangle
        {
            id: topSquare
            anchors
            {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            height: parent.radius
            color: parent.color
            visible: !hasBorderElement
        }

        Rectangle
        {
            id: bottomSquare
            anchors
            {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: parent.radius
            color: parent.color
            visible: !hasBorderElement
        }

        Rectangle
        {
            id: leftSquare
            anchors
            {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.radius
            color: parent.color
            visible: !hasBorderElement
        }
    }

    contentItem: Item
    {
        opacity: parent.enabled ? 1.0 : 0.4
        Loader
        {
            id: contentItemLoader
            anchors.centerIn: parent
        }
    }

    QIDI.ToolTip
    {
        id: tooltip
        tooltipText: base.text
        visible: base.hovered
    }
}
