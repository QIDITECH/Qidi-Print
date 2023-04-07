// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.1 as QD
import QIDI 1.0 as QIDI

Button
{
    id: objectItemButton

    width: parent.width
    height: QD.Theme.getSize("action_button").height
    leftPadding: QD.Theme.getSize("thin_margin").width
    rightPadding: perObjectSettingsInfo.visible ? QD.Theme.getSize("default_lining").width : QD.Theme.getSize("thin_margin").width
    checkable: true
    hoverEnabled: true

    onHoveredChanged:
    {
        if(hovered && (buttonTextMetrics.elidedText != buttonText.text || perObjectSettingsInfo.visible))
        {
            tooltip.show()
        } else
        {
            tooltip.hide()
        }
    }


    onClicked: QIDI.SceneController.changeSelection(index)

    background: Rectangle
    {
        id: backgroundRect
        color: QD.Theme.getColor("white_2")
        radius: 3 * QD.Theme.getSize("size").height
        border.width: QD.Theme.getSize("size").height
        border.color: objectItemButton.checked ? QD.Theme.getColor("primary") : "transparent"
    }

    contentItem: Item
    {
        width: objectItemButton.width - objectItemButton.leftPadding
        height: QD.Theme.getSize("action_button").height

        QD.RecolorImage
        {
            id: swatch
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: height
            height: parent.height
            source: QD.Theme.getIcon("ExtruderSolid", "medium")
            color: extruderColor
            visible: showExtruderSwatches && extruderColor != ""
        }

        Label
        {
            id: buttonText
            anchors
            {
                left: showExtruderSwatches ? swatch.right : parent.left
                leftMargin: showExtruderSwatches ? QD.Theme.getSize("narrow_margin").width : 0
                right: perObjectSettingsInfo.visible ? perObjectSettingsInfo.left : parent.right
                verticalCenter: parent.verticalCenter
            }
            text: objectItemButton.text
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("text_scene")
            opacity: (outsideBuildArea) ? 0.5 : 1.0
            visible: text != ""
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        Button
        {
            id: perObjectSettingsInfo

            anchors
            {
                right: parent.right
                rightMargin: 0
            }
            width: childrenRect.width
            height: parent.height
            padding: 0
            leftPadding: QD.Theme.getSize("thin_margin").width
            visible: meshType != "" || perObjectSettingsCount > 0

            onClicked:
            {
                QIDI.SceneController.changeSelection(index)
                QD.Controller.setActiveTool("PerObjectSettingsTool")
            }

            property string tooltipText:
            {
                var result = "";
                if (!visible)
                {
                    return result;
                }
                if (meshType != "")
                {
                    result += "<br>";
                    switch (meshType) {
                        case "support_mesh":
                            result += catalog.i18nc("@label", "Is printed as support.");
                            break;
                        case "cutting_mesh":
                            result += catalog.i18nc("@label", "Other models overlapping with this model are modified.");
                            break;
                        case "infill_mesh":
                            result += catalog.i18nc("@label", "Infill overlapping with this model is modified.");
                            break;
                        case "anti_overhang_mesh":
                            result += catalog.i18nc("@label", "Overlaps with this model are not supported.");
                            break;
                    }
                }
                if (perObjectSettingsCount != "")
                {
                    result += "<br>" + catalog.i18ncp(
                        "@label %1 is the number of settings it overrides.", "Overrides %1 setting.", "Overrides %1 settings.", perObjectSettingsCount
                    ).arg(perObjectSettingsCount);
                }
                return result;
            }

            contentItem: Item
            {
                height: parent.height
                width: meshTypeIcon.width + perObjectSettingsCountLabel.width + QD.Theme.getSize("narrow_margin").width

                QIDI.NotificationIcon
                {
                    id: perObjectSettingsCountLabel
                    anchors
                    {
                        right: parent.right
                        rightMargin: 0
                    }
                    visible: perObjectSettingsCount > 0
                    color: QD.Theme.getColor("text_scene")
                    labelText: perObjectSettingsCount.toString()
                }

                QD.RecolorImage
                {
                    id: meshTypeIcon
                    anchors
                    {
                        right: perObjectSettingsCountLabel.left
                        rightMargin: QD.Theme.getSize("narrow_margin").width
                    }

                    width: parent.height
                    height: parent.height
                    color: QD.Theme.getColor("text_scene")
                    visible: meshType != ""
                    source:
                    {
                        switch (meshType) {
                            case "support_mesh":
                                return QD.Theme.getIcon("MeshTypeSupport");
                            case "cutting_mesh":
                            case "infill_mesh":
                                return QD.Theme.getIcon("MeshTypeIntersect");
                            case "anti_overhang_mesh":
                                return QD.Theme.getIcon("BlockSupportOverlaps");
                        }
                        return "";
                    }
                }
            }

            background: Item {}
        }
    }

    TextMetrics
    {
        id: buttonTextMetrics
        text: buttonText.text
        font: buttonText.font
        elide: buttonText.elide
        elideWidth: buttonText.width
    }

    QIDI.ToolTip
    {
        id: tooltip
        tooltipText: objectItemButton.text + perObjectSettingsInfo.tooltipText
    }

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }
}
