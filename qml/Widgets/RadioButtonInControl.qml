// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.0 as QIDI


//
// QIDI-style RadioButton.
//
RadioButton
{
    id: radioButton
    property alias source: deviceStateIcon.source
    property alias ip: deviceIPLabel.text
    property bool connected : false 
    font: QD.Theme.getFont("default")
    enabled: controlpanel.connectionState ==0
    background: Item
    {
        anchors.fill: parent
    }

    indicator: Rectangle
    {
        implicitWidth: QD.Theme.getSize("radio_button").width
        implicitHeight: QD.Theme.getSize("radio_button").height
        anchors.verticalCenter: parent.verticalCenter
        anchors.alignWhenCentered: false
        radius: width / 2
        border.width: QD.Theme.getSize("default_lining").width
        border.color: radioButton.hovered ? QD.Theme.getColor("small_button_text") : QD.Theme.getColor("small_button_text_hover")
        visible: deviceIPLabel.text != ""
        Rectangle
        {
            width: (parent.width / 2) | 0
            height: width
            anchors.centerIn: parent
            radius: width / 2
            color: radioButton.hovered ? QD.Theme.getColor("primary_button_hover") : QD.Theme.getColor("primary_button")
            visible: radioButton.checked  && deviceIPLabel.text != ""
        }
    }

    contentItem:Rectangle
	{
		anchors.left:parent.left
		anchors.leftMargin:radioButton.indicator.width + radioButton.spacing
		anchors.verticalCenter: parent.verticalCenter
        height:parent.height
        Label{
            id: deviceNameLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 170 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
            text: radioButton.text
            color: QD.Theme.getColor("text")
            elide: Text.AlignRight
        }
        Label{
            id: deviceIPLabel
            width: 50 * QD.Theme.getSize("size").height
            anchors.left: deviceNameLabel.right
            anchors.leftMargin: 10 * QD.Theme.getSize("size").height
            anchors.verticalCenter: parent.verticalCenter
            font: QD.Theme.getFont("font1")
            text: radioButton.text
            color: QD.Theme.getColor("text")
        }
        QD.RecolorImage{
            id:deviceStateIcon
            //source: QD.Theme.getIcon("Connect","plugin")
            anchors.left: deviceIPLabel.right
            anchors.leftMargin: 75 * QD.Theme.getSize("size").height
            anchors.verticalCenter: parent.verticalCenter
            width: 18 * QD.Theme.getSize("size").height
            height: 20 * QD.Theme.getSize("size").height
            color: QD.Theme.getColor("blue_6")
            visible : deviceIPLabel.text != ""
        }
        Label{
            id: deviceStateLabel2
            //height: parent.height
            anchors.left: deviceStateIcon.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            font: QD.Theme.getFont("font1")
            text: controlpanel.PrintProgress
            topPadding: 6 * QD.Theme.getSize("size").height
            horizontalAlignment: Text.AlignHCenter
            color: QD.Theme.getColor("text")
            visible:controlpanel.isPrinting && deviceIPLabel.text != "" && connected //&& radioButton.checked
        }
	}
}
