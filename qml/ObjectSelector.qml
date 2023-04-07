// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    id: objectSelector
    width: QD.Theme.getSize("objects_menu_size").width*1.5
    property bool opened: QD.Preferences.getValue("qidi/show_list_of_objects")

    // Eat up all the mouse events (we don't want the scene to react or have the scene context menu showing up)
    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Button
    {
        id: openCloseButton
        width: parent.width
        height: 20 * QD.Theme.getSize("size").height+ QD.Theme.getSize("narrow_margin").height / 2 | 0
        hoverEnabled: true
        padding: 0
        bottomPadding: QD.Theme.getSize("narrow_margin").height / 2 | 0

        anchors
        {
            bottom: contents.top
            horizontalCenter: parent.horizontalCenter
        }

        contentItem: Item
        {
            width: parent.width
            height: 20 * QD.Theme.getSize("size").height

            QD.RecolorImage
            {
                id: openCloseIcon
                anchors.verticalCenter: parent.verticalCenter
                width: 15 * QD.Theme.getSize("size").height
                height: 15 * QD.Theme.getSize("size").height
                sourceSize.width: width
                anchors.left: parent.left
                color: openCloseButton.hovered ? QD.Theme.getColor("small_button_text_hover") : QD.Theme.getColor("small_button_text")
                source: objectSelector.opened ? QD.Theme.getIcon("ChevronSingleDown") : QD.Theme.getIcon("ChevronSingleUp")
            }

            Label
            {
                id: label
                anchors.left: openCloseIcon.right
                anchors.leftMargin: QD.Theme.getSize("default_margin").width
                anchors.verticalCenter: parent.verticalCenter
                height: 20 * QD.Theme.getSize("size").height
                text: catalog.i18nc("@label", "Object list")
                font: QD.Theme.getFont("default")
                color: openCloseButton.hovered ? QD.Theme.getColor("small_button_text_hover") : QD.Theme.getColor("small_button_text")
                renderType: Text.NativeRendering
                elide: Text.ElideRight
            }
        }

        background: Item {}

        onClicked:
        {
            QD.Preferences.setValue("qidi/show_list_of_objects", !objectSelector.opened)
            objectSelector.opened = QD.Preferences.getValue("qidi/show_list_of_objects")
        }
    }

    Rectangle
    {
        id: contents
        width: parent.width
        visible: objectSelector.opened
        height: visible ? listView.height : 0
        color: QD.Theme.getColor("gray_5")
        border.width: QD.Theme.getSize("default_lining").width
        border.color: QD.Theme.getColor("lining")
        radius: 3 * QD.Theme.getSize("size").height

        Behavior on height { NumberAnimation { duration: 100 } }

        anchors.bottom: parent.bottom

        property var extrudersModel: QIDIApplication.getExtrudersModel()
        QD.SettingPropertyProvider
        {
            id: machineExtruderCount

            containerStack: QIDI.MachineManager.activeMachine
            key: "machine_extruder_count"
            watchedProperties: [ "value" ]
            storeIndex: 0
        }

        ListView
        {
            id: listView
            clip: true
            anchors
            {
                left: parent.left
                right: parent.right
                margins: QD.Theme.getSize("default_lining").width
            }

            ScrollBar.vertical: ScrollBar
            {
                hoverEnabled: true
            }

            property real maximumHeight: QD.Theme.getSize("objects_menu_size").height

            height: Math.min(contentHeight, maximumHeight)

            model: QIDI.ObjectsModel {}

            delegate: ObjectItemButton
            {
                id: modelButton
                Binding
                {
                    target: modelButton
                    property: "checked"
                    value: model.selected
                }
                text: model.name
                width: listView.width
                property bool outsideBuildArea: model.outside_build_area ? model.outside_build_area : false
                property int perObjectSettingsCount: model.per_object_settings_count ? model.per_object_settings_count : 0
                property string meshType: model.mesh_type ? model.mesh_type : ""
                property int extruderNumber: model.extruder_number ? model.extruder_number :0
                property string extruderColor:
                {
                    if (model.extruder_number == -1)
                    {
                        return "";
                    }
                    return contents.extrudersModel.getItem(model.extruder_number).color;
                }
                property bool showExtruderSwatches: machineExtruderCount.properties.value > 1
            }
        }
    }
}
