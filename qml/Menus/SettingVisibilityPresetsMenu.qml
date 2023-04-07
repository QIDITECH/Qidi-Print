// Copyright (c) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.11
import QtQml.Models 2.14 as Models

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Menu
{
    ActionGroup { id: group }

    id: menu
    title: catalog.i18nc("@action:inmenu", "Visible Settings")

    property QtObject settingVisibilityPresetsModel: QIDIApplication.getSettingVisibilityPresetsModel()

    signal collapseAllCategories()

    Models.Instantiator
    {
        model: settingVisibilityPresetsModel.items

        MenuItem
        {
            text: modelData.name
            checkable: true
            checked: modelData.presetId == settingVisibilityPresetsModel.activePreset
            ActionGroup.group: group
            onTriggered:
            {
                settingVisibilityPresetsModel.setActivePreset(modelData.presetId);
            }
        }

        onObjectAdded: menu.insertItem(index, object)
        onObjectRemoved: menu.removeItem(object)
    }

    MenuSeparator {}
    MenuItem
    {
        text: catalog.i18nc("@action:inmenu", "Collapse All Categories")
        onTriggered:
        {
            collapseAllCategories();
        }
    }
    MenuSeparator {}
    MenuItem
    {
        text: catalog.i18nc("@action:inmenu", "Manage Setting Visibility...")
        icon.name: "configure"
        onTriggered: QIDI.Actions.configureSettingVisibility.trigger()
    }
}
