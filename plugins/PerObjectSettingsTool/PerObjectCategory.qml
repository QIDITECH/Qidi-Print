// Copyright (c) 2015 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import QD 1.1 as QD

import ".."

Button {
    id: base;

    style: ButtonStyle {
        background: Item { }
        label: Row
        {
            spacing: QD.Theme.getSize("default_lining").width

            QD.RecolorImage
            {
                anchors.verticalCenter: parent.verticalCenter
                height: (label.height / 2) | 0
                width: height
                source: control.checked ? QD.Theme.getIcon("ChevronSingleDown") : QD.Theme.getIcon("ChevronSingleRight");
                color: control.hovered ? palette.highlight : palette.buttonText
            }
            QD.RecolorImage
            {
                anchors.verticalCenter: parent.verticalCenter
                height: label.height
                width: height
                source: control.iconSource
                color: control.hovered ? palette.highlight : palette.buttonText
            }
            Label
            {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: control.text
                color: control.hovered ? palette.highlight : palette.buttonText
                font.bold: true
            }

            SystemPalette { id: palette }
        }
    }

    signal showTooltip(string text);
    signal hideTooltip();
    signal contextMenuRequested()

    text: definition.label
    iconSource: QD.Theme.getIcon(definition.icon)

    checkable: true
    checked: definition.expanded

    onClicked: definition.expanded ? settingDefinitionsModel.collapseRecursive(definition.key) : settingDefinitionsModel.expandRecursive(definition.key)
}
