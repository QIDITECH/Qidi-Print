// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This component contains the content for the "Welcome" page of the welcome on-boarding process.
//
QIDI.MachineAction
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    anchors.fill: parent

    property var extrudersModel: QIDI.ExtrudersModel {}

    // If we create a TabButton for "Printer" and use Repeater for extruders, for some reason, once the component
    // finishes it will automatically change "currentIndex = 1", and it is VERY difficult to change "currentIndex = 0"
    // after that. Using a model and a Repeater to create both "Printer" and extruder TabButtons seem to solve this
    // problem.
    Connections
    {
        target: extrudersModel
        function onItemsChanged() { tabNameModel.update() }
    }

    ListModel
    {
        id: tabNameModel

        Component.onCompleted: update()

        function update()
        {
            clear()
            append({ name: catalog.i18nc("@title:tab", "Printer") })
            for (var i = 0; i < extrudersModel.count; i++)
            {
                const m = extrudersModel.getItem(i)
                append({ name: m.name })
            }
        }
    }

    QIDI.RoundedRectangle
    {
        anchors
        {
            top: tabBar.bottom
            topMargin: -QD.Theme.getSize("default_lining").height
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        cornerSide: QIDI.RoundedRectangle.Direction.Down
        border.color: QD.Theme.getColor("lining")
        border.width: QD.Theme.getSize("default_lining").width
        radius: QD.Theme.getSize("default_radius").width
        color: QD.Theme.getColor("main_background")
        StackLayout
        {
            id: tabStack
            anchors.fill: parent

            currentIndex: tabBar.currentIndex

            MachineSettingsPrinterTab
            {
                id: printerTab
            }

            Repeater
            {
                model: extrudersModel
                delegate: MachineSettingsExtruderTab
                {
                    id: discoverTab
                    extruderPosition: model.index
                    extruderStackId: model.id
                }
            }
        }
    }

    Label
    {
        id: machineNameLabel
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        text: QIDI.MachineManager.activeMachine.name
        horizontalAlignment: Text.AlignHCenter
        font: QD.Theme.getFont("large_bold")
        renderType: Text.NativeRendering
    }

    QD.TabRow
    {
        id: tabBar
        anchors.top: machineNameLabel.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height
        width: parent.width
        Repeater
        {
            model: tabNameModel
            delegate: QD.TabRowButton
            {
                text: model.name
            }
        }
    }
}
