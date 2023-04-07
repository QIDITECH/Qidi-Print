// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import QD 1.2 as QD
import QIDI 1.0 as QIDI

import "PrinterOutput"


Item
{
    id: base
    QD.I18nCatalog { id: catalog; name: "qidi"}

    function showTooltip(item, position, text)
    {
        tooltip.text = text;
        position = item.mapToItem(base, position.x - QD.Theme.getSize("default_arrow").width, position.y);
        tooltip.show(position);
    }

    function hideTooltip()
    {
        tooltip.hide();
    }

    function strPadLeft(string, pad, length) {
        return (new Array(length + 1).join(pad) + string).slice(-length);
    }

    function getPrettyTime(time)
    {
        var hours = Math.floor(time / 3600)
        time -= hours * 3600
        var minutes = Math.floor(time / 60);
        time -= minutes * 60
        var seconds = Math.floor(time);

        var finalTime = strPadLeft(hours, "0", 2) + ":" + strPadLeft(minutes, "0", 2) + ":" + strPadLeft(seconds, "0", 2);
        return finalTime;
    }

    property var connectedDevice: QIDI.MachineManager.printerOutputDevices.length >= 1 ? QIDI.MachineManager.printerOutputDevices[0] : null
    property var activePrinter: connectedDevice != null ? connectedDevice.activePrinter : null
    property var activePrintJob: activePrinter != null ? activePrinter.activePrintJob: null

    Column
    {
        id: printMonitor

        anchors.fill: parent

        property var extrudersModel: QIDIApplication.getExtrudersModel()

        OutputDeviceHeader
        {
            outputDevice: connectedDevice
        }

        Rectangle
        {
            color: QD.Theme.getColor("wide_lining")
            width: parent.width
            height: childrenRect.height

            Flow
            {
                id: extrudersGrid
                spacing: QD.Theme.getSize("thick_lining").width
                width: parent.width

                Repeater
                {
                    id: extrudersRepeater
                    model: activePrinter != null ? activePrinter.extruders : null

                    ExtruderBox
                    {
                        color: QD.Theme.getColor("main_background")
                        width: index == machineExtruderCount.properties.value - 1 && index % 2 == 0 ? extrudersGrid.width : Math.round(extrudersGrid.width / 2 - QD.Theme.getSize("thick_lining").width / 2)
                        extruderModel: modelData
                    }
                }
            }
        }

        Rectangle
        {
            color: QD.Theme.getColor("wide_lining")
            width: parent.width
            height: QD.Theme.getSize("thick_lining").width
        }

        HeatedBedBox
        {
            visible:
            {
                if(activePrinter != null && activePrinter.bedTemperature != -1)
                {
                    return true
                }
                return false
            }
            printerModel: activePrinter
        }

        QD.SettingPropertyProvider
        {
            id: bedTemperature
            containerStack: QIDI.MachineManager.activeMachine
            key: "material_bed_temperature"
            watchedProperties: ["value", "minimum_value", "maximum_value", "resolve"]
            storeIndex: 0

            property var resolve: QIDI.MachineManager.activeStack != QIDI.MachineManager.activeMachine ? properties.resolve : "None"
        }

        QD.SettingPropertyProvider
        {
            id: machineExtruderCount
            containerStack: QIDI.MachineManager.activeMachine
            key: "machine_extruder_count"
            watchedProperties: ["value"]
        }

        ManualPrinterControl
        {
            printerModel: activePrinter
            visible: activePrinter != null ? activePrinter.canControlManually : false
        }


        MonitorSection
        {
            label: catalog.i18nc("@label", "Active print")
            width: base.width
            visible: activePrinter != null
        }


        MonitorItem
        {
            label: catalog.i18nc("@label", "Job Name")
            value: activePrintJob != null ? activePrintJob.name : ""
            width: base.width
            visible: activePrinter != null
        }

        MonitorItem
        {
            label: catalog.i18nc("@label", "Printing Time")
            value: activePrintJob != null ? getPrettyTime(activePrintJob.timeTotal) : ""
            width: base.width
            visible: activePrinter != null
        }

        MonitorItem
        {
            label: catalog.i18nc("@label", "Estimated time left")
            value: activePrintJob != null ? getPrettyTime(activePrintJob.timeTotal - activePrintJob.timeElapsed) : ""
            visible:
            {
                if(activePrintJob == null)
                {
                    return false
                }

                return (activePrintJob.state == "printing" ||
                        activePrintJob.state == "resuming" ||
                        activePrintJob.state == "pausing" ||
                        activePrintJob.state == "paused")
            }
            width: base.width
        }
    }

    PrintSetupTooltip
    {
        id: tooltip
    }
}