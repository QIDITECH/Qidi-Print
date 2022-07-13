// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

import UM 1.3 as UM
import Cura 1.0 as Cura

Item
{
    id: objectsList
    width: 180 * UM.Theme.getSize("default_margin").width/10
    height: opened ? openCloseButton.height + objectsListScrollView.height + 8 * UM.Theme.getSize("default_margin").width/10 : openCloseButton.height

    property bool opened: UM.Preferences.getValue("view/show_list_of_objects")

    // Eat up all the mouse events (we don't want the scene to react or have the scene context menu showing up)
    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Rectangle
    {
        id: objectsListBackground
        color: UM.Theme.getColor("color15")
        border.width: UM.Theme.getSize("default_lining").width
        border.color: UM.Theme.getColor("color2")
        radius: 10 * UM.Theme.getSize("default_margin").width/10
        anchors.fill: parent
    }

    Button
    {
        id: openCloseButton
        width: parent.width - 20 * UM.Theme.getSize("default_margin").width/10
        height: 30 * UM.Theme.getSize("default_margin").width/10
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        style: ButtonStyle
        {
            background: Rectangle {
                id: openCloseButtonBackground
                anchors.fill: parent
                color: UM.Theme.getColor("color21")

                UM.RecolorImage
                {
                    id: openCloseIcon
                    width: 10 * UM.Theme.getSize("default_margin").width/10
                    height: 10 * UM.Theme.getSize("default_margin").width/10
                    anchors.right: parent.right
                    anchors.rightMargin: UM.Theme.getSize("default_margin").width
                    anchors.verticalCenter: parent.verticalCenter
                    color: openCloseButton.hovered ? UM.Theme.getColor("color5") : UM.Theme.getColor("color4")
                    source: objectsList.opened ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_top")
                }
                Label
                {
                    id: label
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: catalog.i18nc("@label", "Object list")
                    font: UM.Theme.getFont("font1")
                    color: UM.Theme.getColor("color4")
                    renderType: Text.NativeRendering
                    elide: Text.ElideMiddle
                }
            }
        }

        onClicked:
        {
            UM.Preferences.setValue("view/show_list_of_objects", !objectsList.opened)
            objectsList.opened = UM.Preferences.getValue("view/show_list_of_objects")
        }
    }

    Rectangle
    {
        id:listViewRectangle
        anchors.horizontalCenter: objectsListScrollView.horizontalCenter
        anchors.verticalCenter: objectsListScrollView.verticalCenter
        width: objectsListScrollView.width + 2 * UM.Theme.getSize("default_margin").width/10
        height: objectsListScrollView.height + 2 * UM.Theme.getSize("default_margin").width/10
        color: UM.Theme.getColor("color21")
        border.width: UM.Theme.getSize("default_margin").width/10
        border.color: UM.Theme.getColor("color2")
        radius: 3 * UM.Theme.getSize("default_margin").width/10
        visible: objectsList.opened
    }

    ScrollView
    {
        id: objectsListScrollView
        frameVisible: false
        visible: objectsList.opened
        height: visible ? Math.min(listView.contentHeight, 150 * UM.Theme.getSize("default_margin").width/10) : 0
        width: parent.width - 20 * UM.Theme.getSize("default_margin").width/10
        anchors.top: openCloseButton.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        style: UM.Theme.styles.scrollview

        ListView
        {
            id: listView
            model: Cura.ObjectsModel
            width: parent.width
            clip: true
            delegate: Rectangle
            {
                id: contents
                height: 25 * UM.Theme.getSize("default_margin").width/10
                width: parent.width
                border.width: UM.Theme.getSize("default_margin").width/10
                border.color: Cura.ObjectsModel.getItem(index).isSelected ? UM.Theme.getColor("color12"): color
                radius: 3 * UM.Theme.getSize("default_margin").width/10
                color: index % 2 ? UM.Theme.getColor("color23") : UM.Theme.getColor("color22")
                Behavior on height { NumberAnimation { duration: 100 } }
                Label
                {
                    id: nodeNameLabel
                    anchors.left: parent.left
                    anchors.leftMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    anchors.right: colorRectangle.left
                    anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    anchors.verticalCenter: parent.verticalCenter
                    font: UM.Theme.getFont("font1")
                    color: UM.Theme.getColor("color4")
                    text: (index >= 0) && Cura.ObjectsModel.getItem(index) ? Cura.ObjectsModel.getItem(index).name + updatefilename(index) : ""
                    renderType: Text.NativeRendering
                    elide: Text.ElideMiddle
                    function updatefilename(index){
                        var result= ""
                        var count = 0
                        if(index === 0){
                            result= ""
                        }
                        else{
                            for(var i = 0;i < index ; i++){
                                if(Cura.ObjectsModel.getItem(index).name === Cura.ObjectsModel.getItem(i).name){
                                    count = count + 1
                                    result = "(" + count + ")"
                                }
                                else{
                                    result = ""
                                    count = 0
                                }
                            }
                        }
                       return result
                    }
                }

                UM.SettingPropertyProvider
                {
                    id: machineExtruderCount

                    containerStackId: Cura.MachineManager.activeMachineId
                    key: "machine_extruder_count"
                    watchedProperties: [ "value" ]
                    storeIndex: 0
                }

                Rectangle{
                    id: colorRectangle
                    anchors.right: nodeExtruderLabel.left
                    anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 10 * UM.Theme.getSize("default_margin").width/10
                    height: 10 * UM.Theme.getSize("default_margin").width/10
                    visible: machineExtruderCount.properties.value == "2"
                    color: UM.Preferences.getValue("color/extruder" + (Cura.ObjectsModel.getItem(index).extruder_number + 1))
                    radius: 2 * UM.Theme.getSize("default_margin").width/10
                }

                Label
                {
                    id: nodeExtruderLabel
                    anchors.right: parent.right
                    anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    anchors.verticalCenter: parent.verticalCenter
                    font: UM.Theme.getFont("font1")
                    renderType: Text.NativeRendering
                    visible: colorRectangle.visible
                    text: Cura.MachineManager.getExtruder(Cura.ObjectsModel.getItem(index).extruder_number).name.replace("Extruder ", "")
                }

                MouseArea
                {
                    anchors.fill: parent;
                    onClicked:
                    {
                        Cura.SceneController.changeSelection(index);
                    }
                }
            }
        }
    }
}
