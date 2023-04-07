// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    id: recommendedPrintSetup

    height: childrenRect.height + 2 * padding

    property Action configureSettings

    property bool settingsEnabled: QIDI.ExtruderManager.activeExtruderStackId || extrudersEnabledCount.properties.value == 1
    property real padding: QD.Theme.getSize("thick_margin").width

    Column
    {
        spacing: QD.Theme.getSize("wide_margin").height

        anchors
        {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: parent.padding
        }

        // TODO
        property real firstColumnWidth: Math.round(width / 3)

        RecommendedQualityProfileSelector
        {
            width: parent.width
            // TODO Create a reusable component with these properties to not define them separately for each component
            labelColumnWidth: parent.firstColumnWidth
        }

        RecommendedInfillDensitySelector
        {
            width: parent.width
            // TODO Create a reusable component with these properties to not define them separately for each component
            labelColumnWidth: parent.firstColumnWidth
        }

        RecommendedSupportSelector
        {
            width: parent.width
            // TODO Create a reusable component with these properties to not define them separately for each component
            labelColumnWidth: parent.firstColumnWidth
        }

        RecommendedAdhesionSelector
        {
            width: parent.width
            // TODO Create a reusable component with these properties to not define them separately for each component
            labelColumnWidth: parent.firstColumnWidth
        }
    }

    QD.SettingPropertyProvider
    {
        id: extrudersEnabledCount
        containerStack: QIDI.MachineManager.activeMachine
        key: "extruders_enabled_count"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }
}
