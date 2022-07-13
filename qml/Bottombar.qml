// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.4 as UM
import Cura 1.0 as Cura
import "Menus"

Rectangle
{
    id: base
    anchors.left: parent.left
    anchors.right: parent.right
    height: 30 * UM.Theme.getSize("default_margin").width/10
    color: UM.Controller.activeStage.stageId == "MonitorStage" ? UM.Theme.getColor("topbar_background_color_monitoring") : UM.Theme.getColor("topbar_background_color")

    property bool printerConnected: Cura.MachineManager.printerConnected
    property bool printerAcceptsCommands: printerConnected && Cura.MachineManager.printerOutputDevices[0].acceptsCommands

    property int rightMargin: UM.Theme.getSize("sidebar").width + UM.Theme.getSize("default_margin").width;
    property int allItemsWidth: 0;

    function updateMarginsAndSizes() {
        if (UM.Preferences.getValue("cura/sidebar_collapsed"))
        {
            rightMargin = UM.Theme.getSize("default_margin").width;
        }
        else
        {
            rightMargin = UM.Theme.getSize("sidebar").width + UM.Theme.getSize("default_margin").width;
        }
        allItemsWidth = (UM.Theme.getSize("topbar_logo_right_margin").width + UM.Theme.getSize("topbar_logo_right_margin").width + UM.Theme.getSize("default_margin").width + viewModeButton.width + rightMargin)
    }

    UM.I18nCatalog
    {
        id: catalog
        name:"cura"
    }

    // View orientation Item
    Row
    {
        id: viewOrientationControl
        height: 30 * UM.Theme.getSize("default_margin").width/10

        spacing: 18 * UM.Theme.getSize("default_margin").width/10
        visible: UM.Controller.activeStage.stageId != "MonitorStage"

        anchors
        {
            verticalCenter: base.verticalCenter
            right: viewModeRow.left
            rightMargin: 25 * UM.Theme.getSize("default_margin").width/10
        }

        // #1 3d view
        Button
        {
            iconSource: UM.Theme.getIcon("view_3d")
            style: UM.Theme.styles.small_tool_button
            anchors.verticalCenter: viewOrientationControl.verticalCenter
            onClicked:UM.Controller.rotateView("3d", 0)
            visible: base.width - allItemsWidth - 4 * this.width > 0
        }

        // #2 Front view
        Button
        {
            iconSource: UM.Theme.getIcon("view_front")
            style: UM.Theme.styles.small_tool_button
            anchors.verticalCenter: viewOrientationControl.verticalCenter
            onClicked: UM.Controller.rotateView("home", 0);
            visible: base.width - allItemsWidth - 3 * this.width > 0
        }

        // #3 Top view
        Button
        {
            iconSource: UM.Theme.getIcon("view_top")
            style: UM.Theme.styles.small_tool_button
            anchors.verticalCenter: viewOrientationControl.verticalCenter
            onClicked: UM.Controller.rotateView("y", 90)
            visible: base.width - allItemsWidth - 2 * this.width > 0
        }

        // #4 Left view
        Button
        {
            iconSource: UM.Theme.getIcon("view_left")
            style: UM.Theme.styles.small_tool_button
            anchors.verticalCenter: viewOrientationControl.verticalCenter
            onClicked: UM.Controller.rotateView("x", 90)
            visible: base.width - allItemsWidth - 1 * this.width > 0
        }

        // #5 Right view
        Button
        {
            iconSource: UM.Theme.getIcon("view_right")
            style: UM.Theme.styles.small_tool_button
            anchors.verticalCenter: viewOrientationControl.verticalCenter
            onClicked: UM.Controller.rotateView("x", -90)
            visible: base.width - allItemsWidth > 0
        }
    }

    Rectangle
    {
        id:viewModeSeparator
        anchors.right: viewModeRow.left
        anchors.rightMargin: 12 * UM.Theme.getSize("default_margin").width/10
        anchors.verticalCenter: viewOrientationControl.verticalCenter
        height:22 * UM.Theme.getSize("default_margin").width/10
        width: 1 * UM.Theme.getSize("default_margin").width/10
        color: UM.Theme.getColor("color2")
    }

    Row
    {
        id: viewModeRow;

        anchors.verticalCenter: viewOrientationControl.verticalCenter
        anchors.right: parent.right;
        anchors.rightMargin: 28 * UM.Theme.getSize("default_margin").width/10
        spacing: 18 * UM.Theme.getSize("default_margin").width/10

        Repeater
        {
            id: viewModeButton

            model: UM.ViewModel { }
            width: childrenRect.width
            height: childrenRect.height
            Button
            {
                text: model.id == 'SolidView' ? catalog.i18nc("@action:button","Solid") : (model.id == 'XRayView' ? catalog.i18nc("@action:button","X-Ray") : catalog.i18nc("@action:button","Layer"))//model.name
                iconSource: model.id == 'SolidView' ? UM.Theme.getIcon("view_normal") : (model.id == 'XRayView' ? UM.Theme.getIcon("view_xray") : UM.Theme.getIcon("view_layer"))
                checkable: true
                checked: model.active
                style: UM.Theme.styles.small_tool_button
                MouseArea
                {
                    anchors.fill: parent
                    onClicked:
                    {
                        forceActiveFocus() //First grab focus, so all the text fields are updated
                        if(parent.checked)
                        {
                            UM.Controller.setActiveView(null)
                        }
                        else
                        {
                            UM.Controller.setActiveView(model.id)
                        }
                    }
                }
            }
        }
    }

    Loader
    {
        id: view_panel

        anchors.bottom: parent.top
        anchors.bottomMargin: UM.Theme.getSize("default_margin").height + 12 * UM.Theme.getSize("default_margin").width/10
        anchors.right: parent.right
        anchors.rightMargin: UM.Theme.getSize("default_margin").height

        property var buttonTarget: Qt.point(viewModeButton.x + Math.round(viewModeButton.width / 2), viewModeButton.y + Math.round(viewModeButton.height / 2))

        height: childrenRect.height
        width: childrenRect.width

        source: UM.ActiveView.valid ? UM.ActiveView.activeViewPanel : "";
    }

    JobSpecs
    {
        id: jobSpecs
        anchors
        {
            bottom: parent.bottom;
            left: parent.left;
//            bottomMargin: UM.Theme.getSize("default_margin").height;
//            rightMargin: UM.Theme.getSize("default_margin").width;
        }
        z:1
    }

    // Expand or collapse sidebar
    Connections
    {
        target: Cura.Actions.expandSidebar
        onTriggered: updateMarginsAndSizes()
    }

    Component.onCompleted:
    {
        updateMarginsAndSizes();
    }

}
