// Copyright (c) 2018 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtGraphicalEffects 1.0
import QD 1.3 as QD

Item
{
    id: base;

    property alias source: img.source
    property alias color: overlay.color
    property alias sourceSize: img.sourceSize

    Image
    {
        id: img
        anchors.fill: parent
        visible: false
        sourceSize.width: parent.width
        sourceSize.height: parent.height
    }

    ColorOverlay {
        id: overlay
        anchors.fill: parent
        source: img
        color: "#fff"
    }
}
