// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI


// This element hold all the elements needed for the user to trigger the slicing process, and later
// to get information about the printing times, material consumption and the output process (such as
// saving to a file, printing over network, ...
Item
{
    id: base
    //width: actionPanelWidget.width + additionalComponents.width
    //height: childrenRect.height
    //visible: QIDIApplication.platformActivity

    Rectangle
    {
        id: actionPanelWidget

        anchors.fill: parent
        gradient: Gradient
        {
            GradientStop {position: 0.0; color: QD.Theme.getColor("blue_7")}
            GradientStop {position: 1.0; color: QD.Theme.getColor("white_1")}
        }
        z: 10

        property bool outputAvailable: QD.Backend.state == QD.Backend.Done || QD.Backend.state == QD.Backend.Disabled

        Rectangle
        {
            id: progressBarBackground
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 7 * QD.Theme.getSize("size").height
            color: QD.Theme.getColor("blue_4")
        }
        
        Item
        {
            id: jobNameRow
            anchors.top: progressBarBackground.bottom
            anchors.topMargin: 15 * QD.Theme.getSize("size").height
            anchors.left: parent.left
            anchors.leftMargin: 15 * QD.Theme.getSize("size").height
            height: 25 * QD.Theme.getSize("size").height

            Button
            {
                id: printJobPencilIcon
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: parent.height
                height: parent.height

                onClicked:
                {
                    printJobTextfield.selectAll()
                    printJobTextfield.focus = true
                }

                contentItem: Item
                {
                    anchors.fill: parent
                    QD.RecolorImage
                    {
                        id: buttonIcon
                        anchors.centerIn: parent
                        source: QD.Theme.getIcon("Pen")
                        width: printJobPencilIcon.hovered ? parent.height : parent.height - 2 * QD.Theme.getSize("size").height
                        height: printJobPencilIcon.hovered ? parent.height : parent.height - 2 * QD.Theme.getSize("size").height
                        color: QD.Theme.getColor("gray_6")
                    }
                }

                background: Rectangle
                {
                    id: background
                    anchors.centerIn: parent
                    height: parent.height
                    width: parent.height
                    color: QD.Theme.getColor("white_2")
                }
            }

            TextField
            {
                id: printJobTextfield
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: printJobPencilIcon.right
                anchors.leftMargin: QD.Theme.getSize("narrow_margin").width
                height: 25 * QD.Theme.getSize("size").height
                width: 200 * QD.Theme.getSize("size").height
                maximumLength: 120
                text: (PrintInformation === null) ? "" : PrintInformation.jobName
                horizontalAlignment: TextInput.AlignLeft
                font: QD.Theme.getFont("font1")

                property string textBeforeEdit: ""

                onActiveFocusChanged:
                {
                    if (activeFocus)
                    {
                        textBeforeEdit = text
                    }
                }

                onEditingFinished:
                {
                    if (text != textBeforeEdit) {
                        var new_name = text == "" ? catalog.i18nc("@text Print job name", "Untitled") : text
                        PrintInformation.setJobName(new_name, true)
                    }
                    printJobTextfield.focus = false
                }

                validator: RegExpValidator {
                    regExp: /^[^\\\/\*\?\|\[\]]*$/
                }
            }
        }

        Loader
        {
            id: loader
            anchors.fill: parent
            sourceComponent: actionPanelWidget.outputAvailable ? outputProcessWidget : sliceProcessWidget
        }

        Component
        {
            id: sliceProcessWidget
            SliceProcessWidget { }
        }

        Component
        {
            id: outputProcessWidget
            OutputProcessWidget { }
        }
    }

    Item
    {
        id: additionalComponents
        width: childrenRect.width
        anchors.right: parent.left
        anchors.rightMargin: 15 * QD.Theme.getSize("size").height
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15 * QD.Theme.getSize("size").height
        visible: actionPanelWidget.visible
        z: 11
        Row
        {
            id: additionalComponentsRow
            anchors.bottom: parent.bottom
            spacing: QD.Theme.getSize("default_margin").width
        }
    }

    Component.onCompleted: base.addAdditionalComponents()

    Connections
    {
        target: QIDIApplication
        function onAdditionalComponentsChanged(areaId) { base.addAdditionalComponents() }
    }

    function addAdditionalComponents()
    {
        for (var component in QIDIApplication.additionalComponents["saveButton"])
        {
            QIDIApplication.additionalComponents["saveButton"][component].parent = additionalComponentsRow
        }
    }
}
