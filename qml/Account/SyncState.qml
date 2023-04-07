import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.4 as QD
import QIDI 1.1 as QIDI

Row // Sync state icon + message
{
    property var syncState: QIDI.API.account.syncState

    id: syncRow
    width: childrenRect.width
    height: childrenRect.height
    spacing: QD.Theme.getSize("narrow_margin").height

    states: [
        State
        {
            name: "idle"
            when: syncState == QIDI.AccountSyncState.IDLE
            PropertyChanges { target: icon; source: QD.Theme.getIcon("ArrowDoubleCircleRight")}
        },
        State
        {
            name: "syncing"
            when: syncState == QIDI.AccountSyncState.SYNCING
            PropertyChanges { target: icon; source: QD.Theme.getIcon("ArrowDoubleCircleRight") }
            PropertyChanges { target: stateLabel; text: catalog.i18nc("@label", "Checking...")}
        },
        State
        {
            name: "up_to_date"
            when: syncState == QIDI.AccountSyncState.SUCCESS
            PropertyChanges { target: icon; source: QD.Theme.getIcon("CheckCircle") }
            PropertyChanges { target: stateLabel; text: catalog.i18nc("@label", "Account synced")}
        },
        State
        {
            name: "error"
            when: syncState == QIDI.AccountSyncState.ERROR
            PropertyChanges { target: icon; source: QD.Theme.getIcon("Warning") }
            PropertyChanges { target: stateLabel; text: catalog.i18nc("@label", "Something went wrong...")}
        }
    ]

    QD.RecolorImage
    {
        id: icon
        width: 20 * screenScaleFactor
        height: width

        // source is determined by State
        color: QD.Theme.getColor("account_sync_state_icon")

        RotationAnimator
        {
            id: updateAnimator
            target: icon
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: syncState == QIDI.AccountSyncState.SYNCING

            // reset rotation when stopped
            onRunningChanged: {
                if(!running)
                {
                    icon.rotation = 0
                }
            }
        }
    }

    Column
    {
        width: childrenRect.width
        height: childrenRect.height

        Label
        {
            id: stateLabel
            // text is determined by State
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("medium")
            renderType: Text.NativeRendering
            width: contentWidth + QD.Theme.getSize("default_margin").height
            height: contentHeight
            verticalAlignment: Text.AlignVCenter
            visible: !QIDI.API.account.manualSyncEnabled && !QIDI.API.account.updatePackagesEnabled
        }

        Label
        {
            id: updatePackagesButton
            text: catalog.i18nc("@button", "Install pending updates")
            color: QD.Theme.getColor("text_link")
            font: QD.Theme.getFont("medium")
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            height: contentHeight
            width: contentWidth + QD.Theme.getSize("default_margin").height
            visible: QIDI.API.account.updatePackagesEnabled

            MouseArea
            {
                anchors.fill: parent
                onClicked: QIDI.API.account.onUpdatePackagesClicked()
                hoverEnabled: true
                onEntered: updatePackagesButton.font.underline = true
                onExited: updatePackagesButton.font.underline = false
            }
        }

        Label
        {
            id: accountSyncButton
            text: catalog.i18nc("@button", "Check for account updates")
            color: QD.Theme.getColor("text_link")
            font: QD.Theme.getFont("medium")
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            height: contentHeight
            width: contentWidth + QD.Theme.getSize("default_margin").height
            visible: QIDI.API.account.manualSyncEnabled

            MouseArea
            {
                anchors.fill: parent
                onClicked: QIDI.API.account.sync(true)
                hoverEnabled: true
                onEntered: accountSyncButton.font.underline = true
                onExited: accountSyncButton.font.underline = false
            }
        }
    }
}
