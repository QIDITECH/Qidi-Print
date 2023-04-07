// Copyright (c) 2019 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3 as Controls

import QD 1.3 as QD

//
// Styled progress bar, with colours from the theme and rounded corners.
//
Controls.ProgressBar
{
    id: progressBar
    width: parent.width
    height: QD.Theme.getSize("progressbar").height

    background: Rectangle
    {
        anchors.fill: parent
        color: QD.Theme.getColor("blue_4")
    }

    contentItem: Item
    {
        anchors.fill: parent

        // The progress block for showing progress value
        Rectangle
        {
            id: progressBlockDeterminate
            x: progressBar.indeterminate ? progressBar.visualPosition * parent.width : 0
            width: progressBar.indeterminate ? parent.width * 0.1 : progressBar.visualPosition * parent.width
            height: parent.height
            color: QD.Theme.getColor("blue_6")
        }
        SequentialAnimation
        {
            PropertyAnimation
            {
                target: progressBar
                property: "value"
                from: 0
                to: 0.9 // The block is not centered, so let it go to 90% (since it's 10% long)
                duration: 3000
            }
            PropertyAnimation
            {
                target: progressBar
                property: "value"
                from: 0.9 // The block is not centered, so let it go to 90% (since it's 10% long)
                to: 0
                duration: 3000
            }

            loops: Animation.Infinite
            running: progressBar.visible && progressBar.indeterminate
        }
    }
}
