// Copyright (c) 2016 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.2 as UM

import Cura 1.0 as Cura

UM.PreferencesPage
{
    //title: catalog.i18nc("@title:tab", "Setting Visibility");

    property QtObject settingVisibilityPresetsModel: CuraApplication.getSettingVisibilityPresetsModel()

    property int scrollToIndex: 0

    signal scrollToSection( string key )
    onScrollToSection:
    {
        settingsListView.positionViewAtIndex(definitionsModel.getIndex(key), ListView.Beginning)
    }

    function reset()
    {
        UM.Preferences.resetPreference("general/visible_settings")

        // After calling this function update Setting visibility preset combobox.
        // Reset should set default setting preset ("Basic")
        visibilityPreset.currentIndex = 1
    }
    resetEnabled: true;

    Item
    {
        id: base;
        anchors.fill: parent;

        CheckBox
        {
            id: toggleVisibleSettings
            anchors
            {
                top: parent.top;
                topMargin: 5 * UM.Theme.getSize("default_margin").width/10
                left: parent.left;
                leftMargin: UM.Theme.getSize("default_margin").width
            }
            text: " "+catalog.i18nc("@label:textbox", "Check all")
            style: UM.Theme.styles.checkbox
            checkedState:
            {
                if(definitionsModel.visibleCount == definitionsModel.categoryCount)
                {
                    return Qt.Unchecked
                }
                else if(definitionsModel.visibleCount == definitionsModel.rowCount(null))
                {
                    return Qt.Checked
                }
                else
                {
                    return Qt.PartiallyChecked
                }
            }
            partiallyCheckedEnabled: true

            MouseArea
            {
                anchors.fill: parent;
                onClicked:
                {
                    if(parent.checkedState == Qt.Unchecked || parent.checkedState == Qt.PartiallyChecked)
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

        TextField
        {
            id: filter;

            anchors
            {
                verticalCenter: toggleVisibleSettings.verticalCenter;
                verticalCenterOffset: 2 * UM.Theme.getSize("default_margin").width/10
                left: toggleVisibleSettings.right
                leftMargin: UM.Theme.getSize("default_margin").width
                right: visibilityPreset.left
                rightMargin: UM.Theme.getSize("default_margin").width
            }
            height: 22 * UM.Theme.getSize("default_margin").width/10
            style: UM.Theme.styles.text_field

            placeholderText: catalog.i18nc("@label:textbox", "Filter...")

            onTextChanged: definitionsModel.filter = {"i18n_label": "*" + text}
        }

        ComboBox
        {
            id: visibilityPreset
            width: 150 * screenScaleFactor
            anchors
            {
                //top: parent.top
                right: parent.right
                rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
                verticalCenter: toggleVisibleSettings.verticalCenter;
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

        ScrollView
        {
            id: scrollView

            //frameVisible: true

            anchors
            {
                top: filter.bottom;
                topMargin: 5 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("default_margin").height
                left: parent.left;
                leftMargin: 5 * UM.Theme.getSize("default_margin").width/10
                right: parent.right;
                rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
                bottom: parent.bottom;
            }
            style: UM.Theme.styles.scrollview;
            ListView
            {
                id: settingsListView

                model: UM.SettingDefinitionsModel
                {
                    id: definitionsModel
                    containerId: Cura.MachineManager.activeDefinitionId
                    showAll: true
                    exclude: ["command_line_settings","platform_adhesion","dual","experimental"]
                    showAncestors: true
                    //expanded: ["*"]
                    visibilityHandler: UM.SettingPreferenceVisibilityHandler {}
                }

                delegate: Loader
                {
                    id: loader

                    width: parent.width
                    height: model.type == undefined ? 0 : UM.Theme.getSize("section").height

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

        UM.I18nCatalog { name: "cura"; }
        SystemPalette { id: palette; }

        Component
        {
            id: settingVisibilityCategory;

            UM.SettingVisibilityCategory { }
        }

        Component
        {
            id: settingVisibilityItem;

            UM.SettingVisibilityItem { }
        }
    }
}
