// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QD 1.1 as QD

Column
{
    property var heading: ""
    property var model
    id: gridArea
    height: childrenRect.height + 2 * padding
    width: parent.width
    spacing: QD.Theme.getSize("default_margin").height
    padding: QD.Theme.getSize("wide_margin").height
    Label
    {
        id: heading
        text: gridArea.heading
        width: parent.width
        color: QD.Theme.getColor("text_medium")
        font: QD.Theme.getFont("large")
        renderType: Text.NativeRendering
    }
    Grid
    {
        id: grid
        width: parent.width - 2 * parent.padding
        columns: 2
        columnSpacing: QD.Theme.getSize("default_margin").height
        rowSpacing: QD.Theme.getSize("default_margin").width
        Repeater
        {
            model: gridArea.model
            delegate: Loader
            {
                asynchronous: true
                width: Math.round((grid.width - (grid.columns - 1) * grid.columnSpacing) / grid.columns)
                height: QD.Theme.getSize("toolbox_thumbnail_small").height
                source: "ToolboxDownloadsGridTile.qml"
            }
        }
    }
}
