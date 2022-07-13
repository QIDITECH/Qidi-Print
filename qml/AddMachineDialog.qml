// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import QtQuick.Controls.Styles 1.1

import UM 1.2 as UM
import Cura 1.0 as Cura


UM.Dialog
{
    id: base
    title: catalog.i18nc("@title:window", "Select Printer")
    property bool firstRun: false
    property string preferredCategory: "i-series"
    property string activeCategory: preferredCategory

    minimumWidth: 470 * UM.Theme.getSize("default_margin").width/10
    minimumHeight: 350 * UM.Theme.getSize("default_margin").width/10
    maximumWidth: 470 * UM.Theme.getSize("default_margin").width/10
    maximumHeight: 350 * UM.Theme.getSize("default_margin").width/10
    width: minimumWidth
    height: minimumHeight

    flags: {
        var window_flags = Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint;
        if (Cura.MachineManager.activeDefinitionId !== "") //Disallow closing the window if we have no active printer yet. You MUST add a printer.
        /*{
            window_flags |= Qt.WindowCloseButtonHint;
        }*/
        return window_flags;
    }

    onVisibilityChanged:
    {
        // Reset selection and machine name
        if (visible) {
            activeCategory = preferredCategory;
            machineList.currentIndex = 0;
        }
    }

    signal machineAdded(string id)
    function getMachineName()
    {
        var name = machineList.model.getItem(machineList.currentIndex) != undefined ? machineList.model.getItem(machineList.currentIndex).name : ""
        return name
    }

    ScrollView
    {
        id: machinesHolder

        anchors
        {
            left: parent.left;
            leftMargin: 5 * UM.Theme.getSize("default_margin").width/10
            top: parent.top;
            topMargin: 5 * UM.Theme.getSize("default_margin").width/10
            bottom: parent.bottom;
        }

        style: ScrollViewStyle{
            decrementControl: Item { }
            incrementControl: Item { }

            transientScrollBars: false

            scrollBarBackground: Rectangle {
                implicitWidth: UM.Theme.getSize("scrollbar").width
                radius: Math.round(implicitWidth / 2)
                color: UM.Theme.getColor("color15");
            }

            handle: Rectangle {
                id: scrollViewHandle
                visible: false
            }
        }

        ListView
        {
            id: machineList

            model: UM.DefinitionContainersModel
            {
                id: machineDefinitionsModel
                filter: { "visible": true }
                sectionProperty: "category"
                preferredSectionValue: preferredCategory
            }

            section.property: "section"
            section.delegate: Button
            {
                text: section
                style: ButtonStyle
                {
                    background: Item
                    {
                        height: 20 * UM.Theme.getSize("default_margin").width/10
                        width: machineList.width
                    }
                    label: Label
                    {
                        anchors.left: parent.left
                        anchors.leftMargin: 20 * UM.Theme.getSize("default_margin").width/10
                        anchors.verticalCenter: parent.verticalCenter
                        text: control.text
                        color: UM.Theme.getColor("color4")
                        font: UM.Theme.getFont("font6")
                        UM.RecolorImage
                        {
                            id: downArrow
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.left
                            anchors.rightMargin: 7 * UM.Theme.getSize("default_margin").width/10
                            width: 12 * UM.Theme.getSize("default_margin").width/10
                            height: 12 * UM.Theme.getSize("default_margin").width/10
                            sourceSize.width: width
                            sourceSize.height: width
                            color: UM.Theme.getColor("color4")
                            source: base.activeCategory == section ? UM.Theme.getIcon("arrow_bottom") : UM.Theme.getIcon("arrow_right")
                        }
                    }
                }

                onClicked:
                {
                    base.activeCategory = section;
                    if (machineList.model.getItem(machineList.currentIndex).section != section) {
                        // Find the first machine from this section
                        for(var i = 0; i < machineList.model.rowCount(); i++) {
                            var item = machineList.model.getItem(i);
                            if (item.section == section) {
                                machineList.currentIndex = i;
                                break;
                            }
                        }
                    }
                }
            }

            delegate: RadioButton
            {
                id: machineButton

                anchors.left: parent.left
                anchors.leftMargin: UM.Theme.getSize("standard_list_lineheight").width

                //opacity: 1;
                height: 30 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("standard_list_lineheight").height;

                checked: ListView.isCurrentItem;

                exclusiveGroup: printerGroup;

                text: model.name

                style: RadioButtonStyle {
                    indicator: Rectangle {
                            implicitWidth: 20 * UM.Theme.getSize("default_margin").width/10
                            implicitHeight: 20 * UM.Theme.getSize("default_margin").width/10
                            radius: 10 * UM.Theme.getSize("default_margin").width/10
                            border.color: UM.Theme.getColor("color2")
                            border.width: 1 * UM.Theme.getSize("default_margin").width/10
                            Rectangle {

                                anchors.fill: parent
                                visible: control.checked
                                color: UM.Theme.getColor("color12")
                                radius: 9 * UM.Theme.getSize("default_margin").width/10
                                anchors.margins: 5 * UM.Theme.getSize("default_margin").width/10
                            }
                    }
                    label:Label
                    {
                        text: control.text.replace("_", " ").replace("I-", "i-")
                        color: UM.Theme.getColor("color12")
                        font: UM.Theme.getFont("font4")
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    }
                }

                onClicked:
                {
                    ListView.view.currentIndex = index;
                }

                states: State
                {
                    name: "collapsed";
                    when: base.activeCategory != model.section;

                    PropertyChanges { target: machineButton; opacity: 0; height: 0; }
                }

                transitions:
                [
                    Transition
                    {
                        to: "collapsed";
                        SequentialAnimation
                        {
                            NumberAnimation { property: "opacity"; duration: 75; }
                            NumberAnimation { property: "height"; duration: 75; }
                        }
                    },
                    Transition
                    {
                        from: "collapsed";
                        SequentialAnimation
                        {
                            NumberAnimation { property: "height"; duration: 75; }
                            NumberAnimation { property: "opacity"; duration: 75; }
                        }
                    }
                ]
            }
        }
    }

    Image {
        id: image
        anchors.right: parent.right
        anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
        anchors.top: machinesHolder.top
        source: UM.Theme.getIcon(getMachineName())
    }

    Button
    {
        text: catalog.i18nc("@action:button", "Select Printer")
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
        onClicked: {
            addMachine()
        }
        width: 100 * UM.Theme.getSize("default_margin").width/10
        height: 23 * UM.Theme.getSize("default_margin").width/10
        style: UM.Theme.styles.savebutton
    }

    onAccepted: addMachine()

    function addMachine()
    {
        base.visible = false
        var item = getMachineName().replace("i-", "I-")
        Cura.MachineManager.setActiveMachine(item)
        manager.didAgree(true)
    }

    Item
    {
        UM.I18nCatalog
        {
            id: catalog;
            name: "cura";
        }
        SystemPalette { id: palette }
        ExclusiveGroup { id: printerGroup; }
    }
}
