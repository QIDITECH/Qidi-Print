// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import QD 1.1 as QD
import QIDI 1.0 as QIDI

Item
{
    id: widget

    function requestWriteToDevice()
    {
        QD.OutputDeviceManager.requestWriteToDevice(QD.OutputDeviceManager.activeDevice, PrintInformation.jobName,
            { "filter_by_machine": true, "preferred_mimetypes": QIDI.MachineManager.activeMachine.preferred_output_file_formats });
    }

    QIDI.PrimaryButton
    {
        id: saveToButton
        height: parent.height
        backgroundRadius: Math.round(height / 2)
        fixedWidthMode: true
        cornerSide: deviceSelectionMenu.visible ? QIDI.RoundedRectangle.Direction.Left : QIDI.RoundedRectangle.Direction.All

        anchors
        {
            top: parent.top
            left: parent.left
            right: deviceSelectionMenu.visible ? deviceSelectionMenu.left : parent.right
        }

        tooltip: QD.OutputDeviceManager.activeDeviceDescription

        text: QD.OutputDeviceManager.activeDeviceShortDescription

        onClicked:
        {
            forceActiveFocus()
            widget.requestWriteToDevice()
        }
    }

    QIDI.ActionButton
    {
        id: deviceSelectionMenu
        height: parent.height
        backgroundRadius: Math.round(height / 2)

        shadowEnabled: true
        shadowColor: QD.Theme.getColor("primary_shadow")
        cornerSide: QIDI.RoundedRectangle.Direction.Right

        anchors
        {
            top: parent.top
            right: parent.right
        }

        leftPadding: 10 * QD.Theme.getSize("size").height
        rightPadding: 15 * QD.Theme.getSize("size").height
        iconSource: popup.opened ? QD.Theme.getIcon("ChevronSingleUp") : QD.Theme.getIcon("ChevronSingleDown")
        color: QD.Theme.getColor("action_panel_secondary")
        hoverColor: QD.Theme.getColor("blue_3")
        visible: (devicesModel.deviceCount > 1)

        onClicked: popup.opened ? popup.close() : popup.open()

        Popup
        {
            id: popup
            padding: 0

            y: -height
            x: parent.width - width

            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            contentItem: ColumnLayout
            {
                Repeater
                {
                    model: devicesModel

                    delegate: QIDI.ActionButton
                    {
                        text: model.description
                        visible: model.id != QD.OutputDeviceManager.activeDevice  // Don't show the active device in the list
                        color: "transparent"
                        cornerRadius: 0
                        hoverColor: QD.Theme.getColor("blue_3")
                        Layout.fillWidth: true
                        // The total width of the popup should be defined by the largest button. By stating that each
                        // button should be minimally the size of it's content (aka; implicitWidth) we can ensure that.
                        Layout.minimumWidth: implicitWidth
                        Layout.preferredHeight: widget.height
                        onClicked:
                        {
                            QD.OutputDeviceManager.setActiveDevice(model.id)
                            popup.close()
                        }
                    }
                }
            }

            background: Rectangle
            {
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 100 } }
                color: QD.Theme.getColor("action_panel_secondary")
            }
        }
    }

    QD.OutputDevicesModel { id: devicesModel }
}
