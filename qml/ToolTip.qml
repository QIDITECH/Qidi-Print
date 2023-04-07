// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.0 as QD
import QIDI 1.0 as QIDI

ToolTip
{
    enum ContentAlignment
    {
        AlignLeft,
        AlignRight,
		AlignDown
    }

    // Defines the alignment of the content, by default to the left
    property int contentAlignment: QIDI.ToolTip.ContentAlignment.AlignRight

    property alias tooltipText: tooltip.text
    property alias arrowSize: backgroundRect.arrowSize
    property var targetPoint: Qt.point(parent.x, y + Math.round(height/2))

    id: tooltip
    text: ""
    delay: 500
    font: QD.Theme.getFont("default")
    visible: opacity != 0.0
    opacity: 0.0 // initially hidden

    Behavior on opacity
    {
        NumberAnimation { duration: 100; }
    }

    onAboutToShow: show()
    onAboutToHide: hide()

    // If the text is not set, just set the height to 0 to prevent it from showing
    height: text != "" ? label.contentHeight + 2 * QD.Theme.getSize("thin_margin").width: 0

    x:
    {
        if (contentAlignment == QIDI.ToolTip.ContentAlignment.AlignLeft)
        {
            return (label.width + Math.round(QD.Theme.getSize("default_arrow").width * 1.2) + padding * 2) * -1
        }
        return parent.width + Math.round(QD.Theme.getSize("default_arrow").width * 1.2 + padding)
    }

    y: Math.round(parent.height / 2 - label.height / 2 ) - padding

    padding: QD.Theme.getSize("thin_margin").width

    background: QD.PointingRectangle
    {
        id: backgroundRect
        color: QD.Theme.getColor("tooltip")
        target: Qt.point(targetPoint.x - tooltip.x, targetPoint.y - tooltip.y)
        arrowSize: QD.Theme.getSize("default_arrow").width
    }

    contentItem: Label
    {
        id: label
        text: tooltip.text
        font: tooltip.font
        wrapMode: Text.Wrap
        textFormat: Text.RichText
        color: QD.Theme.getColor("tooltip_text")
        renderType: Text.NativeRendering
    }

    function show() {
        opacity = 1
    }

    function hide() {
        opacity = 0
    }
}