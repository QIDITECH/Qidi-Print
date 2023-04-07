// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.5 as QIDI


//
// This component contains the content for the 'by IP' page of the "Add New Printer" flow of the on-boarding process.
//
Item
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    id: addPrinterByIpScreen

    // If there's a manual address resolve request in progress.
    property bool hasRequestInProgress: QIDIApplication.getDiscoveredPrintersModel().hasManualDeviceRequestInProgress
    // Indicates if a request has finished.
    property bool hasRequestFinished: false
    property string currentRequestAddress: ""

    property var discoveredPrinter: null
    property bool isPrinterDiscovered: discoveredPrinter != null
    // A printer can only be added if it doesn't have an unknown type and it's the host of a group.
    property bool canAddPrinter: isPrinterDiscovered && !discoveredPrinter.isUnknownMachineType && discoveredPrinter.isHostOfGroup

    // For validating IP address
    property var networkingUtil: QIDI.NetworkingUtil {}

    // QIDI-6483
    // For a manually added QD printer, the QD3OutputDevicePlugin will first create a LegacyQD device for it. Later,
    // when it gets more info from the printer, it will first REMOVE the LegacyQD device and then add a ClusterQD device.
    // The Add-by-IP page needs to make sure that the user do not add an unknown printer or a printer that's not the
    // host of a group. Because of the device list change, this page needs to react upon DiscoveredPrintersChanged so
    // it has the correct information.
    Connections
    {
        target: QIDIApplication.getDiscoveredPrintersModel()
        function onDiscoveredPrintersChanged()
        {
            if (hasRequestFinished && currentRequestAddress)
            {
                var printer = QIDIApplication.getDiscoveredPrintersModel().discoveredPrintersByAddress[currentRequestAddress]
                printer = printer ? printer : null
                discoveredPrinter = printer
            }
        }
    }

    // Make sure to cancel the current request when this page closes.
    onVisibleChanged:
    {
        if (!visible)
        {
            QIDIApplication.getDiscoveredPrintersModel().cancelCurrentManualDeviceRequest()
        }
    }

    Label
    {
        id: titleLabel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: catalog.i18nc("@label", "Add printer by IP address")
        color: QD.Theme.getColor("primary_button")
        font: QD.Theme.getFont("huge")
        renderType: Text.NativeRendering
    }

    Item
    {
        anchors.top: titleLabel.bottom
        anchors.bottom: connectButton.top
        anchors.topMargin: QD.Theme.getSize("default_margin").height
        anchors.bottomMargin: QD.Theme.getSize("default_margin").height
        anchors.left: parent.left
        anchors.right: parent.right

        Item
        {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: QD.Theme.getSize("default_margin").width

            Label
            {
                id: explainLabel
                height: contentHeight
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                font: QD.Theme.getFont("default")
                color: QD.Theme.getColor("text")
                renderType: Text.NativeRendering
                text: catalog.i18nc("@label", "Enter the IP address of your printer on the network.")
            }

            Item
            {
                id: userInputFields
                height: childrenRect.height
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: explainLabel.bottom
                anchors.topMargin: QD.Theme.getSize("default_margin").width

                QIDI.TextField
                {
                    id: hostnameField
                    width: (parent.width / 2) | 0
                    height: addPrinterButton.height
                    anchors.verticalCenter: addPrinterButton.verticalCenter
                    anchors.left: parent.left

                    signal invalidInputDetected()

                    onInvalidInputDetected: invalidInputLabel.visible = true

                    validator: RegExpValidator
                    {
                        regExp: /([a-fA-F0-9.:]+)?/
                    }

                    onTextEdited: invalidInputLabel.visible = false

                    placeholderText: catalog.i18nc("@text", "Enter your printer's IP address.")

                    enabled: { ! (addPrinterByIpScreen.hasRequestInProgress || addPrinterByIpScreen.isPrinterDiscovered) }
                    onAccepted: addPrinterButton.clicked()
                }

                Label
                {
                    id: invalidInputLabel
                    anchors.top: hostnameField.bottom
                    anchors.topMargin: QD.Theme.getSize("default_margin").height
                    anchors.left: parent.left
                    visible: false
                    text: catalog.i18nc("@text", "Please enter a valid IP address.")
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    renderType: Text.NativeRendering
                }

                QIDI.SecondaryButton
                {
                    id: addPrinterButton
                    anchors.top: parent.top
                    anchors.left: hostnameField.right
                    anchors.leftMargin: QD.Theme.getSize("default_margin").width
                    text: catalog.i18nc("@button", "Add")
                    enabled: !addPrinterByIpScreen.hasRequestInProgress && !addPrinterByIpScreen.isPrinterDiscovered && (hostnameField.state != "invalid" && hostnameField.text != "")
                    onClicked:
                    {
                        addPrinterByIpScreen.hasRequestFinished = false //In case it's pressed multiple times.
                        const address = hostnameField.text
                        if (!networkingUtil.isValidIP(address))
                        {
                            hostnameField.invalidInputDetected()
                            return
                        }

                        // This address is already in the discovered printer model, no need to add a manual discovery.
                        if (QIDIApplication.getDiscoveredPrintersModel().discoveredPrintersByAddress[address])
                        {
                            addPrinterByIpScreen.discoveredPrinter = QIDIApplication.getDiscoveredPrintersModel().discoveredPrintersByAddress[address]
                            addPrinterByIpScreen.hasRequestFinished = true
                            return
                        }

                        addPrinterByIpScreen.currentRequestAddress = address
                        QIDIApplication.getDiscoveredPrintersModel().checkManualDevice(address)
                    }
                    busy: addPrinterByIpScreen.hasRequestInProgress
                }
            }

            Item
            {
                width: parent.width
                anchors.top: userInputFields.bottom
                anchors.margins: QD.Theme.getSize("default_margin").width

                Label
                {
                    id: waitResponseLabel
                    anchors.top: parent.top
                    anchors.margins: QD.Theme.getSize("default_margin").width
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    renderType: Text.NativeRendering

                    visible: addPrinterByIpScreen.hasRequestInProgress || (addPrinterByIpScreen.hasRequestFinished && !addPrinterByIpScreen.isPrinterDiscovered)
                    textFormat: Text.RichText
                    text:
                    {
                        if (addPrinterByIpScreen.hasRequestFinished)
                        {
                            return catalog.i18nc("@label", "Could not connect to device.") + "<br /><br /><a href=\"https://qidi.com/en/resources/52891-set-up-a-cloud-connection\">"
                                + catalog.i18nc("@label", "Can't connect to your QIDI printer?") + "</a>";
                        }
                        else
                        {
                            return catalog.i18nc("@label", "The printer at this address has not responded yet.") + "<br /><br /><a href=\"https://qidi.com/en/resources/52891-set-up-a-cloud-connection\">"
                                + catalog.i18nc("@label", "Can't connect to your QIDI printer?") + "</a>";
                        }
                    }
                    onLinkActivated: Qt.openUrlExternally(link)
                }

                Item
                {
                    id: printerInfoLabels
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: QD.Theme.getSize("default_margin").width

                    visible: addPrinterByIpScreen.isPrinterDiscovered

                    Label
                    {
                        id: printerNameLabel
                        anchors.top: parent.top
                        font: QD.Theme.getFont("large")
                        color: QD.Theme.getColor("text")
                        renderType: Text.NativeRendering

                        text: !addPrinterByIpScreen.isPrinterDiscovered ? "???" : addPrinterByIpScreen.discoveredPrinter.name
                    }

                    Label
                    {
                        id: printerCannotBeAddedLabel
                        width: parent.width
                        anchors.top: printerNameLabel.bottom
                        anchors.topMargin: QD.Theme.getSize("default_margin").height
                        text: catalog.i18nc("@label", "This printer cannot be added because it's an unknown printer or it's not the host of a group.")
                        visible: addPrinterByIpScreen.hasRequestFinished && !addPrinterByIpScreen.canAddPrinter
                        font: QD.Theme.getFont("default_bold")
                        color: QD.Theme.getColor("text")
                        renderType: Text.NativeRendering
                        wrapMode: Text.WordWrap
                    }

                    GridLayout
                    {
                        id: printerInfoGrid
                        anchors.top: printerCannotBeAddedLabel ? printerCannotBeAddedLabel.bottom : printerNameLabel.bottom
                        anchors.margins: QD.Theme.getSize("default_margin").width
                        columns: 2
                        columnSpacing: QD.Theme.getSize("default_margin").width

                        Label
                        {
                            text: catalog.i18nc("@label", "Type")
                            font: QD.Theme.getFont("default")
                            color: QD.Theme.getColor("text")
                            renderType: Text.NativeRendering
                        }
                        Label
                        {
                            id: typeText
                            text: !addPrinterByIpScreen.isPrinterDiscovered ? "?" : addPrinterByIpScreen.discoveredPrinter.readableMachineType
                            font: QD.Theme.getFont("default")
                            color: QD.Theme.getColor("text")
                            renderType: Text.NativeRendering
                        }

                        Label
                        {
                            text: catalog.i18nc("@label", "Firmware version")
                            font: QD.Theme.getFont("default")
                            color: QD.Theme.getColor("text")
                            renderType: Text.NativeRendering
                        }
                        Label
                        {
                            id: firmwareText
                            text: !addPrinterByIpScreen.isPrinterDiscovered ? "6.0.0" : addPrinterByIpScreen.discoveredPrinter.device.getProperty("firmware_version")
                            font: QD.Theme.getFont("default")
                            color: QD.Theme.getColor("text")
                            renderType: Text.NativeRendering
                        }

                        Label
                        {
                            text: catalog.i18nc("@label", "Address")
                            font: QD.Theme.getFont("default")
                            color: QD.Theme.getColor("text")
                            renderType: Text.NativeRendering
                        }
                        Label
                        {
                            id: addressText
                            text: !addPrinterByIpScreen.isPrinterDiscovered ? "6.0.0" : addPrinterByIpScreen.discoveredPrinter.address
                            font: QD.Theme.getFont("default")
                            color: QD.Theme.getColor("text")
                            renderType: Text.NativeRendering
                        }
                    }

                    Connections
                    {
                        target: QIDIApplication.getDiscoveredPrintersModel()
                        function onManualDeviceRequestFinished(success)
                        {
                            var discovered_printers_model = QIDIApplication.getDiscoveredPrintersModel()
                            var printer = discovered_printers_model.discoveredPrintersByAddress[hostnameField.text]
                            if (printer)
                            {
                                addPrinterByIpScreen.discoveredPrinter = printer
                            }
                            addPrinterByIpScreen.hasRequestFinished = true
                        }
                    }
                }
            }
        }
    }

    QIDI.SecondaryButton
    {
        id: backButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: catalog.i18nc("@button", "Back")
        onClicked:
        {
            QIDIApplication.getDiscoveredPrintersModel().cancelCurrentManualDeviceRequest()
            base.showPreviousPage()
        }
    }

    QIDI.PrimaryButton
    {
        id: connectButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: catalog.i18nc("@button", "Connect")
        onClicked:
        {
            QIDIApplication.getDiscoveredPrintersModel().createMachineFromDiscoveredPrinter(discoveredPrinter)
            base.showNextPage()
        }

        enabled: addPrinterByIpScreen.canAddPrinter
    }
}
