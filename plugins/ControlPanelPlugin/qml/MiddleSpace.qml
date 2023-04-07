import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4

import QD 1.3 as QD
import QIDI 1.1 as QIDI

Rectangle
{
    id: base
    width: parent.width * QD.Theme.getSize("size").height
    height: parent.height 
    border.color: QD.Theme.getColor("gray_2")
    border.width: QD.Theme.getSize("size").height
    radius: 5 * QD.Theme.getSize("size").height
    color: QD.Theme.getColor("white_1")
    property var extrudersModel: QIDIApplication.getExtrudersModel()

    property alias communicationPageButton: communicationPageButton
	//property string stateconrotl: "DisConnect"
	
	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}
    Rectangle
    {
        id: pageSwitch
        height: 55 * QD.Theme.getSize("size").height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1 * QD.Theme.getSize("size").height
        anchors.topMargin: 2 * QD.Theme.getSize("size").height
        radius: 5 * QD.Theme.getSize("size").height
        color: QD.Theme.getColor("white_1")
        Row
        {
            id: pageSwitchRow
            height: 45 * QD.Theme.getSize("size").height
            width: parent.width - 2 * QD.Theme.getSize("size").height
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10 * QD.Theme.getSize("size").height
            anchors.right: parent.right
            anchors.rightMargin: 10 * QD.Theme.getSize("size").height
            anchors.margins: 5 * QD.Theme.getSize("size").height
			spacing:10* QD.Theme.getSize("size").height
			Rectangle
			{
				id: filepage
				height: 40 * QD.Theme.getSize("size").height
                width: (parent.width - 20 * QD.Theme.getSize("size").height) / 3 
				//anchors.top: parent.top
				//anchors.left: parent.left
				//anchors.leftMargin: 10 * QD.Theme.getSize("size").height
				//anchors.topMargin: 10 * QD.Theme.getSize("size").height
				radius: 20 * QD.Theme.getSize("size").height
				color: QD.Theme.getColor("blue_6")
				border.width: QD.Theme.getSize("size").width
				border.color:QD.Theme.getColor("blue_6")
				QD.TabRowButtonForControl
				{
					id:filePageButton
					//anchors.centerIn: parent
					height: parent.height
					width: parent.width   - 2 * QD.Theme.getSize("size").height
					backgroundColor: QD.Theme.getColor("small_button")//parameterspage.color//QD.Theme.getColor("blue_6")
					borderColor: QD.Theme.getColor("small_button")
					contentItem: Item
					{
						QD.RecolorImage
						{
							source: QD.Theme.getIcon("File","plugin")
							color: filepage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
							width: 18 * QD.Theme.getSize("size").height
							height: 18 * QD.Theme.getSize("size").height
							anchors.right: filetext.left
							anchors.rightMargin: 2 * QD.Theme.getSize("size").height
							anchors.verticalCenter: parent.verticalCenter
						}
						Text
						{
							id:filetext
							text: catalog.i18nc("@button", "File")
							font: QD.Theme.getFont("font2")
							color: filepage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
							anchors.centerIn: parent
						}
					}
					onClicked:
					{
						file.visible = true
						communication.visible = false
						temperature.visible = false
						filepage.color =QD.Theme.getColor("blue_6")
						communicationpage.color = QD.Theme.getColor("white_1")
						tempage.color = QD.Theme.getColor("white_1")

					}
				}
			}
			Rectangle
			{
				id: communicationpage
				height: 40 * QD.Theme.getSize("size").height
                width: (parent.width - 20 * QD.Theme.getSize("size").height) / 3 
				radius: 20 * QD.Theme.getSize("size").height
				color: QD.Theme.getColor("white_1")
				border.width: QD.Theme.getSize("size").width
				border.color:QD.Theme.getColor("blue_6")
				QD.TabRowButtonForControl
				{
					id:communicationPageButton

					//anchors.centerIn: parent
					height: parent.height
					width: parent.width   - 2 * QD.Theme.getSize("size").height
					backgroundColor: QD.Theme.getColor("small_button")//informationpage.color//QD.Theme.getColor("blue_6")
					borderColor: QD.Theme.getColor("small_button")

					contentItem: Item
					{
						QD.RecolorImage
						{
							source: QD.Theme.getIcon("Communication","plugin")
							color: communicationpage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
							width: 18 * QD.Theme.getSize("size").height
							height: 18 * QD.Theme.getSize("size").height
							anchors.right: communicationtext.left
							anchors.rightMargin: 2 * QD.Theme.getSize("size").height

							//anchors.leftMargin: 10 * QD.Theme.getSize("size").height
							//anchors.verticalCenter: parent.verticalCenter
							//anchors.centerIn: parent
							anchors.verticalCenter: parent.verticalCenter
							//anchors.rightMargin: 5*QD.Theme.getSize("size").height
						}
						Text
						{
							id:communicationtext

							text: catalog.i18nc("@button", "Communication")
							font: QD.Theme.getFont("font2")
							color: communicationpage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
							anchors.centerIn: parent
						}
					}
					onClicked:
					{
						file.visible = false
						communication.visible = true
						temperature.visible = false
						filepage.color =QD.Theme.getColor("white_1")
						communicationpage.color = QD.Theme.getColor("blue_6")
						tempage.color = QD.Theme.getColor("white_1")

					}
				}
			}
			Rectangle
			{
				id: tempage
				height: 40 * QD.Theme.getSize("size").height
                width: (parent.width - 20 * QD.Theme.getSize("size").height) / 3 
				radius: 20 * QD.Theme.getSize("size").height
				color: QD.Theme.getColor("white_1")
				border.width: QD.Theme.getSize("size").width
				border.color:QD.Theme.getColor("blue_6")
				QD.TabRowButtonForControl
				{
					id:temPageButton

					//anchors.centerIn: parent
					height: parent.height
					width: parent.width   - 2 * QD.Theme.getSize("size").height
					backgroundColor: QD.Theme.getColor("small_button")//informationpage.color//QD.Theme.getColor("blue_6")
					borderColor: QD.Theme.getColor("small_button")

					contentItem: Item
					{
						QD.RecolorImage
						{
							source: QD.Theme.getIcon("Temperature","plugin")
							color: tempage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
							width: 18 * QD.Theme.getSize("size").height
							height: 18 * QD.Theme.getSize("size").height
							anchors.right: temtext.left
							anchors.rightMargin: 2 * QD.Theme.getSize("size").height

							//anchors.leftMargin: 10 * QD.Theme.getSize("size").height
							//anchors.verticalCenter: parent.verticalCenter
							//anchors.centerIn: parent
							anchors.verticalCenter: parent.verticalCenter
							//anchors.rightMargin: 5*QD.Theme.getSize("size").height
						}
						Text
						{
							id:temtext

							text: catalog.i18nc("@button", "Temperature Plot")
							font: QD.Theme.getFont("font2")
							color: tempage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
							anchors.centerIn: parent
						}
					}
					onClicked:
					{
						file.visible = false
						communication.visible = false
						temperature.visible = true
						filepage.color =QD.Theme.getColor("white_1")
						communicationpage.color = QD.Theme.getColor("white_1")
						tempage.color = QD.Theme.getColor("blue_6")
					}
				}
			}
		}
	}
    
	
    File
    {
        id: file
        visible: true
        height: parent.height - pageSwitch.height
        anchors.top: pageSwitch.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").height
        anchors.topMargin: 0 * QD.Theme.getSize("size").height
    }

    Communication
    {
        id: communication
        visible: false
        height: parent.height - pageSwitch.height
        anchors.top: pageSwitch.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").height
        anchors.topMargin: 0 * QD.Theme.getSize("size").height
    }

    Temperature
    {
        id: temperature
        visible: false
        height: parent.height - pageSwitch.height
        anchors.top: pageSwitch.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").height
        anchors.topMargin: 0 * QD.Theme.getSize("size").height
    }
}
