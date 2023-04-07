// Copyright (c) 2018 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QD 1.2 as QD

/*
 * Wrapper around TabBar that uses our theming and more sane defaults.
 */
TabBar
{
    id: base

    width: parent.width
    height: visible ? 40 * screenScaleFactor : 0

    spacing: QD.Theme.getSize("narrow_margin").width //Space between the tabs.

    background: Rectangle
    {
        width: parent.width
        anchors.bottom: parent.bottom
        height: QD.Theme.getSize("default_lining").height
        color: QD.Theme.getColor("lining")
    }
}