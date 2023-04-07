// Copyright (c) 2020 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.1 as QD

ScrollView
{
    id: base
    clip: true

    // Setting this property to false hides the scrollbar both when the scrollbar is not needed (child height < height)
    // and when the scrollbar is not actively being hovered or pressed
    property bool scrollAlwaysVisible: true

    ScrollBar.vertical: ScrollBar
    {
        id: verticalBar
        hoverEnabled: true
        policy: parent.scrollAlwaysVisible ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        contentItem: Rectangle
        {
            implicitWidth: QD.Theme.getSize("scrollbar").width
            opacity: (parent.active || parent.parent.scrollAlwaysVisible) ? 1.0 : 0.0
            radius: Math.round(width / 2)
            color:
            {
                if (parent.hovered)
                {
                    return QD.Theme.getColor("blue_6")
                }
                else
                {
                    return QD.Theme.getColor("blue_4")
                }
            }
            Behavior on color { ColorAnimation { duration: 100; } }
            Behavior on opacity { NumberAnimation { duration: 100 } }
        }
    }

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.horizontal.interactive: false
}