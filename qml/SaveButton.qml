// Copyright (c) 2018 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura

Item {
    id: base;
    UM.I18nCatalog { id: catalog; name:"cura"}

    UM.SettingPropertyProvider
    {
        id: wifivisible
        containerStackId: Cura.MachineManager.activeMachineId
        key: "wifi_visible"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    property real progress: UM.Backend.progress
    property int backendState: UM.Backend.state
    property bool activity: CuraApplication.platformActivity

    property alias buttonRowWidth: saveRow.width

    property string fileBaseName
    property string statusText:
    {
        if(!activity)
        {
            return catalog.i18nc("@label:PrintjobStatus", "Please load a 3D model");
        }

        if (base.backendState == "undefined") {
            return ""
        }

        switch(base.backendState)
        {
            case 1:
                return catalog.i18nc("@label:PrintjobStatus", "Ready to slice");
            case 2:
                return catalog.i18nc("@label:PrintjobStatus", "Slicing...");
            case 3:
                return catalog.i18nc("@label:PrintjobStatus %1 is target operation","Ready to %1").arg(UM.OutputDeviceManager.activeDeviceShortDescription);
            case 4:
                return catalog.i18nc("@label:PrintjobStatus", "Unable to Slice");
            case 5:
                return catalog.i18nc("@label:PrintjobStatus", "Slicing unavailable");
            default:
                return "";
        }
    }

    function sliceOrStopSlicing() {
        try {
            if ([1, 5].indexOf(base.backendState) != -1) {
                //CuraApplication.backend.setPrimeTowerPositionAuto()
                CuraApplication.backend.getOozePrevention()
                sliceTimer.start()
                //CuraApplication.backend.forceSlice()
            } else {
                CuraApplication.backend.stopSlicing()
            }
        } catch (e) {
            console.log('Could not start or stop slicing', e)
        }
    }

    Timer
    {
        id: sliceTimer
        repeat: false
        interval: 200
        onTriggered: CuraApplication.backend.forceSlice()
    }

    Rectangle
    {
        width: parent.width
        height: 1 * UM.Theme.getSize("default_margin").width/10
        anchors.bottom: detailedsettingButton.top
        anchors.bottomMargin: 11 * UM.Theme.getSize("default_margin").width/10
        color: UM.Theme.getColor("color2")
    }

    Button
    {
        id: detailedsettingButton;

        text: catalog.i18nc("@action:button","Expert mode");
        anchors
        {
            bottom: progressBar.top
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 11 * UM.Theme.getSize("default_margin").width/10
        }
        onClicked: parameter.visible = true
        height: 26 * UM.Theme.getSize("default_margin").width/10
        style: UM.Theme.styles.parameterbutton//UM.Theme.styles.savebutton
    }

    Rectangle {
        id: progressBar
        width: parent.width //- 2 * UM.Theme.getSize("sidebar_margin").width
        height: UM.Theme.getSize("progressbar").height
        anchors.bottom: jobNameRow.top
        anchors.bottomMargin: 10 * UM.Theme.getSize("default_margin").width/10//Math.round(UM.Theme.getSize("sidebar_margin").height / 4)
        anchors.left: parent.left
        color: UM.Theme.getColor("color9")

        Rectangle {
            width: Math.max(parent.width * base.progress)
            height: parent.height
            color: UM.Theme.getColor("color16")
            visible: (base.backendState != "undefined" && base.backendState == 2) ? true : false
        }
        Rectangle {
            width: Math.max(parent.width * Cura.MyWifiSend.progress/100)
            height: parent.height
            color: UM.Theme.getColor("progressbar_control")
            visible: Cura.MyWifiSend.progress > 0
        }
    }

    Rectangle
    {
        id: jobNameRow
        anchors.bottom: saveRow.top
        anchors.bottomMargin: 7 * UM.Theme.getSize("default_margin").width/10
        anchors.left: parent.left
        height: Cura.MachineManager.activeMachineId == "QIDI I" ? 25 * UM.Theme.getSize("default_margin").width/10 : Cura.MachineManager.activeMachineId == "X-one2" ? 25 * UM.Theme.getSize("default_margin").width/10 : wifivisible.properties.value == "False" ? 25 * UM.Theme.getSize("default_margin").width/10 : 50 * UM.Theme.getSize("default_margin").width/10

        Item
        {
            id: filename
            width: parent.width
            height: 25 * UM.Theme.getSize("default_margin").width/10
            anchors.top: parent.top
            visible: base.activity

            TextField
            {
                id: printJobTextfield
                anchors.left: parent.left
                anchors.leftMargin: Math.round(UM.Theme.getSize("default_margin").width / 2)
                height: 25 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("jobspecs_line").height
                width:  Math.min(Math.max(__contentWidth + UM.Theme.getSize("default_margin").width + 5 * UM.Theme.getSize("default_margin").width/10, 50 * UM.Theme.getSize("default_margin").width/10), 240 * UM.Theme.getSize("default_margin").width/10)
                property int unremovableSpacing: 5 * UM.Theme.getSize("default_margin").width/10
                text: PrintInformation.jobName

                //horizontalAlignment: TextInput.AlignRight
                onTextChanged: {
                    PrintInformation.setJobName(text);
                }
                onEditingFinished: {
                    if (printJobTextfield.text != ''){
                        printJobTextfield.focus = false;
                    }
                }
                validator: RegExpValidator {
                    regExp: /^[^\\ \/ \*\?\|\[\]]*$/
                }
                style: TextFieldStyle{
                    textColor: UM.Theme.getColor("color4");
                    font: UM.Theme.getFont("font4");
                    background: Rectangle {
                        opacity: 0
                        border.width: 0
                    }
                }
            }

            Button
            {
                id: printJobPencilIcon
                anchors.left: printJobTextfield.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -3 * UM.Theme.getSize("default_margin").width/10
                width: UM.Theme.getSize("save_button_specs_icons").width
                height: UM.Theme.getSize("save_button_specs_icons").height

                onClicked:
                {
                    printJobTextfield.selectAll();
                    printJobTextfield.focus = true;
                }
                style: ButtonStyle
                {
                    background: Item
                    {
                        UM.RecolorImage
                        {
                            width: UM.Theme.getSize("save_button_specs_icons").width + 3 * UM.Theme.getSize("default_margin").width/10;
                            height: UM.Theme.getSize("save_button_specs_icons").height + 3 * UM.Theme.getSize("default_margin").width/10;
                            sourceSize.width: width;
                            sourceSize.height: width;
                            color: control.hovered ? UM.Theme.getColor("text_scene_hover") : UM.Theme.getColor("text_scene");
                            source: UM.Theme.getIcon("pencil");
                        }
                    }
                }
            }
        }

        Item
        {
            id: wifiname
            visible: Cura.MachineManager.activeMachineId == "QIDI I" ? false : Cura.MachineManager.activeMachineId == "X-one2" ? false : wifivisible.properties.value == "False" ? false : true
            width: parent.width
            height:25 * UM.Theme.getSize("default_margin").width/10
            anchors.top: filename.bottom

            Text {
                id: ipText
                text: catalog.i18nc("@action:label", "Device Name")
                font: UM.Theme.getFont("font1")
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 12 * UM.Theme.getSize("default_margin").width/10
                }
            }
            UM.SimpleButton {
                id: refresh
                width:25 * UM.Theme.getSize("default_margin").width/10
                height:25 * UM.Theme.getSize("default_margin").width/10
                visible: Cura.MyWifiSend.progress == 0
                color: UM.Theme.getColor("color12")
                hoverColor: UM.Theme.getColor("color11")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: ipText.right
                anchors.leftMargin: Math.round(UM.Theme.getSize("default_margin").width / 2)
                iconSource: UM.Theme.getIcon("refresh")
                onClicked: {
                    Cura.MyWifiSend.scanDeviceThread()
                    ipComboBox.currentIndex = -1            //清空列表
                }
            }
            ComboBox {
                id: ipComboBox
                width: 235 * UM.Theme.getSize("default_margin").width/10 - ipText.width - refresh.width
                model: Cura.MyWifiSend.IPList
                style: UM.Theme.styles.combobox
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: refresh.right
                    leftMargin: Math.round(UM.Theme.getSize("default_margin").width / 2)
                }
                onAccepted: {
                    if (currentText.length > 0 && find(currentText) === -1) {
                        currentIndex = -1
                    }
                }
            }
        }
    }

    // Shortcut for "save as/print/..."
    Action {
        shortcut: "Ctrl+P"
        onTriggered:
        {
            // only work when the button is enabled
            if (saveToButton.enabled) {
                saveToButton.clicked();
            }
            // prepare button
            if (prepareButton.enabled) {
                sliceOrStopSlicing();
            }
        }
    }

    Item {
        id: saveRow
        width: base.width
        height: 26 * UM.Theme.getSize("default_margin").width/10//saveToButton.height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: UM.Theme.getSize("sidebar_margin").height
        anchors.horizontalCenter: parent.horizontalCenter
//        clip: true

        Row {
            id: additionalComponentsRow
            anchors.top: parent.top
            anchors.topMargin: Cura.MachineManager.activeMachineId == "QIDI I" ? -83 * UM.Theme.getSize("default_margin").width/10 : Cura.MachineManager.activeMachineId == "X-one2" ? -83 * UM.Theme.getSize("default_margin").width/10 : wifivisible.properties.value == "False" ? -83 * UM.Theme.getSize("default_margin").width/10 : -108 * UM.Theme.getSize("default_margin").width/10
            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("default_margin").width
            spacing: UM.Theme.getSize("default_margin").width
        }

        Component.onCompleted: {
            saveRow.addAdditionalComponents("saveButton")
        }

        Connections {
            target: CuraApplication
            onAdditionalComponentsChanged: saveRow.addAdditionalComponents("saveButton")
        }

        function addAdditionalComponents (areaId) {
            if(areaId == "saveButton") {
                for (var component in CuraApplication.additionalComponents["saveButton"]) {
                    CuraApplication.additionalComponents["saveButton"][component].parent = additionalComponentsRow
                }
            }
        }

        Connections {
            target: UM.Preferences
            onPreferenceChanged:
            {
                var autoSlice = UM.Preferences.getValue("general/auto_slice");
                prepareButton.autoSlice = autoSlice;
                saveToButton.autoSlice = autoSlice;
            }
        }

        // Prepare button, only shows if auto_slice is off
        Button {
            id: prepareButton

            tooltip: [1, 5].indexOf(base.backendState) != -1 ? catalog.i18nc("@info:tooltip","Slice current printjob") : catalog.i18nc("@info:tooltip","Cancel slicing process")
            // 1 = not started, 2 = Processing
            enabled: base.backendState != "undefined" && ([1, 2].indexOf(base.backendState) != -1) && base.activity
            visible: base.backendState != "undefined" && !autoSlice && ([1, 2, 4].indexOf(base.backendState) != -1) //&& base.activity
            property bool autoSlice
            height: 26 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("save_button_save_to_button").height

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            // 1 = not started, 4 = error, 5 = disabled
            text: [1, 4, 5].indexOf(base.backendState) != -1 ? catalog.i18nc("@label:Printjob", "Prepare") : catalog.i18nc("@label:Printjob", "Cancel")
            onClicked:
            {
                forceActiveFocus()
                sliceOrStopSlicing()
            }
            style: UM.Theme.styles.savebutton
        }

        Button{
            id: sendToWifi
            text: catalog.i18nc("@title:tooltip","Send to Wifi")
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 60 * UM.Theme.getSize("default_margin").width/10
            style: UM.Theme.styles.savebutton
            visible: Cura.MachineManager.activeMachineId == "QIDI I" ? false : Cura.MachineManager.activeMachineId == "X-one2" ? false : prepareButton.visible ? false : deviceSelectionMenu.visible ? false : wifivisible.properties.value == "False" ? false : true
            onClicked: {
                Cura.MyWifiSend.startSending(PrintInformation.jobName,ipComboBox.currentText)
            }
            tooltip: catalog.i18nc("@title:tooltip","Send file to the target printer")
            height: 26 * UM.Theme.getSize("default_margin").width/10
        }

        Button {
            id: saveToButton

            tooltip: UM.OutputDeviceManager.activeDeviceDescription;
            // 3 = done, 5 = disabled
            enabled: base.backendState != "undefined" && (base.backendState == 3 || base.backendState == 5) && base.activity == true
            visible: base.backendState != "undefined" && autoSlice || ((base.backendState == 3 || base.backendState == 5) && base.activity == true)
            property bool autoSlice
            height: 26 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("save_button_save_to_button").height
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: deviceSelectionMenu.visible ? - 9 * UM.Theme.getSize("default_margin").width/10 : sendToWifi.visible ? -60 : 0
            z: 1
            text: UM.OutputDeviceManager.activeDeviceShortDescription
            onClicked:
            {
                UM.OutputDeviceManager.requestWriteToDevice(UM.OutputDeviceManager.activeDevice, PrintInformation.jobName, { "filter_by_machine": true, "preferred_mimetype":Printer.preferredOutputMimetype })
            }
            style: UM.Theme.styles.savebutton
        }

        Button {
            id: deviceSelectionMenu
            tooltip: catalog.i18nc("@info:tooltip","Select the active output device");
            anchors.top: parent.top
            anchors.left: saveToButton.right

            anchors.leftMargin: -21 * UM.Theme.getSize("default_margin").width/10
            width: 40 * UM.Theme.getSize("default_margin").width/10
            height: 26 * UM.Theme.getSize("default_margin").width/10
            // 3 = Done, 5 = Disabled
            enabled: base.backendState != "undefined" && (base.backendState == 3 || base.backendState == 5) && base.activity == true
            visible: base.backendState != "undefined" && (devicesModel.deviceCount > 1) && (base.backendState == 3 || base.backendState == 5) && base.activity == true

            style: ButtonStyle {
                background: Rectangle {
                    id: deviceSelectionIcon
                    border.width: 1 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("default_lining").width
                    border.color: UM.Theme.getColor("color19")
                    gradient: Gradient
                    {
                        GradientStop { position: 0.0; color: UM.Theme.getColor("color11")}
                        GradientStop { position: 1.0; color: UM.Theme.getColor("color12")}
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }
                    anchors.left: parent.left
                    radius: 13 * UM.Theme.getSize("default_margin").width/10
                    width: parent.width
                    height: parent.height

                    UM.RecolorImage {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 8 * UM.Theme.getSize("default_margin").width/10
                        width: UM.Theme.getSize("standard_arrow").width
                        height: UM.Theme.getSize("standard_arrow").height
                        sourceSize.width: width
                        sourceSize.height: height
                        color:
                        {
                            if(!control.enabled)
                                return UM.Theme.getColor("color9");
                            else
                                return UM.Theme.getColor("color7");
                        }
                        source: UM.Theme.getIcon("arrow_bottom");
                    }
                }
                label: Label{ }
            }

            menu: Menu {
                id: devicesMenu ;
                Instantiator {
                    model: devicesModel;
                    MenuItem {
                        text: model.description
                        checkable: true;
                        checked: model.id == UM.OutputDeviceManager.activeDevice;
                        exclusiveGroup: devicesMenuGroup;
                        onTriggered: {
                            UM.OutputDeviceManager.setActiveDevice(model.id);
                        }
                    }
                    onObjectAdded: devicesMenu.insertItem(index, object)
                    onObjectRemoved: devicesMenu.removeItem(object)
                }
                ExclusiveGroup { id: devicesMenuGroup; }
            }
        }
        UM.OutputDevicesModel { id: devicesModel; }
    }
}
