// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.4 as UM
import Cura 1.0 as Cura
import "Menus"

Item
{
    id: base
    anchors.fill: parent

    UM.I18nCatalog{id: catalog; name:"cura"}
    property int wizardnumber: 0

    Item {
        id: mouseWizard

        anchors.fill: parent
        MouseArea {anchors.fill: parent}
        //visible: false
        Rectangle {
            id: mouseWizardShadow
            anchors.fill: parent
            color: UM.Theme.getColor("color25")
        }
        UM.RecolorImage
        {
            id: firstmouse
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 20 * UM.Theme.getSize("default_margin").width/10
            width: 124 * UM.Theme.getSize("default_margin").width/10
            height: 193 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: height
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("mouse")
        }
        UM.RecolorImage
        {
            id: leftButtonArrow
            anchors.verticalCenter: firstmouse.verticalCenter
            anchors.horizontalCenter: firstmouse.horizontalCenter
            anchors.verticalCenterOffset: -70 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenterOffset: -70 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
        }
        Label {
            id: leftButtonLabel
            anchors.right: leftButtonArrow.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: leftButtonArrow.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Left Button: Click to select and the model for operations");
        }
        UM.RecolorImage
        {
            id: rightButtonArrow
            anchors.verticalCenter: firstmouse.verticalCenter
            anchors.horizontalCenter: firstmouse.horizontalCenter
            anchors.verticalCenterOffset: -70 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenterOffset: 70 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_left")
        }
        Label {
            id: rightButtonLabel
            anchors.left: rightButtonArrow.left
            anchors.leftMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: rightButtonArrow.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Right Button: Click and drag to change camera viewpoint");
        }
        UM.RecolorImage
        {
            id: medialButtonArrow
            anchors.verticalCenter: firstmouse.verticalCenter
            anchors.horizontalCenter: firstmouse.horizontalCenter
            anchors.verticalCenterOffset: -110 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenterOffset: 1 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_bottom")
        }
        Label {
            id: medialButtonLabel
            anchors.horizontalCenter: medialButtonArrow.horizontalCenter
            anchors.verticalCenter: medialButtonArrow.verticalCenter
            anchors.verticalCenterOffset: -30 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenterOffset: 20 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Wheel: Roll to zoom in and out \nClick and drag to pan the camera");
        }
        Button {
            id: mouseWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 180 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                mouseWizard.visible = false
                firstWizard.visible = true
            }
            text: catalog.i18nc("@action:label","Next");
            style: UM.Theme.styles.wizardbutton
        }
    }
    Item {
        id: firstWizard

        anchors.fill: parent
        MouseArea {anchors.fill: parent}
        visible: false
        Rectangle {
            id: firstWizardShadow
            anchors.fill: parent
            anchors.leftMargin: toolbar.width + 1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color25")
        }
        Rectangle {
            id: firstWizardrec
            height: parent.height
            anchors.left: parent.left
            width: toolbar.width
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        UM.RecolorImage
        {
            id: firstWizardArrow
            anchors.top: parent.top
            anchors.topMargin: 230 * UM.Theme.getSize("default_margin").width/10
            anchors.left: firstWizardShadow.left
            anchors.leftMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_left")
        }
        Label {
            id: firstWizardLabel
            anchors.left: firstWizardArrow.left
            anchors.leftMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: firstWizardArrow.verticalCenter
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Toolbar Operations: Move, Scale, Rotate,..., and Wifi");
        }
        Button {
            id: firstWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 180 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                firstWizard.visible = false
                secondWizard.visible = true
            }
            text: catalog.i18nc("@action:label","Next");
            style: UM.Theme.styles.wizardbutton
        }
    }

    Item {
        id: secondWizard

        anchors.fill: parent
        MouseArea {anchors.fill: parent}
        visible: false
        Rectangle {
            id: secondWizardShadow
            anchors.fill: parent
            anchors.rightMargin: sidebar.width + 1
            color: UM.Theme.getColor("color25")
        }
        Rectangle {
            id: secondWizardrec1
            height: 50 * UM.Theme.getSize("default_margin").width/10
            anchors.right: parent.right
            width: sidebar.width
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        Rectangle {
            id: secondWizardrec2
            anchors.top: secondWizardrec1.bottom
            anchors.topMargin: 1 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Cura.MachineManager.activeMachineDefinitionName == "QIDI I" ? 137 * UM.Theme.getSize("default_margin").width/10 : Cura.MachineManager.activeMachineDefinitionName == "X-one2" ? 137 * UM.Theme.getSize("default_margin").width/10 : wifivisible.properties.value == "False" ? 137 * UM.Theme.getSize("default_margin").width/10 : 162 * UM.Theme.getSize("default_margin").width/10
            anchors.right: parent.right
            width: sidebar.width
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        Rectangle {
            id: secondWizardrec3
            anchors.top: secondWizardrec2.bottom
            anchors.topMargin: 5 * UM.Theme.getSize("default_margin").width/10
            height: 44 * UM.Theme.getSize("default_margin").width/10
            anchors.right: parent.right
            width: sidebar.width
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        Rectangle {
            id: secondWizardrec4
            height: 40 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 7 * UM.Theme.getSize("default_margin").width/10
            anchors.right: parent.right
            width: sidebar.width
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        UM.RecolorImage
        {
            id: secondWizardArrow1
            anchors.top: parent.top
            anchors.topMargin: 17 * UM.Theme.getSize("default_margin").width/10
            anchors.right: secondWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
        }
        Label {
            id: secondWizardLabel1
            anchors.right: secondWizardArrow1.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: secondWizardArrow1.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Select the machine");
        }
        UM.RecolorImage
        {
            id: secondWizardArrow2
            anchors.top: parent.top
            anchors.topMargin: 250 * UM.Theme.getSize("default_margin").width/10
            anchors.right: secondWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
        }
        Label {
            id: secondWizardLabel2
            anchors.right: secondWizardArrow2.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: secondWizardArrow2.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Configure parameters");
        }
        UM.RecolorImage
        {
            id: secondWizardArrow3
            anchors.verticalCenter: secondWizardrec3.verticalCenter
            anchors.right: secondWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
        }
        Label {
            id: secondWizardLabel3
            anchors.right: secondWizardArrow3.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: secondWizardArrow3.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","More parameters");
        }
        UM.RecolorImage
        {
            id: secondWizardArrow4
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30 * UM.Theme.getSize("default_margin").width/10
            anchors.right: secondWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
        }
        Label {
            id: secondWizardLabel4
            anchors.right: secondWizardArrow4.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: secondWizardArrow4.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            width: 480 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","After importing the model and adjusting the parameters, click on this button to slice");
            wrapMode: Text.Wrap
        }
        UM.RecolorImage
        {
            id: secondWizardArrow5
            anchors.verticalCenter: secondWizardrec3.verticalCenter
            anchors.verticalCenterOffset: 50 * UM.Theme.getSize("default_margin").width/10
            anchors.right: secondWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            visible: Cura.MachineManager.activeMachineDefinitionName == "QIDI I" ? false : Cura.MachineManager.activeMachineDefinitionName == "X-one2" ? false : wifivisible.properties.value == "False" ? false : true
            source: UM.Theme.getIcon("arrow_right")
        }
        Label {
            id: secondWizardLabel5
            anchors.right: secondWizardArrow5.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: secondWizardArrow5.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            visible: Cura.MachineManager.activeMachineDefinitionName == "QIDI I" ? false : Cura.MachineManager.activeMachineDefinitionName == "X-one2" ? false : wifivisible.properties.value == "False" ? false : true
            text: catalog.i18nc("@action:label","File name and Wifi")
        }
        Button {
            id: secondWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 180 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                secondWizard.visible = false
                thirdWizard.visible = true
            }
            text: catalog.i18nc("@action:label","Next");
            style: UM.Theme.styles.wizardbutton
        }
    }

    Item {
        id: thirdWizard

        anchors.fill: parent
        MouseArea {anchors.fill: parent}
        visible: false
        Rectangle {
            id: thirdWizardShadow
            anchors.fill: parent
            anchors.bottomMargin: bottombar.height + 1
            color: UM.Theme.getColor("color25")
        }
        Rectangle {
            id: thirdWizardShadow2
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.top: thirdWizardShadow.bottom
            width: sidebar.width
            color: UM.Theme.getColor("color25")
        }
        Rectangle {
            id: thirdWizardShadow3
            anchors.top: thirdWizardShadow.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: toolbar.width
            color: UM.Theme.getColor("color25")
        }
        Rectangle {
            id: thirdWizardrec1
            height: bottombar.height
            anchors.left: parent.left
            anchors.leftMargin: toolbar.width + 1
            anchors.right: thirdWizardrec3.left
            anchors.rightMargin: 3 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: parent.bottom
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        Rectangle {
            id: thirdWizardrec2
            height: bottombar.height
            anchors.right: parent.right
            anchors.rightMargin: sidebar.width + 1 * UM.Theme.getSize("default_margin").width/10
            width: 134 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: parent.bottom
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        Rectangle {
            id: thirdWizardrec3
            height:bottombar.height
            anchors.right: thirdWizardrec2.left
            anchors.rightMargin: 3 * UM.Theme.getSize("default_margin").width/10
            width: 200 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: parent.bottom
            color: UM.Theme.getColor("color21")
            border.width: 2 * UM.Theme.getSize("default_margin").width/10
            border.color: UM.Theme.getColor("color17")
        }
        UM.RecolorImage
        {
            id: thirdWizardArrow1
            anchors.left: parent.left
            anchors.leftMargin: 230 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: thirdWizardShadow.bottom
            anchors.bottomMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_bottom")
        }
        Label {
            id: thirdWizardLabel1
            anchors.bottom: thirdWizardArrow1.top
            anchors.bottomMargin: 5 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenter: thirdWizardArrow1.horizontalCenter
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Model size and print information");
        }
        UM.RecolorImage
        {
            id: thirdWizardArrow2
            anchors.right: parent.right
            anchors.rightMargin: 498 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: thirdWizardShadow.bottom
            anchors.bottomMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_bottom")
        }
        Label {
            id: thirdWizardLabel2
            anchors.bottom: thirdWizardArrow2.top
            anchors.bottomMargin: 5 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenter: thirdWizardArrow2.horizontalCenter
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Camera position");
        }
        UM.RecolorImage
        {
            id: thirdWizardArrow3
            anchors.right: parent.right
            anchors.rightMargin: 339 * UM.Theme.getSize("default_margin").width/10
            anchors.bottom: thirdWizardShadow.bottom
            anchors.bottomMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_bottom")
        }
        Label {
            id: thirdWizardLabel3
            anchors.bottom: thirdWizardArrow3.top
            anchors.bottomMargin: 5 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenter: thirdWizardArrow3.horizontalCenter
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","View");
        }
        Button {
            id: thirdWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 180 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                thirdWizard.visible = false
                fourthWizard.visible = true
            }
            text: catalog.i18nc("@action:label","Next");
            style: UM.Theme.styles.wizardbutton
        }
    }

    Item {
        id: fourthWizard

        anchors.fill: parent
        MouseArea {anchors.fill: parent}
        visible: false
        Rectangle {
            id: fourthWizardShadow
            anchors.fill: parent
            color: UM.Theme.getColor("color25")
        }
        UM.RecolorImage
        {
            id: fourthWizardArrow
            anchors.left: parent.left
            anchors.leftMargin: sidebar.width
            anchors.top: parent.top
            anchors.topMargin: UM.Theme.getSize("default_margin").width
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_top")
        }
        Label {
            id: fourthWizardLabel
            anchors.top: fourthWizardArrow.bottom
            anchors.topMargin: 5 * UM.Theme.getSize("default_margin").width/10
            anchors.horizontalCenter: fourthWizardArrow.horizontalCenter
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Menubar: Includes Control Panel, Configure Qidi, First Run Wizard, Factory setting...");
            width: 350 * UM.Theme.getSize("default_margin").width/10
        }
        Button {
            id: fourthWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 180 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                fourthWizard.visible = false
                fifthWizard.visible = true
                wizardnumber += 1
            }
            text: catalog.i18nc("@action:label","Next");
            style: UM.Theme.styles.wizardbutton
        }
    }
    Item {
        id: fifthWizard

        anchors.fill: parent
        MouseArea {anchors.fill: parent}
        visible: false
        Rectangle {
            id: fifthWizardShadow
            anchors.fill: parent
            anchors.rightMargin: sidebar.width + 1
            color: UM.Theme.getColor("color25")
        }
        UM.RecolorImage
        {
            id: fifthWizardArrow1
            anchors.right: fifthWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            anchors.top: parent.top
            anchors.topMargin: 18 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
            visible: wizardnumber > 0 ? true : false
        }
        Label {
            id: fifthWizardLabel1
            anchors.right: fifthWizardArrow1.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: fifthWizardArrow1.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Select your print type.①");
            visible: wizardnumber > 0 ? true : false
        }
        UM.RecolorImage
        {
            id: fifthWizardArrow2
            anchors.right: fifthWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            anchors.top: fifthWizardArrow1.bottom
            anchors.topMargin:
            {
                if (machineExtruderCount.properties.value == "2")
                {
                    return 71 * UM.Theme.getSize("default_margin").width/10
                }
                else
                {
                    return 30 * UM.Theme.getSize("default_margin").width/10
                }
            }
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
            visible: wizardnumber > 1 ? true : false
        }
        Label {
            id: fifthWizardLabel2
            anchors.right: fifthWizardArrow2.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: fifthWizardArrow2.verticalCenter
            anchors.verticalCenterOffset: -1
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Select your material type.②");
            visible: wizardnumber > 1 ? true : false
        }
        UM.RecolorImage
        {
            id: fifthWizardArrow3
            anchors.right: fifthWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            anchors.top: fifthWizardArrow2.bottom
            anchors.topMargin: 16 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
            visible: wizardnumber > 2 ? true : false
        }
        Label {
            id: fifthWizardLabel3
            anchors.right: fifthWizardArrow3.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: fifthWizardArrow3.verticalCenter
            anchors.verticalCenterOffset: -1 * UM.Theme.getSize("default_margin").width/10
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Select your printing precision (layer height).③");
            visible: wizardnumber > 2 ? true : false
        }
        UM.RecolorImage
        {
            id: fifthWizardArrow4
            anchors.right: fifthWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            anchors.top: fifthWizardArrow3.bottom
            anchors.topMargin: 53 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
            visible: wizardnumber > 3 ? true : false
        }
        Label {
            id: fifthWizardLabel4
            anchors.right: fifthWizardArrow4.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: fifthWizardArrow4.verticalCenter
            anchors.verticalCenterOffset: -1
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Select an infill density.④");
            visible: wizardnumber > 3 ? true : false
        }
        UM.RecolorImage
        {
            id: fifthWizardArrow5
            anchors.right: fifthWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            anchors.top: fifthWizardArrow4.bottom
            anchors.topMargin: 17 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
            visible: wizardnumber > 4 ? true : false
        }
        Label {
            id: fifthWizardLabel5
            anchors.right: fifthWizardArrow5.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: fifthWizardArrow5.verticalCenter
            anchors.verticalCenterOffset: -1
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Click the checkbox to enable print support.⑤");
            visible: wizardnumber > 4 ? true : false
        }
        UM.RecolorImage
        {
            id: fifthWizardArrow6
            anchors.right: fifthWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 33 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
            visible: wizardnumber > 5 ? true : false
        }
        Label {
            id: fifthWizardLabel6
            anchors.right: fifthWizardArrow5.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: fifthWizardArrow6.verticalCenter
            anchors.verticalCenterOffset: -1
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text: catalog.i18nc("@action:label","Click Prepare to slice your model.⑥");
            visible: wizardnumber > 5 ? true : false
        }
        UM.RecolorImage
        {
            id: fifthWizardArrow7
            anchors.right: fifthWizardShadow.right
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            anchors.top: fifthWizardArrow6.bottom
            anchors.topMargin: 8 * UM.Theme.getSize("default_margin").width/10
            width: 15 * UM.Theme.getSize("default_margin").width/10
            height: 15 * UM.Theme.getSize("default_margin").width/10
            sourceSize.width: width
            sourceSize.height: width
            color: UM.Theme.getColor("color7")
            source: UM.Theme.getIcon("arrow_right")
            visible: wizardnumber > 6 ? true : false
        }
        Label {
            id: fifthWizardLabel7
            anchors.right: fifthWizardArrow5.right
            anchors.rightMargin: 15 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: fifthWizardArrow7.verticalCenter
            anchors.verticalCenterOffset: -1
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font10")
            text:// catalog.i18nc("@action:label","Save the file to SD card or USB drive.⑦");
            {
                if (Cura.MachineManager.activeMachineName == "X-one2" || Cura.MachineManager.activeMachineName == "QIDI I")
                {
                    return catalog.i18nc("@action:label","Save the file to SD card or USB drive.⑦")
                }
                else
                {
                    return catalog.i18nc("@action:label","Save the file or use Wifi to send the file.⑦")
                }
            }
            visible: wizardnumber > 6 ? true : false
        }
        Label {
            id: fifthWizardLabel
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: UM.Theme.getColor("color7")
            font: UM.Theme.getFont("font11")
            text: catalog.i18nc("@action:label","Follow the steps to make your first print!");
        }
        Button {
            id: fifthWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 180 * UM.Theme.getSize("default_margin").width/10
            onClicked: {
                if (wizardnumber != 7)
                {
                    wizardnumber += 1
                }
                else
                {
                    fifthWizard.visible = false
                    mouseWizard.visible = true
                    base.visible = false
                    wizardnumber = 0
                }
            }
            text: wizardnumber == 7 ? catalog.i18nc("@action:label","Start") : catalog.i18nc("@action:label","Next")
            style: UM.Theme.styles.wizardbutton
        }
    }
}
