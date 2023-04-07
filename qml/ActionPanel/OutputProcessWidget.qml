// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.0 as QIDI


// This element contains all the elements the user needs to visualize the data
// that is gather after the slicing process, such as printint time, material usage, ...
// There are also two buttons: one to previsualize the output layers, and the other to
// select what to do with it (such as print over network, save to file, ...)
Item
{
    id: widget

    property bool preSlicedData: PrintInformation.preSliced

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    QD.ProgressBar
    {
        id: progressBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 7 * QD.Theme.getSize("size").height
        value: QIDI.WifiSend.progress / 100
        visible: QIDI.WifiSend.progress > 0
    }

    Item
    {
        id: information
        anchors.bottom: buttonRow.top
        anchors.bottomMargin: 15 * QD.Theme.getSize("size").height
        anchors.left: buttonRow.left
        anchors.right: buttonRow.right
        height: childrenRect.height
        
        PrintInformationWidget
        {
            id: printInformationPanel
            visible: !preSlicedData
            anchors.right: parent.right
            anchors.verticalCenter: timeAndCostsInformation.verticalCenter
        }

        Row
        {
            id: timeAndCostsInformation
            spacing: 10 * QD.Theme.getSize("size").height

            anchors
            {
                left: parent.left
                right: parent.right
            }

            QIDI.IconWithText
            {
                id: estimatedTime
                width: parent.width / 2

                text: preSlicedData ? QIDIApplication.gcodePrintTime.getDisplayString(QD.DurationFormat.Seconds) <= 0?  catalog.i18nc("@label", "No time estimation available")  :  QIDIApplication.gcodePrintTime.getDisplayString(QD.DurationFormat.Long) : PrintInformation.currentPrintTime.getDisplayString(QD.DurationFormat.Long)
                source: QD.Theme.getIcon("Clock")
                font: QD.Theme.getFont("medium_bold")
            }

            QIDI.IconWithText
            {
                id: estimatedCosts
                width: parent.width / 2

                property var printMaterialLengths: PrintInformation.materialLengths
                property var printMaterialWeights: PrintInformation.materialWeights
                property var printMaterialCosts: PrintInformation.materialCosts

                text:
                {
                    if (preSlicedData)
                    {
                        return catalog.i18nc("@label", "No cost estimation available")
                    }
                    var totalLengths = 0
                    var totalWeights = 0
                    var totalCosts = 0.0
                    if (printMaterialLengths)
                    {
                        for(var index = 0; index < printMaterialLengths.length; index++)
                        {
                            if(printMaterialLengths[index] > 0)
                            {
                                totalLengths += printMaterialLengths[index]
                                totalWeights += Math.round(printMaterialWeights[index])
                                var cost = printMaterialCosts[index] == undefined ? 0.0 : printMaterialCosts[index]
                                totalCosts += cost
                            }
                        }
                    }
                    if(totalCosts > 0)
                    {
                        var costString = "%1 %2".arg(QD.Preferences.getValue("qidi/currency")).arg(totalCosts.toFixed(2))
                        return totalWeights + "g · " + totalLengths.toFixed(2) + "m · " + costString
                    }
                    return totalWeights + "g · " + totalLengths.toFixed(2) + "m"
                }
                source: QD.Theme.getIcon("Spool")
                font: QD.Theme.getFont("default")
            }
        }
    }

    Item
    {
        id: buttonRow
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15 * QD.Theme.getSize("size").height
        height: QD.Theme.getSize("action_button").height

        QIDI.SecondaryButton
        {
            id: previewStageShortcut
            anchors
            {
                left: parent.left
                right: outputDevicesButton.left
                rightMargin: QD.Theme.getSize("default_margin").width
            }
            height: QD.Theme.getSize("action_button").height
            backgroundRadius: Math.round(height / 2)
            text: catalog.i18nc("@button", "Preview")
            tooltip: previewStageShortcut.text
            fixedWidthMode: true
            toolTipContentAlignment: QIDI.ToolTip.ContentAlignment.AlignLeft
            onClicked: QD.Controller.setActiveView("SimulationView")
            visible: QD.Controller.activeView.name != "SimulationView"
        }

        QIDI.OutputDevicesActionButton
        {
            id: outputDevicesButton
            anchors.right: parent.right
            width: previewStageShortcut.visible ? 200 * QD.Theme.getSize("size").width : parent.width
            height: QD.Theme.getSize("action_button").height
        }
    }
}
