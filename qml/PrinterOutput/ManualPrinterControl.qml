// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.0 as QIDI

import "."


Item
{
    property var printerModel: null
    property var activePrintJob: printerModel != null ? printerModel.activePrintJob : null
    property var connectedPrinter: QIDI.MachineManager.printerOutputDevices.length >= 1 ? QIDI.MachineManager.printerOutputDevices[0] : null

    implicitWidth: parent.width
    implicitHeight: childrenRect.height

    Column
    {
        enabled:
        {
            if (printerModel == null)
            {
                return false; //Can't control the printer if not connected
            }

            if (!connectedDevice.acceptsCommands)
            {
                return false; //Not allowed to do anything.
            }

            if(activePrintJob == null)
            {
                return true
            }

            if (activePrintJob.state == "printing" || activePrintJob.state == "resuming" || activePrintJob.state == "pausing" || activePrintJob.state == "error" || activePrintJob.state == "offline")
            {
                return false; //Printer is in a state where it can't react to manual control
            }
            return true;
        }

        MonitorSection
        {
            label: catalog.i18nc("@label", "Printer control")
            width: base.width
        }

        Row
        {
            width: base.width - 2 * QD.Theme.getSize("default_margin").width
            height: childrenRect.height + QD.Theme.getSize("default_margin").width
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width

            spacing: QD.Theme.getSize("default_margin").width

            Label
            {
                text: catalog.i18nc("@label", "Jog Position")
                color: QD.Theme.getColor("setting_control_text")
                font: QD.Theme.getFont("default")

                width: Math.floor(parent.width * 0.4) - QD.Theme.getSize("default_margin").width
                height: QD.Theme.getSize("setting_control").height
                verticalAlignment: Text.AlignVCenter
            }

            GridLayout
            {
                columns: 3
                rows: 4
                rowSpacing: QD.Theme.getSize("default_lining").width
                columnSpacing: QD.Theme.getSize("default_lining").height

                Label
                {
                    text: catalog.i18nc("@label", "X/Y")
                    color: QD.Theme.getColor("setting_control_text")
                    font: QD.Theme.getFont("default")
                    width: height
                    height: QD.Theme.getSize("setting_control").height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter

                    Layout.row: 0
                    Layout.column: 1
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                }

                Button
                {
                    Layout.row: 1
                    Layout.column: 1
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                    iconSource: QD.Theme.getIcon("ChevronSingleUp");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.moveHead(0, distancesRow.currentDistance, 0)
                    }
                }

                Button
                {
                    Layout.row: 2
                    Layout.column: 0
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                    iconSource: QD.Theme.getIcon("ChevronSingleLeft");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.moveHead(-distancesRow.currentDistance, 0, 0)
                    }
                }

                Button
                {
                    Layout.row: 2
                    Layout.column: 2
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                    iconSource: QD.Theme.getIcon("ChevronSingleRight");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.moveHead(distancesRow.currentDistance, 0, 0)
                    }
                }

                Button
                {
                    Layout.row: 3
                    Layout.column: 1
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                    iconSource: QD.Theme.getIcon("ChevronSingleDown");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.moveHead(0, -distancesRow.currentDistance, 0)
                    }
                }

                Button
                {
                    Layout.row: 2
                    Layout.column: 1
                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                    iconSource: QD.Theme.getIcon("House");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.homeHead()
                    }
                }
            }


            Column
            {
                spacing: QD.Theme.getSize("default_lining").height

                Label
                {
                    text: catalog.i18nc("@label", "Z")
                    color: QD.Theme.getColor("setting_control_text")
                    font: QD.Theme.getFont("default")
                    width: QD.Theme.getSize("section").height
                    height: QD.Theme.getSize("setting_control").height
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                Button
                {
                    iconSource: QD.Theme.getIcon("ChevronSingleUp");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.moveHead(0, 0, distancesRow.currentDistance)
                    }
                }

                Button
                {
                    iconSource: QD.Theme.getIcon("House");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.homeBed()
                    }
                }

                Button
                {
                    iconSource: QD.Theme.getIcon("ChevronSingleDown");
                    style: QD.Theme.styles.monitor_button_style
                    width: height
                    height: QD.Theme.getSize("setting_control").height

                    onClicked:
                    {
                        printerModel.moveHead(0, 0, -distancesRow.currentDistance)
                    }
                }
            }
        }

        Row
        {
            id: distancesRow

            width: base.width - 2 * QD.Theme.getSize("default_margin").width
            height: childrenRect.height + QD.Theme.getSize("default_margin").width
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width

            spacing: QD.Theme.getSize("default_margin").width

            property real currentDistance: 10

            Label
            {
                text: catalog.i18nc("@label", "Jog Distance")
                color: QD.Theme.getColor("setting_control_text")
                font: QD.Theme.getFont("default")

                width: Math.floor(parent.width * 0.4) - QD.Theme.getSize("default_margin").width
                height: QD.Theme.getSize("setting_control").height
                verticalAlignment: Text.AlignVCenter
            }

            Row
            {
                Repeater
                {
                    model: distancesModel
                    delegate: Button
                    {
                        height: QD.Theme.getSize("setting_control").height
                        width: height + QD.Theme.getSize("default_margin").width

                        text: model.label
                        exclusiveGroup: distanceGroup
                        checkable: true
                        checked: distancesRow.currentDistance == model.value
                        onClicked: distancesRow.currentDistance = model.value

                        style: QD.Theme.styles.monitor_checkable_button_style
                    }
                }
            }
        }

        Row
        {
            id: customCommandInputRow

            width: base.width - 2 * QD.Theme.getSize("default_margin").width
            height: childrenRect.height + QD.Theme.getSize("default_margin").width
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width

            spacing: QD.Theme.getSize("default_margin").width

            Label
            {
                text: catalog.i18nc("@label", "Send G-code")
                color: QD.Theme.getColor("setting_control_text")
                font: QD.Theme.getFont("default")

                width: Math.floor(parent.width * 0.4) - QD.Theme.getSize("default_margin").width
                height: QD.Theme.getSize("setting_control").height
                verticalAlignment: Text.AlignVCenter
            }

            Row
            {
                // Input field for custom G-code commands.
                Rectangle
                {
                    id: customCommandControl

                    // state
                    visible: printerModel != null ? printerModel.canSendRawGcode: true
                    enabled: {
                        if (printerModel == null) {
                            return false // Can't send custom commands if not connected.
                        }
                        if (connectedPrinter == null || !connectedPrinter.acceptsCommands) {
                            return false // Not allowed to do anything
                        }
                        if (connectedPrinter.jobState == "printing" || connectedPrinter.jobState == "pre_print" || connectedPrinter.jobState == "resuming" || connectedPrinter.jobState == "pausing" || connectedPrinter.jobState == "paused" || connectedPrinter.jobState == "error" || connectedPrinter.jobState == "offline") {
                            return false // Printer is in a state where it can't react to custom commands.
                        }
                        return true
                    }

                    // style
                    color: !enabled ? QD.Theme.getColor("setting_control_disabled") : QD.Theme.getColor("setting_validation_ok")
                    border.width: QD.Theme.getSize("default_lining").width
                    border.color: !enabled ? QD.Theme.getColor("setting_control_disabled_border") : customCommandControlMouseArea.containsMouse ? QD.Theme.getColor("setting_control_border_highlight") : QD.Theme.getColor("setting_control_border")

                    // size
                    width: QD.Theme.getSize("setting_control").width
                    height: QD.Theme.getSize("setting_control").height

                    // highlight
                    Rectangle
                    {
                        anchors.fill: parent
                        anchors.margins: QD.Theme.getSize("default_lining").width
                        color: QD.Theme.getColor("setting_control_highlight")
                        opacity: customCommandControl.hovered ? 1.0 : 0
                    }

                    // cursor hover popup
                    MouseArea
                    {
                        id: customCommandControlMouseArea
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor

                        onHoveredChanged:
                        {
                            if (containsMouse)
                            {
                                base.showTooltip(
                                    base,
                                    { x: -tooltip.width, y: customCommandControlMouseArea.mapToItem(base, 0, 0).y },
                                    catalog.i18nc("@tooltip of G-code command input", "Send a custom G-code command to the connected printer. Press 'enter' to send the command.")
                                )
                            }
                            else
                            {
                                base.hideTooltip()
                            }
                        }
                    }

                    TextInput
                    {
                        id: customCommandControlInput

                        // style
                        font: QD.Theme.getFont("default")
                        color: !enabled ? QD.Theme.getColor("setting_control_disabled_text") : QD.Theme.getColor("setting_control_text")
                        selectByMouse: true
                        clip: true
                        enabled: parent.enabled
                        renderType: Text.NativeRendering

                        // anchors
                        anchors.left: parent.left
                        anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        // send the command when pressing enter
                        // we also clear the text field
                        Keys.onReturnPressed:
                        {
                            printerModel.sendRawCommand(customCommandControlInput.text)
                            customCommandControlInput.text = ""
                        }
                    }
                }
            }
        }

        ListModel
        {
            id: distancesModel
            ListElement { label: "0.1"; value: 0.1 }
            ListElement { label: "1";   value: 1   }
            ListElement { label: "10";  value: 10  }
            ListElement { label: "100"; value: 100 }
        }
        ExclusiveGroup { id: distanceGroup }
    }
}
