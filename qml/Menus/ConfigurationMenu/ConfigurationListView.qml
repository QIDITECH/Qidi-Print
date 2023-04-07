// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    id: base
    property var outputDevice: null
    height: childrenRect.height

    function forceModelUpdate()
    {
        // FIXME For now the model has to be removed and then created again, otherwise changes in the printer don't automatically update the UI
        configurationList.model = []
        if (outputDevice)
        {
            configurationList.model = outputDevice.uniqueConfigurations
        }
    }

    // This component will appear when there are no configurations (e.g. when losing connection or when they are being loaded)
    Item
    {
        width: parent.width
        visible: configurationList.model.length == 0
        height: label.height + QD.Theme.getSize("wide_margin").height
        anchors.top: parent.top
        anchors.topMargin: QD.Theme.getSize("default_margin").height

        QD.RecolorImage
        {
            id: icon

            anchors.left: parent.left
            anchors.verticalCenter: label.verticalCenter

            source: QD.Theme.getIcon("Warning")
            color: QD.Theme.getColor("warning")
            width: QD.Theme.getSize("section_icon").width
            height: width
        }

        Label
        {
            id: label
            anchors.left: icon.right
            anchors.right: parent.right
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            // There are two cases that we want to diferenciate, one is when QIDI is loading the configurations and the
            // other when the connection was lost
            text: QIDI.MachineManager.printerConnected ?
                    catalog.i18nc("@label", "Loading available configurations from the printer...") :
                    catalog.i18nc("@label", "The configurations are not available because the printer is disconnected.")
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default")
            renderType: Text.NativeRendering
            wrapMode: Text.WordWrap
        }
    }

    ScrollView
    {
        id: container
        width: parent.width
        readonly property int maximumHeight: 350 * screenScaleFactor
        height: Math.round(Math.min(configurationList.height, maximumHeight))
        contentHeight: configurationList.height
        clip: true

        ScrollBar.vertical.policy: (configurationList.height > maximumHeight) ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff //The AsNeeded policy also hides it when the cursor is away, and we don't want that.
        ScrollBar.vertical.background: Rectangle
        {
            implicitWidth: QD.Theme.getSize("scrollbar").width
            radius: width / 2
            color: QD.Theme.getColor("scrollbar_background")
        }
        ScrollBar.vertical.contentItem: Rectangle
        {
            implicitWidth: QD.Theme.getSize("scrollbar").width
            radius: width / 2
            color: QD.Theme.getColor(parent.pressed ? "scrollbar_handle_down" : parent.hovered ? "scrollbar_handle_hover" : "scrollbar_handle")
        }

        ButtonGroup
        {
            buttons: configurationList.children
        }

        ListView
        {
            id: configurationList
            spacing: QD.Theme.getSize("narrow_margin").height
            width: container.width - ((height > container.maximumHeight) ? container.ScrollBar.vertical.background.width : 0) //Make room for scroll bar if there is any.
            height: contentHeight
            interactive: false  // let the ScrollView process scroll events.

            section.property: "modelData.printerType"
            section.criteria: ViewSection.FullString
            section.delegate: Item
            {
                height: printerTypeLabel.height + QD.Theme.getSize("wide_margin").height //Causes a default margin above the label and a default margin below the label.
                QIDI.PrinterTypeLabel
                {
                    id: printerTypeLabel
                    text: section
                    anchors.verticalCenter: parent.verticalCenter //One default margin above and one below.
                    autoFit: true
                }
            }

            model: (outputDevice != null) ? outputDevice.uniqueConfigurations : []

            delegate: ConfigurationItem
            {
                width: parent.width
                configuration: modelData
            }
        }
    }

    Connections
    {
        target: outputDevice
        function onUniqueConfigurationsChanged()
        {
            forceModelUpdate()
        }
    }

    Connections
    {
        target: QIDI.MachineManager
        function onOutputDevicesChanged()
        {
            forceModelUpdate()
        }
    }
}
