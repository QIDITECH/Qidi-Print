// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura
import "Menus"

ToolButton
{
    id: base
    property bool isNetworkPrinter: Cura.MachineManager.activeMachineNetworkKey != ""
    property bool printerConnected: Cura.MachineManager.printerConnected
    property var printerStatus: Cura.MachineManager.printerConnected ? "connected" : "disconnected"
    text: isNetworkPrinter ? Cura.MachineManager.activeMachineNetworkGroupName : Cura.MachineManager.activeMachineName

//    tooltip: Cura.MachineManager.activeMachineName

    style: ButtonStyle
    {
        background: Rectangle
        {
            gradient: Gradient
            {
                GradientStop
                {
                    position: 0.0;
                    color: //UM.Theme.getColor("color10")
                    {
                        if (control.pressed)
                        {
                            return UM.Theme.getColor("color5");
                        }
                        else if (control.hovered)
                        {
                            return UM.Theme.getColor("color6");
                        }
                        else
                        {
                            return UM.Theme.getColor("color10");
                        }
                    }
                }
                GradientStop
                {
                    position: 1.0;
                    color: //UM.Theme.getColor("color9")
                    {
                        if (control.pressed)
                        {
                            return UM.Theme.getColor("color5");
                        }
                        else if (control.hovered)
                        {
                            return UM.Theme.getColor("color6");
                        }
                        else {
                            return UM.Theme.getColor("color9");
                        }
                    }
                }
            }
            Behavior on color { ColorAnimation { duration: 50; } }
/*
            UM.RecolorImage
            {
                id: downArrow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: UM.Theme.getSize("default_margin").width
                width: UM.Theme.getSize("standard_arrow").width
                height: UM.Theme.getSize("standard_arrow").height
                sourceSize.width: width
                sourceSize.height: width
                color: UM.Theme.getColor("color4")
                source: UM.Theme.getIcon("arrow_bottom")
            }
*/
/*            PrinterStatusIcon
            {
                id: printerStatusIcon
                visible: printerConnected || isNetworkPrinter
                status: printerStatus
                anchors
                {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: UM.Theme.getSize("sidebar_margin").width
                }
            }
*/
            Label
            {
                id: sidebarComboBoxLabel
                color: //UM.Theme.getColor("color4")
                {
                    if (control.pressed)
                    {
                        return UM.Theme.getColor("color7");
                    }
                    else if (control.hovered)
                    {
                        return UM.Theme.getColor("color7");
                    }
                    else {
                        return UM.Theme.getColor("color4");
                    }
                }
                text: control.text.replace("I-", "i-").replace("_", " ")
                elide: Text.ElideRight;
                anchors.left: parent.left;
                anchors.leftMargin: UM.Theme.getSize("sidebar_margin").width
//                anchors.right: parent.right;
//                anchors.rightMargin: control.rightMargin;
//                width: 600
                anchors.verticalCenter: parent.verticalCenter;
                font: UM.Theme.getFont("font6")
            }
            Image {
                id: image
                anchors.right: parent.right
                anchors.rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
                anchors.verticalCenter: parent.verticalCenter
                //fillMode: Image.PreserveAspectFit
                height: 50 * UM.Theme.getSize("default_margin").width/10
                width: 50 * UM.Theme.getSize("default_margin").width/10
                source: UM.Theme.getIcon(Cura.MachineManager.activeMachineDefinitionName + "1")
            }
        }
        label: Label {}
    }

    menu: PrinterMenu { }
}
