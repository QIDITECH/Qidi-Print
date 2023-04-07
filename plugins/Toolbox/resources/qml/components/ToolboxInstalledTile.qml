// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QD 1.1 as QD

Item
{
    height: QD.Theme.getSize("toolbox_installed_tile").height
    width: parent.width
    property bool isEnabled: true

    Rectangle
    {
        color: QD.Theme.getColor("lining")
        width: parent.width
        height: Math.floor(QD.Theme.getSize("default_lining").height)
        anchors.bottom: parent.top
        visible: index != 0
    }
    Row
    {
        id: tileRow
        height: parent.height
        width: parent.width
        spacing: QD.Theme.getSize("default_margin").width
        topPadding: QD.Theme.getSize("default_margin").height

        CheckBox
        {
            id: disableButton
            anchors.verticalCenter: pluginInfo.verticalCenter
            checked: isEnabled
            visible: model.type == "plugin"
            width: visible ? QD.Theme.getSize("checkbox").width : 0
            enabled: !toolbox.isDownloading
            style: QD.Theme.styles.checkbox
            onClicked: toolbox.isEnabled(model.id) ? toolbox.disable(model.id) : toolbox.enable(model.id)
        }
        Column
        {
            id: pluginInfo
            topPadding: QD.Theme.getSize("narrow_margin").height
            property var color: model.type === "plugin" && !isEnabled ? QD.Theme.getColor("lining") : QD.Theme.getColor("text")
            width: Math.floor(tileRow.width - (authorInfo.width + pluginActions.width + 2 * tileRow.spacing + ((disableButton.visible) ? disableButton.width + tileRow.spacing : 0)))
            Label
            {
                text: model.name
                width: parent.width
                maximumLineCount: 1
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                font: QD.Theme.getFont("large_bold")
                color: pluginInfo.color
                renderType: Text.NativeRendering
            }
            Label
            {
                text: model.description
                font: QD.Theme.getFont("default")
                maximumLineCount: 3
                elide: Text.ElideRight
                width: parent.width
                wrapMode: Text.WordWrap
                color: pluginInfo.color
                renderType: Text.NativeRendering
            }
        }
        Column
        {
            id: authorInfo
            width: Math.floor(QD.Theme.getSize("toolbox_action_button").width * 1.25)

            Label
            {
                text:
                {
                    if (model.author_email)
                    {
                        return "<a href=\"mailto:" + model.author_email + "?Subject=QIDI: " + model.name + "\">" + model.author_name + "</a>"
                    }
                    else
                    {
                        return model.author_name
                    }
                }
                font: QD.Theme.getFont("medium")
                width: parent.width
                height: Math.floor(QD.Theme.getSize("toolbox_property_label").height)
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                onLinkActivated: Qt.openUrlExternally("mailto:" + model.author_email + "?Subject=QIDI: " + model.name + " Plugin")
                color: model.enabled ? QD.Theme.getColor("text") : QD.Theme.getColor("lining")
                linkColor: QD.Theme.getColor("text_link")
                renderType: Text.NativeRendering
            }

            Label
            {
                text: model.version
                font: QD.Theme.getFont("default")
                width: parent.width
                height: QD.Theme.getSize("toolbox_property_label").height
                color: QD.Theme.getColor("text")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                renderType: Text.NativeRendering
            }
        }
        ToolboxInstalledTileActions
        {
            id: pluginActions
        }
        Connections
        {
            target: toolbox
            function onToolboxEnabledChanged() { isEnabled = toolbox.isEnabled(model.id) }
        }
    }
}
