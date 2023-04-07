// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI
Component
{
    Item
    {
        Rectangle
        {
            color: QD.Theme.getColor("main_background")

            anchors.right: parent.right
            width: parent.width * 0.3
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            QIDI.PrintMonitor
            {
                anchors.fill: parent
            }

            Rectangle
            {
                id: footerSeparator
                width: parent.width
                height: QD.Theme.getSize("wide_lining").height
                color: QD.Theme.getColor("wide_lining")
                anchors.bottom: monitorButton.top
                anchors.bottomMargin: QD.Theme.getSize("thick_margin").height
            }

            // MonitorButton is actually the bottom footer panel.
            QIDI.MonitorButton
            {
                id: monitorButton
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }
    }
}