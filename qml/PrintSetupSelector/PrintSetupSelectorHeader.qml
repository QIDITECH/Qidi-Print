// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.0 as QIDI

Rectangle
{
    id: base
    height: machineSelector.height + machineIPItem.height + 15 * QD.Theme.getSize("size").height
    gradient: Gradient
    {
        GradientStop {position: 0.0; color: QD.Theme.getColor("blue_7")}
        GradientStop {position: 1.0; color: QD.Theme.getColor("white_1")}
    }

    QIDI.MachineSelector
    {
        id: machineSelector
        anchors.top: parent.top
        anchors.topMargin: 10 * QD.Theme.getSize("size").height
        anchors.left: machineImage.right
        anchors.leftMargin: 5 * QD.Theme.getSize("size").height
        anchors.right: parent.right
        height: 40 * QD.Theme.getSize("size").height
    }

    Item
    {
        id: machineIPItem
        anchors.top: machineSelector.bottom
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.left: machineSelector.left
        anchors.right: parent.right
        height: 30 * QD.Theme.getSize("size").height

        Label
        {
            id: ipLabel
            text: catalog.i18nc("@action:label", "IP:")
            font: QD.Theme.getFont("font1")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            color: QD.Theme.getColor("black_1")
			visible: !inputiprow.visible
        }

        QIDI.ComboBoxForIP
        {
            id: ipComboBox
            model: QIDI.WifiSend.IPList
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: ipLabel.right
            anchors.leftMargin: 10 * QD.Theme.getSize("size").height
            anchors.right: refreshButton.left
            anchors.rightMargin: 5 * QD.Theme.getSize("size").height
            height: 20 * QD.Theme.getSize("size").height
            onActivated: 
			{
				QIDI.WifiSend.setCurrentDeviceIP(QIDI.WifiSend.FullNameIPList[currentIndex])
				//QIDI.WifiSend.setNameable()
			}
            onAccepted:
            {
                if (currentText.length > 0 && find(currentText) === -1)
                {
                    currentIndex = -1
                }
            }
			visible: !inputiprow.visible
        }

        Button
        {
            id: refreshButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: showrenameButton.left
            anchors.rightMargin: 5 * QD.Theme.getSize("size").height
            width: 20 * QD.Theme.getSize("size").height
            height: 20 * QD.Theme.getSize("size").height
            onClicked: {
                ipComboBox.currentIndex = -1            //清空列表
                QIDI.WifiSend.scanDeviceThread()
                enabled = false
                ipComboBox.enabled = false
                refreshTimer.start()
            }
            contentItem: Item
            {
                anchors.fill: parent
                QD.RecolorImage
                {
                    id: buttonIcon
                    anchors.centerIn: parent
                    source: QD.Theme.getIcon("Refresh")
                    width: refreshButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                    height: refreshButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                    color: QD.Theme.getColor("gray_6")
                }
            }

            background: Rectangle
            {
                id: background
                anchors.centerIn: parent
                height: parent.height
                width: parent.height
                color: QD.Theme.getColor("white_2")
            }
			visible: !inputiprow.visible
        }
		Button
        {
            id: showrenameButton
            //anchors.verticalCenter: parent.verticalCenter
			anchors.bottom: parent.bottom
			anchors.bottomMargin: inputiprow.visible ? 7.5 * QD.Theme.getSize("size").height : 5 * QD.Theme.getSize("size").height 
            anchors.right: parent.right
            anchors.rightMargin: 5 * QD.Theme.getSize("size").height
            width: 20 * QD.Theme.getSize("size").height
            height: 20 * QD.Theme.getSize("size").height
			onClicked: {
				inputiprow.visible = !inputiprow.visible
            }
			contentItem: Item
            {
                anchors.fill: parent
                QD.RecolorImage
                {
                    id: changenamebuttonIcon
                    anchors.centerIn: parent
                    source: inputiprow.visible ? QD.Theme.getIcon("Cancel") : QD.Theme.getIcon("Pen")
                    width: showrenameButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                    height: showrenameButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                    color: inputiprow.visible ? QD.Theme.getColor("red_1") : enabled ? QD.Theme.getColor("gray_6") :QD.Theme.getColor("gray_3")
                }
            }
			background: Rectangle
            {
                id: changenamebackground
                anchors.centerIn: parent
                height: parent.height
                width: parent.height
                color: QD.Theme.getColor("white_2")
            }
			enabled : QIDI.WifiSend.nameable == "true"
		}
		TextField
		{
			id:inputiprow
			//anchors.verticalCenter: parent.verticalCenter
			anchors.left: parent.left
			anchors.leftMargin: 1 * QD.Theme.getSize("size").height
			//anchors.right: changenameButton.left
			//anchors.rightMargin: 1 * QD.Theme.getSize("size").height
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 5 * QD.Theme.getSize("size").height
			placeholderText:catalog.i18nc("@action:label", "Please input a new name")
			text:""
			height: 24 * QD.Theme.getSize("size").height
			width: 155 * QD.Theme.getSize("size").height
			visible: false
		}
		QIDI.PrimaryButton
        {
            id: changenameButton
            //anchors.verticalCenter: parent.verticalCenter
            anchors.right: showrenameButton.left
            anchors.rightMargin: 10 * QD.Theme.getSize("size").height
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 9 * QD.Theme.getSize("size").height
            width: 60 * QD.Theme.getSize("size").height
            height: 20  * QD.Theme.getSize("size").height
			fixedWidthMode: true //添加之后文字居中
			backgroundRadius: Math.round(height / 2)
			text:catalog.i18nc("@action:label", "Apply")
			onClicked: {
				QIDI.WifiSend.renameDevice(inputiprow.text, "test")
				// QIDI.controlpanel.changename(inputiprow.text)
				inputiprow.text=""
				inputiprow.visible = !inputiprow.visible
            }
			visible:inputiprow.visible
			enabled: inputiprow.text != ""
		}
        Timer
        {
            id: refreshTimer
            repeat: false
            interval: 5300
            onTriggered: 
			{
				refreshButton.enabled = ipComboBox.enabled = true
				ipComboBox.currentIndex = 0
				//QIDI.WifiSend.setCurrentDeviceIP(QIDI.WifiSend.FullNameIPList[0])
			}
        }
    }

    Image
    {
        id: machineImage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 5 * QD.Theme.getSize("size").height
        source: QD.Theme.getIcon(QIDI.MachineManager.activeMachine.name + "_small")
        width: height
    }

    Rectangle
    {
        anchors.bottom: printSetupSelectorHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: QD.Theme.getSize("size").width
        color: QD.Theme.getColor("gray_3")
    }
}
