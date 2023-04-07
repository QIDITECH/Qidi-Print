// Copyright (c) 2020 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4

import QD 1.4 as QD
import QIDI 1.0 as QIDI

Item
{
    id: header
    width: parent.width
    height: QD.Theme.getSize("toolbox_header").height
    Row
    {
        id: bar
        spacing: QD.Theme.getSize("default_margin").width
        height: childrenRect.height
        width: childrenRect.width
        anchors
        {
            left: parent.left
            leftMargin: QD.Theme.getSize("default_margin").width
        }

        ToolboxTabButton
        {
            id: pluginsTabButton
            text: catalog.i18nc("@title:tab", "Plugins")
            active: toolbox.viewCategory == "plugin" && enabled
            enabled: !toolbox.isDownloading && toolbox.viewPage != "loading" && toolbox.viewPage != "errored"
            onClicked:
            {
                toolbox.filterModelByProp("packages", "type", "plugin")
                toolbox.viewCategory = "plugin"
                toolbox.viewPage = "overview"
            }
        }

        ToolboxTabButton
        {
            id: materialsTabButton
            text: catalog.i18nc("@title:tab", "Materials")
            active: toolbox.viewCategory == "material" && enabled
            enabled: !toolbox.isDownloading && toolbox.viewPage != "loading" && toolbox.viewPage != "errored"
            onClicked:
            {
                toolbox.filterModelByProp("authors", "package_types", "material")
                toolbox.viewCategory = "material"
                toolbox.viewPage = "overview"
            }
        }

        ToolboxTabButton
        {
            id: installedTabButton
            text: catalog.i18nc("@title:tab", "Installed")
            active: toolbox.viewCategory == "installed"
            enabled: !toolbox.isDownloading
            onClicked: toolbox.viewCategory = "installed"
            width: QD.Theme.getSize("toolbox_header_tab").width + marketplaceNotificationIcon.width - QD.Theme.getSize("default_margin").width
        }


    }

    QIDI.NotificationIcon
    {
        id: marketplaceNotificationIcon
        visible: QIDIApplication.getPackageManager().packagesWithUpdate.length > 0
        anchors.right: bar.right
        labelText:
        {
            const itemCount = QIDIApplication.getPackageManager().packagesWithUpdate.length
            return itemCount > 9 ? "9+" : itemCount
        }
    }


    QD.TooltipArea
    {
        id: webMarketplaceButtonTooltipArea
        width: childrenRect.width
        height: parent.height
        text: catalog.i18nc("@info:tooltip", "Go to Web Marketplace")
        anchors
        {
            right: parent.right
            rightMargin: QD.Theme.getSize("default_margin").width
            verticalCenter: parent.verticalCenter
        }
        acceptedButtons: Qt.LeftButton
        onClicked: Qt.openUrlExternally(toolbox.getWebMarketplaceUrl("plugins"))
        QD.RecolorImage
        {
            id: cloudMarketplaceButton
            source: "../../images/Shop.svg"
            color: QD.Theme.getColor(webMarketplaceButtonTooltipArea.containsMouse ? "primary" : "text")
            height: parent.height / 2
            width: height
            anchors.verticalCenter: parent.verticalCenter
            sourceSize.width: width
            sourceSize.height: height
        }
    }

    ToolboxShadow
    {
        anchors.top: bar.bottom
    }
}
