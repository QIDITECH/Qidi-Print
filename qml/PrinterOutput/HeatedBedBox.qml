// Copyright (c) 2017 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    implicitWidth: parent.width
    height: visible ? QD.Theme.getSize("print_setup_extruder_box").height : 0
    property var printerModel
    property var connectedPrinter: QIDI.MachineManager.printerOutputDevices.length >= 1 ? QIDI.MachineManager.printerOutputDevices[0] : null

    Rectangle
    {
        color: QD.Theme.getColor("main_background")
        anchors.fill: parent

        Label //Build plate label.
        {
            text: catalog.i18nc("@label", "Build plate")
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("text")
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: QD.Theme.getSize("default_margin").width
        }

        Label //Target temperature.
        {
            id: bedTargetTemperature
            text: printerModel != null ? printerModel.targetBedTemperature + "°C" : ""
            font: QD.Theme.getFont("default_bold")
            color: QD.Theme.getColor("text_inactive")
            anchors.right: parent.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            anchors.bottom: bedCurrentTemperature.bottom

            MouseArea //For tooltip.
            {
                id: bedTargetTemperatureTooltipArea
                hoverEnabled: true
                anchors.fill: parent
                onHoveredChanged:
                {
                    if (containsMouse)
                    {
                        base.showTooltip(
                            base,
                            {x: 0, y: bedTargetTemperature.mapToItem(base, 0, -parent.height / 4).y},
                            catalog.i18nc("@tooltip", "The target temperature of the heated bed. The bed will heat up or cool down towards this temperature. If this is 0, the bed heating is turned off.")
                        );
                    }
                    else
                    {
                        base.hideTooltip();
                    }
                }
            }
        }
        Label //Current temperature.
        {
            id: bedCurrentTemperature
            text: printerModel != null ? printerModel.bedTemperature + "°C" : ""
            font: QD.Theme.getFont("large_bold")
            color: QD.Theme.getColor("text")
            anchors.right: bedTargetTemperature.left
            anchors.top: parent.top
            anchors.margins: QD.Theme.getSize("default_margin").width

            MouseArea //For tooltip.
            {
                id: bedTemperatureTooltipArea
                hoverEnabled: true
                anchors.fill: parent
                onHoveredChanged:
                {
                    if (containsMouse)
                    {
                        base.showTooltip(
                            base,
                            {x: 0, y: bedCurrentTemperature.mapToItem(base, 0, -parent.height / 4).y},
                            catalog.i18nc("@tooltip", "The current temperature of the heated bed.")
                        );
                    }
                    else
                    {
                        base.hideTooltip();
                    }
                }
            }
        }
        Rectangle //Input field for pre-heat temperature.
        {
            id: preheatTemperatureControl
            color: !enabled ? QD.Theme.getColor("setting_control_disabled") : showError ? QD.Theme.getColor("setting_validation_error_background") : QD.Theme.getColor("setting_validation_ok")
            property var showError:
            {
                if(bedTemperature.properties.maximum_value != "None" && bedTemperature.properties.maximum_value <  Math.floor(preheatTemperatureInput.text))
                {
                    return true;
                } else
                {
                    return false;
                }
            }
            enabled:
            {
                if (printerModel == null)
                {
                    return false; //Can't preheat if not connected.
                }
                if (connectedPrinter == null || !connectedPrinter.acceptsCommands)
                {
                    return false; //Not allowed to do anything.
                }
                if (connectedPrinter.activePrinter && connectedPrinter.activePrinter.activePrintJob)
                {
                    if((["printing", "pre_print", "resuming", "pausing", "paused", "error", "offline"]).indexOf(connectedPrinter.activePrinter.activePrintJob.state) != -1)
                    {
                        return false; //Printer is in a state where it can't react to pre-heating.
                    }
                }
                return true;
            }
            border.width: QD.Theme.getSize("default_lining").width
            border.color: !enabled ? QD.Theme.getColor("setting_control_disabled_border") : preheatTemperatureInputMouseArea.containsMouse ? QD.Theme.getColor("setting_control_border_highlight") : QD.Theme.getColor("setting_control_border")
            anchors.right: preheatButton.left
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: QD.Theme.getSize("default_margin").height
            width: QD.Theme.getSize("monitor_preheat_temperature_control").width
            height: QD.Theme.getSize("monitor_preheat_temperature_control").height
            visible: printerModel != null ? enabled && printerModel.canPreHeatBed && !printerModel.isPreheating : true
            Rectangle //Highlight of input field.
            {
                anchors.fill: parent
                anchors.margins: QD.Theme.getSize("default_lining").width
                color: QD.Theme.getColor("setting_control_highlight")
                opacity: preheatTemperatureControl.hovered ? 1.0 : 0
            }
            MouseArea //Change cursor on hovering.
            {
                id: preheatTemperatureInputMouseArea
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor

                onHoveredChanged:
                {
                    if (containsMouse)
                    {
                        base.showTooltip(
                            base,
                            {x: 0, y: preheatTemperatureInputMouseArea.mapToItem(base, 0, 0).y},
                            catalog.i18nc("@tooltip of temperature input", "The temperature to pre-heat the bed to.")
                        );
                    }
                    else
                    {
                        base.hideTooltip();
                    }
                }
            }
            Label
            {
                id: unit
                anchors.right: parent.right
                anchors.rightMargin: QD.Theme.getSize("setting_unit_margin").width
                anchors.verticalCenter: parent.verticalCenter

                text: "°C";
                color: QD.Theme.getColor("setting_unit")
                font: QD.Theme.getFont("default")
            }
            TextInput
            {
                id: preheatTemperatureInput
                font: QD.Theme.getFont("default")
                color: !enabled ? QD.Theme.getColor("setting_control_disabled_text") : QD.Theme.getColor("setting_control_text")
                selectByMouse: true
                maximumLength: 5
                enabled: parent.enabled
                validator: RegExpValidator { regExp: /^-?[0-9]{0,9}[.,]?[0-9]{0,10}$/ } //Floating point regex.
                anchors.left: parent.left
                anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
                anchors.right: unit.left
                anchors.verticalCenter: parent.verticalCenter
                renderType: Text.NativeRendering

                text:
                {
                    if (!bedTemperature.properties.value)
                    {
                        return "";
                    }
                    if ((bedTemperature.resolve != "None" && bedTemperature.resolve) && (bedTemperature.stackLevels[0] != 0) && (bedTemperature.stackLevels[0] != 1))
                    {
                        // We have a resolve function. Indicates that the setting is not settable per extruder and that
                        // we have to choose between the resolved value (default) and the global value
                        // (if user has explicitly set this).
                        return bedTemperature.resolve;
                    }
                    else
                    {
                        return bedTemperature.properties.value;
                    }
                }
            }
        }

        Button // The pre-heat button.
        {
            id: preheatButton
            height: QD.Theme.getSize("setting_control").height
            visible: printerModel != null ? printerModel.canPreHeatBed: true
            enabled:
            {
                if (!preheatTemperatureControl.enabled)
                {
                    return false; //Not connected, not authenticated or printer is busy.
                }
                if (printerModel.isPreheating)
                {
                    return true;
                }
                if (bedTemperature.properties.minimum_value != "None" && Math.floor(preheatTemperatureInput.text) < Math.floor(bedTemperature.properties.minimum_value))
                {
                    return false; //Target temperature too low.
                }
                if (bedTemperature.properties.maximum_value != "None" && Math.floor(preheatTemperatureInput.text) > Math.floor(bedTemperature.properties.maximum_value))
                {
                    return false; //Target temperature too high.
                }
                if (Math.floor(preheatTemperatureInput.text) == 0)
                {
                    return false; //Setting the temperature to 0 is not allowed (since that cancels the pre-heating).
                }
                return true; //Preconditions are met.
            }
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: QD.Theme.getSize("default_margin").width
            style: ButtonStyle {
                background: Rectangle
                {
                    border.width: QD.Theme.getSize("default_lining").width
                    implicitWidth: actualLabel.contentWidth + (QD.Theme.getSize("default_margin").width * 2)
                    border.color:
                    {
                        if(!control.enabled)
                        {
                            return QD.Theme.getColor("action_button_disabled_border");
                        }
                        else if(control.pressed)
                        {
                            return QD.Theme.getColor("action_button_active_border");
                        }
                        else if(control.hovered)
                        {
                            return QD.Theme.getColor("action_button_hovered_border");
                        }
                        else
                        {
                            return QD.Theme.getColor("action_button_border");
                        }
                    }
                    color:
                    {
                        if(!control.enabled)
                        {
                            return QD.Theme.getColor("action_button_disabled");
                        }
                        else if(control.pressed)
                        {
                            return QD.Theme.getColor("action_button_active");
                        }
                        else if(control.hovered)
                        {
                            return QD.Theme.getColor("action_button_hovered");
                        }
                        else
                        {
                            return QD.Theme.getColor("action_button");
                        }
                    }
                    Behavior on color
                    {
                        ColorAnimation
                        {
                            duration: 50
                        }
                    }

                    Label
                    {
                        id: actualLabel
                        anchors.centerIn: parent
                        color:
                        {
                            if(!control.enabled)
                            {
                                return QD.Theme.getColor("action_button_disabled_text");
                            }
                            else if(control.pressed)
                            {
                                return QD.Theme.getColor("action_button_active_text");
                            }
                            else if(control.hovered)
                            {
                                return QD.Theme.getColor("action_button_hovered_text");
                            }
                            else
                            {
                                return QD.Theme.getColor("action_button_text");
                            }
                        }
                        font: QD.Theme.getFont("medium")
                        text:
                        {
                            if(printerModel == null)
                            {
                                return ""
                            }
                            if(printerModel.isPreheating )
                            {
                                return catalog.i18nc("@button Cancel pre-heating", "Cancel")
                            } else
                            {
                                return catalog.i18nc("@button", "Pre-heat")
                            }
                        }
                    }
                }
            }

            onClicked:
            {
                if (!printerModel.isPreheating)
                {
                    printerModel.preheatBed(preheatTemperatureInput.text, 900);
                }
                else
                {
                    printerModel.cancelPreheatBed();
                }
            }

            onHoveredChanged:
            {
                if (hovered)
                {
                    base.showTooltip(
                        base,
                        {x: 0, y: preheatButton.mapToItem(base, 0, 0).y},
                        catalog.i18nc("@tooltip of pre-heat", "Heat the bed in advance before printing. You can continue adjusting your print while it is heating, and you won't have to wait for the bed to heat up when you're ready to print.")
                    );
                }
                else
                {
                    base.hideTooltip();
                }
            }
        }
    }
}