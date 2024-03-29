// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0 // For the dropshadow

import QD 1.2 as QD

// Empty placeholder
Rectangle
{
    color: QD.Theme.getColor("disabled")

    DropShadow
    {
        id: shadow
        // Don't blur the shadow
        radius: 0
        anchors.fill: parent
        source: parent
        verticalOffset: 2
        visible: true
        color: QD.Theme.getColor("action_button_shadow")
        // Should always be drawn behind the background.
        z: parent.z - 1
    }
}
