// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Dialogs 1.2

import UM 1.2 as UM
import Cura 1.0 as Cura

import "Menus"

Column
{
    id: base;

    property int currentExtruderIndex: Cura.ExtruderManager.activeExtruderIndex;
    property bool currentExtruderVisible: extrudersList.visible;
    property bool printerConnected: Cura.MachineManager.printerConnected
    property bool hasManyPrinterTypes: printerConnected ? Cura.MachineManager.printerOutputDevices[0].connectedPrintersTypeCount.length > 1 : false
    property bool buildplateCompatibilityError: !Cura.MachineManager.variantBuildplateCompatible && !Cura.MachineManager.variantBuildplateUsable
    property bool buildplateCompatibilityWarning: Cura.MachineManager.variantBuildplateUsable

    spacing: 10 * UM.Theme.getSize("default_margin").width/10//Math.round(UM.Theme.getSize("sidebar_margin").width * 0.9)

    signal showTooltip(Item item, point location, string text)
    signal hideTooltip()

    property Action configureSettings;
    property variant minimumPrintTime: PrintInformation.minimumPrintTime;
    property variant maximumPrintTime: PrintInformation.maximumPrintTime;
    property bool settingsEnabled: Cura.ExtruderManager.activeExtruderStackId || extrudersEnabledCount.properties.value == 1

    Component.onCompleted: PrintInformation.enabled = true
    Component.onDestruction: PrintInformation.enabled = false

    Item
    {
        id: initialSeparator
        anchors
        {
            left: parent.left
            right: parent.right
        }
        height: UM.Theme.getSize("default_lining").height
        width: height
    }

    Item
    {
        id: extruderSelectionRow
        width: parent.width
        height: 30 * UM.Theme.getSize("default_margin").width/10
        visible: machineExtruderCount.properties.value > 1 && !sidebar.monitoringPrint

        anchors
        {
            left: parent.left
            leftMargin: Math.round(UM.Theme.getSize("sidebar_margin").width * 0.7)
            right: parent.right
            rightMargin: Math.round(UM.Theme.getSize("sidebar_margin").width * 0.7)
        }

        ListView
        {
            id: extrudersList
            property var index: 0

            height: UM.Theme.getSize("sidebar_header_mode_tabs").height
            width: Math.round(parent.width)
            boundsBehavior: Flickable.StopAtBounds

            anchors
            {
                left: parent.left
                leftMargin: Math.round(UM.Theme.getSize("default_margin").width / 2)
                right: parent.right
                rightMargin: Math.round(UM.Theme.getSize("default_margin").width / 2)
                top: parent.top
                //verticalCenter: parent.verticalCenter
            }

            ExclusiveGroup { id: extruderMenuGroup; }

            orientation: ListView.Horizontal
            layoutDirection: "RightToLeft"

            property var _model: Cura.ExtrudersModel { id: extrudersModel }
            model: _model.items.length > 1 ? _model : 0

            Connections
            {
                target: Cura.MachineManager
                onGlobalContainerChanged: forceActiveFocus() // Changing focus applies the currently-being-typed values so it can change the displayed setting values.
            }

            delegate: Button
            {
                height: 30 * UM.Theme.getSize("default_margin").width/10
                width: Math.round(ListView.view.width / extrudersModel.rowCount())

                text: model.name
                tooltip: model.name
                exclusiveGroup: extruderMenuGroup
                checked: base.currentExtruderIndex == index
                checkable: true

                property bool extruder_enabled: true

                MouseArea
                {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        switch (mouse.button) {
                            case Qt.LeftButton:
                                forceActiveFocus(); // Changing focus applies the currently-being-typed values so it can change the displayed setting values.
                                Cura.ExtruderManager.setActiveExtruderIndex(index);
                                break;
                            case Qt.RightButton:
                                extruder_enabled = Cura.MachineManager.getExtruder(model.index).isEnabled
                                extruderMenu.popup();
                                break;
                        }

                    }
                }

                Menu
                {
                    id: extruderMenu

                    MenuItem {
                        text: catalog.i18nc("@action:inmenu", "Enable Extruder")
                        onTriggered: Cura.MachineManager.setExtruderEnabled(model.index, true)
                        visible: !extruder_enabled  // using an intermediate variable prevents an empty popup that occured now and then
                    }

                    MenuItem {
                        text: catalog.i18nc("@action:inmenu", "Disable Extruder")
                        onTriggered: Cura.MachineManager.setExtruderEnabled(model.index, false)
                        visible: extruder_enabled
                        enabled: Cura.MachineManager.numberExtrudersEnabled > 1
                    }

                    MenuItem {
                        text: catalog.i18nc("@action:inmenu", "Custom Color")
                        onTriggered: colorDialog.open()
                        visible: extruder_enabled
                        enabled: Cura.MachineManager.numberExtrudersEnabled > 1
                    }

                    ColorDialog {
                        id: colorDialog
                        color: UM.Preferences.getValue("color/extruder" + (model.index + 1))
                        onAccepted:
                        {
                            UM.Preferences.setValue("color/extruder" + (model.index + 1), color.toString())
                            Cura.MachineManager.setExtruderEnabled(model.index, true)
                            var optionalExtruder = ['wall_extruder_nr','wall_0_extruder_nr','wall_x_extruder_nr','roofing_extruder_nr','top_bottom_extruder_nr','infill_extruder_nr','adhesion_extruder_nr',
                                                    'support_extruder_nr','support_infill_extruder_nr','support_extruder_nr_layer_0','support_interface_extruder_nr','support_roof_extruder_nr',
                                                    'support_bottom_extruder_nr']
                            for (var i in optionalExtruder)
                            {
                                if (definitionsModel.getVisible(optionalExtruder[i]))
                                {
                                    definitionsModel.setVisible(optionalExtruder[i], false)
                                    definitionsModel.setVisible(optionalExtruder[i], true)
                                }
                            }
                        }
                    }
                }

                UM.SettingDefinitionsModel
                {
                    id: definitionsModel
                    containerId: Cura.MachineManager.activeDefinitionId
                    showAll: true
                    exclude: ["machine_settings","shell","speed","travel","cooling","platform_adhesion","dual","meshfix","blackmagic","experimental","command_line_settings"]
                    showAncestors: true
                    expanded: ["*"]
                    visibilityHandler: UM.SettingPreferenceVisibilityHandler { }
                }

                style: ButtonStyle
                {
                    background: Item
                    {
                        function buttonBackgroundColor(index)
                        {
                            var extruder = Cura.MachineManager.getExtruder(index)
                            if (extruder.isEnabled) {
                                return (control.checked || control.pressed) ? UM.Theme.getColor("action_button_active") :
                                        control.hovered ? UM.Theme.getColor("action_button_hovered") :
                                        UM.Theme.getColor("action_button")
                            } else {
                                return UM.Theme.getColor("action_button_disabled")
                            }
                        }

                        function buttonBorderColor(index)
                        {
                            var extruder = Cura.MachineManager.getExtruder(index)
                            if (extruder.isEnabled) {
                                return (control.checked || control.pressed) ? UM.Theme.getColor("action_button_active_border") :
                                        control.hovered ? UM.Theme.getColor("action_button_hovered_border") :
                                        UM.Theme.getColor("action_button_border")
                            } else {
                                return UM.Theme.getColor("action_button_disabled_border")
                            }
                        }

                        function buttonColor(index) {
                            var extruder = Cura.MachineManager.getExtruder(index);
                            if (extruder.isEnabled)
                            {
                                return (
                                    control.checked || control.pressed) ? UM.Theme.getColor("action_button_active_text") :
                                    control.hovered ? UM.Theme.getColor("action_button_hovered_text") :
                                    UM.Theme.getColor("action_button_text");
                            } else {
                                return UM.Theme.getColor("action_button_disabled_text");
                            }
                        }

                        Rectangle
                        {
                            anchors.fill: parent
                            border.width: 1 * UM.Theme.getSize("default_margin").width/10
                            border.color: UM.Theme.getColor("color2")
                            radius: 15 * UM.Theme.getSize("default_margin").width/10
                            color:
                            {
                                if(control.customColor !== undefined && control.customColor !== null)
                                {
                                    return control.customColor
                                }
                                else if(control.checkable && control.checked && control.hovered)
                                {
                                    return UM.Theme.getColor("color5");
                                }
                                else if(control.pressed || (control.checkable && control.checked))
                                {
                                    return UM.Theme.getColor("color5");
                                }
                                else if(control.hovered)
                                {
                                    return UM.Theme.getColor("color6");
                                }
                                else
                                {
                                    return UM.Theme.getColor("color1");
                                }
                            }
                            Behavior on color { ColorAnimation { duration: 50; } }
                        }

                        Item
                        {
                            id: extruderButtonFace
                            anchors.centerIn: parent

                            width: {
                                var extruderTextWidth = extruderStaticText.visible ? extruderStaticText.width : 0;
                                var iconWidth = extruderIconItem.width;
                                return Math.round(extruderTextWidth + iconWidth + UM.Theme.getSize("default_margin").width / 2);
                            }

                            // Static text "Extruder"
                            Label
                            {
                                id: extruderStaticText
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right

                                color:
                                {
                                    if(checkable && checked && hovered)
                                    {
                                        return UM.Theme.getColor("color7");
                                    }
                                    else if(pressed || (checkable && checked))
                                    {
                                        return UM.Theme.getColor("color7");
                                    }
                                    else if(hovered)
                                    {
                                        return UM.Theme.getColor("color7");
                                    }
                                    else
                                    {
                                        return UM.Theme.getColor("color8");
                                    }
                                }

                                font: UM.Theme.getFont("font3")
                                text: catalog.i18nc("@label", "Extruder")
                                visible: width < (control.width - extruderIconItem.width - UM.Theme.getSize("default_margin").width)
                                elide: Text.ElideRight
                            }

                            // Everthing for the extruder icon
                            Item
                            {
                                id: extruderIconItem
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left

                                property var sizeToUse:
                                {
                                    var minimumWidth = control.width < UM.Theme.getSize("button").width ? control.width : UM.Theme.getSize("button").width;
                                    var minimumHeight = control.height < UM.Theme.getSize("button").height ? control.height : UM.Theme.getSize("button").height;
                                    var minimumSize = minimumWidth < minimumHeight ? minimumWidth : minimumHeight;
                                    minimumSize -= Math.round(UM.Theme.getSize("default_margin").width / 2);
                                    return minimumSize;
                                }

                                width: 20 * UM.Theme.getSize("default_margin").width/10
                                height: 20 * UM.Theme.getSize("default_margin").width/10

                                UM.RecolorImage {
                                    id: mainCircle
                                    anchors.fill: parent

                                    sourceSize.width: parent.width
                                    sourceSize.height: parent.width
                                    source: UM.Theme.getIcon("extruder_button")

                                    color:
                                    {
                                        if(checkable && checked && hovered)
                                        {
                                            return UM.Theme.getColor("color7");
                                        }
                                        else if(pressed || (checkable && checked))
                                        {
                                            return UM.Theme.getColor("color7");
                                        }
                                        else if(hovered)
                                        {
                                            return UM.Theme.getColor("color7");
                                        }
                                        else
                                        {
                                            return UM.Theme.getColor("color8");
                                        }
                                    }
                                }

                                Label
                                {
                                    id: extruderNumberText
                                    anchors
                                    {
                                        top: parent.top
                                        topMargin: -2 * UM.Theme.getSize("default_margin").width/10
                                        left: parent.left
                                        leftMargin: 7 * UM.Theme.getSize("default_margin").width/10
                                    }
                                    text: Cura.MachineManager.getExtruder(index).name.replace("Extruder ", "")
                                    color:
                                    {
                                        if(checkable && checked && hovered)
                                        {
                                            return UM.Theme.getColor("color7");
                                        }
                                        else if(pressed || (checkable && checked))
                                        {
                                            return UM.Theme.getColor("color7");
                                        }
                                        else if(hovered)
                                        {
                                            return UM.Theme.getColor("color7");
                                        }
                                        else
                                        {
                                            return UM.Theme.getColor("color8");
                                        }
                                    }
                                    font: UM.Theme.getFont("font5")
                                }

                                Rectangle
                                {
                                    id: extruderBorder
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.leftMargin: -3 * UM.Theme.getSize("default_margin").width/10
                                    anchors.topMargin: -3 * UM.Theme.getSize("default_margin").width/10
                                    border.width: 2 * UM.Theme.getSize("default_margin").width/10
                                    border.color: UM.Preferences.getValue("color/extruder" + (index + 1))
                                    width: 26 * UM.Theme.getSize("default_margin").width/10
                                    height: 26 * UM.Theme.getSize("default_margin").width/10
                                    color: UM.Theme.getColor("color21");
                                    radius: 3 * UM.Theme.getSize("default_margin").width/10
                                }
                            }
                        }
                    }
                    label: Item {}
                }
            }
        }
    }
    // Material Row
    Item
    {
        id: materialRow
        height: 20 * UM.Theme.getSize("default_margin").width/10
        visible: Cura.MachineManager.hasMaterials && !sidebar.monitoringPrint && !sidebar.hideSettings

        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("sidebar_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("sidebar_margin").width
        }

        Label
        {
            id: materialLabel
            text: catalog.i18nc("@label", "Material");
            width: Math.round(parent.width * 0.45 - UM.Theme.getSize("default_margin").width)
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            font: UM.Theme.getFont("font1");
            color: UM.Theme.getColor("color4");
        }

        ToolButton
        {
            id: materialSelection

            property var activeExtruder: Cura.MachineManager.activeStack
            property var hasActiveExtruder: activeExtruder != null
            property var currentRootMaterialName: hasActiveExtruder ? activeExtruder.material.name : ""

            text: currentRootMaterialName
            tooltip: currentRootMaterialName
            visible: Cura.MachineManager.hasMaterials && machineExtruderCount.properties.value != 2
            enabled: !extrudersList.visible || base.currentExtruderIndex > -1
            height: UM.Theme.getSize("setting_control").height
            width: 155 * UM.Theme.getSize("default_margin").width/10
            anchors.right: parent.right
            style: UM.Theme.styles.sidebar_header_button
            activeFocusOnPress: true;
            menu: MaterialMenu
            {
                extruderIndex: base.currentExtruderIndex
            }

            property var valueError: !isMaterialSupported()
            property var valueWarning: ! Cura.MachineManager.isActiveQualitySupported

            function isMaterialSupported ()
            {
                if (!hasActiveExtruder)
                {
                    return false;
                }
                return Cura.ContainerManager.getContainerMetaDataEntry(activeExtruder.material.id, "compatible") == "True"
            }
        }

        ListView{
            id:materialSelectionListView

            height: UM.Theme.getSize("setting_control").height
            width: 155 * UM.Theme.getSize("default_margin").width/10
            anchors.right: parent.right
            visible: Cura.MachineManager.hasMaterials && machineExtruderCount.properties.value == 2
            orientation: ListView.Horizontal
            layoutDirection: "RightToLeft"
            spacing: 5 * UM.Theme.getSize("default_margin").width/10
            model: Cura.ExtrudersModel { id: extrudersModelforMaterial }

            delegate: ToolButton
            {
                id: materialSelectionToolButton

                text: model.material
                tooltip: model.material
                enabled: !extrudersList.visible || base.currentExtruderIndex > -1
                height: UM.Theme.getSize("setting_control").height
                width: 75 * UM.Theme.getSize("default_margin").width/10
                style: UM.Theme.styles.sidebar_header_button2
                activeFocusOnPress: true;
                menu: MaterialMenu
                {
                    extruderIndex: model.index
                }
                Label
                {
                    id: materialSelectionLabel
                    anchors
                    {
                        top: materialSelectionToolButton.top
                        right: materialSelectionToolButton.right
                        rightMargin: 6 * UM.Theme.getSize("default_margin").width/10
                    }
                    text:
                    {
                        if (Cura.MachineManager.activeMachineDefinitionName == "QIDI I" || Cura.MachineManager.activeMachineDefinitionName == "X-pro")
                        {
                            if (model.index == 1)
                            {
                                return "L"
                            }
                            else
                            {
                                return "R"
                            }
                        }
                        else
                        {
                            return model.index + 1
                        }
                    }
                    color: UM.Theme.getColor("color4")
                    font: UM.Theme.getFont("font5")
                    z: 1
                }
            }
        }
    }

    Item
    {
        id: configRow
        height: 20 * UM.Theme.getSize("default_margin").width/10
        anchors
        {
            left: parent.left
            leftMargin: UM.Theme.getSize("sidebar_margin").width
            right: parent.right
            rightMargin: UM.Theme.getSize("sidebar_margin").width
        }

        Label
        {
            id: configLabel
            text: Cura.MachineManager.activeMachineDefinitionName == "i-mate_s" ? catalog.i18nc("@label", "Nozzle") : catalog.i18nc("@label", "Config")
            width: Math.round(parent.width * 0.45 - UM.Theme.getSize("default_margin").width)
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            font: UM.Theme.getFont("font1");
            color: UM.Theme.getColor("color4");
        }

        ToolButton
        {
            id: configToolButton
            text: Cura.MachineManager.activeQualityOrQualityChangesName
            tooltip: Cura.MachineManager.activeMachineDefinitionName
            height: UM.Theme.getSize("setting_control").height
            width: 155 * UM.Theme.getSize("default_margin").width/10
            anchors.right: parent.right
            //font: UM.Theme.getFont("font3")
            style: UM.Theme.styles.sidebar_header_button
            activeFocusOnPress: true;
            menu: ProfileMenu { title: catalog.i18nc("@title:menu", "&Profile"); }
        }
    }

    Item
    {
        id: printquality

        height: 30 * UM.Theme.getSize("default_margin").width/10
        anchors.topMargin: UM.Theme.getSize("sidebar_margin").height
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.getSize("sidebar_margin").width
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("sidebar_margin").width

        Label
        {
            id: printqualityTitle
            text: catalog.i18nc("@label", "Layer Height")
            font: UM.Theme.getFont("default")
            color: UM.Theme.getColor("color4")
            anchors.left:parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Label {
            id: printqualityText

            anchors.top: printqualitySlider.bottom
            anchors.topMargin: -13 * UM.Theme.getSize("default_margin").width/10
            anchors.left: printqualitySlider.left
            anchors.leftMargin: printqualitySlider.value < 0.08 ? 0 : printqualitySlider.value < 0.44 ? Math.round((printqualitySlider.value / printqualitySlider.stepSize) * (printqualitySlider.width / ((printqualitySlider.maximumValue - printqualitySlider.minimumValue) / printqualitySlider.stepSize)) - 32 * screenScaleFactor) : 112 * UM.Theme.getSize("default_margin").width/10
            anchors.right: printqualitySlider.right


            text: layerHeight.properties.value + "mm"
            font: UM.Theme.getFont("font1")
            horizontalAlignment: Text.AlignLeft

            color: UM.Theme.getColor("color4")
        }

        // We use a binding to make sure that after manually setting infillSlider.value it is still bound to the property provider
        Binding {
            target: printqualitySlider
            property: "value"
            value: layerHeight.properties.value
        }

        Slider
        {
            id: printqualitySlider

            anchors.verticalCenter: printqualityTitle.verticalCenter
            anchors.right: parent.right
            height: UM.Theme.getSize("sidebar_margin").height * 2
            width: 155 * UM.Theme.getSize("default_margin").width/10

            minimumValue: 0
            maximumValue: 0.5
            stepSize: 0.01
            tickmarksEnabled: true

            // disable slider when gradual support is enabled
            //enabled: layerHeight.properties.value >= 0.01

            // set initial value from stack
            value: layerHeight.properties.value

            onValueChanged: {
                if (layerHeight.properties.value == Math.round(printqualitySlider.value * 100) / 100) {
                    return
                }
                var printqualitySliderValue = printqualitySlider.value
                printqualitySlider.value = printqualitySliderValue
                Cura.MachineManager.setSettingForExtruders("layer_height", "value", printqualitySliderValue)
            }

            style: SliderStyle
            {
                groove: Rectangle {
                    id: groove
                    //implicitWidth: 200//200 * screenScaleFactor
                    implicitHeight: 2 * UM.Theme.getSize("default_margin").width/10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: -2 * UM.Theme.getSize("default_margin").width/10
                    color: UM.Theme.getColor("color20")
                    radius: 1 * UM.Theme.getSize("default_margin").width/10
                }

                handle: Item {
                    Canvas{
                        id: handleButton
                        width: 8 * UM.Theme.getSize("default_margin").width/10
                        height: 7 * UM.Theme.getSize("default_margin").width/10
                        contextType: "2d";
                        onPaint: {
                            context.lineWidth = 0.05;
                            context.strokeStyle = UM.Theme.getColor("color4");
                            context.fillStyle = UM.Theme.getColor("color4");
                            //context.beginPath();
                            context.moveTo(0 ,0);
                            context.lineTo(8 * UM.Theme.getSize("default_margin").width/10 ,0);
                            context.lineTo(4 * UM.Theme.getSize("default_margin").width/10 ,7 * UM.Theme.getSize("default_margin").width/10);
                            context.lineTo(0 ,0)
                            //context.closePath();
                            context.fill(UM.Theme.getColor("color4"));
                            context.stroke();
                        }
                        anchors.top: parent.top
                        anchors.topMargin: -13 * UM.Theme.getSize("default_margin").width/10
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 1 * UM.Theme.getSize("default_margin").width/10
                    }
                }

                tickmarks: Repeater {
                    id: repeater
                    model: (control.maximumValue -control.minimumValue) / control.stepSize + 1

                    // check if a tick should be shown based on it's index and wether the infill density is a multiple of 10 (slider step size)
                    function shouldShowTick (index) {
                        if (index % 5 == 0) {
                            return true
                        }
                        return false
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -2 * UM.Theme.getSize("default_margin").width/10
                        color: UM.Theme.getColor("color20")
                        width: 2 * UM.Theme.getSize("default_margin").width/10
                        height: 6 * screenScaleFactor
                        y: 0
                        x: Math.round(styleData.handleWidth / 2 + index * ((repeater.width - styleData.handleWidth) / (repeater.count-1)))
                        visible: shouldShowTick(index)
                    }
                }
            }
        }
    }

    Item
    {
        id: infillCell

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: UM.Theme.getSize("sidebar_margin").width
        anchors.rightMargin: UM.Theme.getSize("sidebar_margin").width + 2 * UM.Theme.getSize("default_margin").width/10
        height: 20 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("sidebar_margin").height*2.5
        Label
        {
            id: infillLabel
            text: catalog.i18nc("@label", "Infill")
            font: UM.Theme.getFont("font1")
            color: UM.Theme.getColor("color4")
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
        }

        Label {
            id: selectedInfillRateText

            anchors.top: infillSlider.bottom
            anchors.topMargin: -13 * UM.Theme.getSize("default_margin").width/10
            anchors.left: infillSlider.left
            anchors.leftMargin: infillSlider.value < 5 * UM.Theme.getSize("default_margin").width/10 ? 0 : infillSlider.value < 90 ? Math.round((infillSlider.value / infillSlider.stepSize) * (infillSlider.width / (infillSlider.maximumValue / infillSlider.stepSize)) - 11 * screenScaleFactor) : infillSlider.value >=100 ? 125 * UM.Theme.getSize("default_margin").width/10 : 132 * UM.Theme.getSize("default_margin").width/10
            anchors.right: infillSlider.right

            text: parseInt(infillDensity.properties.value) + "%"
            font: UM.Theme.getFont("font1")
            horizontalAlignment: Text.AlignLeft

            color: UM.Theme.getColor("color4")
        }

        // We use a binding to make sure that after manually setting infillSlider.value it is still bound to the property provider
        Binding {
            target: infillSlider
            property: "value"
            value: parseInt(infillDensity.properties.value)
        }

        Slider
        {
            id: infillSlider

            anchors.verticalCenter: infillLabel.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: -2 * UM.Theme.getSize("default_margin").width/10

            height: UM.Theme.getSize("sidebar_margin").height * 2 * UM.Theme.getSize("default_margin").width/10
            width: 155 * UM.Theme.getSize("default_margin").width/10

            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            tickmarksEnabled: true

            // disable slider when gradual support is enabled
            enabled: parseInt(infillSteps.properties.value) == 0

            // set initial value from stack
            value: parseInt(infillDensity.properties.value)

            onValueChanged: {

                // Don't round the value if it's already the same
                if (parseInt(infillDensity.properties.value) == infillSlider.value) {
                    return
                }

                // Round the slider value to the nearest multiple of 10 (simulate step size of 10)
                var roundedSliderValue = Math.round(infillSlider.value / 10) * 10

                // Update the slider value to represent the rounded value
                infillSlider.value = roundedSliderValue

                // Update value only if the Recomended mode is Active,
                // Otherwise if I change the value in the Custom mode the Recomended view will try to repeat
                // same operation
                Cura.MachineManager.setSettingForAllExtruders("infill_sparse_density", "value", roundedSliderValue)
            }

            style: SliderStyle
            {
                groove: Rectangle {
                    id: groove1
                    //implicitWidth: 200//200 * screenScaleFactor
                    implicitHeight: 2 * UM.Theme.getSize("default_margin").width/10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: -2 * UM.Theme.getSize("default_margin").width/10
                    color: UM.Theme.getColor("color20")
                    radius: 1 * UM.Theme.getSize("default_margin").width/10
                }

                handle: Item {
                    Canvas{
                        id: handleButton1
                        width: 8 * UM.Theme.getSize("default_margin").width/10;
                        height: 7 * UM.Theme.getSize("default_margin").width/10
                        contextType: "2d";
                        onPaint: {
                            context.lineWidth = 1 * UM.Theme.getSize("default_margin").width/10
                            context.strokeStyle = UM.Theme.getColor("color4");
                            context.fillStyle = UM.Theme.getColor("color4");
                            //context.beginPath();
                            context.moveTo(0 ,0);
                            context.lineTo(8 * UM.Theme.getSize("default_margin").width/10 ,0);
                            context.lineTo(4 * UM.Theme.getSize("default_margin").width/10 ,7 * UM.Theme.getSize("default_margin").width/10);
                            context.lineTo(0 ,0)
                            //context.closePath();
                            context.fill(UM.Theme.getColor("color4"));
                            context.stroke();
                        }
                        anchors.top: parent.top
                        anchors.topMargin: -13 * UM.Theme.getSize("default_margin").width/10
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.horizontalCenterOffset: 1 * UM.Theme.getSize("default_margin").width/10
                    }
                }

                tickmarks: Repeater {
                    id: repeater1
                    model: control.maximumValue / control.stepSize + 1

                    // check if a tick should be shown based on it's index and wether the infill density is a multiple of 10 (slider step size)
                    function shouldShowTick (index) {
                        if (index % 10 == 0) {
                            return true
                        }
                        return false
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: -2 * UM.Theme.getSize("default_margin").width/10
                        color: UM.Theme.getColor("color20")
                        width: 2 * UM.Theme.getSize("default_margin").width/10
                        height: 6 * screenScaleFactor
                        y: 0
                        x: Math.round(styleData.handleWidth / 2 + index * ((repeater1.width - styleData.handleWidth) / (repeater1.count-1)))
                        visible: shouldShowTick(index)
                    }
                }
            }
        }
    }

    Item
    {
        id: supportbutton

        height: 20 * UM.Theme.getSize("default_margin").width/10
        anchors.topMargin: UM.Theme.getSize("sidebar_margin").height
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.getSize("sidebar_margin").width
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("sidebar_margin").width

        Label
        {
            id: enableSupportLabel
            visible: enableSupportCheckBox.visible

            anchors.left:parent.left
            anchors.verticalCenter: parent.verticalCenter

            text: catalog.i18nc("@label", "Add Support");
            font: UM.Theme.getFont("font1");
            color: UM.Theme.getColor("color4");
            elide: Text.ElideRight
        }

        CheckBox
        {
            id: enableSupportCheckBox
            property alias _hovered: enableSupportMouseArea.containsMouse

            anchors.verticalCenter: enableSupportLabel.verticalCenter
            anchors.right: parent.right

            style: UM.Theme.styles.checkbox;
            enabled: base.settingsEnabled

            visible: supportEnabled.properties.enabled == "True"
            checked: supportEnabled.properties.value == "True";

            MouseArea
            {
                id: enableSupportMouseArea
                anchors.fill: parent
                enabled: true
                onClicked: supportEnabled.setPropertyValue("value", supportEnabled.properties.value != "True")
            }
        }

        ComboBox
        {
            id: supportExtruderCombobox
            visible: enableSupportCheckBox.visible && (supportEnabled.properties.value == "True") && (extrudersEnabledCount.properties.value > 1)
            model: extruderModel
            anchors.verticalCenter: enableSupportLabel.verticalCenter
            anchors.right: enableSupportCheckBox.left
            anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
            height: 22 * UM.Theme.getSize("default_margin").width/10
            width: 100 * UM.Theme.getSize("default_margin").width/10
            Behavior on height { NumberAnimation { duration: 100 } }
            style: UM.Theme.styles.combobox_color
            enabled: base.settingsEnabled
            currentIndex:
            {
                if (supportExtruderNr.properties == null)
                {
                    return Cura.MachineManager.defaultExtruderPosition;
                }
                else
                {
                    var extruder = parseInt(supportExtruderNr.properties.value);
                    if ( extruder === -1)
                    {
                        return Cura.MachineManager.defaultExtruderPosition;
                    }
                    return extruder;
                }
            }
            onActivated: supportExtruderNr.setPropertyValue("value", String(index))
            MouseArea
            {
                id: supportExtruderMouseArea
                anchors.fill: parent
                enabled: base.settingsEnabled
                acceptedButtons: Qt.NoButton
                onEntered:
                {
                    base.showTooltip(supportExtruderCombobox, Qt.point(-supportExtruderCombobox.x, 0),
                        catalog.i18nc("@label", "Select which extruder to use for support. This will build up supporting structures below the model to prevent the model from sagging or printing in mid air."));
                }
                onExited: base.hideTooltip()
            }
        }

        ListModel
        {
            id: extruderModel
            Component.onCompleted: populateExtruderModel()
        }

        //: Model used to populate the extrudelModel
        Cura.ExtrudersModel
        {
            id: extruders
            onModelChanged: populateExtruderModel()
        }
    }

    function populateExtruderModel()
    {
        extruderModel.clear();
        for(var extruderNumber = 0; extruderNumber < extruders.rowCount() ; extruderNumber++)
        {
            extruderModel.append({
                text: extruders.getItem(extruderNumber).name,
            })
        }
    }

    UM.SettingPropertyProvider
    {
        id: infillExtruderNumber
        containerStackId: Cura.MachineManager.activeStackId
        key: "infill_extruder_nr"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: infillDensity
        containerStackId: Cura.MachineManager.activeStackId
        key: "infill_sparse_density"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: layerHeight
        containerStackId: Cura.MachineManager.activeStackId
        key: "layer_height"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: printSpeed
        containerStackId: Cura.MachineManager.activeStackId
        key: "speed_print"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: infillSteps
        containerStackId: Cura.MachineManager.activeStackId
        key: "gradual_infill_steps"
        watchedProperties: ["value", "enabled"]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: platformAdhesionType
        containerStackId: Cura.MachineManager.activeMachineId
        key: "adhesion_type"
        watchedProperties: [ "value", "enabled" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: supportEnabled
        containerStackId: Cura.MachineManager.activeMachineId
        key: "support_enable"
        watchedProperties: [ "value", "enabled", "description" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: extrudersEnabledCount
        containerStackId: Cura.MachineManager.activeMachineId
        key: "extruders_enabled_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: supportExtruderNr
        containerStackId: Cura.MachineManager.activeMachineId
        key: "support_extruder_nr"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.SettingPropertyProvider
    {
        id: machineExtruderCount

        containerStackId: Cura.MachineManager.activeMachineId
        key: "machine_extruder_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    UM.I18nCatalog { id: catalog; name:"cura" }
}
