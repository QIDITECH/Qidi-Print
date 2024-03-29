// Copyright (c) 2015 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import QD 1.2 as QD

QD.TooltipArea
{
    x: model.depth * QD.Theme.getSize("default_margin").width;
    text: model.description;

    width: childrenRect.width;
    height: childrenRect.height;

    CheckBox
    {
        id: check

        text: definition.label
        checked: addedSettingsModel.getVisible(model.key)

        onClicked:
        {
            addedSettingsModel.setVisible(model.key, checked);
            QD.ActiveTool.forceUpdate();
        }
    }

    // When the user removes settings from the list addedSettingsModel, we need to recheck if the
    // setting is visible or not to show a mark in the CheckBox.
    Connections
    {
        target: addedSettingsModel
        function onVisibleCountChanged()
        {
            check.checked = addedSettingsModel.getVisible(model.key)
        }
    }
}


