// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.1 as QIDI

QIDI.ExpandablePopup
{
    id: machineSelector

    property bool isNetworkPrinter: QIDI.MachineManager.activeMachineHasNetworkConnection
    property bool isConnectedCloudPrinter: QIDI.MachineManager.activeMachineHasCloudConnection
    property bool isCloudRegistered: QIDI.MachineManager.activeMachineHasCloudRegistration
    property bool isGroup: QIDI.MachineManager.activeMachineIsGroup

    readonly property string connectionStatus: {
        if (isNetworkPrinter)
        {
            return "printer_connected"
        }
        else if (isConnectedCloudPrinter && QIDI.API.connectionStatus.isInternetReachable)
        {
            return "printer_cloud_connected"
        }
        else if (isCloudRegistered)
        {
            return "printer_cloud_not_available"
        }
        else
        {
            return ""
        }
    }

    function getConnectionStatusMessage() {
        if (connectionStatus == "printer_cloud_not_available")
        {
            if(QIDI.API.connectionStatus.isInternetReachable)
            {
                if (QIDI.API.account.isLoggedIn)
                {
                    if (QIDI.MachineManager.activeMachineIsLinkedToCurrentAccount)
                    {
                        return catalog.i18nc("@status", "The cloud printer is offline. Please check if the printer is turned on and connected to the internet.")
                    }
                    else
                    {
                        return catalog.i18nc("@status", "This printer is not linked to your account. Please visit the QIDI Digital Factory to establish a connection.")
                    }
                }
                else
                {
                    return catalog.i18nc("@status", "The cloud connection is currently unavailable. Please sign in to connect to the cloud printer.")
                }
            } else
            {
                return catalog.i18nc("@status", "The cloud connection is currently unavailable. Please check your internet connection.")
            }
        }
        else
        {
            return ""
        }
    }

    contentPadding: QD.Theme.getSize("default_lining").width
    contentAlignment: QIDI.ExpandablePopup.ContentAlignment.AlignLeft

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    headerBackgroundColor: QD.Theme.getColor("blue_6")
    headerHoverColor: QD.Theme.getColor("blue_6")
    headerCornerSide: QIDI.RoundedRectangle.Direction.Left
    headerRadius: Math.round(height / 2)
    expandedHighlightColor: QD.Theme.getColor("white_2")
    iconColor: QD.Theme.getColor("white_1")
    headerItem: QIDI.IconWithText
    {
        text:
        {
            if (isNetworkPrinter && QIDI.MachineManager.activeMachineNetworkGroupName != "")
            {
                return QIDI.MachineManager.activeMachineNetworkGroupName
            }
            if(QIDI.MachineManager.activeMachine != null)
            {
				QIDIApplication.parameter_testf_change("")
				//QIDIApplication.writeToLog("e",QIDI.MachineManager.activeMachine.name)
				QIDIApplication.parameter_testf_change("Machine")
                return QIDI.MachineManager.activeMachine.name
            }
            return ""
        }
        source:
        {
            if (isGroup)
            {
                return QD.Theme.getIcon("PrinterTriple")
            }
            else if (isNetworkPrinter || isCloudRegistered)
            {
                return QD.Theme.getIcon("Printer")
            }
            else
            {
                return ""
            }
        }
        font: QD.Theme.getFont("font4")
        color: QD.Theme.getColor("white_1")
        iconColor: QD.Theme.getColor("machine_selector_printer_icon")
        iconSize: source != "" ? QD.Theme.getSize("machine_selector_icon").width : 0

        QD.RecolorImage
        {
            id: connectionStatusImage
            anchors
            {
                bottom: parent.bottom
                left: parent.left
                leftMargin: QD.Theme.getSize("thick_margin").width
            }

            source:
            {
                if (connectionStatus == "printer_connected")
                {
                    return QD.Theme.getIcon("CheckBlueBG", "low")
                }
                else if (connectionStatus == "printer_cloud_connected")
                {
                    return QD.Theme.getIcon("CloudBlueBG", "low")
                }
                else if (connectionStatus == "printer_cloud_not_available")
                {
                    return QD.Theme.getIcon("CloudGreyBG", "low")
                }
                else
                {
                    return ""
                }
            }

            width: QD.Theme.getSize("printer_status_icon").width
            height: QD.Theme.getSize("printer_status_icon").height

            color: connectionStatus == "printer_cloud_not_available" ? QD.Theme.getColor("cloud_unavailable") : QD.Theme.getColor("primary")

            visible: isNetworkPrinter || isCloudRegistered

            // Make a themable circle in the background so we can change it in other themes
            Rectangle
            {
                id: iconBackground
                anchors.centerIn: parent
                // Make it a bit bigger so there is an outline
                width: parent.width + 2 * QD.Theme.getSize("default_lining").width
                height: parent.height + 2 * QD.Theme.getSize("default_lining").height
                radius: Math.round(width / 2)
                color: QD.Theme.getColor("main_background")
                z: parent.z - 1
            }

        }

        MouseArea // Connection status tooltip hover area
        {
            id: connectionStatusTooltipHoverArea
            anchors.fill: parent
            hoverEnabled: getConnectionStatusMessage() !== ""
            acceptedButtons: Qt.NoButton // react to hover only, don't steal clicks

            onEntered:
            {
                machineSelector.mouseArea.entered() // we want both this and the outer area to be entered
                tooltip.tooltipText = getConnectionStatusMessage()
                tooltip.show()
            }
            onExited: { tooltip.hide() }
        }

        QIDI.ToolTip
        {
            id: tooltip

            width: 250 * screenScaleFactor
            tooltipText: getConnectionStatusMessage()
            arrowSize: QD.Theme.getSize("button_tooltip_arrow").width
            x: connectionStatusImage.x - QD.Theme.getSize("narrow_margin").width
            y: connectionStatusImage.y + connectionStatusImage.height + QD.Theme.getSize("narrow_margin").height
            z: popup.z + 1
            targetPoint: Qt.point(
                connectionStatusImage.x + Math.round(connectionStatusImage.width / 2),
                connectionStatusImage.y
            )
        }
    }

    enableHeaderShadow: false

    contentItem: Item
    {
        id: popup
        width: machineSelector.width

        ScrollView
        {
            id: scroll
            width: parent.width
            clip: true
            leftPadding: QD.Theme.getSize("default_lining").width
            rightPadding: QD.Theme.getSize("default_lining").width

            MachineSelectorList
            {
                id: machineSelectorList
                // Can't use parent.width since the parent is the flickable component and not the ScrollView
                width: scroll.width - scroll.leftPadding - scroll.rightPadding
                property real maximumHeight: QD.Theme.getSize("machine_selector_widget_content").height

                // We use an extra property here, since we only want to to be informed about the content size changes.
                onContentHeightChanged:
                {
                    scroll.height = Math.min(contentHeight, maximumHeight)
                    popup.height = scroll.height + buttonRow.height 
                }

                Component.onCompleted:
                {
                    scroll.height = Math.min(contentHeight, maximumHeight)
                    popup.height = scroll.height + buttonRow.height
                }
            }
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.horizontal.interactive: false
        }


        Rectangle
        {
            id: separator

            anchors.top: scroll.bottom
            width: parent.width
            height: QD.Theme.getSize("default_lining").height
            color: QD.Theme.getColor("lining")
        }
        
        Row
        {
            id: buttonRow

            // The separator is inside the buttonRow. This is to avoid some weird behaviours with the scroll bar.
            anchors.top: separator.top
            anchors.horizontalCenter: parent.horizontalCenter
            padding: QD.Theme.getSize("default_margin").width
            spacing: QD.Theme.getSize("default_margin").width

            QIDI.PrimaryButton
            {
                id: addPrinterButton

                backgroundRadius: Math.round(height / 2)
                leftPadding: QD.Theme.getSize("default_margin").width
                rightPadding: QD.Theme.getSize("default_margin").width
                text: catalog.i18nc("@button", "Add printer")
            
                // The maximum width of the button is half of the total space, minus the padding of the parent, the left
                // padding of the component and half the spacing because of the space between buttons.
                fixedWidthMode: true
                width: QD.Theme.getSize("machine_selector_widget_content").width / 2 - leftPadding
                onClicked:
                {
                    toggleContent()
                    QIDI.Actions.addMachine.trigger()
                }
            }
        }
    }
}
