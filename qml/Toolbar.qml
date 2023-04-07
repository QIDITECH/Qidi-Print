// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI
import QtGraphicalEffects 1.0 // For the dropshadow

Rectangle
{
    id: base

    width: buttons.width
    color: QD.Theme.getColor("white_1")
    property int activeY

    Item
    {
        id: buttons
        width: parent.visible ? toolButtons.width : 0
        height: childrenRect.height

        Behavior on width { NumberAnimation { duration: 100 } }

        Column
        {
            id: toolButtons

            anchors.top: parent.top
            anchors.left: parent.left
            spacing: QD.Theme.getSize("size").height

            Repeater
            {
                id: repeat

                model: QD.ToolModel { id: toolsModel }
                width: parent.width
                height: width

                delegate: ToolbarButton
                {
                    text: model.name + (model.shortcut ? (" (" + model.shortcut + ")") : "")
                    checkable: true
                    checked: model.active
                    enabled: model.enabled && QD.Selection.hasSelection && QD.Controller.toolsEnabled

                    isTopElement: toolsModel.getItem(0).id == model.id
                    isBottomElement: toolsModel.getItem(toolsModel.count - 1).id == model.id

                    toolItem: QD.RecolorImage
                    {
                        source: QD.Theme.getIcon(model.icon) != "" ? QD.Theme.getIcon(model.icon) : "file:///" + model.location + "/" + model.icon
                        color: QD.Theme.getColor("blue_6")
                        width: hovered ? 32 * QD.Theme.getSize("size").height : 30 * QD.Theme.getSize("size").height
                        height: hovered ? 32 * QD.Theme.getSize("size").height : 30 * QD.Theme.getSize("size").height
                    }

                    onCheckedChanged:
                    {
                        if (checked)
                        {
                            base.activeY = y;
                        }
                        //Clear focus when tools change. This prevents the tool grabbing focus when activated.
                        //Grabbing focus prevents items from being deleted.
                        //Apparently this was only a problem on MacOS.
                        forceActiveFocus();
                    }

                    //Workaround since using ToolButton's onClicked would break the binding of the checked property, instead
                    //just catch the click so we do not trigger that behaviour.
                    MouseArea
                    {
                        anchors.fill: parent;
                        onClicked:
                        {
                            forceActiveFocus() //First grab focus, so all the text fields are updated
                            if(parent.checked)
                            {
                                QD.Controller.setActiveTool(null);
                            }
                            else
                            {
                                QD.Controller.setActiveTool(model.id);
                            }

                            base.state = (index < toolsModel.count/2) ? "anchorAtTop" : "anchorAtBottom";
                        }
                    }
                }
            }
        }

        Rectangle
        {
            anchors.top: toolButtons.bottom
            anchors.horizontalCenter: toolButtons.horizontalCenter
            width: parent.width - 20 * QD.Theme.getSize("size").width
            height: QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_3")
            visible: extrudersModel.items.length > 1
        }

        Column
        {
            id: extruderButtons
            anchors.top: toolButtons.bottom
            anchors.topMargin: 2 * QD.Theme.getSize("size").width
            anchors.left: parent.left
            spacing: QD.Theme.getSize("default_lining").height

            Repeater
            {
                width: childrenRect.width
                height: childrenRect.height
                model: extrudersModel.items.length > 1 ? extrudersModel : 0

                delegate: ExtruderButton
                {
                    extruder: model
                    isTopElement: extrudersModel.getItem(0).id == model.id
                    isBottomElement: extrudersModel.getItem(extrudersModel.rowCount() - 1).id == model.id
                }
            }
        }
    }

    property var extrudersModel: QIDIApplication.getExtrudersModel()

    QD.PointingRectangle
    {
        id: panelBorder

        anchors.left: parent.right
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        anchors.top: base.top
        anchors.topMargin: base.activeY
        z: buttons.z - 1

        target: Qt.point(parent.right, base.activeY +  Math.round(QD.Theme.getSize("button").height/2))
        arrowSize: QD.Theme.getSize("default_arrow").width

        width:
        {
            if (panel.item && panel.width > 0)
            {
                 return Math.max(panel.width + 2 * QD.Theme.getSize("default_margin").width)
            }
            else
            {
                return 0;
            }
        }
        height: panel.item ? panel.height + 2 * QD.Theme.getSize("default_margin").height : 0

        opacity: panel.item && panel.width > 0 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }

        color: QD.Theme.getColor("tool_panel_background")
        borderColor: QD.Theme.getColor("lining")
        borderWidth: QD.Theme.getSize("default_lining").width

        MouseArea //Catch all mouse events (so scene doesnt handle them)
        {
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            onWheel: wheel.accepted = true
        }

        Loader
        {
            id: panel

            x: QD.Theme.getSize("default_margin").width
            y: QD.Theme.getSize("default_margin").height

            source: QD.ActiveTool.valid ? QD.ActiveTool.activeToolPanel : ""
            enabled: QD.Controller.toolsEnabled
        }
    }

    // This rectangle displays the information about the current angle etc. when
    // dragging a tool handle.
    Rectangle
    {
        id: toolInfo
        x: visible ? -base.x + base.mouseX + QD.Theme.getSize("default_margin").width: 0
        y: visible ? -base.y + base.mouseY + QD.Theme.getSize("default_margin").height: 0

        width: toolHint.width + QD.Theme.getSize("default_margin").width
        height: toolHint.height;
        color: QD.Theme.getColor("tooltip")
        Label
        {
            id: toolHint
            text: QD.ActiveTool.properties.getValue("ToolHint") != undefined ? QD.ActiveTool.properties.getValue("ToolHint") : ""
            color: QD.Theme.getColor("tooltip_text")
            font: QD.Theme.getFont("default")
            anchors.horizontalCenter: parent.horizontalCenter
        }

        visible: toolHint.text != ""
    }

    states: [
        State {
            name: "anchorAtTop"

            AnchorChanges {
                target: panelBorder
                anchors.top: base.top
                anchors.bottom: undefined
            }
            PropertyChanges {
                target: panelBorder
                anchors.topMargin: base.activeY
            }
        },
        State {
            name: "anchorAtBottom"

            AnchorChanges {
                target: panelBorder
                anchors.top: undefined
                anchors.bottom: base.top
            }
            PropertyChanges {
                target: panelBorder
                anchors.bottomMargin: {
                    if (panelBorder.height > (base.activeY + QD.Theme.getSize("button").height)) {
                        // panel is tall, align the top of the panel with the top of the first tool button
                        return -panelBorder.height
                    }
                    // align the bottom of the panel with the bottom of the selected tool button
                    return -(base.activeY + QD.Theme.getSize("button").height)
                }
            }
        }
    ]
}
