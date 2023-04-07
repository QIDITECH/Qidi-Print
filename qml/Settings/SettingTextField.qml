// Copyright (c) 2017 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.1 as QD

SettingItem
{
    id: base
    property var focusItem: input

    property string textBeforeEdit
    property bool textHasChanged
    property bool focusGainedByClick: false
    onFocusReceived:
    {
        textHasChanged = false;
        textBeforeEdit = focusItem.text;

        if(!focusGainedByClick)
        {
            // select all text when tabbing through fields (but not when selecting a field with the mouse)
            focusItem.selectAll();
        }
    }

    contents: Rectangle
    {
        id: control

        anchors.fill: parent

        radius: QD.Theme.getSize("setting_control_radius").width
        border.width: QD.Theme.getSize("default_lining").width
        border.color:
        {
            if(!enabled)
            {
                return QD.Theme.getColor("setting_control_disabled_border")
            }
            switch(propertyProvider.properties.validationState)
            {
                case "ValidatorState.Invalid":
                case "ValidatorState.Exception":
                case "ValidatorState.MinimumError":
                case "ValidatorState.MaximumError":
                    return QD.Theme.getColor("setting_validation_error");
                case "ValidatorState.MinimumWarning":
                case "ValidatorState.MaximumWarning":
                    return QD.Theme.getColor("setting_validation_warning");
            }
            //Validation is OK.
            if(hovered || input.activeFocus)
            {
                return QD.Theme.getColor("setting_control_border_highlight")
            }
            return QD.Theme.getColor("setting_control_border")
        }

        color: {
            if(!enabled)
            {
                return QD.Theme.getColor("setting_control_disabled")
            }
            switch(propertyProvider.properties.validationState)
            {
                case "ValidatorState.Invalid":
                case "ValidatorState.Exception":
                case "ValidatorState.MinimumError":
                case "ValidatorState.MaximumError":
                    return QD.Theme.getColor("setting_validation_error_background")
                case "ValidatorState.MinimumWarning":
                case "ValidatorState.MaximumWarning":
                    return QD.Theme.getColor("setting_validation_warning_background")
                case "ValidatorState.Valid":
                    return QD.Theme.getColor("setting_validation_ok")

                default:
                    return QD.Theme.getColor("setting_control")
            }
        }

        Rectangle
        {
            anchors.fill: parent
            anchors.margins: Math.round(QD.Theme.getSize("default_lining").width)
            color: QD.Theme.getColor("setting_control_highlight")
            opacity: !control.hovered ? 0 : propertyProvider.properties.validationState == "ValidatorState.Valid" ? 1.0 : 0.35
        }

        Label
        {
            anchors
            {
                left: parent.left
                leftMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                right: parent.right
                rightMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                verticalCenter: parent.verticalCenter
            }

            text: definition.unit
            //However the setting value is aligned, align the unit opposite. That way it stays readable with right-to-left languages.
            horizontalAlignment: (input.effectiveHorizontalAlignment == Text.AlignLeft) ? Text.AlignRight : Text.AlignLeft
            textFormat: Text.PlainText
            renderType: Text.NativeRendering
            color: QD.Theme.getColor("setting_unit")
            font: QD.Theme.getFont("default")
        }

        TextInput
        {
            id: input

            anchors
            {
                left: parent.left
                leftMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                right: parent.right
                rightMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                verticalCenter: parent.verticalCenter
            }
            renderType: Text.NativeRendering

            Keys.onTabPressed:
            {
                base.setActiveFocusToNextSetting(true)
            }
            Keys.onBacktabPressed:
            {
                base.setActiveFocusToNextSetting(false)
            }

            Keys.onReleased:
            {
                if (text != textBeforeEdit)
                {
                    textHasChanged = true;
                }
                if (textHasChanged)
                {
                    propertyProvider.setPropertyValue("value", text)
                }
            }

            onActiveFocusChanged:
            {
                if(activeFocus)
                {
                    base.focusReceived();
                }
                base.focusGainedByClick = false;
            }

            color: !enabled ? QD.Theme.getColor("setting_control_disabled_text") : QD.Theme.getColor("setting_control_text")
            font: QD.Theme.getFont("default")

            selectByMouse: true

            maximumLength: (definition.type == "str" || definition.type == "[int]") ? -1 : 10

            // Since [int] & str don't have a max length, they need to be clipped (since clipping is expensive, this
            // should be done as little as possible)
            clip: definition.type == "str" || definition.type == "[int]"

            validator: RegExpValidator { regExp: (definition.type == "[int]") ? /^\[?(\s*-?[0-9]{0,9}\s*,)*(\s*-?[0-9]{0,9})\s*\]?$/ : (definition.type == "int") ? /^-?[0-9]{0,10}$/ : (definition.type == "float") ? /^-?[0-9]{0,9}[.,]?[0-9]{0,3}$/ : /^.*$/ } // definition.type property from parent loader used to disallow fractional number entry

            Binding
            {
                target: input
                property: "text"
                value:
                {
                    // Stacklevels
                    // 0: user  -> unsaved change
                    // 1: quality changes  -> saved change
                    // 2: quality
                    // 3: material  -> user changed material in materialspage
                    // 4: variant
                    // 5: machine_changes
                    // 6: machine
                    if ((base.resolve != "None" && base.resolve) && (stackLevel != 0) && (stackLevel != 1))
                    {
                        // We have a resolve function. Indicates that the setting is not settable per extruder and that
                        // we have to choose between the resolved value (default) and the global value
                        // (if user has explicitly set this).
                        return base.resolve
                    }
                    else {
                        return propertyProvider.properties.value
                    }
                }
                when: !input.activeFocus
            }

            MouseArea
            {
                id: mouseArea
                anchors.fill: parent

                cursorShape: Qt.IBeamCursor

                onPressed: {
                    if (!input.activeFocus)
                    {
                        base.focusGainedByClick = true
                        input.forceActiveFocus()
                    }
                    mouse.accepted = false
                }
            }
        }
    }
}
