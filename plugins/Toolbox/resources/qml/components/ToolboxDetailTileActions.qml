// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QD 1.5 as QD
import QIDI 1.1 as QIDI

Column
{
    property bool installed: toolbox.isInstalled(model.id)
    property bool canUpdate: QIDIApplication.getPackageManager().packagesWithUpdate.indexOf(model.id) != -1
    property bool loginRequired: model.login_required && !QIDI.API.account.isLoggedIn
    property var packageData

    width: QD.Theme.getSize("toolbox_action_button").width
    spacing: QD.Theme.getSize("narrow_margin").height

    Item
    {
        width: installButton.width
        height: installButton.height
        ToolboxProgressButton
        {
            id: installButton
            active: toolbox.isDownloading && toolbox.activePackage == model
            onReadyAction:
            {
                toolbox.activePackage = model
                toolbox.startDownload(model.download_url)
            }
            onActiveAction: toolbox.cancelDownload()

            // Don't allow installing while another download is running
            enabled: installed || (!(toolbox.isDownloading && toolbox.activePackage != model) && !loginRequired)
            opacity: enabled ? 1.0 : 0.5
            visible: !updateButton.visible && !installed // Don't show when the update button is visible
        }

        QIDI.SecondaryButton
        {
            id: installedButton
            visible: installed
            onClicked: toolbox.viewCategory = "installed"
            text: catalog.i18nc("@action:button", "Installed")
            fixedWidthMode: true
            width: installButton.width
            height: installButton.height
        }
    }

    Label
    {
        wrapMode: Text.WordWrap
        text: catalog.i18nc("@label:The string between <a href=> and </a> is the highlighted link", "<a href='%1'>Log in</a> is required to install or update")
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        linkColor: QD.Theme.getColor("text_link")
        visible: loginRequired
        width: installButton.width
        renderType: Text.NativeRendering

        MouseArea
        {
            anchors.fill: parent
            onClicked: QIDI.API.account.login()
        }
    }

    Label
    {
        property var whereToBuyUrl:
        {
            var pg_name = "whereToBuy"
            return (pg_name in packageData.links) ? packageData.links[pg_name] : undefined
        }

        renderType: Text.NativeRendering
        text: catalog.i18nc("@label:The string between <a href=> and </a> is the highlighted link", "<a href='%1'>Buy material spools</a>")
        linkColor: QD.Theme.getColor("text_link")
        visible: whereToBuyUrl != undefined
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        MouseArea
        {
            anchors.fill: parent
            onClicked: QD.UrlUtil.openUrl(parent.whereToBuyUrl, ["https", "http"])
        }
    }

    ToolboxProgressButton
    {
        id: updateButton
        active: toolbox.isDownloading && toolbox.activePackage == model
        readyLabel: catalog.i18nc("@action:button", "Update")
        activeLabel: catalog.i18nc("@action:button", "Updating")
        completeLabel: catalog.i18nc("@action:button", "Updated")

        onReadyAction:
        {
            toolbox.activePackage = model
            toolbox.update(model.id)
        }
        onActiveAction: toolbox.cancelDownload()
        // Don't allow installing while another download is running
        enabled: !(toolbox.isDownloading && toolbox.activePackage != model) && !loginRequired
        opacity: enabled ? 1.0 : 0.5
        visible: canUpdate
    }

    Connections
    {
        target: toolbox
        function onInstallChanged() { installed = toolbox.isInstalled(model.id) }
        function onFilterChanged()
        {
            installed = toolbox.isInstalled(model.id)
        }
    }
}
