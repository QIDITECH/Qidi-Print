import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15

import QD 1.1 as QD
import QIDI 1.1 as QIDI

Rectangle
{
    id: base
    width: 370 * QD.Theme.getSize("size").height
    height: parent.height
    border.color: QD.Theme.getColor("gray_2")
    border.width: QD.Theme.getSize("size").height
    radius: 5 * QD.Theme.getSize("size").height
    color: QD.Theme.getColor("gray_7")

	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}

    Grid
    {
        id: xyControlGrid
        height: 150 * QD.Theme.getSize("size").height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10 * QD.Theme.getSize("size").height
        spacing: 5 * QD.Theme.getSize("size").height
        columns: 3

        Item
        {
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
        }

        QIDI.ToolbarButton
        {
            id: yMoveUpButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("YMoveUp","plugin")
				color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")//stateconrotl == "Connect" ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: yMoveUpButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: yMoveUpButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: 
			{
				xyDistance.value = xyDistance.text
				xySpeed.value = xySpeed.text
                controlpanel.yfont(xyDistance.value,xySpeed.value)
			}
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && controlpanel.MotorsString.indexOf("xyz")!=-1
        }

        Item
        {
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
        }

        QIDI.ToolbarButton
        {
            id: xMoveLeftButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("XMoveLeft","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")//stateconrotl == "Connect" ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: xMoveLeftButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: xMoveLeftButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: 
			{
				xyDistance.value = xyDistance.text
				xySpeed.value = xySpeed.text
                controlpanel.xleft(xyDistance.value,xySpeed.value)
			}
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && controlpanel.MotorsString.indexOf("xyz")!=-1
        }

        QIDI.ToolbarButton
        {
            id: moveHomeButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("XYMoveHome","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")//stateconrotl == "Connect" ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: moveHomeButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: moveHomeButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: controlpanel.xyhome()
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
        }

        QIDI.ToolbarButton
        {
            id: xMoveRightButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("XMoveRight","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")//stateconrotl == "Connect" ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: xMoveRightButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: xMoveRightButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: controlpanel.xright(xyDistance.value,xySpeed.value)
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)&& controlpanel.MotorsString.indexOf("xyz")!=-1
        }

        Item
        {
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
        }

        QIDI.ToolbarButton
        {
            id: yMoveDownButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("YMoveDown","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: yMoveDownButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: yMoveDownButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: controlpanel.yback(xyDistance.value,xySpeed.value)
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)&& controlpanel.MotorsString.indexOf("xyz")!=-1
        }

        Item
        {
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
        }
    }

    Row
    {
        id: stopAndCloseRow
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10 * QD.Theme.getSize("size").width
        height: 40 * QD.Theme.getSize("size").width
        spacing: 5 * QD.Theme.getSize("size").width

        QIDI.ToolbarButton
        {
            id: stopButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("MachineStop","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("red_1") : QD.Theme.getColor("gray_2")
                width: stopButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: stopButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: controlpanel.machinestop()
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
        }

        QIDI.ToolbarButton
        {
            id: closeButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("MachineClose","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && controlpanel.close_machine_enabled =="True" ? QD.Theme.getColor("orange_1") : QD.Theme.getColor("gray_2")
                width: closeButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: closeButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: controlpanel.machineclose()
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && controlpanel.close_machine_enabled =="True"
        }
    }
    Column
    {
        id: zControlRow
        height: 20 * QD.Theme.getSize("size").height
        anchors.top: parent.top
        anchors.topMargin: 10 * QD.Theme.getSize("size").height
        anchors.left: xyControlGrid.right
        anchors.leftMargin: 5 * QD.Theme.getSize("size").height
        spacing: 10 * QD.Theme.getSize("size").height

        QIDI.ToolbarButton
        {
            id: zMoveUpButton
            width: 40 * QD.Theme.getSize("size").width
            height: 60 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("ZMoveUp","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: zMoveUpButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: zMoveUpButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: 
			{
				zDistance.value = zDistance.text
				zSpeed.value = zSpeed.text
                controlpanel.zup(zDistance.value,zSpeed.value)
			}
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)&& controlpanel.MotorsString.indexOf("xyz")!=-1
        }

        QIDI.ToolbarButton
        {
            id: zMoveHomeButton
            width: 40 * QD.Theme.getSize("size").width
            height: 40 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("XYMoveHome","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: zMoveHomeButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: zMoveHomeButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: controlpanel.zhome()
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
			visible:false
        }

        QIDI.ToolbarButton
        {
            id: zMoveDownButton
            width: 40 * QD.Theme.getSize("size").width
            height: 60 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("ZMoveDown","plugin")
                color:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: zMoveDownButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
                height: zMoveDownButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }
            onClicked: 
			{
				zDistance.value = zDistance.text
				zSpeed.value = zSpeed.text
                controlpanel.zdown(zDistance.value,zSpeed.value)

			}
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)&& controlpanel.MotorsString.indexOf("xyz")!=-1
        }
    }
    Item
    {
        id: xyzAdvanced

        height: 20 * QD.Theme.getSize("size").height
		width : 120* QD.Theme.getSize("size").height 
        anchors.top: stopAndCloseRow.bottom
        anchors.topMargin: 20 * QD.Theme.getSize("size").height
        anchors.right: parent.right
        anchors.rightMargin: 10 * QD.Theme.getSize("size").height

        Label
        {
			id:xyzlabel
            anchors.left: parent.left
			anchors.leftMargin: 20 * QD.Theme.getSize("size").height
            width: 30 * QD.Theme.getSize("size").height
            text: "X:"
            font: QD.Theme.getFont("font1")
			color: controlpanel.connectionState > 1  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

		Label
        {
            height: 20 * QD.Theme.getSize("size").height
            width: 80 * QD.Theme.getSize("size").height
            anchors.left: xyzlabel.right
			anchors.leftMargin: 5 * QD.Theme.getSize("size").height
            Text
            {
                text: controlpanel.xlocationString
				color: controlpanel.connectionState > 1  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                font: QD.Theme.getFont("font1")
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
            }
        }
		Label
        {
			id:ylabel
            anchors.left: parent.left
			anchors.leftMargin: 20 * QD.Theme.getSize("size").height
			anchors.top:xyzlabel.bottom
			anchors.topMargin: 5 * QD.Theme.getSize("size").height
            width: 30 * QD.Theme.getSize("size").height
            text: "Y:"
            font: QD.Theme.getFont("font1")
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
		
		Label
        {
            height: 20 * QD.Theme.getSize("size").height
            width: 80 * QD.Theme.getSize("size").height
            anchors.left: ylabel.right
			anchors.leftMargin: 5 * QD.Theme.getSize("size").height
			anchors.verticalCenter: ylabel.verticalCenter
            Text
            {
                text: controlpanel.ylocationString
				color:  controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                font: QD.Theme.getFont("font1")
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
            }
        }		

		Label
        {
			id:zlabel
            anchors.left: parent.left
			anchors.leftMargin: 20 * QD.Theme.getSize("size").height
			anchors.top:ylabel.bottom
			anchors.topMargin: 5 * QD.Theme.getSize("size").height
            width: 30 * QD.Theme.getSize("size").height
            text: "Z:"
            font: QD.Theme.getFont("font1")
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
		
		Label
        {
            height: 20 * QD.Theme.getSize("size").height
            width: 80 * QD.Theme.getSize("size").height
            anchors.left: zlabel.right
			anchors.leftMargin: 5 * QD.Theme.getSize("size").height
			anchors.verticalCenter: zlabel.verticalCenter
            Text
            {
                text: controlpanel.zlocationString
				color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                font: QD.Theme.getFont("font1")
				verticalAlignment: Text.AlignVCenter
				horizontalAlignment: Text.AlignHCenter
            }
        }
    }
	Label
	{
		width: 70 * QD.Theme.getSize("size").width
		anchors.bottom: xySpeedGrid.top
		anchors.bottomMargin: 5 * QD.Theme.getSize("size").height
		anchors.left: parent.left
		anchors.leftMargin: 120 * QD.Theme.getSize("size").height
		font: QD.Theme.getFont("font1")
		color: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
		text: catalog.i18nc("@label", "X/Y-Axis")
	}
	Label
	{
		width: 70 * QD.Theme.getSize("size").width
		anchors.bottom: xySpeedGrid.top
		anchors.bottomMargin: 5 * QD.Theme.getSize("size").height
		anchors.left: parent.left
		anchors.leftMargin: 260 * QD.Theme.getSize("size").height
		font: QD.Theme.getFont("font1")
		color: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
		text: catalog.i18nc("@label", "Z-Axis")
	}
    Grid
    {
        id: xySpeedGrid
        anchors.top: xyControlGrid.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5 * QD.Theme.getSize("size").width
        columns: 3
        // spacing: 20 * QD.Theme.getSize("size").width
        rowSpacing : 10 * QD.Theme.getSize("size").width
        columnSpacing: 20 * QD.Theme.getSize("size").width
        Label
        {
            width: 75 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@label", "Distance:")
			color: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            // elide: Text.ElideMiddle
        }
        QIDI.SpinBox
        {
            id: xyDistance
            width: 110 * QD.Theme.getSize("size").height
            value: 50
            to: 100
            from: 0
            stepSize: 10
            unit: "mm"
			text : value
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
        }
		
        QIDI.SpinBox
        {
            id: zDistance
            width: 110 * QD.Theme.getSize("size").height
            value: 10
            to: 50
            from: 0
            stepSize: 5
            unit: "mm"
			text : value
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
        }

        Label
        {
            width: 65 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@label", "Speed:")
			color: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            // elide: Text.ElideMiddle
        }
        QIDI.SpinBox
        {
            id: xySpeed
            width: 110 * QD.Theme.getSize("size").height
            value: 100
            to: 200
            from: 0
            stepSize: 10
            unit: "mm/s"
			text : value
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
        }
		
        QIDI.SpinBox
        {
            id: zSpeed
            width: 110 * QD.Theme.getSize("size").height
            value: 5
            to: 20
            from: 0
            stepSize: 1
            unit: "mm/s"
			text : value
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
        }
    }

}
