// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QD 1.1 as QD

Item
{
    id: sidebar
    height: parent.height
    width: QD.Theme.getSize("toolbox_back_column").width
    anchors
    {
        top: parent.top
        left: parent.left
        topMargin: QD.Theme.getSize("wide_margin").height
        leftMargin: QD.Theme.getSize("default_margin").width
        rightMargin: QD.Theme.getSize("default_margin").width
    }
    Button
    {
        id: button
        text: catalog.i18nc("@action:button", "Back")
        enabled: !toolbox.isDownloading
        QD.RecolorImage
        {
            id: backArrow
            anchors
            {
                verticalCenter: parent.verticalCenter
                left: parent.left
                rightMargin: QD.Theme.getSize("default_margin").width
            }
            width: QD.Theme.getSize("standard_arrow").width
            height: QD.Theme.getSize("standard_arrow").height
            sourceSize
            {
                width: width
                height: height
            }
            color: button.enabled ? (button.hovered ? QD.Theme.getColor("primary") : QD.Theme.getColor("text")) : QD.Theme.getColor("text_inactive")
            source: QD.Theme.getIcon("ChevronSingleLeft")
        }
        width: QD.Theme.getSize("toolbox_back_button").width
        height: QD.Theme.getSize("toolbox_back_button").height
        onClicked:
        {
            toolbox.viewPage = "overview"
            if (toolbox.viewCategory == "material")
            {
                toolbox.filterModelByProp("authors", "package_types", "material")
            }
            else if (toolbox.viewCategory == "plugin")
            {
                toolbox.filterModelByProp("packages", "type", "plugin")
            }

        }
        style: ButtonStyle
        {
            background: Rectangle
            {
                color: "transparent"
            }
            label: Label
            {
                id: labelStyle
                text: control.text
                color: control.enabled ? (control.hovered ? QD.Theme.getColor("primary") : QD.Theme.getColor("text")) : QD.Theme.getColor("text_inactive")
                font: QD.Theme.getFont("medium_bold")
                horizontalAlignment: Text.AlignLeft
                anchors
                {
                    left: parent.left
                    leftMargin: QD.Theme.getSize("default_margin").width
                }
                width: control.width
                renderType: Text.NativeRendering
            }
        }
    }
}
