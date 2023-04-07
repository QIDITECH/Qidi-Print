// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QD 1.5 as QD

import "../components"

Item
{
    id: page
    property var details: base.selection || {}
    anchors.fill: parent
    ToolboxBackColumn
    {
        id: sidebar
    }
    Item
    {
        id: header
        anchors
        {
            left: sidebar.right
            right: parent.right
            rightMargin: QD.Theme.getSize("wide_margin").width
        }
        height: QD.Theme.getSize("toolbox_detail_header").height
        Image
        {
            id: thumbnail
            width: QD.Theme.getSize("toolbox_thumbnail_medium").width
            height: QD.Theme.getSize("toolbox_thumbnail_medium").height
            fillMode: Image.PreserveAspectFit
            source: details && details.icon_url ? details.icon_url : "../../images/placeholder.svg"
            mipmap: true
            anchors
            {
                top: parent.top
                left: parent.left
                leftMargin: QD.Theme.getSize("wide_margin").width
                topMargin: QD.Theme.getSize("wide_margin").height
            }
        }

        Label
        {
            id: title
            anchors
            {
                top: thumbnail.top
                left: thumbnail.right
                leftMargin: QD.Theme.getSize("default_margin").width
                right: parent.right
                rightMargin: QD.Theme.getSize("wide_margin").width
                bottomMargin: QD.Theme.getSize("default_margin").height
            }
            text: details && details.name ? details.name : ""
            font: QD.Theme.getFont("large_bold")
            color: QD.Theme.getColor("text_medium")
            wrapMode: Text.WordWrap
            width: parent.width
            height: QD.Theme.getSize("toolbox_property_label").height
            renderType: Text.NativeRendering
        }
        Label
        {
            id: description
            text: details && details.description ? details.description : ""
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("text_medium")
            anchors
            {
                top: title.bottom
                left: title.left
                topMargin: QD.Theme.getSize("default_margin").height
            }
            renderType: Text.NativeRendering
        }
        Column
        {
            id: properties
            anchors
            {
                top: description.bottom
                left: description.left
                topMargin: QD.Theme.getSize("default_margin").height
            }
            spacing: Math.floor(QD.Theme.getSize("narrow_margin").height)
            width: childrenRect.width

            Label
            {
                text: catalog.i18nc("@label", "Website") + ":"
                font: QD.Theme.getFont("default")
                color: QD.Theme.getColor("text_medium")
                renderType: Text.NativeRendering
            }
            Label
            {
                text: catalog.i18nc("@label", "Email") + ":"
                font: QD.Theme.getFont("default")
                color: QD.Theme.getColor("text_medium")
                renderType: Text.NativeRendering
            }
        }
        Column
        {
            id: values
            anchors
            {
                top: description.bottom
                left: properties.right
                leftMargin: QD.Theme.getSize("default_margin").width
                right: parent.right
                rightMargin: QD.Theme.getSize("default_margin").width
                topMargin: QD.Theme.getSize("default_margin").height
            }
            spacing: Math.floor(QD.Theme.getSize("narrow_margin").height)

            Label
            {
                text:
                {
                    if (details && details.website)
                    {
                        return "<a href=\"" + details.website + "\">" + details.website + "</a>"
                    }
                    return ""
                }
                width: parent.width
                elide: Text.ElideRight
                font: QD.Theme.getFont("default")
                color: QD.Theme.getColor("text")
                linkColor: QD.Theme.getColor("text_link")
                onLinkActivated: QD.UrlUtil.openUrl(link, ["https", "http"])
                renderType: Text.NativeRendering
            }

            Label
            {
                text:
                {
                    if (details && details.email)
                    {
                        return "<a href=\"mailto:" + details.email + "\">" + details.email + "</a>"
                    }
                    return ""
                }
                font: QD.Theme.getFont("default")
                color: QD.Theme.getColor("text")
                linkColor: QD.Theme.getColor("text_link")
                onLinkActivated: Qt.openUrlExternally(link)
                renderType: Text.NativeRendering
            }
        }
        Rectangle
        {
            color: QD.Theme.getColor("lining")
            width: parent.width
            height: QD.Theme.getSize("default_lining").height
            anchors.bottom: parent.bottom
        }
    }
    ToolboxDetailList
    {
        anchors
        {
            top: header.bottom
            bottom: page.bottom
            left: header.left
            right: page.right
        }
    }
}
