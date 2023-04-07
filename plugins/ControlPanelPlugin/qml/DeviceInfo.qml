import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick 2.2
import QtQuick.Dialogs 1.1

import QD 1.1 as QD
import QIDI 1.1 as QIDI

Rectangle{
    id: base
    width: 400 * QD.Theme.getSize("size").height
    height: parent.height
    border.color: QD.Theme.getColor("gray_2")
    border.width: QD.Theme.getSize("size").height
    radius: 5 * QD.Theme.getSize("size").height
    color: QD.Theme.getColor("white_1")

	QD.I18nCatalog{
		id: catalog
		name: "qidi"
	}

    Rectangle{
        id: title
        height: 35 * QD.Theme.getSize("size").height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").height
        color: QD.Theme.getColor("blue_7")
        radius: 5 * QD.Theme.getSize("size").height

        //细节处理，当父级是以锚点定位的宽度，以及边距，则在子级的控件所继承的父级宽度是减去了边距的宽度
        Rectangle{
            width: parent.width
            height: 5 * QD.Theme.getSize("size").height
            anchors.bottom: parent.bottom
            color: QD.Theme.getColor("blue_7")
        }

        Label{
            id: titleLabel
            anchors.centerIn: parent
            text: catalog.i18nc("@label", "Device Information")
            font: QD.Theme.getFont("font2")
        }
    }

    Row{
        id: nameRow
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.margins: QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height

        Label{
            id: nameLabel
            height: parent.height
            width: 90 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@label", "Device Name:" ) 
			color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            font: QD.Theme.getFont("font1")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 8 * QD.Theme.getSize("size").height
        }
        Rectangle {
            width: parent.width  - nameLabel.width - 40*QD.Theme.getSize("size").height
            height: 28 * QD.Theme.getSize("size").height  
            border.color: controlpanel.connectionState > 1 ? QD.Theme.getColor("gray_3") : QD.Theme.getColor("gray_2")
            radius: QD.Theme.getSize("setting_control_radius").width
            border.width: QD.Theme.getSize("default_lining").width
            TextInput{
                anchors.fill: parent
                anchors.margins: 2
                text: controlpanel.printernameString
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1 ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                autoScroll: false //是否滚动，占据一定的宽度和高度
                verticalAlignment: Qt.AlignCenter
                horizontalAlignment : TextInput.AlignHCenter
                activeFocusOnPress :controlpanel.connectionState > 1
                clip:true
                // validator: IntValidator{ bottom: 0; top: 999; }
                onEditingFinished: {
                    controlpanel.setname(text.replace("\n",""))
                    devicelist.deviceView.currentItem.text = text.replace("\n","")
                    // focus=false
                }                    
            }
        }
    }
    Row{
        id:typerow
        // width: parent.width
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: nameRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.margins: QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label{
            id: menuLabel
            width: 90 * QD.Theme.getSize("size").height
            height: parent.height
            color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            text:catalog.i18nc("@label", "Type:" )
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 8 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
        }
        Rectangle {
            width: parent.width  - menuLabel.width - 40*QD.Theme.getSize("size").height
            height: 28 * QD.Theme.getSize("size").height  
            TextInput{
                anchors.fill: parent
                anchors.margins: 2
                text: controlpanel.printertypeString
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1 ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                autoScroll: false //是否滚动，占据一定的宽度和高度
                verticalAlignment: Qt.AlignCenter
                horizontalAlignment : TextInput.AlignHCenter
                activeFocusOnPress :false
                clip:true

            }
        }
    }
    Row{
        id:macrow
        // width: parent.width
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: typerow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.margins: QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label{
            id : macLabel
            width: 90 * QD.Theme.getSize("size").height
            height: parent.height
            color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            text:catalog.i18nc("@label", "MAC:" )
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 8 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
        }
        Rectangle {
            width: parent.width  - menuLabel.width - 40*QD.Theme.getSize("size").height
            height: 28 * QD.Theme.getSize("size").height  
            TextInput{
                anchors.fill: parent
                anchors.margins: 2
                text: controlpanel.macadressString
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1 ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                autoScroll: false //是否滚动，占据一定的宽度和高度
                verticalAlignment: Qt.AlignCenter
                horizontalAlignment : TextInput.AlignHCenter
                activeFocusOnPress :false
                clip:true

            }
        }
    }
    Row{
        id:wifiverrow
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: macrow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.margins: QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label{
            width: 90 * QD.Theme.getSize("size").height
            height: parent.height
            color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            text:catalog.i18nc("@label", "Wifi Version:" )
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 8 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
        }
        Rectangle {
            width: parent.width  - menuLabel.width - 40*QD.Theme.getSize("size").height
            height: 28 * QD.Theme.getSize("size").height  
            TextInput{
                anchors.fill: parent
                anchors.margins: 2
                text: controlpanel.wifiversionString
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1 ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                autoScroll: false //是否滚动，占据一定的宽度和高度
                verticalAlignment: Qt.AlignCenter
                horizontalAlignment : TextInput.AlignHCenter
                activeFocusOnPress :false
                clip:true

            }
        }
    }

    Row{
        id:iprow
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: wifiverrow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.margins: QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label{
            width: 90 * QD.Theme.getSize("size").height
            height: parent.height
            color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            text:catalog.i18nc("@label", "IP:" )
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 8 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
        }
        Rectangle {
            width: parent.width  - menuLabel.width - 40*QD.Theme.getSize("size").height
            height: 28 * QD.Theme.getSize("size").height  
            TextInput{
                anchors.fill: parent
                anchors.margins: 2
                text: controlpanel.ipadressString
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1 ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                autoScroll: false //是否滚动，占据一定的宽度和高度
                verticalAlignment: Qt.AlignCenter
                horizontalAlignment : TextInput.AlignHCenter
                activeFocusOnPress :false
                clip:true

            }
        }
    }
    Row{
        id:printersizerow
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: iprow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.margins: QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label{
            width: 90 * QD.Theme.getSize("size").height
            height: parent.height
            color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            text:catalog.i18nc("@label", "Print Size:" )
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 8 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
        }
        Rectangle {
            width: parent.width  - menuLabel.width - 40*QD.Theme.getSize("size").height
            height: 28 * QD.Theme.getSize("size").height  
            TextInput{
                anchors.fill: parent
                anchors.margins: 2
                text: controlpanel.printersizeString
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1 ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                autoScroll: false //是否滚动，占据一定的宽度和高度
                verticalAlignment: Qt.AlignCenter
                horizontalAlignment : TextInput.AlignHCenter
                activeFocusOnPress :false
                clip:true

            }
        }
    }
    Row{
        id:extrudernumrow
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: printersizerow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.margins: QD.Theme.getSize("size").height
        spacing: 20 * QD.Theme.getSize("size").height
        Label{
            width: 90 * QD.Theme.getSize("size").height
            height: parent.height
            color: controlpanel.connectionState > 1 ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            text:catalog.i18nc("@label", "Extruder:" )
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            leftPadding: 8 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
        }
        Rectangle {
            width: parent.width  - menuLabel.width - 40*QD.Theme.getSize("size").height
            height: 28 * QD.Theme.getSize("size").height  
            TextInput{
                anchors.fill: parent
                anchors.margins: 2
                text: controlpanel.extrudernumString
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1 ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                autoScroll: false //是否滚动，占据一定的宽度和高度
                verticalAlignment: Qt.AlignCenter
                horizontalAlignment : TextInput.AlignHCenter
                activeFocusOnPress :false
                clip:true
            }
        }
    }
}
