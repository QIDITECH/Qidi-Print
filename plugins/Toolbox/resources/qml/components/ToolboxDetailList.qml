// Copyright (c) 2019 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QD 1.1 as QD

Item
{
    id: detailList
    ScrollView
    {
        clip: true
        anchors.fill: detailList

        Column
        {
            anchors
            {
                right: parent.right
                topMargin: QD.Theme.getSize("wide_margin").height
                bottomMargin: QD.Theme.getSize("wide_margin").height
                top: parent.top
            }
            height: childrenRect.height + 2 * QD.Theme.getSize("wide_margin").height
            spacing: QD.Theme.getSize("default_margin").height

            Repeater
            {
                model: toolbox.packagesModel
                delegate: Loader
                {
                    // FIXME: When using asynchronous loading, on Mac and Windows, the tile may fail to load complete,
                    // leaving an empty space below the title part. We turn it off for now to make it work on Mac and
                    // Windows.
                    // Can be related to this QT bug: https://bugreports.qt.io/browse/QTBUG-50992
                    asynchronous: false
                    source: "ToolboxDetailTile.qml"
                }
            }
        }
    }
}
