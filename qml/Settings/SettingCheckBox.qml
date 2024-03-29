// Copyright (c) 2018 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import QD 1.2 as QD

SettingItem
{
    id: base
    property var focusItem: control

    contents: MouseArea
    {
        id: control
        anchors.fill: parent
        hoverEnabled: true

        property bool checked:
        {
            // FIXME this needs to go away once 'resolve' is combined with 'value' in our data model.
            // Stacklevels
            // 0: user  -> unsaved change
            // 1: quality changes  -> saved change
            // 2: quality
            // 3: material  -> user changed material in materials page
            // 4: variant
            // 5: machine
            var value
            if ((base.resolve !== undefined && base.resolve != "None") && (stackLevel != 0) && (stackLevel != 1))
            {
                // We have a resolve function. Indicates that the setting is not settable per extruder and that
                // we have to choose between the resolved value (default) and the global value
                // (if user has explicitly set this).
                value = base.resolve
            }
            else
            {
                value = propertyProvider.properties.value
            }

            switch(value)
            {
                case "True":
                    return true
                case "False":
                    return false
                default:
                    return (value !== undefined) ? value : false
            }
        }

        Keys.onSpacePressed:
        {
            forceActiveFocus()
            propertyProvider.setPropertyValue("value", !checked)
        }

        onClicked:
        {
            forceActiveFocus()
            propertyProvider.setPropertyValue("value", !checked)
        }

        Keys.onTabPressed:
        {
            base.setActiveFocusToNextSetting(true)
        }
        Keys.onBacktabPressed:
        {
            base.setActiveFocusToNextSetting(false)
        }

        onActiveFocusChanged:
        {
            if (activeFocus)
            {
                base.focusReceived()
            }
        }

        Rectangle
        {
            anchors
            {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: height

            radius: QD.Theme.getSize("setting_control_radius").width
            border.width: QD.Theme.getSize("default_lining").width

            border.color:
            {
                if(!enabled)
                {
                    return QD.Theme.getColor("setting_control_disabled_border")
                }
                switch (propertyProvider.properties.validationState)
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
                // Validation is OK.
                if (control.containsMouse || control.activeFocus || hovered)
                {
                    return QD.Theme.getColor("setting_control_border_highlight")
                }
                return QD.Theme.getColor("setting_control_border")
            }

            color: {
                if (!enabled)
                {
                    return QD.Theme.getColor("setting_control_disabled")
                }
                switch (propertyProvider.properties.validationState)
                {
                    case "ValidatorState.Invalid":
                    case "ValidatorState.Exception":
                    case "ValidatorState.MinimumError":
                    case "ValidatorState.MaximumError":
                        return QD.Theme.getColor("setting_validation_error_background")
                    case "ValidatorState.MinimumWarning":
                    case "ValidatorState.MaximumWarning":
                        return QD.Theme.getColor("setting_validation_warning_background")
                }
                // Validation is OK.
                if (control.containsMouse || control.activeFocus)
                {
                    return QD.Theme.getColor("setting_control_highlight")
                }
                return QD.Theme.getColor("setting_control")
            }

            QD.RecolorImage
            {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.round(parent.width / 2.5)
                height: Math.round(parent.height / 2.5)
                sourceSize.height: width
                color: !enabled ? QD.Theme.getColor("setting_control_disabled_text") : QD.Theme.getColor("setting_control_text");
                source: QD.Theme.getIcon("Check")
                opacity: control.checked ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 100; } }
            }
        }
    }
}
