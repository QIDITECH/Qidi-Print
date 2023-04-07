// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1

import QD 1.1 as QD
import QIDI 1.0 as QIDI

QD.RecolorImage
{
    id: widget

    source: QD.Theme.getIcon("Information")
    width: visible ? QD.Theme.getSize("section_icon").width : 0
    height: QD.Theme.getSize("section_icon").height

    color: QD.Theme.getColor("icon")

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: popup.open()
        onExited: popup.close()
    }

    Popup
    {
        id: popup

        y: -(height + QD.Theme.getSize("default_arrow").height + QD.Theme.getSize("thin_margin").height)
        x: parent.width - width + QD.Theme.getSize("thin_margin").width

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        opacity: opened ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }

        contentWidth: printJobInformation.width
        contentHeight: printJobInformation.implicitHeight

        contentItem: PrintJobInformation
        {
            id: printJobInformation
            width: QD.Theme.getSize("action_panel_information_widget").width
        }

        background: QD.PointingRectangle
        {
            color: QD.Theme.getColor("tool_panel_background")
            borderColor: QD.Theme.getColor("lining")
            borderWidth: QD.Theme.getSize("default_lining").width

            target: Qt.point(width - (widget.width / 2) - QD.Theme.getSize("thin_margin").width,
                            height + QD.Theme.getSize("default_arrow").height - QD.Theme.getSize("thin_margin").height)

            arrowSize: QD.Theme.getSize("default_arrow").width
        }
    }
}
