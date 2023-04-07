// Copyright (C) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4 as OldControls // TableView doesn't exist in the QtQuick Controls 2.x in 5.10, so use the old one
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4

import QD 1.2 as QD


OldControls.TableView
{
    itemDelegate: Item
    {
        height: tableCellLabel.implicitHeight

        Label
        {
            id: tableCellLabel
            color: styleData.selected ? QD.Theme.getColor("primary_button_text") : QD.Theme.getColor("text")
            elide: Text.ElideRight
            text: styleData.value
            anchors.fill: parent
            anchors.leftMargin: 10 * screenScaleFactor
            verticalAlignment: Text.AlignVCenter
        }
    }

    rowDelegate: Rectangle
    {
        color: styleData.selected ? QD.Theme.getColor("primary_button") : QD.Theme.getColor("main_background")
        height: QD.Theme.getSize("table_row").height
    }

    // Use the old styling technique since it's the only way to make the scrollbars themed in the TableView
    style: TableViewStyle
    {
        backgroundColor: QD.Theme.getColor("main_background")

        handle: Rectangle
        {
            // Both implicit width and height have to be set, since the handle is used by both the horizontal and the vertical scrollbars
            implicitWidth: QD.Theme.getSize("scrollbar").width
            implicitHeight: QD.Theme.getSize("scrollbar").width
            radius: width / 2
            color: QD.Theme.getColor(styleData.pressed ? "scrollbar_handle_down" : (styleData.hovered ? "scrollbar_handle_hover" : "scrollbar_handle"))
        }

        scrollBarBackground: Rectangle
        {
            // Both implicit width and height have to be set, since the handle is used by both the horizontal and the vertical scrollbars
            implicitWidth: QD.Theme.getSize("scrollbar").width
            implicitHeight: QD.Theme.getSize("scrollbar").width
            color: QD.Theme.getColor("main_background")
        }

        // The little rectangle between the vertical and horizontal scrollbars
        corner: Rectangle
        {
            color: QD.Theme.getColor("main_background")
        }

        // Override the control arrows
        incrementControl: Item { }
        decrementControl: Item { }
    }
}