// Copyright (c) 2019 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.1 as QD

Item
{
    id: tile
    width: detailList.width - QD.Theme.getSize("wide_margin").width
    height: normalData.height + 2 * QD.Theme.getSize("wide_margin").height
    Column
    {
        id: normalData

        anchors
        {
            top: parent.top
            left: parent.left
            right: controls.left
            rightMargin: QD.Theme.getSize("wide_margin").width
        }

        Label
        {
            width: parent.width
            height: QD.Theme.getSize("toolbox_property_label").height
            text: model.name
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("medium_bold")
            renderType: Text.NativeRendering
        }

        Label
        {
            width: parent.width
            text: model.description
            maximumLineCount: 25
            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default")
            renderType: Text.NativeRendering
        }

        ToolboxCompatibilityChart
        {
            width: parent.width
            packageData: model
        }
    }

    ToolboxDetailTileActions
    {
        id: controls
        anchors.right: tile.right
        anchors.top: tile.top
        width: childrenRect.width
        height: childrenRect.height
        packageData: model
    }

    Rectangle
    {
        color: QD.Theme.getColor("lining")
        width: tile.width
        height: QD.Theme.getSize("default_lining").height
        anchors.top: normalData.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height + QD.Theme.getSize("wide_margin").height //Normal margin for spacing after chart, wide margin between items.
    }
}
