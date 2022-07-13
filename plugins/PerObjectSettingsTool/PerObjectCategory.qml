// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.1 as UM

import ".."

Button {
    id: base;

    style: ButtonStyle {
        background: Item { }
        label: Row
        {
            spacing: UM.Theme.getSize("default_lining").width * 4

            UM.RecolorImage
            {
                anchors.verticalCenter: parent.verticalCenter
                height: (label.height / 2) | 0
                width: height
                source: control.checked ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_right");
                color: control.hovered ? UM.Theme.getColor("color12") : UM.Theme.getColor("color4")
            }
            UM.RecolorImage
            {
                anchors.verticalCenter: parent.verticalCenter
                height: label.height * 0.7
                width: height
                source: control.iconSource
                color: control.hovered ? UM.Theme.getColor("color12") : UM.Theme.getColor("color4")
            }
            Label
            {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
                color: control.hovered ? UM.Theme.getColor("color12") : UM.Theme.getColor("color4")
                //font.bold: true
                font: UM.Theme.getFont("font3")
            }

            SystemPalette { id: palette }
        }
    }

    signal showTooltip(string text);
    signal hideTooltip();
    signal contextMenuRequested()

    text: definition ? definition.label : ""
    iconSource: definition ? UM.Theme.getIcon(definition.icon) : ""

    checkable: true
    checked: definition? definition.expanded : ""

    onClicked: definition.expanded ? settingDefinitionsModel.collapse(definition.key) : settingDefinitionsModel.expandRecursive(definition.key)
}
