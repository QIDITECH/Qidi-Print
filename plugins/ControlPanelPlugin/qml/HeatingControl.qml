import QtQuick 2.10
import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

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
    color: QD.Theme.getColor("white_1")

	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}


    Grid
    {
        id: doubleETem
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10 * QD.Theme.getSize("size").height
        columns: 7
        columnSpacing: 6 * QD.Theme.getSize("size").height
        rowSpacing: 10 * QD.Theme.getSize("size").height
		QD.RecolorImage
		{
			source: QD.Theme.getIcon("extruder_button","plugin")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
			
		}
        Label
        {
            width: 105 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: "E1:"
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
        }
        Label
        {
            id: e1Label
            height: 21 * QD.Theme.getSize("size").width
            width:  35 * QD.Theme.getSize("size").width
            Text
            {
                text: controlpanel.realE1TempString
                height: parent.height
				anchors.left: parent.left
                width: 53 * QD.Theme.getSize("size").width / 2
                font: QD.Theme.getFont("font1")
				anchors.verticalCenter: parent.verticalCenter
				color: controlpanel.connectionState > 1 ? controlpanel.expectE1TempString > 50 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }
            Text
            {
                text: "℃"
                height: e1Label.height
				anchors.right: parent.right
				anchors.rightMargin: 5 * QD.Theme.getSize("size").width
                width: 10 * QD.Theme.getSize("size").width / 2
                font: QD.Theme.getFont("font1")
				anchors.verticalCenter: parent.verticalCenter
				color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }
        }

        Label
        {
            height: 20 * QD.Theme.getSize("size").width
            width: 10 * QD.Theme.getSize("size").width
            text: "/"
            font: QD.Theme.getFont("font4")
			color: controlpanel.connectionState > 1  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
        }

        QIDI.SpinBoxWithValidator
        {
            id: e1Tem
            width: 70 * QD.Theme.getSize("size").height
            value: 200
            to: 350
            from: 0
            stepSize: 5
            unit: "℃"
			text : value
			enabled:controlpanel.connectionState > 1  
        }

        QIDI.PrimaryButtonInControl
        {
            id: e1OnButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button", "ON")
            backgroundRadius: Math.round(height / 2)
            onClicked: 
			{
				e1Tem.value = e1Tem.text
                controlpanel.setextruder0t(e1Tem.value)
			}
			enabled:controlpanel.connectionState > 1
        }

        QIDI.SecondaryButtonInControl
        {
            id: e1OffButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button", "Off")
            backgroundRadius: Math.round(height / 2)
            ////leftPadding: 10 * QD.Theme.getSize("size").height
            onClicked:
            {
                controlpanel.setextruder0t("0")
                //controlpanel.setCustomControlCmd("E1" + "/" + "0")
                //e1Tem.value = 0
            }
			enabled:controlpanel.connectionState > 1 
        }
		QD.RecolorImage
		{
			source: QD.Theme.getIcon("extruder_button","plugin")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: controlpanel.connectionState > 1 && controlpanel.extrudernumString == "2" ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
		}
        Label
        {
            width: 105 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: "E2:"
			color: controlpanel.connectionState > 1  && controlpanel.extrudernumString == "2" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
        }

        Label
        {
            id: e2Label
            height: 21 * QD.Theme.getSize("size").width
            width:  35 * QD.Theme.getSize("size").width

            Text
            {
                text: controlpanel.realE2TempString
                height: parent.height
                width: 53 * QD.Theme.getSize("size").width / 2
                anchors.left: parent.left
				color: controlpanel.connectionState > 1 && controlpanel.extrudernumString == "2" ? controlpanel.expectE2TempString > 50 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                font: QD.Theme.getFont("font1")
				anchors.verticalCenter: parent.verticalCenter
                //verticalAlignment: Text.AlignVCenter
                //horizontalAlignment: Text.AlignRight
            }

            Text
            {
                text: "℃"
                height: parent.height
                width: 10 * QD.Theme.getSize("size").width / 2
                anchors.right: parent.right
				color: controlpanel.connectionState > 1 && controlpanel.extrudernumString == "2" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                anchors.rightMargin: 5 * QD.Theme.getSize("size").width
                font: QD.Theme.getFont("font1")
				anchors.verticalCenter: parent.verticalCenter
                //verticalAlignment: Text.AlignVCenter
                //horizontalAlignment: Text.AlignRight
            }
        }

        Label
        {
            height: 20 * QD.Theme.getSize("size").width
            width: 10 * QD.Theme.getSize("size").width
            text: "/"
            font: QD.Theme.getFont("font4")
			color: controlpanel.connectionState > 1 && controlpanel.extrudernumString == "2" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
        }

        QIDI.SpinBoxWithValidator
        {
            id: e2Tem
            width: 70 * QD.Theme.getSize("size").height
            value: 200
            to: 350
            from: 0
            stepSize: 5
            unit: "℃"
			text : value
			enabled:controlpanel.connectionState > 1  && controlpanel.extrudernumString == "2"
        }

        QIDI.PrimaryButtonInControl
        {
            id: e2OnButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button", "ON")
            backgroundRadius: Math.round(height / 2)
            ////leftPadding: 10 * QD.Theme.getSize("size").height
            onClicked: 
			{
				e2Tem.value = e2Tem.text
				// controlpanel.setCustomControlCmd("E2" + "/" + e2Tem.value.toString())
                controlpanel.setextruder1t(e2Tem.value)

			}
			enabled:controlpanel.connectionState > 1   && controlpanel.extrudernumString == "2"
        }

        QIDI.SecondaryButtonInControl
        {
            id: e2OffButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button", "Off")
            backgroundRadius: Math.round(height / 2)
            ////leftPadding: 10 * QD.Theme.getSize("size").height
            onClicked:
            {
                // controlpanel.setCustomControlCmd("E2" + "/" + "0")
                controlpanel.setextruder1t("0")

                //e2Tem.value = 0
            }
			enabled:controlpanel.connectionState > 1   && controlpanel.extrudernumString == "2"
        }
    }
	Label
	{
		id:distancelabel
		width: 105 * QD.Theme.getSize("size").width
		anchors.top: doubleETem.bottom
		anchors.left: parent.left
		anchors.topMargin: 10 * QD.Theme.getSize("size").height
		anchors.leftMargin: 150 * QD.Theme.getSize("size").height
		font: QD.Theme.getFont("font1")
		text: "E2"
		color:controlpanel.connectionState > 1 && controlpanel.extrudernumString == "2"  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
	}
	Label
	{
		width: 105 * QD.Theme.getSize("size").width
		anchors.top: doubleETem.bottom
		anchors.left: distancelabel.right
		anchors.topMargin: 10 * QD.Theme.getSize("size").height
		anchors.leftMargin: 25 * QD.Theme.getSize("size").height
		font: QD.Theme.getFont("font1")
		text: "E1"
		color: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
	}
    Row
    {
        id: e1Advanced
        height: 21 * QD.Theme.getSize("size").height
        anchors.top: distancelabel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10 * QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label
        {
            width: 75 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@heatingLabel", "Distance:")
			color: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
        }
        QIDI.SpinBox
        {
            id: e2Distance
            width: 110 * QD.Theme.getSize("size").height
            value: 10
            to: 1000
            from: 0
            stepSize: 1
            unit: "mm"
			text : value
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && controlpanel.extrudernumString == "2"
        }

        QIDI.SpinBox
        {
            id: eDistance
            width: 110 * QD.Theme.getSize("size").height
            value: 10
            to: 1000
            from: 0
            stepSize: 1
            unit: "mm"
			text : value
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)
        }
    }

    Row
    {
        id: e2Advanced
        height: 21 * QD.Theme.getSize("size").height
        anchors.top: e1Advanced.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10 * QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label
        {
            width: 75 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@heatingLabel", "Speed:")
			color: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
        }
        QIDI.SpinBox
        {
            id: e2Speed
            width: 110 * QD.Theme.getSize("size").height
            value: 5
            to: 20
            from: 0
            stepSize: 1
            unit: "mm/s"
			text : value
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && controlpanel.extrudernumString == "2"
        }

        QIDI.SpinBox
        {
            id: eSpeed
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


    Row
    {
        id: doubleEMove
        height: 35 * QD.Theme.getSize("size").height
        anchors.top: e2Advanced.bottom
        anchors.left: parent.left
        anchors.leftMargin:50* QD.Theme.getSize("size").height
        anchors.right: parent.right
        anchors.margins: 10 * QD.Theme.getSize("size").height
        spacing: 40 * QD.Theme.getSize("size").height

        QIDI.ToolbarButton
        {
            id: e2MoveUpButton
            width: 35 * QD.Theme.getSize("size").width
            height: 35 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("extruder_button","plugin")
                color: e2MoveUpButton.enabled ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_2")
                width: e2MoveUpButton.hovered ? 34 * QD.Theme.getSize("size").height : 32 * QD.Theme.getSize("size").height
                height: e2MoveUpButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }

            QD.RecolorImage
            {
                source: QD.Theme.getIcon("e_red_up","plugin")
                color: e2MoveUpButton.enabled  ? QD.Theme.getColor("red_1") : QD.Theme.getColor("gray_2")
                width: 10 *　QD.Theme.getSize("size").height
                height: 15 *　QD.Theme.getSize("size").height
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 4 * QD.Theme.getSize("size").height
                anchors.bottomMargin: 6 *　QD.Theme.getSize("size").height
            }

            Text
            {
                text: QIDI.ExtruderManager.activeExtruderStackId.search("x-pro") !=-1 ? "L":"E2" 
                font: QD.Theme.getFont("default")
				anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16 *　QD.Theme.getSize("size").height
				color : e2MoveUpButton.enabled  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }

            onClicked: 
			{
				e2Distance.value = e2Distance.text
				e2Speed.value = e2Speed.text
                controlpanel.e1up(e2Distance.value,e2Speed.value )
			}
			enabled:Number(controlpanel.realE2TempString) > 150 && controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && Number(controlpanel.realE2TempString) != 1077
        }

        QIDI.ToolbarButton
        {
            id: e2MoveDownButton
            width: 35 * QD.Theme.getSize("size").width
            height: 35 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("extruder_button","plugin")
                color: e2MoveDownButton.enable ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: e2MoveDownButton.hovered ? 34 * QD.Theme.getSize("size").height : 32 * QD.Theme.getSize("size").height
                height: e2MoveDownButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }

            QD.RecolorImage
            {
                source: QD.Theme.getIcon("e_red_down","plugin")
                color: e2MoveDownButton.enable  ? QD.Theme.getColor("red_1") : QD.Theme.getColor("gray_2")
                width: 10 *　QD.Theme.getSize("size").height
                height: 15 *　QD.Theme.getSize("size").height
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 4 * QD.Theme.getSize("size").height
                anchors.bottomMargin: 6 *　QD.Theme.getSize("size").height
            }

            Text
            {
                text: QIDI.ExtruderManager.activeExtruderStackId.search("x-pro") !=-1 ? "L":"E2" 
                font: QD.Theme.getFont("default")
				anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16 *　QD.Theme.getSize("size").height
				color : e2MoveDownButton.enable ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }

            onClicked: 
			{
				e2Distance.value = e2Distance.text
				e2Speed.value = e2Speed.text
                controlpanel.e1down(e2Distance.value,e2Speed.value )

			}
			enabled: Number(controlpanel.realE2TempString) > 150 && controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && Number(controlpanel.realE2TempString) != 1077
        }

        QIDI.ToolbarButton
        {
            id: e1MoveUpButton
            width: 35 * QD.Theme.getSize("size").width
            height: 35 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("extruder_button","plugin")
                color: e1MoveUpButton.enabled ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: e1MoveUpButton.hovered ? 34 * QD.Theme.getSize("size").height : 32 * QD.Theme.getSize("size").height
                height: e1MoveUpButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }

            QD.RecolorImage
            {
                source: QD.Theme.getIcon("e_red_up","plugin")
                color: e1MoveUpButton.enabled ? QD.Theme.getColor("red_1") : QD.Theme.getColor("gray_2")
                width: 10 *　QD.Theme.getSize("size").height
                height: 15 *　QD.Theme.getSize("size").height
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 4 * QD.Theme.getSize("size").height
                anchors.bottomMargin: 6 *　QD.Theme.getSize("size").height
            }

            Text
            {
                text: QIDI.ExtruderManager.activeExtruderStackId.search("x-pro") !=-1 ? "R":"E1" 
                font: QD.Theme.getFont("default")
                //anchors.right: parent.right
				anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                //anchors.rightMargin: 9 * QD.Theme.getSize("size").height
                anchors.bottomMargin: 16 *　QD.Theme.getSize("size").height
				color : e1MoveUpButton.enabled ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }

            onClicked: 
			{
				eDistance.value = eDistance.text
				eSpeed.value = eSpeed.text
                controlpanel.e0up(eDistance.value,eSpeed.value )

			}
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && Number(controlpanel.realE1TempString) > 150
        }

        QIDI.ToolbarButton
        {
            id: e1MoveDownButton
            width: 35 * QD.Theme.getSize("size").width
            height: 35 * QD.Theme.getSize("size").width
            hasBorderElement: true
            toolItem: QD.RecolorImage
            {
                source: QD.Theme.getIcon("extruder_button","plugin")
                color: e1MoveDownButton.enabled ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
                width: e1MoveDownButton.hovered ? 34 * QD.Theme.getSize("size").height : 32 * QD.Theme.getSize("size").height
                height: e1MoveDownButton.hovered ? 30 * QD.Theme.getSize("size").height : 28 * QD.Theme.getSize("size").height
            }

            QD.RecolorImage
            {
                source: QD.Theme.getIcon("e_red_down","plugin")
                color: e1MoveDownButton.enabled ? QD.Theme.getColor("red_1") : QD.Theme.getColor("gray_2")
                width: 10 *　QD.Theme.getSize("size").height
                height: 15 *　QD.Theme.getSize("size").height
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 4 * QD.Theme.getSize("size").height
                anchors.bottomMargin: 6 *　QD.Theme.getSize("size").height
            }

            Text
            {
                text: QIDI.ExtruderManager.activeExtruderStackId.search("x-pro") !=-1 ? "R":"E1" 
                font: QD.Theme.getFont("default")
				anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16 *　QD.Theme.getSize("size").height
				color : e1MoveDownButton.enabled ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }

            onClicked: 
			{
				eDistance.value = eDistance.text
				eSpeed.value = eSpeed.text
                controlpanel.e0down(eDistance.value,eSpeed.value )
			}
			enabled:controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause) && Number(controlpanel.realE1TempString) > 150
        }

    }

    Grid
    {
        id: otherGrid
        anchors.top: doubleEMove.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10 * QD.Theme.getSize("size").height
        columns: 7
        columnSpacing: 6 * QD.Theme.getSize("size").height
        rowSpacing: 10 * QD.Theme.getSize("size").height
		QD.RecolorImage
		{
			source: QD.Theme.getIcon("Bed","plugin")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
		}
        Label
        {
            width: 30 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text:  catalog.i18nc("@label", "Bed:")
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            elide: Text.ElideMiddle
        }

        Label
        {
            id: bedLabel
            height: 21 * QD.Theme.getSize("size").width
            width:  35 * QD.Theme.getSize("size").width

            Text
            {
                text: controlpanel.realBedTempString
                height: parent.height
                width: 53 * QD.Theme.getSize("size").width / 2
                anchors.left: parent.left
                font: QD.Theme.getFont("font1")
				color: controlpanel.connectionState > 1 ? controlpanel.expectBedTempString > 40 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }

            Text
            {
                text: "℃"
                height: parent.height
                width: 10 * QD.Theme.getSize("size").width / 2
                anchors.right: parent.right
                anchors.rightMargin: 5 * QD.Theme.getSize("size").width
                font: QD.Theme.getFont("font1")
				color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label
        {
            height: 20 * QD.Theme.getSize("size").width
            width: 10 * QD.Theme.getSize("size").width
            text: "/"
			color: controlpanel.connectionState > 1  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            font: QD.Theme.getFont("font4")
            verticalAlignment: Text.AlignVCenter
        }

        QIDI.SpinBoxWithValidator
        {
            id: bedTem
            width: 70 * QD.Theme.getSize("size").height
            value: 60
            to: 120
            from: 0
            stepSize: 10
			text : value
            unit: "℃"
			enabled:controlpanel.connectionState > 1 
        }

        QIDI.PrimaryButtonInControl
        {
            id: bedOnButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button", "ON")
            backgroundRadius: Math.round(height / 2)
            onClicked: {
				bedTem.value = bedTem.text
                controlpanel.setbedt(bedTem.value)
			}
			enabled:controlpanel.connectionState > 1 
        }

        QIDI.SecondaryButtonInControl
        {
            id: bedOffButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button", "Off")
            backgroundRadius: Math.round(height / 2)
            onClicked:
            {
                controlpanel.setbedt("0")
            }
			enabled:controlpanel.connectionState > 1 
        }

		QD.RecolorImage
		{
			source: QD.Theme.getIcon("Fan","default")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
		}

        Label
        {
            width: 105 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@label","Cooling:")
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            elide: Text.ElideMiddle
        }

        Label
        {
            id: printCoolingLabel
            height: 21 * QD.Theme.getSize("size").width
            width:  35 * QD.Theme.getSize("size").width

            Text
            {
                text: controlpanel.realFanSpeedString
                height: parent.height
                width: 53 * QD.Theme.getSize("size").width / 2
                anchors.left: parent.left
                font: QD.Theme.getFont("font1")
				color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }

            Text
            {
                text: "%"
                height: parent.height
                width: 10 * QD.Theme.getSize("size").width / 2
                anchors.right: parent.right
                anchors.rightMargin: 5 * QD.Theme.getSize("size").width
                font: QD.Theme.getFont("font1")
				color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label
        {
            height: 20 * QD.Theme.getSize("size").width
            width: 10 * QD.Theme.getSize("size").width
            text: "/"
            font: QD.Theme.getFont("font4")
			color: controlpanel.connectionState > 1  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
        }

        QIDI.SpinBoxWithValidator
        {
            id: printCoolingRate
            width: 70 * QD.Theme.getSize("size").height
            value: 100
            to: 100
            from: 0
            stepSize: 10
			text : value
            unit: "%"
			enabled:controlpanel.connectionState > 1 
        }

        QIDI.PrimaryButtonInControl
        {
            id: printCoolingOnButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button","ON")
            backgroundRadius: Math.round(height / 2)
            onClicked: 
			{
				printCoolingRate.value = printCoolingRate.text
                controlpanel.setfan(printCoolingRate.value)
			}
			enabled:controlpanel.connectionState > 1 
        }

        QIDI.SecondaryButtonInControl
        {
            id: printCoolingOffButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button","Off")
            backgroundRadius: Math.round(height / 2)
            onClicked:
            {
                controlpanel.setfan("0")
            }
			enabled:controlpanel.connectionState > 1 
        }

		QD.RecolorImage
		{
			source: QD.Theme.getIcon("Fan","default")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True"? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
		}

        Label
        {
            width: 105 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@label","Rapid Cooling:")
			color:  controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            elide: Text.ElideMiddle
        }

        Label
        {
            id: rapidprintCoolingLabel
            height: 21 * QD.Theme.getSize("size").width
            width:  35 * QD.Theme.getSize("size").width

            Text
            {
                text: controlpanel.realrapid_cooling_speedString
                height: parent.height
                width: 53 * QD.Theme.getSize("size").width / 2
                anchors.left: parent.left
                font: QD.Theme.getFont("font1")
				color:  controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }

            Text
            {
                text: "%"
                height: parent.height
                width: 10 * QD.Theme.getSize("size").width / 2
                anchors.right: parent.right
                anchors.rightMargin: 5 * QD.Theme.getSize("size").width
                font: QD.Theme.getFont("font1")
				color:  controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label
        {
            height: 20 * QD.Theme.getSize("size").width
            width: 10 * QD.Theme.getSize("size").width
            text: "/"
            font: QD.Theme.getFont("font4")
			color:  controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True"  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
        }

        QIDI.SpinBoxWithValidator
        {
            id: rapidprintCoolingRate
            width: 70 * QD.Theme.getSize("size").height
            value: 100
            to: 100
            from: 0
            stepSize: 10
			text : value
            unit: "%"
			enabled: controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True"
        }

        QIDI.PrimaryButtonInControl
        {
            id: rapidprintCoolingOnButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button","ON")
            backgroundRadius: Math.round(height / 2)
            onClicked: 
			{
				rapidprintCoolingRate.value = rapidprintCoolingRate.text
                controlpanel.setrapidfan(rapidprintCoolingRate.value)
			}
			enabled: controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True"
        }

        QIDI.SecondaryButtonInControl
        {
            id: rapidprintCoolingOffButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@button","Off")
            backgroundRadius: Math.round(height / 2)
            onClicked:
            {
                controlpanel.setfan("0")
            }
			enabled: controlpanel.connectionState > 1 && controlpanel.rapid_cooling_enabled =="True"
        }

		QD.RecolorImage
		{
			source: QD.Theme.getIcon("Chamber","plugin")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: (controlpanel.connectionState > 1 && controlpanel.chamber_cooling_enabled == "True") ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
		}

        Label
        {
            width: 105 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text:  catalog.i18nc("@label","Chamber Cooling:")
			color: (controlpanel.connectionState > 1 && controlpanel.chamber_cooling_enabled == "True") ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            elide: Text.ElideMiddle
        }

        Label
        {
            id: fanSpeedLabel
            height: 21 * QD.Theme.getSize("size").width
            width:  35 * QD.Theme.getSize("size").width

            Text
            {
				id: charmbertext
                text: controlpanel.realchamber_cooling_speedString
                height: parent.height
                width: 53 * QD.Theme.getSize("size").width / 2
                anchors.left: parent.left
                font: QD.Theme.getFont("font1")
				color: (controlpanel.connectionState > 1 && controlpanel.chamber_cooling_enabled == "True") ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }

            Text
            {
                text: "%"
                height: parent.height
                width: 10 * QD.Theme.getSize("size").width / 2
                anchors.right: parent.right
                anchors.rightMargin: 5 * QD.Theme.getSize("size").width
                font: QD.Theme.getFont("font1")
				color: (controlpanel.connectionState > 1 && controlpanel.chamber_cooling_enabled == "True") ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
				anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label
        {
            height: 20 * QD.Theme.getSize("size").width
            width: 10 * QD.Theme.getSize("size").width
            text: "/"
            font: QD.Theme.getFont("font4")
			color: (controlpanel.connectionState > 1 &&    controlpanel.chamber_cooling_enabled == "True") ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            verticalAlignment: Text.AlignVCenter
        }

        QIDI.SpinBoxWithValidator
        {
            id: fanSpeedRate
            width: 70 * QD.Theme.getSize("size").height
            value: 100
            to: 100
            from: 0
            stepSize: 10
			text : value
            unit: "%"
			enabled:(controlpanel.connectionState > 1 &&    controlpanel.chamber_cooling_enabled == "True")
        }

        QIDI.PrimaryButtonInControl
        {
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text:  catalog.i18nc("@button","ON")
            backgroundRadius: Math.round(height / 2)
            onClicked: 
			{
				fanSpeedRate.value = fanSpeedRate.text
                controlpanel.setchamber(rapidprintCoolingRate.value)
				charmbertext.text = fanSpeedRate.value
			}
			enabled:(controlpanel.connectionState > 1 &&   controlpanel.chamber_cooling_enabled == "True") 
        }

        QIDI.SecondaryButtonInControl
        {
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text:  catalog.i18nc("@button","Off")
            backgroundRadius: Math.round(height / 2)
            onClicked:
            {
                controlpanel.setchamber("0")
				charmbertext.text = 0
            }
			enabled:(controlpanel.connectionState > 1  && controlpanel.chamber_cooling_enabled == "True") 
        }

		QD.RecolorImage
		{
			source: QD.Theme.getIcon("Volume Temp","plugin")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True" ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2") 
		}

        Label
        {
            width: 105 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
            text:  catalog.i18nc("@label","Volume:")
			color: controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2") 
            elide: Text.ElideMiddle
        }

        Label
        {
            id: volumeTempLabel
            height: 21 * QD.Theme.getSize("size").width
            width:  35 * QD.Theme.getSize("size").width


            Text
            {
				id:volumetext
                text: controlpanel.realVolTempString
                height: parent.height
                width: 53 * QD.Theme.getSize("size").width / 2
                anchors.left: parent.left
                font: QD.Theme.getFont("font1")
				color: controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True" ? controlpanel.expectVolTempString > 40 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
 				anchors.verticalCenter: parent.verticalCenter
            }

            Text
            {
                text: "℃"
                height: parent.height
                width: 10 * QD.Theme.getSize("size").width / 2
                anchors.right: parent.right
                anchors.rightMargin: 5 * QD.Theme.getSize("size").width
                font: QD.Theme.getFont("font1")
				color: controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2") 
				anchors.verticalCenter: parent.verticalCenter
            }
        }

        Label
        {
            height: 20 * QD.Theme.getSize("size").width
            width: 10 * QD.Theme.getSize("size").width
            text: "/"
            font: QD.Theme.getFont("font4")
			color: controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True" ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2") 
            verticalAlignment: Text.AlignVCenter
        }

        QIDI.SpinBoxWithValidator
        {
            id: volumeTempTem
            width: 70 * QD.Theme.getSize("size").height
            value: 80
            to: 80
            from: 0
            stepSize: 10
			text : value
            unit: "℃"
			enabled:controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True"
        }

        QIDI.PrimaryButtonInControl
        {
            id: volumeTempOnButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text:  catalog.i18nc("@button","ON")
            backgroundRadius: Math.round(height / 2)
            onClicked: 
			{
				volumeTempTem.value = volumeTempTem.text
                controlpanel.setVolumet(volumeTempTem.value)
			}
			enabled:controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True"
        }

        QIDI.SecondaryButtonInControl
        {
            id: volumeTempOffButton
            width: 40 * QD.Theme.getSize("size").height
            height: 21 * QD.Theme.getSize("size").height
            text:  catalog.i18nc("@button","Off")
            backgroundRadius: Math.round(height / 2)
            onClicked:
            {
                controlpanel.setVolumet("0")
            }
			enabled:controlpanel.connectionState > 1  && controlpanel.volume_enabled == "True"
        }
    }

    Row
    {
        id: filamentSenserRow
        height: 21 * QD.Theme.getSize("size").height
        anchors.top: otherGrid.bottom
		anchors.topMargin: 10 * QD.Theme.getSize("size").height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
        spacing: 6 * QD.Theme.getSize("size").width
		QD.RecolorImage
		{
			source: QD.Theme.getIcon("Filament Senser","plugin")
			width: 20 * QD.Theme.getSize("size").height
			height: 20 * QD.Theme.getSize("size").height
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_2")
		}
        Label
        {
            width: 100 * QD.Theme.getSize("size").width
            font: QD.Theme.getFont("font1")
			color: controlpanel.connectionState > 1  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            text: catalog.i18nc("@label","Filament Sensor:")
            elide: Text.ElideMiddle
        }

        QIDI.CheckBox
        {
			id:filamentcheckbox
            height: 18 * QD.Theme.getSize("size").width
            width: height
            checked:controlpanel.realIReadString == "1"
			onClicked:
			{
				if(filamentcheckbox.checked == true)
				{
                    controlpanel.setSensor("1")
				}
				else
				{
                    controlpanel.setSensor("0")

				}
				
			}
			enabled: controlpanel.connectionState > 1  
        }
    }
}
