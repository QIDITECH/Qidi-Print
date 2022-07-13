// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.2 as UM

UM.TooltipArea
{
    x: definition ? (definition.depth + 1)* UM.Theme.getSize("default_margin").width : UM.Theme.getSize("default_margin").width
    text: definition ? definition.description : ""

    width: childrenRect.width;
    height: childrenRect.height;
    id: checkboxTooltipArea
    CheckBox
    {
        id: check

        text: definition ? " "+definition.label: ""
        checked: addedSettingsModel.getVisible(model.key)
        enabled: definition ? !definition.prohibited: false
        visible: definition ? model.type != "category":true
        style: UM.Theme.styles.checkbox
        onClicked:
        {
            addedSettingsModel.setVisible(model.key, checked);
            UM.ActiveTool.forceUpdate();
        }
    }
}

