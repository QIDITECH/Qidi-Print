// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.3 as QD
import QIDI 1.0 as QIDI

Item
{
    id: printSetupSelector

    property int minimumWidth: 300
    property int maxmumWidth: 500
	property int mouseRegion: 5


	MouseArea {
		id:leftX
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.left
		width: 3*QD.Theme.getSize("size").width
		cursorShape: Qt.SizeHorCursor
		property int xPosition: 0
		onPressed: {
			xPosition = mouse.x
		}
 
		onPositionChanged: {
			var xOffset = xPosition-mouse.x
			var xWidth = printSetupSelector.width+xOffset
			if(xWidth<maxmumWidth && xWidth>minimumWidth){
				printSetupSelector.width = xWidth
				QD.Preferences.setValue("general/setting_veiw_width",xWidth)
			}
		}

	}

    Rectangle
    {
        id: separator
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.left
        width: QD.Theme.getSize("size").width
        color: QD.Theme.getColor("gray_3")
    }

    PrintSetupSelectorHeader
    {
        id: printSetupSelectorHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    PrintSetupSelectorContents
    {
        id: printSetupSelectorContents
        anchors.top: printSetupSelectorHeader.bottom
        anchors.bottom: actionPanelWidget.top
        anchors.left: parent.left
        anchors.right: parent.right
    }

    QIDI.ActionPanelWidget
    {
        id: actionPanelWidget
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 130 * QD.Theme.getSize("size").height
    }
}
