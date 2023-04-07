// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.0 as QIDI

import "Recommended"
import "Custom"

Item
{
    id: content

    // Catch all mouse events
    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
    }

    property int currentModeIndex:
    {
        var index = Math.round(QD.Preferences.getValue("qidi/active_mode"))

        if (index != null && !isNaN(index))
        {
            return index
        }
        return PrintSetupSelectorContents.Mode.Recommended
    }
    onCurrentModeIndexChanged: 
	{
		QD.Preferences.setValue("qidi/active_mode", currentModeIndex)
	}
    CustomPrintSetup
    {
        id: customPrintSetup
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
