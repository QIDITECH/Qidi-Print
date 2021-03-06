// Copyright (c) 2016 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.2 as UM

PreferencesPage
{
    title: catalog.i18nc("@title:tab", "Setting Visibility");

    property int scrollToIndex: 0

    signal scrollToSection( string key )
    onScrollToSection:
    {
        settingsListView.positionViewAtIndex(definitionsModel.getIndex(key), ListView.Beginning)
    }

    function reset()
    {
        UM.Preferences.resetPreference("general/visible_settings")
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
                verticalCenter: filter.verticalCenter;
                left: parent.left;
                leftMargin: UM.Theme.getSize("default_margin").width
            }
            text: catalog.i18nc("@label:textbox", "Check all")
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
                top: parent.top
                left: toggleVisibleSettings.right
                leftMargin: UM.Theme.getSize("default_margin").width
                right: parent.right
            }

            placeholderText: catalog.i18nc("@label:textbox", "Filter...")

            onTextChanged: definitionsModel.filter = {"i18n_label": "*" + text}
        }

        ScrollView
        {
            id: scrollView

            frameVisible: true

            anchors
            {
                top: filter.bottom;
                topMargin: UM.Theme.getSize("default_margin").height
                left: parent.left;
                right: parent.right;
                bottom: parent.bottom;
            }
            ListView
            {
                id: settingsListView

                model: UM.SettingDefinitionsModel
                {
                    id: definitionsModel
                    containerId: ""
                    showAll: true
                    exclude: [""]
                    expanded: ["*"]
                    visibilityHandler: UM.SettingPreferenceVisibilityHandler { }
                }

                delegate: Loader
                {
                    id: loader

                    width: parent.width
                    height: model.type != undefined ? UM.Theme.getSize("section").height : 0

                    property var definition: model
                    property var settingDefinitionsModel: definitionsModel

                    asynchronous: true
                    active: model.type != undefined
                    source:
                    {
                        switch(model.type)
                        {
                            case "category":
                                return "SettingVisibilityCategory.qml"
                            default:
                                return "SettingVisibilityItem.qml"
                        }
                    }
                }
            }
        }

        UM.I18nCatalog { name: "uranium"; }
        SystemPalette { id: palette; }
    }
}
