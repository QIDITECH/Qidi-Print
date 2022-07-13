// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import QtQuick.Dialogs 1.2

import ".."

import UM 1.1 as UM
import Cura 1.0 as Cura

Dialog
{
    id: base;

    title: catalog.i18nc("@title:window", "Parameter")
    minimumWidth: 630 * UM.Theme.getSize("default_margin").width/10
    minimumHeight: 429 * UM.Theme.getSize("default_margin").width/10

    property int currentPage: 0;
    property int currentExtruderIndex: Cura.ExtruderManager.activeExtruderIndex;

    Rectangle {
        id: parametertopbar
        width: parent.width
        height: 76 * UM.Theme.getSize("default_margin").width/10
        color: UM.Theme.getColor("color1")
        anchors.top: parent.top
/*
        ProfilesPage{
            id:profilespage
        }

        ProfileMenu{
            id: profilemenu
        }
*/
        Label
        {
            id: configurationLabel
            text: Cura.MachineManager.activeMachineDefinitionName == "i-mate_s" ? catalog.i18nc("@label", "Nozzle") : catalog.i18nc("@label", "Config")
            //width: Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/1.5
            //height: 25
            color: UM.Theme.getColor("color4");
            font: UM.Theme.getFont("font3")
            anchors.top: parent.top
            anchors.topMargin: 12 * UM.Theme.getSize("default_margin").width/10
            anchors.left: parent.left
            anchors.leftMargin: 35 * UM.Theme.getSize("default_margin").width/10
        }
/*
        TextField
        {
            id: configurationNameText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 2
            anchors.leftMargin: 150//Math.round(UM.Theme.getSize("default_margin").width / 2)/4
            height: 23//UM.Theme.getSize("setting_control").height
            width: 160//Math.round(parent.width * 0.7)
            maximumLength: 25
            property int unremovableSpacing: 5
            text: Cura.MachineManager.activeQualityOrQualityChangesName
//            horizontalAlignment: TextInput.AlignRight
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
            style: UM.Theme.styles.text_field
        }*/

        ToolButton
        {
            id: configurationToolButton
            text: Cura.MachineManager.activeQualityOrQualityChangesName
            tooltip: Cura.MachineManager.activeMachineDefinitionName
            height: 23 * UM.Theme.getSize("default_margin").width/10
            width: 184 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width * 0.7)/2
            anchors.left: configurationLabel.right
            anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
            anchors.verticalCenter: configurationLabel.verticalCenter
            //font: UM.Theme.getFont("font3")
            style: UM.Theme.styles.sidebar_header_button
            activeFocusOnPress: true;
            menu: ProfileMenu { title: catalog.i18nc("@title:menu", "&Profile"); }
        }

        ListView
        {
            id: extrudersList
            property var index: 0

            height: 23 * UM.Theme.getSize("default_margin").width/10
            width: 220 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width)
            boundsBehavior: Flickable.StopAtBounds
            visible: machineExtruderCount.properties.value > 1 && !sidebar.monitoringPrint

            anchors
            {
                left: configurationToolButton.right
                leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
                verticalCenter: configurationToolButton.verticalCenter
            }

            ExclusiveGroup { id: extruderMenuGroup; }

            orientation: ListView.Horizontal
            layoutDirection: "RightToLeft"

            model: Cura.ExtrudersModel { id: extrudersModel; }

            Connections
            {
                target: Cura.MachineManager
                onGlobalContainerChanged: forceActiveFocus() // Changing focus applies the currently-being-typed values so it can change the displayed setting values.
            }

            delegate: Button
            {
                height: 23 * UM.Theme.getSize("default_margin").width/10
                width: Math.round(ListView.view.width / extrudersModel.rowCount())

                text: model.name
                tooltip: model.name
                /*{
                    if (Cura.MachineManager.activeMachineId == "QIDI I" || Cura.MachineManager.activeMachineId == "X-pro")
                    {
                        if (model.name == "Extruder 1")
                        {
                            return "Extruder R"
                        }
                        else if (model.name == "Extruder 2")
                        {
                            return "Extruder L"
                        }
                    }
                    else
                    {
                        return model.name
                    }
                }*/
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
                            radius: 11.5 * UM.Theme.getSize("default_margin").width/10
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

                                width: 18 * UM.Theme.getSize("default_margin").width/10//sizeToUse
                                height: 18 * UM.Theme.getSize("default_margin").width/10//sizeToUse

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
                                        topMargin: -1 * UM.Theme.getSize("default_margin").width/10
                                        left: parent.left
                                        leftMargin: index == 0 ? 6 * UM.Theme.getSize("default_margin").width/10 : 7 * UM.Theme.getSize("default_margin").width/10
                                    }
                                    text:
                                    {
                                        if (Cura.MachineManager.activeMachineDefinitionName == "QIDI I" || Cura.MachineManager.activeMachineDefinitionName == "X-pro")
                                        {
                                            if (index == 0)
                                            {
                                                return "R"
                                            }
                                            else
                                            {
                                                return "L"
                                            }
                                        }
                                        else
                                        {
                                            return index + 1
                                        }
                                    }
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
                                    font: UM.Theme.getFont("font9")
                                }
                                Rectangle
                                {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.leftMargin: -2 * UM.Theme.getSize("default_margin").width/10
                                    anchors.topMargin: -2 * UM.Theme.getSize("default_margin").width/10
                                    border.width: 1 * UM.Theme.getSize("default_margin").width/10
                                    border.color: index == 0 ? UM.Preferences.getValue("color/extruder1") : UM.Preferences.getValue("color/extruder2")
                                    width: 22 * UM.Theme.getSize("default_margin").width/10
                                    height: 22 * UM.Theme.getSize("default_margin").width/10

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

        Button
        {
            id: openconfigurationButton
            anchors.top: configurationLabel.bottom
            anchors.left: configurationLabel.left
            anchors.topMargin: 12 * UM.Theme.getSize("default_margin").width/10
            //anchors.leftMargin: UM.Theme.getSize("default_margin").width / 2
            width: 85 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@label", "Open")
            style: UM.Theme.styles.parameterbutton
            onClicked: openDialog.open()
        }

        Button
        {
            id: saveconfigurationButton
            anchors.verticalCenter: openconfigurationButton.verticalCenter
            anchors.left: openconfigurationButton.right
            anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
            width: 85 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@label", "Save")
            style: UM.Theme.styles.parameterbutton
            action: Cura.Actions.updateProfile
        }

        Button
        {
            id: addconfigurationButton
            anchors.verticalCenter: saveconfigurationButton.verticalCenter
            anchors.left: saveconfigurationButton.right
            anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
            width: 85 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@label", "Add")
            style: UM.Theme.styles.parameterbutton
            onClicked: {
                //createQualityDialog.object = Cura.ContainerManager.makeUniqueName(base.currentItem.name);
                createQualityDialog.open();
                createQualityDialog.selectText();
            }
        }

        Button
        {
            id: saveasconfigurationButton
            anchors.verticalCenter: addconfigurationButton.verticalCenter
            anchors.left: addconfigurationButton.right
            anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
            width: 85 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@label", "Save As")
            style: UM.Theme.styles.parameterbutton
            onClicked:
            {
                UM.OutputDeviceManager.requestWriteToDevice("local_file", PrintInformation.jobName, { "filter_by_machine": false, "file_type": "workspace" })
            }
        }

        Button
        {
            id: defaultconfigurationButton
            anchors.verticalCenter: saveasconfigurationButton.verticalCenter
            anchors.left: saveasconfigurationButton.right
            anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
            width: 85 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@label", "Default")
            style: UM.Theme.styles.parameterbutton
            action: Cura.Actions.resetProfile
        }

        Button
        {
            id: removeconfigurationButton
            anchors.verticalCenter: defaultconfigurationButton.verticalCenter
            anchors.left: defaultconfigurationButton.right
            anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
            width: 85 * UM.Theme.getSize("default_margin").width/10//Math.round(parent.width * 0.4 - UM.Theme.getSize("default_margin").width)/2+10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            text: catalog.i18nc("@label", "Delete")
            style: UM.Theme.styles.parameterbutton
            action: Cura.Actions.manageProfiles
        }

        UM.RenameDialog
        {
            id: createQualityDialog
            title: catalog.i18nc("@title:window", "Create Profile")
            object: "Default"
            onAccepted:
            {
                parametertopbar.newQualityNameToSelect = newName;  // We want to switch to the new profile once it's created
                parametertopbar.toActivateNewQuality = true;
                parametertopbar.qualityManager.createQualityChanges(newName);
                //Cura.MachineManager.setQualityChangesGroup(parametertopbar.currentItem.quality_changes_group)
            }
        }

        // This connection makes sure that we will switch to the correct quality after the model gets updated
        Connections
        {
            target: qualitiesModel
            onItemsChanged: {
                var toSelectItemName = parametertopbar.currentItem == null ? "" : parametertopbar.currentItem.name;
                if (parametertopbar.newQualityNameToSelect != "") {
                    toSelectItemName = parametertopbar.newQualityNameToSelect;
                }

                var newIdx = -1;  // Default to nothing if nothing can be found
                if (toSelectItemName != "") {
                    // Select the required quality name if given
                    for (var idx = 0; idx < qualitiesModel.rowCount(); ++idx) {
                        var item = qualitiesModel.getItem(idx);
                        if (item.name == toSelectItemName) {
                            // Switch to the newly created profile if needed
                            newIdx = idx;
                            if (parametertopbar.toActivateNewQuality) {
                                // Activate this custom quality if required
                                Cura.MachineManager.setQualityChangesGroup(item.quality_changes_group);
                            }
                            break;
                        }
                    }
                }
                parametertopbar.current_index = newIdx;

                // Reset states
                parametertopbar.newQualityNameToSelect = "";
                parametertopbar.toActivateNewQuality = false;
            }
        }

        property QtObject qualityManager: CuraApplication.getQualityManager()
        property string newQualityNameToSelect: ""
        property bool toActivateNewQuality: false

        property var resetEnabled: false  // Keep PreferencesDialog happy
        property var extrudersModel: Cura.ExtrudersModel {}
        property int current_index: 5

        Cura.QualityManagementModel {
            id: qualitiesModel
        }

        property var currentItem: {
            //var current_index = 5//qualityListView.currentIndex;
            return (current_index == -1) ? null : qualitiesModel.getItem(current_index);
        }
    }

    Item
    {
        id: test
        anchors.top:parametertopbar.bottom
        anchors.left: parent.left;
        anchors.right: parent.right;
        anchors.bottom: parent.bottom;
        //anchors.fill: parent;

        TableView
        {
            id: pagesList;

            anchors {
                left: parent.left;
                top: parent.top;
                bottom: parent.bottom;
            }

            width: 145 * UM.Theme.getSize("default_margin").width/10//10 * UM.Theme.getSize("line").width;

            alternatingRowColors: true//false;
            headerVisible: false;
            backgroundVisible: false;
            frameVisible: false

            model: ListModel { id: configPagesModel; }
            TableViewColumn
            {
                role: "name"
            }
            itemDelegate: Item
            {
                Text
                {
                    text: catalog.i18nc("@title:tab",styleData.value)
                    color: styleData.selected ? UM.Theme.getColor("color7") : UM.Theme.getColor("color4");
                    font: UM.Theme.getFont("font3")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: icon.right
                    anchors.leftMargin: UM.Theme.getSize("default_margin").width
                }
                UM.RecolorImage
                {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15 * UM.Theme.getSize("default_margin").width/10
                    source: UM.Theme.getIcon(styleData.value)
                    color: styleData.selected ? UM.Theme.getColor("color7") : UM.Theme.getColor("color8");
                    width: UM.Theme.getSize("section_icon").width;
                    height: UM.Theme.getSize("section_icon").height;
                    sourceSize.width: width + 15 * screenScaleFactor
                    sourceSize.height: width + 15 * screenScaleFactor
                }
            }

            rowDelegate: Rectangle
            {
                height: 35 * UM.Theme.getSize("default_margin").width/10
                width: parent.width
                color: styleData.selected ? UM.Theme.getColor("color5") : styleData.row % 2 ? UM.Theme.getColor("color23") : UM.Theme.getColor("color22")
            }

            onClicked:
            {
                if(base.currentPage != row)
                {
                    stackView.replace(configPagesModel.get(row).item);
                    base.currentPage = row;
                }
            }
        }

        StackView {
            id: stackView
            anchors {
                left: pagesList.right
                //leftMargin: (UM.Theme.getSize("default_margin").width / 2) | 0
                top: parent.top
                topMargin: -4 * UM.Theme.getSize("default_margin").width/10
                bottom: parent.bottom
                right: parent.right
                rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
            }

            initialItem: Item { property bool resetEnabled: false; }

            delegate: StackViewDelegate
            {
                function transitionFinished(properties)
                {
                    properties.exitItem.opacity = 1
                }

                pushTransition: StackViewTransition
                {
                    PropertyAnimation
                    {
                        target: enterItem
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 100
                    }
                    PropertyAnimation
                    {
                        target: exitItem
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 100
                    }
                }
            }
        }
        UM.I18nCatalog { id: catalog; name: "uranium"; }
    }
/*
    leftButtons: Button
    {
        text: catalog.i18nc("@action:button", "Defaults");
        enabled: stackView.currentItem.resetEnabled;
        onClicked: stackView.currentItem.reset();
    }*/

    property QtObject settingVisibilityPresetsModel: CuraApplication.getSettingVisibilityPresetsModel()
    ComboBox
    {
        id: visibilityPreset
        width: 150 * screenScaleFactor
        anchors
        {
            top: test.bottom
            topMargin: 6 * UM.Theme.getSize("default_margin").width/10
            left: parent.left
            leftMargin: 15 * UM.Theme.getSize("default_margin").width/10
        }
        style: UM.Theme.styles.combobox

        model: settingVisibilityPresetsModel
        textRole: "name"

        currentIndex:
        {
            // Load previously selected preset.
            var index = settingVisibilityPresetsModel.find("id", settingVisibilityPresetsModel.activePreset)
            if (index == -1)
            {
                return 0
            }

            return index
        }

        onActivated:
        {
            var preset_id = settingVisibilityPresetsModel.getItem(index).id;
            settingVisibilityPresetsModel.setActivePreset(preset_id);
        }
    }

    rightButtons: Button
    {
        text: catalog.i18nc("@action:button", "Close");
        width: 70 * UM.Theme.getSize("default_margin").width/10
        height: 23 * UM.Theme.getSize("default_margin").width/10
        //iconName: "dialog-close";
        onClicked: base.accept();
        style: UM.Theme.styles.parameterbutton
    }

    function setPage(index)
    {
        pagesList.selection.clear();
        pagesList.selection.select(index);

        stackView.replace(configPagesModel.get(index).item);

        base.currentPage = index
    }

    function insertPage(index, name, item)
    {
        configPagesModel.insert(index, { "name": name, "item": item });
    }

    function removePage(index)
    {
        configPagesModel.remove(index)
    }

    function getCurrentItem(key)
    {
        return stackView.currentItem
    }

    Component.onCompleted:
    {
        //This uses insertPage here because ListModel is stupid and does not allow using qsTr() on elements.
        insertPage(0, catalog.i18nc("@title:tab", "General"), Qt.resolvedUrl("GeneralPage.qml"));
        insertPage(1, catalog.i18nc("@title:tab", "Settings"), Qt.resolvedUrl("SettingVisibilityPage.qml"));
        insertPage(2, catalog.i18nc("@title:tab", "Plugins"), Qt.resolvedUrl("PluginsPage.qml"));

        setPage(0)
    }
}
