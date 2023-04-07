// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QD 1.1 as QD

import QIDI 1.1 as QIDI

Column
{
    property bool canUpdate: QIDIApplication.getPackageManager().packagesWithUpdate.indexOf(model.id) != -1
    property bool canDowngrade: false
    property bool loginRequired: model.login_required && !QIDI.API.account.isLoggedIn
    width: QD.Theme.getSize("toolbox_action_button").width
    spacing: QD.Theme.getSize("narrow_margin").height

    Label
    {
        visible: !model.is_installed
        text: catalog.i18nc("@label", "Will install upon restarting")
        color: QD.Theme.getColor("lining")
        font: QD.Theme.getFont("default")
        wrapMode: Text.WordWrap
        width: parent.width
        renderType: Text.NativeRendering
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

    Label
    {
        wrapMode: Text.WordWrap
        text: catalog.i18nc("@label:The string between <a href=> and </a> is the highlighted link", "<a href='%1'>Log in</a> is required to update")
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
        linkColor: QD.Theme.getColor("text_link")
        visible: loginRequired
        width: updateButton.width
        renderType: Text.NativeRendering

        MouseArea
        {
            anchors.fill: parent
            onClicked: QIDI.API.account.login()
        }
    }

    QIDI.SecondaryButton
    {
        id: removeButton
        text: canDowngrade ? catalog.i18nc("@action:button", "Downgrade") : catalog.i18nc("@action:button", "Uninstall")
        visible: !model.is_bundled && model.is_installed
        enabled: !toolbox.isDownloading

        width: QD.Theme.getSize("toolbox_action_button").width
        height: QD.Theme.getSize("toolbox_action_button").height

        fixedWidthMode: true

        onClicked: toolbox.checkPackageUsageAndUninstall(model.id)
        Connections
        {
            target: toolbox
            function onMetadataChanged()
            {
                canDowngrade = toolbox.canDowngrade(model.id)
            }
        }
    }
}
