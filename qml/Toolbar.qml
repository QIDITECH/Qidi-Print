// Copyright (c) 2015 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura

Item
{
    id: base;

    width: buttons.width;
    height: buttons.height
    property int activeY

    Column
    {
        id: buttons;

        anchors.top: parent.top;
        anchors.left: parent.left;
        spacing: UM.Theme.getSize("button_lining").width

        Repeater
        {
            id: repeat

            model: UM.ToolModel { }
            width: childrenRect.width
            height: childrenRect.height
            Button
            {
                text: model.name
                iconSource: (UM.Theme.getIcon(model.icon) != "") ? UM.Theme.getIcon(model.icon) : "file:///" + model.location + "/" + model.icon
                checkable: true
                checked: model.active
                enabled: model.enabled && UM.Selection.hasSelection && UM.Controller.toolsEnabled
                style: UM.Theme.styles.tool_button

                onCheckedChanged: {
                    if (checked) {
                        base.activeY = y
                    }
                }

                //Workaround since using ToolButton"s onClicked would break the binding of the checked property, instead
                //just catch the click so we do not trigger that behaviour.
                MouseArea
                {
                    anchors.fill: parent;
                    onClicked:
                    {
                        forceActiveFocus() //First grab focus, so all the text fields are updated
                        if(parent.checked)
                        {
                            UM.Controller.setActiveTool(null)
                        }
                        else
                        {
                            UM.Controller.setActiveTool(model.id);
                        }
                    }
                }
            }
        }

        Item
        {
            height: UM.Theme.getSize("default_margin").height;
            width: UM.Theme.getSize("default_lining").width;
            visible: extruders.count > 0
            Rectangle
            {
                color: UM.Theme.getColor("color2")
                height: 1 * UM.Theme.getSize("default_margin").width/10
                width: 40 * UM.Theme.getSize("default_margin").width/10
                anchors.left: parent.left
                anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
                anchors.top: parent.top
                anchors.topMargin: 5 * UM.Theme.getSize("default_margin").width/10
            }
        }

        Repeater
        {
            id: extruders
            width: childrenRect.width
            height: childrenRect.height
            property var _model: Cura.ExtrudersModel { id: extrudersModel }
            model: _model.items.length > 1 ? _model : 0
            ExtruderButton { extruder: model }
        }

        Item
        {
            height: UM.Theme.getSize("default_margin").height;
            width: UM.Theme.getSize("default_lining").width;
            visible: Cura.MachineManager.activeMachineDefinitionName == "QIDI I" ? false : Cura.MachineManager.activeMachineDefinitionName == "X-one2" ? false : true
            Rectangle
            {
                color: UM.Theme.getColor("color2")
                height: 1 * UM.Theme.getSize("default_margin").width/10
                width: 40 * UM.Theme.getSize("default_margin").width/10
                anchors.left: parent.left
                anchors.leftMargin: 10 * UM.Theme.getSize("default_margin").width/10
                anchors.top: parent.top
                anchors.topMargin: 5 * UM.Theme.getSize("default_margin").width/10
            }
        }

        Button {

            id: wifiButton          //这个ID已经被别的地方引用，不要轻易地改动
            visible: Cura.MachineManager.activeMachineDefinitionName == "QIDI I" ? false : Cura.MachineManager.activeMachineDefinitionName == "X-one2" ? false : true
            onVisibleChanged: wifiPanel.visible = false
            iconSource: UM.Theme.getIcon("WIFI")
            style: UM.Theme.styles.tool_button
            text: catalog.i18nc("@action:label", "WIFI")
            onClicked: {
                if(wifiPanel.visible == false)
                {
                    wifiPanel.visible = true
                }
                else
                {
                    wifiPanel.visible = false
                }
            }
        }
    }

    Wifi {
        id: wifiPanel
        visible: false
        anchors {
            top: base.top
            topMargin:
            {
                if (extruders.count > 0)
                {
                    return 470 * UM.Theme.getSize("default_margin").width/10
                    /*if (base.height > 637 * UM.Theme.getSize("default_margin").width/10)
                    {
                        return 470 * UM.Theme.getSize("default_margin").width/10
                    }
                    else
                    {
                        return 435 * UM.Theme.getSize("default_margin").width/10
                    }*/
                }
                else
                {
                    return 360 * UM.Theme.getSize("default_margin").width/10
                    /*if (base.height > 537 * UM.Theme.getSize("default_margin").width/10)
                    {
                        return 360 * UM.Theme.getSize("default_margin").width/10
                    }
                    else
                    {
                        return 325 * UM.Theme.getSize("default_margin").width/10
                    }*/
                }
            }
            left: parent.right
            //bottom: wifiButton.bottom
            //leftMargin: UM.Theme.getSize("window_margin").height
        }
    }

    UM.PointingRectangle
    {
        id: panelBorder;

        anchors.left: parent.right;
        anchors.leftMargin: UM.Theme.getSize("default_margin").width;
        anchors.top: base.top;
        anchors.topMargin: base.activeY
        z: buttons.z -1

        target: Qt.point(parent.right,base.activeY + 5 * UM.Theme.getSize("default_margin").width/10 + Math.round(UM.Theme.getSize("button").height/2))
        arrowSize: UM.Theme.getSize("default_arrow").width

        width:
        {
            if (panel.item && panel.width > 0){
                 return Math.max(panel.width + 2 * UM.Theme.getSize("default_margin").width)
            }
            else {
                return 0
            }
        }
        height: panel.item ? panel.height + 2 * UM.Theme.getSize("default_margin").height : 0;

        opacity: panel.item && panel.width > 0 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }

        color: UM.Theme.getColor("color15")
        borderColor: UM.Theme.getColor("color2")
        borderWidth: UM.Theme.getSize("default_lining").width

        MouseArea //Catch all mouse events (so scene doesnt handle them)
        {
            anchors.fill: parent
        }

        Loader
        {
            id: panel

            x: UM.Theme.getSize("default_margin").width;
            y: UM.Theme.getSize("default_margin").height;

            source: UM.ActiveTool.valid ? UM.ActiveTool.activeToolPanel : "";
            enabled: UM.Controller.toolsEnabled;
        }
    }

    // This rectangle displays the information about the current angle etc. when
    // dragging a tool handle.
    Rectangle
    {
        x: -base.x + base.mouseX + UM.Theme.getSize("default_margin").width
        y: -base.y + base.mouseY + UM.Theme.getSize("default_margin").height

        width: toolHint.width + UM.Theme.getSize("default_margin").width
        height: toolHint.height;
        color: UM.Theme.getColor("tooltip")
        Label
        {
            id: toolHint
            text: UM.ActiveTool.properties.getValue("ToolHint") != undefined ? UM.ActiveTool.properties.getValue("ToolHint") : ""
            color: UM.Theme.getColor("tooltip_text")
            font: UM.Theme.getFont("default")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        visible: toolHint.text != "";
    }
}
