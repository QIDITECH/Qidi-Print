// Copyright (c) 2015 Jaime van Kessel, QIDI B.V.
// The PostProcessingPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Controls.Styles 1.1
import QtQml.Models 2.15 as Models
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI

QD.Dialog
{
    id: dialog

    title: catalog.i18nc("@title:window", "Post Processing Plugin")
    minimumWidth: 800 * screenScaleFactor;
    minimumHeight: 500 * screenScaleFactor;
    width: minimumWidth
    height: minimumHeight
    Rectangle
    {
        width: parent.width
        height: parent.height
        border.color: QD.Theme.getColor("gray_3")
        border.width: QD.Theme.getSize("size").width
    }
    /*Rectangle
    {
        color: QD.Theme.getColor("gray_3")
        width: parent.width
        height: QD.Theme.getSize("size").width
        anchors
        {
            top: parent.top
            topMargin: 30 * QD.Theme.getSize("size").width
            left: parent.left
            right: parent.right

        }
    }*/

    backgroundColor: QD.Theme.getColor("main_background")
    onVisibleChanged:
    {
        if(!visible) //Whenever the window is closed (either via the "Close" button or the X on the window frame), we want to update it in the stack.
        {
            manager.writeScriptsToStack()
        }
    }

    Item
    {
        QD.I18nCatalog{id: catalog; name: "qidi"}
        id: base
        property int columnWidth: Math.round((base.width / 2) - QD.Theme.getSize("default_margin").width)
        property int textMargin: Math.round(QD.Theme.getSize("default_margin").width / 2)
        property string activeScriptName
        SystemPalette{ id: palette }
        SystemPalette{ id: disabledPalette; colorGroup: SystemPalette.Disabled }
        anchors.fill: parent

        ExclusiveGroup
        {
            id: selectedScriptGroup
        }
        Item
        {
            id: activeScripts
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            width:base.columnWidth
                /*250 * QD.Theme.getSize("size").width*/
            height: parent.height
            Label
            {
                id: activeScriptsHeader
                text: catalog.i18nc("@label", "Post Processing Scripts")
                horizontalAlignment: Text.AlignHCenter
                anchors.top: parent.top
                anchors.topMargin: base.textMargin
                anchors.left: parent.left
                anchors.leftMargin: QD.Theme.getSize("default_margin").width
                anchors.right: parent.right
                anchors.rightMargin: base.textMargin
                font: QD.Theme.getFont("large_bold")
                color: QD.Theme.getColor("blue_6")
                elide: Text.ElideRight
            }

            ScrollView
            {
                id: scrollViewLeft
                anchors
                {
                    top: activeScriptsHeader.bottom
                    topMargin: 10 * QD.Theme.getSize("size").width
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                visible: manager.selectedScriptDefinitionId != ""
                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                ListView
                {
                    id: activeScriptsList

                    anchors
                    {
                        top: activeScriptsHeader.bottom
                        left: parent.left
                        right: parent.right
                        rightMargin: base.textMargin
                    }
                    spacing: QD.Theme.getSize("default_lining").height
                    clip: true
                    model: manager.scriptList
                    delegate: Item
                    {
                        width: parent.width
                        height: activeScriptButton.height
                        Button
                        {
                            id: activeScriptButton
                            text: manager.getScriptLabelByKey(modelData.toString())
                            exclusiveGroup: selectedScriptGroup
                            width: parent.width
                            height: QD.Theme.getSize("section").height
                            checkable: true

                            checked:
                            {
                                if (manager.selectedScriptIndex == index)
                                {
                                    base.activeScriptName = manager.getScriptLabelByKey(modelData.toString())
                                    return true
                                }
                                else
                                {
                                    return false
                                }
                            }

                            onClicked:
                            {
                                forceActiveFocus()
                                manager.setSelectedScriptIndex(index)
                                base.activeScriptName = manager.getScriptLabelByKey(modelData.toString())
                            }

                            style: ButtonStyle
                            {
                                background: Rectangle
                                {
                                    color: activeScriptButton.checked ? QD.Theme.getColor("blue_4") : "transparent"         //选中背景色
                                    width: parent.width
                                    height: parent.height
                                }
                                label: Label
                                {
                                    verticalAlignment: Text.AlignVCenter
                                    wrapMode: Text.Wrap
                                    text: control.text
                                    elide: Text.ElideRight
                                    color: activeScriptButton.checked ? QD.Theme.getColor("blue_6") : palette.text
                                    font: QD.Theme.getFont("font1")
                                    /*opacity: 0.5*/
                                }
                            }
                        }

                        Button
                        {
                            id: removeButton
                            text: "x"
                            width: 15 * QD.Theme.getSize("size").width      /*20 * screenScaleFactor*/
                            height: width     /*20 * screenScaleFactor*/
                            anchors.right:parent.right
                            anchors.rightMargin: 2 * base.textMargin
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked: manager.removeScriptByIndex(index)
                            style: ButtonStyle
                            {
                                background:Rectangle
                                {
                                    anchors.fill: parent
                                    color: QD.Theme.getColor("primary_button")
                                    radius: 5
                                }
                                label: Item
                                {
                                    QD.RecolorImage
                                    {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: Math.round(control.width / 1.3)
                                        height: Math.round(control.height / 1.3)
                                        sourceSize.height: width
                                        color: palette.highlightedText
                                        source: QD.Theme.getIcon("Cancel")
                                    }
                                }
                            }
                        }
                        Button
                        {
                            id: downButton
                            text: ""
                            anchors.right: removeButton.left
                            anchors.rightMargin: base.textMargin
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: index != manager.scriptList.length - 1
                            width: 15 * QD.Theme.getSize("size").width
                            height: width

                            onClicked:
                            {
                                if (manager.selectedScriptIndex == index)
                                {
                                    manager.setSelectedScriptIndex(index + 1)
                                }
                                return manager.moveScript(index, index + 1)
                            }
                            style: ButtonStyle
                            {
                                background:Rectangle
                                {
                                    anchors.fill: parent
                                    color: control.enabled ? QD.Theme.getColor("primary_button") : QD.Theme.getColor("disabled")
                                    radius: 5
                                }

                                label: Item
                                {
                                    QD.RecolorImage
                                    {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: Math.round(control.width / 1.2)
                                        height: Math.round(control.height / 1.2)
                                        sourceSize.height: width
                                        color: control.enabled ? palette.highlightedText : disabledPalette.text
                                        source: QD.Theme.getIcon("ChevronSingleDown")
                                    }
                                }
                            }
                        }
                        Button
                        {
                            id: upButton
                            text: ""
                            enabled: index != 0
                            width: 15 * QD.Theme.getSize("size").width     /*20 * screenScaleFactor*/
                            height: width     /*20 * screenScaleFactor*/
                            anchors.right: downButton.left
                            anchors.rightMargin: base.textMargin
                            anchors.verticalCenter: parent.verticalCenter
                            onClicked:
                            {
                                if (manager.selectedScriptIndex == index)
                                {
                                    manager.setSelectedScriptIndex(index - 1)
                                }
                                return manager.moveScript(index, index - 1)
                            }
                            style: ButtonStyle
                            {
                                background:Rectangle
                                {
                                    anchors.fill: parent
                                    color: control.enabled ? QD.Theme.getColor("primary_button") : QD.Theme.getColor("disabled")
                                    radius: 5
                                }
                                label: Item
                                {
                                    QD.RecolorImage
                                    {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: Math.round(control.width / 1.2)
                                        height: Math.round(control.height / 1.2)
                                        sourceSize.height: width
                                        color: control.enabled ? palette.highlightedText : disabledPalette.text
                                        source: QD.Theme.getIcon("ChevronSingleUp")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Button
            {
                id: addButton
                text: catalog.i18nc("@action", "Add a script")
                width: 20 * QD.Theme.getSize("size").width
                height: width
                /*anchors.horizontalCenter: scrollViewLeft.horizontalCenter*/
                /*anchors.bottom: scrollViewLeft.top
                anchors.bottomMargin: 10 * QD.Theme.getSize("size").width*/
                anchors.top: parent.top
                anchors.topMargin: base.textMargin
                anchors.left: parent.left
                anchors.leftMargin: QD.Theme.getSize("default_margin").width
                onClicked:
                {
                    scriptsMenu.x = QD.Theme.getSize("default_margin").width
                    scriptsMenu.y = 25 * QD.Theme.getSize("size").width
                    scriptsMenu.width = parent.width
                    scriptsMenu.open()
                }
                style: ButtonStyle
                {
                    background:Rectangle
                    {
                        anchors.fill:parent
                        color:QD.Theme.getColor("primary_button")
                        radius: 5
                    }
                    label: Item
                    {
                        QD.RecolorImage
                        {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.round(control.width / 0.9)
                            height: Math.round(control.height / 0.9)
                            sourceSize.height: width
                            color: palette.highlightedText
                            source: QD.Theme.getIcon("Additions")
                        }
                    }
                }
            }

            QQC2.Menu
            {
                id: scriptsMenu
                Models.Instantiator
                {
                    model: manager.loadedScriptList

                    QQC2.MenuItem
                    {
                        id:addMenuItem
                        background:Rectangle
                        {
                            width: parent.width - 2 * QD.Theme.getSize("size").width
                            height: parent.height - 2 * QD.Theme.getSize("size").width
                            anchors.left: parent.left
                            anchors.leftMargin: QD.Theme.getSize("size").width
                            anchors.top: parent.top
                            anchors.topMargin: QD.Theme.getSize("size").width
                            color: addMenuItem.hovered? QD.Theme.getColor("blue_4") : "transparent"
                            /*border.color: addMenuItem.hovered ? QD.Theme.getColor("blue_6"): "transparent"
                            border.width: QD.Theme.getSize("size").width*/
                        }
                        height:  25 * QD.Theme.getSize("size").width
                        Text{
                            anchors.left: addMenuItem.left
                            anchors.leftMargin: 5 * QD.Theme.getSize("size").width
                            anchors.verticalCenter: addMenuItem.verticalCenter
                            text: manager.getScriptLabelByKey(modelData.toString())
                            font: QD.Theme.getFont("font2")
                            color: addMenuItem.hovered? QD.Theme.getColor("blue_6") : palette.text
                        }
                        onTriggered: manager.addScriptToList(modelData.toString())
                    }

                    onObjectAdded: scriptsMenu.insertItem(index, object)
                    onObjectRemoved: scriptsMenu.removeItem(object)
                }
            }
        }
        Rectangle
        {
            id: lineOfCut
            color: QD.Theme.getColor("blue_7")
            width: QD.Theme.getSize("size").width
            height: scrollViewLeft.height
            anchors.centerIn: parent
            /*anchors.verticalCenterOffset: 20 * QD.Theme.getSize("size").width*/
        }

        Rectangle
        {
            anchors.left: activeScripts.right
            anchors.right: parent.right
            anchors.rightMargin: QD.Theme.getSize("size").width
            height: parent.height - QD.Theme.getSize("size").width
            id: settingsPanel
            Label
            {
                id: scriptSpecsHeader
                text: manager.selectedScriptIndex == -1 ? catalog.i18nc("@label", "Settings") : base.activeScriptName
                anchors
                {
                    top: parent.top
                    topMargin: base.textMargin
                    left: parent.left
                    leftMargin: QD.Theme.getSize("default_margin").width
                    right: parent.right
                    rightMargin: base.textMargin
                }
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                /*height: 20 * screenScaleFactor*/
                font: QD.Theme.getFont("large_bold")
                color: QD.Theme.getColor("blue_6")
            }

            ScrollView
            {
                id: scrollView
                anchors
                {
                    top: scriptSpecsHeader.bottom
                    topMargin: 10 * QD.Theme.getSize("size").width
                    left: parent.left
                    leftMargin: QD.Theme.getSize("default_margin").width
                    right: parent.right
                    bottom: parent.bottom
                }
                visible: manager.selectedScriptDefinitionId != ""
                verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

                ListView
                {
                    id: listview
                    anchors
                    {
                        top: scriptSpecsHeader.bottom
                        left: parent.left
                        right: parent.right
                        rightMargin: base.textMargin
                    }
                    spacing: QD.Theme.getSize("default_lining").height
                    model: QD.SettingDefinitionsModel
                    {
                        id: definitionsModel
                        containerId: manager.selectedScriptDefinitionId
                        onContainerIdChanged:definitionsModel.setAllVisible(true)
                        showAll: true
                    }
                    delegate: Loader
                    {
                        id: settingLoader
                        width: parent.width
                        height:
                        {
                            if(provider.properties.enabled == "True")
                            {
                                if(model.type != undefined)
                                {
                                    return QD.Theme.getSize("section").height
                                }
                                else
                                {
                                    return 0
                                }
                            }
                            else
                            {
                                return 0
                            }
                        }
                        Behavior on height { NumberAnimation { duration: 100 } }
                        opacity: provider.properties.enabled == "True" ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 100 } }
                        enabled: opacity > 0

                        property var definition: model
                        property var settingDefinitionsModel: definitionsModel
                        property var propertyProvider: provider
                        property var globalPropertyProvider: inheritStackProvider

                        //Qt5.4.2 and earlier has a bug where this causes a crash: https://bugreports.qt.io/browse/QTBUG-35989
                        //In addition, while it works for 5.5 and higher, the ordering of the actual combo box drop down changes,
                        //causing nasty issues when selecting different options. So disable asynchronous loading of enum type completely.
                        asynchronous: model.type != "enum" && model.type != "extruder"

                        onLoaded:
                        {
                            settingLoader.item.showRevertButton = false
                            settingLoader.item.showInheritButton = false
                            settingLoader.item.showLinkedSettingIcon = false
                            settingLoader.item.doDepthIndentation = false
                            settingLoader.item.doQualityUserSettingEmphasis = false
                        }

                        sourceComponent:
                        {
                            switch(model.type)
                            {
                                case "int":
                                    return settingTextField
                                case "float":
                                    return settingTextField
                                case "enum":
                                    return settingComboBox
                                case "extruder":
                                    return settingExtruder
                                case "bool":
                                    return settingCheckBox
                                case "str":
                                    return settingTextField
                                case "category":
                                    return settingCategory
                                default:
                                    return settingUnknown
                            }
                        }

                        QD.SettingPropertyProvider
                        {
                            id: provider
                            containerStackId: manager.selectedScriptStackId
                            key: model.key ? model.key : "None"
                            watchedProperties: [ "value", "enabled", "state", "validationState" ]
                            storeIndex: 0
                        }

                        // Specialty provider that only watches global_inherits (we cant filter on what property changed we get events
                        // so we bypass that to make a dedicated provider).
                        QD.SettingPropertyProvider
                        {
                            id: inheritStackProvider
                            containerStack: QIDI.MachineManager.activeMachine
                            key: model.key ? model.key : "None"
                            watchedProperties: [ "limit_to_extruder" ]
                        }

                        Connections
                        {
                            target: item

                            function onShowTooltip(text)
                            {
                                tooltip.text = text
                                var position = settingLoader.mapToItem(settingsPanel, settingsPanel.x, 0)
                                tooltip.show(position)
                                tooltip.target.x = position.x + 1
                            }

                            function onHideTooltip() { tooltip.hide() }
                        }
                    }
                }
            }
        }

        QIDI.PrintSetupTooltip
        {
            id: tooltip
        }

        Component
        {
            id: settingTextField;

            QIDI.SettingTextField { }
        }

        Component
        {
            id: settingComboBox;

            QIDI.SettingComboBox { }
        }

        Component
        {
            id: settingExtruder;

            QIDI.SettingExtruder { }
        }

        Component
        {
            id: settingCheckBox;

            QIDI.SettingCheckBox { }
        }

        Component
        {
            id: settingCategory;

            QIDI.SettingCategory { }
        }

        Component
        {
            id: settingUnknown;

            QIDI.SettingUnknown { }
        }
    }
    Rectangle
    {
        width: parent.width
        height: QD.Theme.getSize("size").width
        anchors.top: dialog.top
        anchors.right:dialog.right
        color: QD.Theme.getColor("gray_3")
    }

    Item
    {
        objectName: "postProcessingSaveAreaButton"
        visible: activeScriptsList.count > 0
        height: QD.Theme.getSize("action_button").height
        width: height

        QIDI.SecondaryButton
        {
            height: QD.Theme.getSize("action_button").height
            tooltip:
            {
                var tipText = catalog.i18nc("@info:tooltip", "Change active post-processing scripts.");
                if (activeScriptsList.count > 0)
                {
                    tipText += "<br><br>" + catalog.i18ncp("@info:tooltip",
                        "The following script is active:",
                        "The following scripts are active:",
                        activeScriptsList.count
                    ) + "<ul>";
                    for(var i = 0; i < activeScriptsList.count; i++)
                    {
                        tipText += "<li>" + manager.getScriptLabelByKey(manager.scriptList[i]) + "</li>";
                    }
                    tipText += "</ul>";
                }
                return tipText
            }
            toolTipContentAlignment: QIDI.ToolTip.ContentAlignment.AlignLeft
            onClicked: dialog.show()
            iconSource: "Script.svg"
            fixedWidthMode: false
        }

        QIDI.NotificationIcon
        {
            id: activeScriptCountIcon
            visible: activeScriptsList.count > 0
            anchors
            {
                top: parent.top
                right: parent.right
                rightMargin: (-0.5 * width) | 0
                topMargin: (-0.5 * height) | 0
            }

            labelText: activeScriptsList.count
        }
    }
}
