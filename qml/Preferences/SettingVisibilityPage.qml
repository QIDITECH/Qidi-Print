// Copyright (c) 2016 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QtQuick.Controls 2.3 as NewControls

import QD 1.3 as QD
import QIDI 1.1 as QIDI

QD.PreferencesPage
{
    title: catalog.i18nc("@title:tab", "Setting Visibility");

    property QtObject settingVisibilityPresetsModel: QIDIApplication.getSettingVisibilityPresetsModel()
    property int scrollToIndex: 0

    signal scrollToSection( string key )
    onScrollToSection:
    {
        settingsListView.positionViewAtIndex(definitionsModel.getIndex(key), ListView.Beginning)
    }

    function reset()
    {
        settingVisibilityPresetsModel.setActivePreset("basic")
    }
    resetEnabled: true;

    Item
    {
        id: base;
        anchors.fill: parent;
        anchors.topMargin: 5 * QD.Theme.getSize("size").width
        QD.I18nCatalog { id: catalog; name: "qdtech"; }

        QIDI.CheckBox
        {
            id: toggleVisibleSettings
            height: 20 * QD.Theme.getSize("size").height
            anchors.verticalCenter: filter.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            text: catalog.i18nc("@label:textbox", "Check all")
            checkState:
            {
                if(definitionsModel.visibleCount == definitionsModel.categoryCount)
                {
                    return Qt.Unchecked
                }
                else if(definitionsModel.visibleCount == definitionsModel.count)
                {
                    return Qt.Checked
                }
                else
                {
                    return Qt.PartiallyChecked
                }
            }

            indicator: Rectangle
            {
                id: checkReg
                width: 20 * QD.Theme.getSize("size").width
                height: 20 * QD.Theme.getSize("size").width
                radius: QD.Theme.getSize("setting_control_radius").width
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                color: toggleVisibleSettings.hovered || toggleVisibleSettings.activeFocus ? QD.Theme.getColor("setting_control_highlight") : QD.Theme.getColor("setting_control")
                border.color: toggleVisibleSettings.hovered || toggleVisibleSettings.activeFocus ? QD.Theme.getColor("blue_6") : QD.Theme.getColor("setting_control_border")

                QD.RecolorImage
                {
                    anchors.centerIn: parent
                    width: Math.round(parent.width / 2)
                    height: Math.round(parent.height / 2)
                    sourceSize.height: width
                    color: !enabled ? QD.Theme.getColor("setting_control_disabled_text") : QD.Theme.getColor("blue_6")
                    source: toggleVisibleSettings.checkState == Qt.PartiallyChecked ? QD.Theme.getIcon("") : QD.Theme.getIcon("Check")
                    opacity: toggleVisibleSettings.checked | toggleVisibleSettings.checkState == Qt.PartiallyChecked ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 100; } }
                }
            }

            MouseArea
            {
                anchors.fill: parent;
                onClicked:
                {
                    if(parent.checkState == Qt.Unchecked || parent.checkState == Qt.PartiallyChecked)
                    {
                        definitionsModel.setAllExpandedVisible(true)
                    }
                    else
                    {
                        definitionsModel.setAllExpandedVisible(false)
                    }
                }
            }
        }

        QIDI.TextField
        {
            id: filter
            height: 24 * QD.Theme.getSize("size").height
            anchors.top: parent.top
            anchors.left: toggleVisibleSettings.right
            anchors.leftMargin: 10 * QD.Theme.getSize("size").width
            anchors.right: visibilityPreset.left
            anchors.rightMargin: 10 * QD.Theme.getSize("size").width
            placeholderText: catalog.i18nc("@label:textbox", "Search settings")
            onTextChanged: definitionsModel.filter = {"i18n_label": "*" + text}
        }

        QIDI.ComboBox
        {
            id: visibilityPreset
            height: filter.height
            width: 120 * QD.Theme.getSize("size").width
            anchors.verticalCenter: filter.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 15 * QD.Theme.getSize("size").width

            model: settingVisibilityPresetsModel.items
            textRole: "name"

            currentIndex:
            {
                var idx = -1;
                for(var i = 0; i < settingVisibilityPresetsModel.items.length; ++i)
                {
                    if(settingVisibilityPresetsModel.items[i].presetId == settingVisibilityPresetsModel.activePreset)
                    {
                        idx = i;
                        break;
                    }
                }
                return idx;
            }

            onActivated:
            {
                var preset_id = settingVisibilityPresetsModel.items[index].presetId
                settingVisibilityPresetsModel.setActivePreset(preset_id)
            }
        }

        QIDI.ScrollView
        {
            id: scrollView

            anchors
            {
                top: filter.bottom;
                topMargin: QD.Theme.getSize("default_margin").height
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;
            }

            ListView
            {
                id: settingsListView

                spacing: 5 * QD.Theme.getSize("size").width
                model: QD.SettingDefinitionsModel
                {
                    id: definitionsModel
                    containerId: QIDI.MachineManager.activeMachine != null ? QIDI.MachineManager.activeMachine.definition.id: ""
                    showAll: true
                    exclude: ["command_line_settings" , "meshfix" , "dual" , "travel" , "material" , "top_bottom" , "resolution",  "shell" , "blackmagic"]
                    showAncestors: true
                    expanded: ["*"]
                    visibilityHandler: QD.SettingPreferenceVisibilityHandler {}
                }

                delegate: Loader
                {
                    id: loader

                    width: settingsListView.width
                    height: model.type != undefined ? QD.Theme.getSize("section").height : 0

                    property var definition: model
                    property var settingDefinitionsModel: definitionsModel

                    asynchronous: true
                    active: model.type != undefined
                    sourceComponent:
                    {
                        switch(model.type)
                        {
                            case "category":
                                return settingVisibilityCategory
                            default:
                                return settingVisibilityItem
                        }
                    }
                }
            }
        }

        QD.I18nCatalog { name: "qidi"; }
        SystemPalette { id: palette; }

        Component
        {
            id: settingVisibilityCategory;

            QD.SettingVisibilityCategory { }
        }

        Component
        {
            id: settingVisibilityItem;

            QD.SettingVisibilityItem { }
        }
    }
}