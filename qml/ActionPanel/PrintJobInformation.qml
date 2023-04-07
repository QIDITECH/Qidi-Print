// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1

import QD 1.1 as QD
import QIDI 1.0 as QIDI

Column
{
    id: base
    spacing: QD.Theme.getSize("default_margin").width

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    Column
    {
        id: timeSpecification
        width: parent.width
        topPadding: QD.Theme.getSize("default_margin").height
        leftPadding: QD.Theme.getSize("default_margin").width
        rightPadding: QD.Theme.getSize("default_margin").width

        Label
        {
            text: catalog.i18nc("@label", "Time estimation").toUpperCase()
            color: QD.Theme.getColor("primary")
            font: QD.Theme.getFont("default_bold")
            renderType: Text.NativeRendering
        }

        Label
        {
            id: byLineType

            property var printDuration: PrintInformation.currentPrintTime
            property var columnWidthMultipliers: [ 0.45, 0.3, 0.25 ]
			//property var columnWidthMultipliers: [ 0.2, 0.3, 0.25,0.25 ]

            property var columnHorizontalAligns: [ Text.AlignLeft, Text.AlignHCenter, Text.AlignRight ]

            function getMaterialTable()
            {
                var result = []

                // All the time information for the different features is achieved
                var printTime = PrintInformation.getFeaturePrintTimes()
                var totalSeconds = parseInt(printDuration.getDisplayString(QD.DurationFormat.Seconds))

                // A message is created and displayed when the user hover the time label
                for(var feature in printTime)
                {
                    if(!printTime[feature].isTotalDurationZero)
                    {
                        var row = []
                        row.push(feature + ": ")
                        row.push("%1".arg(printTime[feature].getDisplayString(QD.DurationFormat.ISO8601).slice(0,-3)))
                        row.push("%1%".arg(Math.round(100 * parseInt(printTime[feature].getDisplayString(QD.DurationFormat.Seconds)) / totalSeconds)))
                        result.push(row)
                    }
                }

                return result
            }

            Column
            {
                Repeater
                {
                    model: byLineType.getMaterialTable()
                    Row
                    {
                        Repeater
                        {
                            model: modelData
                            Label
                            {
                                width: Math.round(byLineType.width * byLineType.columnWidthMultipliers[index])
                                height: contentHeight
                                horizontalAlignment: byLineType.columnHorizontalAligns[index]
                                color: QD.Theme.getColor("text")
                                font: QD.Theme.getFont("default")
                                wrapMode: Text.WrapAnywhere
                                text: modelData
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }

            width: parent.width - 2 * QD.Theme.getSize("default_margin").width
            height: childrenRect.height
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default")
            renderType: Text.NativeRendering
            textFormat: Text.RichText
        }
    }

    Column
    {
        id: materialSpecification
        width: parent.width
        bottomPadding: QD.Theme.getSize("default_margin").height
        leftPadding: QD.Theme.getSize("default_margin").width
        rightPadding: QD.Theme.getSize("default_margin").width

        Label
        {
            text: catalog.i18nc("@label", "Material estimation").toUpperCase()
            color: QD.Theme.getColor("primary")
            font: QD.Theme.getFont("default_bold")
            renderType: Text.NativeRendering
        }
        
        Label
        {
            id: byMaterialType

            property var printMaterialLengths: PrintInformation.materialLengths
            property var printMaterialWeights: PrintInformation.materialWeights
            property var printMaterialCosts: PrintInformation.materialCosts
            property var printMaterialNames: PrintInformation.materialNames
            property var columnWidthMultipliers: [ 0.46, 0.18, 0.18, 0.18 ]
            property var columnHorizontalAligns: [ Text.AlignLeft, Text.AlignHCenter, Text.AlignHCenter, Text.AlignRight ]

            function getMaterialTable()
            {
                var result = []

                var lengths = []
                var weights = []
                var costs = []
                var names = []
                if(printMaterialLengths)
                {
                    for(var index = 0; index < printMaterialLengths.length; index++)
                    {
                        if(printMaterialLengths[index] > 0)
                        {
                            names.push(printMaterialNames[index])
                            lengths.push(printMaterialLengths[index].toFixed(2))
                            weights.push(String(printMaterialWeights[index].toFixed(1)))
                            var cost = printMaterialCosts[index] == undefined ? 0 : printMaterialCosts[index].toFixed(2)
                            costs.push(cost)
                        }
                    }
                }
                if(lengths.length == 0)
                {
                    lengths = ["0.00"]
                    weights = ["0.0"]
                    costs = ["0.00"]
                }

                for(var index = 0; index < lengths.length; index++)
                {
                    var row = []
                    row.push("%1".arg(names[index]))
					result.push(row)
                    var row = []
                    row.push(catalog.i18nc("@label m for meter", "%1m").arg(lengths[index]))
                    row.push(catalog.i18nc("@label g for grams", "%1g").arg(weights[index]))
                    row.push("%1 %2".arg(costs[index]).arg(QD.Preferences.getValue("qidi/currency")))
                    result.push(row)
                }

                return result
            }

            Column
            {
                Repeater
                {
                    model: byMaterialType.getMaterialTable()
                    Row
                    {
                        Repeater
                        {
                            model: modelData
                            Label
                            {
                                //width: Math.round(1.2*byMaterialType.width * byMaterialType.columnWidthMultipliers[index])
								width: Math.round(byLineType.width * byLineType.columnWidthMultipliers[index])
                                height: contentHeight
                                horizontalAlignment: byMaterialType.columnHorizontalAligns[index]
								//horizontalAlignment: byLineType.columnHorizontalAligns[index]
                                color: QD.Theme.getColor("text")
                                font: QD.Theme.getFont("default")
                                wrapMode: Text.WrapAnywhere
                                text: modelData
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }
            }

            width: parent.width - 2 * QD.Theme.getSize("default_margin").width
            height: childrenRect.height
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default")
            renderType: Text.NativeRendering
            textFormat: Text.RichText
        }
    }
}