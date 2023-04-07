// Copyright (c) 2019 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.1 as QD

import "../components"

ScrollView
{
    id: page
    clip: true
    width: parent.width
    height: parent.height

    Column
    {
        width: page.width
        spacing: QD.Theme.getSize("default_margin").height
        padding: QD.Theme.getSize("wide_margin").width
        height: childrenRect.height + 2 * QD.Theme.getSize("wide_margin").height

        Label
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            text: catalog.i18nc("@title:tab", "Installed plugins")
            color: QD.Theme.getColor("text_medium")
            font: QD.Theme.getFont("medium")
            renderType: Text.NativeRendering
        }

        Rectangle
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            id: installedPlugins
            color: "transparent"
            height: childrenRect.height + QD.Theme.getSize("default_margin").width
            border.color: QD.Theme.getColor("lining")
            border.width: QD.Theme.getSize("default_lining").width
            Column
            {
                anchors
                {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                    margins: QD.Theme.getSize("default_margin").width
                }
                Repeater
                {
                    id: pluginList
                    model: toolbox.pluginsInstalledModel
                    delegate: ToolboxInstalledTile { }
                }
            }
            Label
            {
                visible: toolbox.pluginsInstalledModel.count < 1
                padding: QD.Theme.getSize("default_margin").width
                text: catalog.i18nc("@info", "No plugin has been installed.")
                font: QD.Theme.getFont("medium")
                renderType: Text.NativeRendering
            }
        }

        Label
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            text: catalog.i18nc("@title:tab", "Installed materials")
            color: QD.Theme.getColor("text_medium")
            font: QD.Theme.getFont("medium")
            renderType: Text.NativeRendering
        }

        Rectangle
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            id: installedMaterials
            color: "transparent"
            height: childrenRect.height + QD.Theme.getSize("default_margin").width
            border.color: QD.Theme.getColor("lining")
            border.width: QD.Theme.getSize("default_lining").width
            Column
            {
                anchors
                {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                    margins: QD.Theme.getSize("default_margin").width
                }
                Repeater
                {
                    id: installedMaterialsList
                    model: toolbox.materialsInstalledModel
                    delegate: ToolboxInstalledTile { }
                }
            }
            Label
            {
                visible: toolbox.materialsInstalledModel.count < 1
                padding: QD.Theme.getSize("default_margin").width
                text: catalog.i18nc("@info", "No material has been installed.")
                font: QD.Theme.getFont("medium")
                renderType: Text.NativeRendering
            }
        }

        Label
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            text: catalog.i18nc("@title:tab", "Bundled plugins")
            color: QD.Theme.getColor("text_medium")
            font: QD.Theme.getFont("medium")
            renderType: Text.NativeRendering
        }

        Rectangle
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            id: bundledPlugins
            color: "transparent"
            height: childrenRect.height + QD.Theme.getSize("default_margin").width
            border.color: QD.Theme.getColor("lining")
            border.width: QD.Theme.getSize("default_lining").width
            Column
            {
                anchors
                {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                    margins: QD.Theme.getSize("default_margin").width
                }
                Repeater
                {
                    id: bundledPluginsList
                    model: toolbox.pluginsBundledModel
                    delegate: ToolboxInstalledTile { }
                }
            }
        }

        Label
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            text: catalog.i18nc("@title:tab", "Bundled materials")
            color: QD.Theme.getColor("text_medium")
            font: QD.Theme.getFont("medium")
            renderType: Text.NativeRendering
        }

        Rectangle
        {
            anchors
            {
                left: parent.left
                right: parent.right
                margins: parent.padding
            }
            id: bundledMaterials
            color: "transparent"
            height: childrenRect.height + QD.Theme.getSize("default_margin").width
            border.color: QD.Theme.getColor("lining")
            border.width: QD.Theme.getSize("default_lining").width
            Column
            {
                anchors
                {
                    top: parent.top
                    right: parent.right
                    left: parent.left
                    margins: QD.Theme.getSize("default_margin").width
                }
                Repeater
                {
                    id: bundledMaterialsList
                    model: toolbox.materialsBundledModel
                    delegate: ToolboxInstalledTile {}
                }
            }
        }
    }
}
