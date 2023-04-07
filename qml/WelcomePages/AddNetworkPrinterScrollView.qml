// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI

//
// This is the widget for adding a network printer. There are 2 parts in this widget. One is a scroll view of a list
// of discovered network printers. Beneath the scroll view is a container with 3 buttons: "Refresh", "Add by IP", and
// "Troubleshooting".
//
Item
{
    id: base
    height: networkPrinterInfo.height + controlsRectangle.height

    property alias maxItemCountAtOnce: networkPrinterScrollView.maxItemCountAtOnce
    property var currentItem: (networkPrinterListView.currentIndex >= 0)
                              ? networkPrinterListView.model[networkPrinterListView.currentIndex]
                              : null

    signal refreshButtonClicked()
    signal addByIpButtonClicked()
    signal addCloudPrinterButtonClicked()

    Item
    {
        id: networkPrinterInfo
        height: networkPrinterScrollView.visible ? networkPrinterScrollView.height : noPrinterLabel.height
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Label
        {
            id: noPrinterLabel
            height: QD.Theme.getSize("setting_control").height + QD.Theme.getSize("default_margin").height
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            text: catalog.i18nc("@label", "There is no printer found over your network.")
            color: QD.Theme.getColor("text")
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            visible: networkPrinterListView.count == 0  // Do not show if there are discovered devices.
        }

        ScrollView
        {
            id: networkPrinterScrollView
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            property int maxItemCountAtOnce: 8  // show at max 8 items at once, otherwise you need to scroll.
            height: Math.min(contentHeight, (maxItemCountAtOnce * QD.Theme.getSize("action_button").height) - QD.Theme.getSize("default_margin").height)

            visible: networkPrinterListView.count > 0

            clip: true

            ListView
            {
                id: networkPrinterListView
                anchors.fill: parent
                model: contentLoader.enabled ? QIDIApplication.getDiscoveredPrintersModel().discoveredPrinters: undefined

                section.property: "modelData.sectionName"
                section.criteria: ViewSection.FullString
                section.delegate: sectionHeading
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 20000  // To prevent the flicking behavior.
                cacheBuffer: 1000000   // Set a large cache to effectively just cache every list item.

                Component.onCompleted:
                {
                    var toSelectIndex = -1
                    // Select the first one that's not "unknown" and is the host a group by default.
                    for (var i = 0; i < count; i++)
                    {
                        if (!model[i].isUnknownMachineType && model[i].isHostOfGroup)
                        {
                            toSelectIndex = i
                            break
                        }
                    }
                    currentIndex = toSelectIndex
                }

                // QIDI-6483 For some reason currentIndex can be reset to 0. This check is here to prevent automatically
                // selecting an unknown or non-host printer.
                onCurrentIndexChanged:
                {
                    var item = model[currentIndex]
                    if (!item || item.isUnknownMachineType || !item.isHostOfGroup)
                    {
                        currentIndex = -1
                    }
                }

                Component
                {
                    id: sectionHeading

                    Label
                    {
                        anchors.left: parent.left
                        anchors.leftMargin: QD.Theme.getSize("default_margin").width
                        height: QD.Theme.getSize("setting_control").height
                        text: section
                        font: QD.Theme.getFont("default")
                        color: QD.Theme.getColor("small_button_text")
                        verticalAlignment: Text.AlignVCenter
                        renderType: Text.NativeRendering
                    }
                }

                delegate: QIDI.MachineSelectorButton
                {
                    text: modelData.device.name

                    width: networkPrinterListView.width
                    outputDevice: modelData.device

                    enabled: !modelData.isUnknownMachineType && modelData.isHostOfGroup

                    printerTypeLabelAutoFit: true

                    // update printer types for all items in the list
                    updatePrinterTypesOnlyWhenChecked: false
                    updatePrinterTypesFunction: updateMachineTypes
                    // show printer type as it is
                    printerTypeLabelConversionFunction: function(value) { return value }

                    function updateMachineTypes()
                    {
                        printerTypesList = [ modelData.readableMachineType ]
                    }

                    checkable: false
                    selected: ListView.view.currentIndex == model.index
                    onClicked:
                    {
                        ListView.view.currentIndex = index
                    }
                }
            }
        }
    }

    // Horizontal line separating the buttons (below) and the discovered network printers (above)
    Rectangle
    {
        id: separator
        anchors.left: parent.left
        anchors.top: networkPrinterInfo.bottom
        anchors.right: parent.right
        height: QD.Theme.getSize("default_lining").height
        color: QD.Theme.getColor("lining")
    }

    Item
    {
        id: controlsRectangle
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: separator.bottom

        height: QD.Theme.getSize("message_action_button").height + QD.Theme.getSize("default_margin").height

        QIDI.SecondaryButton
        {
            id: refreshButton
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            anchors.verticalCenter: parent.verticalCenter
            text: catalog.i18nc("@label", "Refresh")
            height: QD.Theme.getSize("message_action_button").height
            onClicked: base.refreshButtonClicked()
        }

        QIDI.SecondaryButton
        {
            id: addPrinterByIpButton
            anchors.left: refreshButton.right
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            anchors.verticalCenter: parent.verticalCenter
            text: catalog.i18nc("@label", "Add printer by IP")
            height: QD.Theme.getSize("message_action_button").height
            onClicked: base.addByIpButtonClicked()
        }

        QIDI.SecondaryButton
        {
            id: addCloudPrinterButton
            anchors.left: addPrinterByIpButton.right
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            anchors.verticalCenter: parent.verticalCenter
            text: catalog.i18nc("@label", "Add cloud printer")
            height: QD.Theme.getSize("message_action_button").height
            onClicked: {
                QIDIApplication.getDiscoveredCloudPrintersModel().clear()
                base.addCloudPrinterButtonClicked()
            }
        }

        Item
        {
            id: troubleshootingButton

            anchors.right: parent.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            anchors.verticalCenter: parent.verticalCenter
            height: troubleshootingLinkIcon.height
            width: troubleshootingLinkIcon.width + troubleshootingLabel.width + QD.Theme.getSize("default_margin").width

            QD.RecolorImage
            {
                id: troubleshootingLinkIcon
                anchors.right: troubleshootingLabel.left
                anchors.rightMargin: QD.Theme.getSize("default_margin").width
                anchors.verticalCenter: parent.verticalCenter
                height: troubleshootingLabel.height
                width: height
                sourceSize.height: width
                color: QD.Theme.getColor("text_link")
                source: QD.Theme.getIcon("LinkExternal")
            }

            Label
            {
                id: troubleshootingLabel
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: catalog.i18nc("@label", "Troubleshooting")
                font: QD.Theme.getFont("default")
                color: QD.Theme.getColor("text_link")
                linkColor: QD.Theme.getColor("text_link")
                renderType: Text.NativeRendering
            }

            MouseArea
            {
                anchors.fill: parent
                hoverEnabled: true
                onClicked:
                {
                    // open the troubleshooting URL with web browser
                    const url = "https://qidi.com/in/qidi/troubleshooting/network"
                    Qt.openUrlExternally(url)
                }
                onEntered:
                {
                    troubleshootingLabel.font.underline = true
                }
                onExited:
                {
                    troubleshootingLabel.font.underline = false
                }
            }
        }
    }
}
