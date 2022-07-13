// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura

Button
{
    id: base

    property var extruder;

    text:
    {
        if (Cura.MachineManager.activeMachineDefinitionName == "QIDI I" || Cura.MachineManager.activeMachineDefinitionName == "X-pro")
        {
            if (model.name == "Extruder 1")
            {
                return catalog.i18ncp("@label %1 is filled in with the name of an extruder", "Print Selected Model with %1", "Print Selected Models with %1", UM.Selection.selectionCount).arg("Extruder R")
            }
            else if (model.name == "Extruder 2")
            {
                return catalog.i18ncp("@label %1 is filled in with the name of an extruder", "Print Selected Model with %1", "Print Selected Models with %1", UM.Selection.selectionCount).arg("Extruder L")
            }
        }
        else
        {
            return catalog.i18ncp("@label %1 is filled in with the name of an extruder", "Print Selected Model with %1", "Print Selected Models with %1", UM.Selection.selectionCount).arg(extruder.name)
        }
    }
    style: UM.Theme.styles.tool_button

    iconSource: UM.Theme.getIcon("extruder_button")

    checkable: true
    checked: Cura.ExtruderManager.selectedObjectExtruders.indexOf(extruder.id) != -1
    enabled: UM.Selection.hasSelection && extruder.stack.isEnabled

    MouseArea
    {
        anchors.fill: parent;
        onClicked:
        {
            forceActiveFocus() //First grab focus, so all the text fields are updated
            CuraActions.setExtruderForSelection(extruder.id);
        }
    }

//    property color customColor: base.checked ? UM.Theme.getColor("color5") : (base.hovered ? UM.Theme.getColor("color6") : UM.Theme.getColor("color1"));

    /*Rectangle
    {
        anchors.fill: parent
        anchors.margins: UM.Theme.getSize("default_lining").width;

        color: "transparent"

        border.width: base.checked ? UM.Theme.getSize("default_lining").width : 0;
        border.color: UM.Theme.getColor("button_text")
    }*/

    Item
    {
        anchors.centerIn: parent
        width: UM.Theme.getSize("default_margin").width
        height: UM.Theme.getSize("default_margin").height

        Label
        {
            text:
            {
                if (Cura.MachineManager.activeMachineDefinitionName == "QIDI I" || Cura.MachineManager.activeMachineDefinitionName == "X-pro")
                {
                    if (index == 0)
                    {
                        return "R"
                    }
                    else
                    {
                        return "L"
                    }
                }
                else
                {
                    return index + 1
                }
            }
            anchors
            {
                top: parent.top
                topMargin: -10 * UM.Theme.getSize("default_margin").width/10
                left: parent.left
                leftMargin: text == "R" ? 0 : 1 * UM.Theme.getSize("default_margin").width/10
            }
            //property color customColor: base.checked ? UM.Theme.getColor("color7") : (base.hovered ? UM.Theme.getColor("color7") : UM.Theme.getColor("color8"));
            color:
            {
                if(enabled)
                {
                    if(checkable && checked && hovered)
                    {
                        return UM.Theme.getColor("color7");
                    }
                    else if(pressed || (checkable && checked))
                    {
                        return UM.Theme.getColor("color7");
                    }
                    else if(hovered)
                    {
                        return UM.Theme.getColor("color7");
                    }
                    else
                    {
                        return UM.Theme.getColor("color8");
                    }
                }
                else
                {
                    return UM.Theme.getColor("color9");
                }
            }
            font: UM.Theme.getFont("font1");
        }
    }

    Rectangle
    {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 12 * UM.Theme.getSize("default_margin").width/10
        anchors.topMargin: 7 * UM.Theme.getSize("default_margin").width/10
        border.width: 3 * UM.Theme.getSize("default_margin").width/10
        border.color: index == 0 ? UM.Preferences.getValue("color/extruder1") : UM.Preferences.getValue("color/extruder2")
        width: 35 * UM.Theme.getSize("default_margin").width/10
        height: 35 * UM.Theme.getSize("default_margin").width/10

        color: UM.Theme.getColor("color21");
        radius: 3 * UM.Theme.getSize("default_margin").width/10

        opacity: !base.enabled ? 0.2 : 1.0
    }

    // Material colour circle
    // Only draw the filling colour of the material inside the SVG border.
/*    Rectangle
    {
        anchors
        {
            right: parent.right
            top: parent.top
            rightMargin: UM.Theme.getSize("extruder_button_material_margin").width
            topMargin: UM.Theme.getSize("extruder_button_material_margin").height
        }

        color: model.color

        width: UM.Theme.getSize("extruder_button_material").width
        height: UM.Theme.getSize("extruder_button_material").height
        radius: Math.round(width / 2)

        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("extruder_button_material_border")

        opacity: !base.enabled ? 0.2 : 1.0
    }*/

/*    onClicked:
    {
        forceActiveFocus() //First grab focus, so all the text fields are updated
        CuraActions.setExtruderForSelection(extruder.id);
    }*/
}
