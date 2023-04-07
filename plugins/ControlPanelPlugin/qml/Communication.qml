import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 

import QD 1.1 as QD
import QIDI 1.1 as QIDI
import "."
Item
{
    id: commbase
    height: parent.height
    width: parent.width

	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}
    XYZControl
    {
        id: xyzControl
        height: 230 * QD.Theme.getSize("size").height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10 * QD.Theme.getSize("size").height
    }

    HeatingControl
    {
        id: heatingControl
        anchors.top: xyzControl.bottom
        anchors.topMargin:5 * QD.Theme.getSize("size").height
        anchors.right: parent.right
        anchors.rightMargin:10 * QD.Theme.getSize("size").height
        anchors.bottom: parent.bottom
        anchors.bottomMargin:10 * QD.Theme.getSize("size").height
    }
    Rectangle
    {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: xyzControl.left
        anchors.bottom: parent.bottom
        anchors.margins: 10 * QD.Theme.getSize("size").height

        TextArea
        {
            id: textArea
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: commandText.top
            anchors.bottomMargin: 10 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@textArea", "Some Commands would have sent by Device IP") + " \n" +  controlpanel.allResultdata 
            frameVisible: true
            font: QD.Theme.getFont("font1")
        }

        QIDI.TextField
        {
            id: commandText
            height: 30 * QD.Theme.getSize("size").height
            anchors.left: parent.left
            anchors.right: sendCommandButton.left
            anchors.rightMargin: 10 * QD.Theme.getSize("size").height
            anchors.bottom: parent.bottom
        }

        QIDI.SecondaryButton
        {
            id: sendCommandButton
            width: 100 * QD.Theme.getSize("size").height
            height: 25 * QD.Theme.getSize("size").height
            anchors.verticalCenter: commandText.verticalCenter
            anchors.right: parent.right
            text:  catalog.i18nc("@button", "Send")
            backgroundRadius: Math.round(height / 3)
            fixedWidthMode: true
            onClicked: controlpanel.sendCommand(commandText.text)
            enabled:!controlpanel.isBusy
        }

    }
}
