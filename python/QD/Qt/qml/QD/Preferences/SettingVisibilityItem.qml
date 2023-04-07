// Copyright (c) 2015 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import QD 1.2 as QD
import QIDI 1.1 as QIDI

Item {
    // Use the depth of the model to move the item, but also leave space for the visibility / enabled exclamation mark.

    x: definition ? (definition.depth + 1)* QD.Theme.getSize("default_margin").width : QD.Theme.getSize("default_margin").width
    QD.TooltipArea
    {
        width: height;
        height: check.height;
        anchors.right: checkboxTooltipArea.left
        anchors.rightMargin: 2 * screenScaleFactor
        visible: provider.properties.enabled == "False"

        text:
        {
            if(provider.properties.enabled == "True")
            {
                return ""
            }
            var key = definition ? definition.key : ""
            var requires = settingDefinitionsModel.getRequires(key, "enabled")
            if(requires.length == 0)
            {
                return catalog.i18nc("@item:tooltip", "This setting has been hidden by the active machine and will not be visible.");
            }
            else
            {
                var requires_text = ""
                for(var i in requires)
                {
                    if(requires_text == "")
                    {
                        requires_text = requires[i].label
                    }
                    else
                    {
                        requires_text += ", " + requires[i].label
                    }
                }

                return catalog.i18ncp("@item:tooltip %1 is list of setting names", "This setting has been hidden by the value of %1. Change the value of that setting to make this setting visible.", "This setting has been hidden by the values of %1. Change the values of those settings to make this setting visible.", requires.length) .arg(requires_text);
            }
        }

        QD.RecolorImage
        {
            anchors.centerIn: parent
            width: Math.round(check.height * 0.75) | 0
            height: width
            source: QD.Theme.getIcon("Information")
            color: palette.buttonText
        }
    }

    QD.TooltipArea
    {
        text: definition ? definition.description : ""
        width: childrenRect.width;
        height: childrenRect.height;
        id: checkboxTooltipArea
        QIDI.CheckBox
        {
            id: check
            height: 18 * QD.Theme.getSize("size").height
            text: definition ? definition.label: ""
            checked: definition ? definition.visible: false
            enabled: definition ? !definition.prohibited: false

            MouseArea
            {
                anchors.fill: parent
                onClicked: definitionsModel.setVisible(definition.key, !check.checked)
            }
        }
    }

    QD.SettingPropertyProvider
    {
        id: provider

        containerStackId: "global"
        watchedProperties: [ "enabled" ]
        key: definition ? definition.key : ""
    }

    QD.I18nCatalog { id: catalog; name: "qdtech" }
    SystemPalette { id: palette }
}
