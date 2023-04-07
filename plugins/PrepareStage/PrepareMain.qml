//Copyright (c) 2020 Ultimaker B.V.
//Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import QD 1.0 as QD
import QIDI 1.0 as QIDI

Item
{
    id: prepareMain

    QIDI.ActionPanelWidget
    {
        id: actionPanelWidget
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: QD.Theme.getSize("thick_margin").width
        anchors.bottomMargin: QD.Theme.getSize("thick_margin").height
    }
}