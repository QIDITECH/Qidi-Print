import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.2


import UM 1.2 as UM

import Cura 1.0 as Cura
Item {
    id:base
    property int defaultTopMargin: UM.Theme.getSize("default_arrow").height
    property int defaultTextFieldWidth: 160 * UM.Theme.getSize("default_margin").width/10
    property int defaultButtonIconHeight :UM.Theme.getSize("button_icon").height
    UM.PointingRectangle
    {
        id: sendBackground
        target: Qt.point(parent.right, 3 * UM.Theme.getSize("default_margin").width/10 + Math.round(UM.Theme.getSize("button").height/2))
        arrowSize: UM.Theme.getSize("default_arrow").width
        width: 250 * UM.Theme.getSize("default_margin").width/10
        color: UM.Theme.getColor("color15")
        borderColor: UM.Theme.getColor("color2")
        borderWidth: UM.Theme.getSize("default_lining").width
        MouseArea //Catch all mouse events (so scene doesnt handle them)
        {
            anchors.fill: parent
        }
        anchors.left: parent.right;
        anchors.leftMargin: UM.Theme.getSize("default_margin").width;
        anchors.top: parent.top;
        anchors.topMargin: base.activeY

        height: wifivisible.properties.value == "True" ? 100 * UM.Theme.getSize("default_margin").width/10 : 154 * UM.Theme.getSize("default_margin").width/10

        Text {
            id: ipText
            text: catalog.i18nc("@action:label", "Device Name")
            font: UM.Theme.getFont("font1")
            anchors {
                top: parent.top
                topMargin: defaultTopMargin
                left: parent.left
                leftMargin: defaultTopMargin
            }
            visible: wifivisible.properties.value == "True" ? false : true
        }
        Button {
            id: inputButton
            text: catalog.i18nc("@Button:text", "Input IP")
            style: UM.Theme.styles.savebutton
            height: 22 * UM.Theme.getSize("default_margin").width/10
            anchors {
                verticalCenter: ipText.verticalCenter
                right: parent.right
                rightMargin: defaultTopMargin
            }
            enabled: ipComboBox.currentText == '' ? true : false
            onClicked: {
                ipComboBox.visible = false
                ipTextField.visible = true
                ipApply.visible = true
                addtosidebar.enabled = false
                newName.visible = false
                newNameTextField.visible = false
                newNameApply.visible = false
                inputIPText.visible = true
                inputIPListText.visible = true
                addtosidebar.visible = false
                send.visible = false
                sendName.visible = false
            }
            visible: wifivisible.properties.value == "True" ? false : true
        }

        Timer
        {
            id: refreshTimer
            repeat: false
            interval: 3000

            onTriggered: refresh.enabled = ipComboBox.enabled = true
        }

        UM.SimpleButton {
            id: refresh
            width: 25 * UM.Theme.getSize("default_margin").width/10
            height: 25 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color12")
            hoverColor: UM.Theme.getColor("color11")
            anchors {
                verticalCenter: ipText.verticalCenter
                right: inputButton.left
                rightMargin: defaultTopMargin
            }
            iconSource: UM.Theme.getIcon("refresh")
            onClicked: {
                Cura.MyWifiSend.scanDeviceThread()
                ipComboBox.currentIndex = -1            //清空列表
                enabled = false
                ipComboBox.enabled = false
                refreshTimer.start()
            }
            visible: wifivisible.properties.value == "True" ? false : true
        }
        ComboBox {
            id: ipComboBox
            model: Cura.MyWifiSend.IPList
            style: UM.Theme.styles.combobox
            anchors {
                top: ipText.bottom
                topMargin: defaultTopMargin
                right: parent.right
                rightMargin: defaultTopMargin
                left: parent.left
                leftMargin: defaultTopMargin
            }
            onAccepted: {
                if (currentText.length > 0 && find(currentText) === -1) {
                    currentIndex = -1
                }
            }
            visible: wifivisible.properties.value == "True" ? false : true
        }

        TextField {
            id: ipTextField
            font: UM.Theme.getFont("font1")
            style: UM.Theme.styles.text_field
            height: 22 * UM.Theme.getSize("default_margin").width/10
            //text: UM.Preferences.getValue("general/input_ip")
            placeholderText: catalog.i18nc("@label:textbox", "Please input host IP.")
            validator: RegExpValidator { regExp: /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ }
            anchors {
                top: ipText.bottom
                topMargin: defaultTopMargin
                left: parent.left
                leftMargin: defaultTopMargin
                right: ipApply.left
                rightMargin: defaultTopMargin
            }
            visible: false
        }
        Button {
            id: ipApply
            text: catalog.i18nc("@Button:text", "Apply")
            style: UM.Theme.styles.savebutton
            height: 22 * UM.Theme.getSize("default_margin").width/10
            anchors {
                verticalCenter:  ipTextField.verticalCenter
                right: parent.right
                rightMargin: defaultTopMargin
            }
            onClicked: {
                UM.Preferences.setValue("general/input_ip", ipTextField.text == "" ? "Please input host IP." : ipTextField.text)
                ipComboBox.visible = true
                ipTextField.visible = false
                ipApply.visible = false
                addtosidebar.enabled = true
                ipComboBox.currentIndex = -1
                newName.visible = true
                newNameTextField.visible = true
                newNameApply.visible = true
                inputIPText.visible = false
                inputIPListText.visible = false
                addtosidebar.visible = true
                send.visible = true
                sendName.visible = true
                Cura.MyWifiSend.scanDeviceThreadByInputIP()
            }
            visible: false
            tooltip: catalog.i18nc("@title:tooltip","If you cant't search any printer by WIFI, you can try to input your computer's IP to search.")
        }

        Text {
            id: newName
            text: catalog.i18nc("@action:label", "New Name")
            font: UM.Theme.getFont("font1")
            anchors {
                top: wifivisible.properties.value == "True" ? parent.top : ipComboBox.bottom
                topMargin: defaultTopMargin
                left: parent.left
                leftMargin: defaultTopMargin
            }
        }
        TextField {
            id: newNameTextField
            font: UM.Theme.getFont("font1")
            style: UM.Theme.styles.text_field
            height: 22 * UM.Theme.getSize("default_margin").width/10
            property string unit: " "
            anchors {
                top: newName.bottom
                topMargin: defaultTopMargin
                left: parent.left
                leftMargin: defaultTopMargin
                right: newNameApply.left
                rightMargin: defaultTopMargin
            }
        }
        Button {
            id: newNameApply
            text: catalog.i18nc("@Button:text", "Apply")
            style: UM.Theme.styles.savebutton
            height: 22 * UM.Theme.getSize("default_margin").width/10
            anchors {
                verticalCenter:  newNameTextField.verticalCenter
                right: parent.right
                rightMargin: defaultTopMargin
            }
            visible: newName.visible
            enabled: newNameTextField.text != ''
            onClicked: {
                Cura.MyWifiSend.renameDevice(newNameTextField.text,ipComboBox.currentText)
                ipComboBox.currentIndex = -1 * UM.Theme.getSize("default_margin").width/10
                newNameTextField.text = ""
                ipComboBox.enabled = false
                refreshTimer.start()
            }
            tooltip: catalog.i18nc("@title:tooltip","Apply the new name")
        }

        Text {
            id: inputIPText
            text: catalog.i18nc("@action:label", "Unable to get host IP,\nplease try to input the following IP.")
            font: UM.Theme.getFont("font7")
            visible: false
            anchors {
                top: wifivisible.properties.value == "True" ? parent.top : ipComboBox.bottom
                topMargin: defaultTopMargin
                left: parent.left
                leftMargin: defaultTopMargin
            }
        }

        Text {
            id: inputIPListText
            text: UM.Preferences.getValue("general/iplist")
            wrapMode: Text.WordWrap
            font: UM.Theme.getFont("font1")
            color: UM.Theme.getColor("color12")
            visible: false
            anchors {
                top: wifivisible.properties.value == "True" ? parent.top : inputIPText.bottom
                topMargin: defaultTopMargin
                left: parent.left
                leftMargin: defaultTopMargin
                right: parent.right
                rightMargin: defaultTopMargin
            }
        }

        Button {
            id: addtosidebar
            text: catalog.i18nc("@action:label", "Add/hide Wifi to Sidebar")
            anchors {
                top: newNameTextField.bottom
                topMargin: defaultTopMargin - 5 * UM.Theme.getSize("default_margin").width/10
                left: parent.left
                leftMargin: defaultButtonIconHeight
            }
            iconSource: UM.Theme.getIcon("export")
            style: UM.Theme.styles.wifi_button
            onClicked: {
                if(wifivisible.properties.value == "True")
                {
                    Cura.MachineManager.setSettingForExtruders("wifi_visible", "value", "False")
                    ipComboBox.visible = true
                }
                else
                {
                    Cura.MachineManager.setSettingForExtruders("wifi_visible", "value", "True")
                    ipComboBox.visible = false
                }
            }
        }

        //=====发送========
        Button {
            id: send
            anchors {
                verticalCenter: addtosidebar.verticalCenter
                right: parent.right
                rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
                left: sendName.left
                leftMargin: -20 * UM.Theme.getSize("default_margin").width/10
            }
            iconSource: UM.Theme.getIcon("sending")
            //width: 150 * UM.Theme.getSize("default_margin").width/10
            height: 40 * UM.Theme.getSize("default_margin").width/10
            style: ButtonStyle {
                background: Rectangle {

                    border.width: UM.Theme.getSize("default_margin").width/10
                    border.color: UM.Theme.getColor("color19")
                    color:
                    {
                        if(control.hovered)
                        {
                            return UM.Theme.getColor("color6");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color5");
                        }
                        else
                        {
                            return UM.Theme.getColor("color21");
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }
                    anchors.right: parent.right
                    radius: 20 * UM.Theme.getSize("default_margin").width/10

                    UM.RecolorImage {
                        id: sendImage
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 20 * UM.Theme.getSize("default_margin").width/10
                        opacity: !control.enabled ? 0.2 : 1.0
                        source: control.iconSource;
                        width: UM.Theme.getSize("button_icon").width;
                        height: UM.Theme.getSize("button_icon").height;
                        color:
                        {
                            if(control.hovered)
                            {
                                return UM.Theme.getColor("color7");
                            }
                            else
                            {
                                return UM.Theme.getColor("color12");
                            }
                        }
                        sourceSize: UM.Theme.getSize("button_icon")
                    }
                }
                label: Label { }
            }
            //style: UM.Theme.styles.wifi_button
            enabled: (UM.Backend.state == 3 || UM.Backend.state == 5) && (Cura.MyWifiSend.progress == 0) && (ipComboBox.currentText.length > 0)
            onClicked: {
                Cura.MyWifiSend.startSending(PrintInformation.jobName,ipComboBox.currentText)
            }
            tooltip: catalog.i18nc("@title:tooltip","Send file to the target printer")
        }

        Text {
            id: sendName
            text: catalog.i18nc("@label","Wifi Send")
            font: UM.Theme.getFont("font2")
            color: !send.enabled ? UM.Theme.getColor("color3") : send.hovered ? UM.Theme.getColor("color7") : UM.Theme.getColor("color12")
            anchors {
                verticalCenter: send.verticalCenter
                right: parent.right
                rightMargin: 70 * UM.Theme.getSize("default_margin").width/10
            }
        }
        /*
        Rectangle {
            id: sendRectangle
            anchors.right: send.right
            anchors.rightMargin: -10 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: send.verticalCenter
            width: send.width + sendName.width + 35 * UM.Theme.getSize("default_margin").width/10
            height: send.height + 4 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color21")
            border.width: UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color19")
            radius: 20 * UM.Theme.getSize("default_margin").width/10
        }*/

        Rectangle {
            id: progressBar
            width: parent.width - 3 * UM.Theme.getSize("default_margin").width - 30 * UM.Theme.getSize("default_margin").width/10 - UM.Theme.getSize("progressbar").height*1.5
            height: UM.Theme.getSize("progressbar").height*1.5
            anchors.top: addtosidebar.bottom
            anchors.topMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("default_margin").width
            color: UM.Theme.getColor("progressbar_background")
            visible: Cura.MyWifiSend.progress > 0
            Rectangle {
                width: Math.max(parent.width * Cura.MyWifiSend.progress/100)
                height: parent.height
                color: UM.Theme.getColor("progressbar_control")
                visible: Cura.MyWifiSend.progress > 0
            }
        }

        Text {
            id: progressBarText
            text: Cura.MyWifiSend.progress + '%'
            width:30 * UM.Theme.getSize("default_margin").width/10
            height: UM.Theme.getSize("progressbar").height*1.5
            font.bold: true
            anchors {
                verticalCenter: progressBar.verticalCenter
                verticalCenterOffset: -3 * UM.Theme.getSize("default_margin").width/10
                left: progressBar.right
                leftMargin: defaultTopMargin
            }
            visible: Cura.MyWifiSend.progress > 0
        }
        Rectangle {
            id:stopPrint
            width:UM.Theme.getSize("progressbar").height*1.5
            height:UM.Theme.getSize("progressbar").height*1.5
            color:"red"
            anchors {
                verticalCenter: progressBar.verticalCenter
                left: progressBarText.right
//                leftMargin: defaultTopMargin
            }
            MouseArea {
                anchors.fill: parent
                onClicked: Cura.MyWifiSend.stopSending()
            }
            visible: Cura.MyWifiSend.progress > 0
        }
    }

    MessageDialog {
        id: messageDialog1
        modality: Qt.ApplicationModal
        title: catalog.i18nc("@title:window", "Print")
        text: catalog.i18nc(
                  "@info:question",
                  "Send file OK,Do you want to print the file now?")
        standardButtons: StandardButton.Yes | StandardButton.No
        icon: StandardIcon.Question
        onYes: {
            Cura.MyWifiSend.startPrint()
        }
        visible: Cura.MyWifiSend.sendFileDone
    }

    UM.SettingPropertyProvider
    {
        id: wifivisible
        containerStackId: Cura.MachineManager.activeStackId
        key: "wifi_visible"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

}
