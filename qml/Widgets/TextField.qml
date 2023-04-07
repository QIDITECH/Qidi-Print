// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// QIDI-style TextField
//
TextField
{
    id: textField

    QD.I18nCatalog { id: catalog; name: "qidi" }

    property var borderRadius: ""
    hoverEnabled: true
    selectByMouse: true
    font: QD.Theme.getFont("default")
    color: QD.Theme.getColor("text")
    renderType: Text.NativeRendering

    states: [
        State
        {
            name: "disabled"
            when: !textField.enabled
            PropertyChanges { target: backgroundRectangle.border; color: QD.Theme.getColor("setting_control_disabled_border")}
            PropertyChanges { target: backgroundRectangle; color: QD.Theme.getColor("setting_control_disabled")}
        },
        State
        {
            name: "invalid"
            when: !textField.acceptableInput
            PropertyChanges { target: backgroundRectangle.border; color: QD.Theme.getColor("setting_validation_error")}
            PropertyChanges { target: backgroundRectangle; color: QD.Theme.getColor("setting_validation_error_background")}
        },
        State
        {
            name: "hovered"
            when: textField.hovered || textField.activeFocus
            PropertyChanges { target: backgroundRectangle.border; color: QD.Theme.getColor("setting_control_border_highlight") }
        }
    ]

    background: Rectangle
    {
        id: backgroundRectangle

        color: QD.Theme.getColor("main_background")

        anchors.margins: Math.round(QD.Theme.getSize("default_lining").width)
        radius: borderRadius == "" ? QD.Theme.getSize("setting_control_radius").width : borderRadius

        border.color:
        {
            if (!textField.enabled)
            {
                return QD.Theme.getColor("setting_control_disabled_border")
            }
            if (textField.hovered || textField.activeFocus)
            {
                return QD.Theme.getColor("setting_control_border_highlight")
            }
            return QD.Theme.getColor("setting_control_border")
        }
    }
}
