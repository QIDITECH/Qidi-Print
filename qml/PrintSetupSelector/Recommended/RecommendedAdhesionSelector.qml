// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import QD 1.2 as QD
import QIDI 1.0 as QIDI


//
//  Adhesion
//
Item
{
    id: enableAdhesionRow
    height: childrenRect.height

    property real labelColumnWidth: Math.round(width / 3)
    property var qidiRecommendedMode: QIDI.RecommendedMode {}

    QIDI.IconWithText
    {
        id: enableAdhesionRowTitle
        anchors.top: parent.top
        anchors.left: parent.left
        source: QD.Theme.getIcon("Adhesion")
        text: catalog.i18nc("@label", "Adhesion")
        font: QD.Theme.getFont("medium")
        width: labelColumnWidth
    }

    Item
    {
        id: enableAdhesionContainer
        height: enableAdhesionCheckBox.height

        anchors
        {
            left: enableAdhesionRowTitle.right
            right: parent.right
            verticalCenter: enableAdhesionRowTitle.verticalCenter
        }

        CheckBox
        {
            id: enableAdhesionCheckBox
            anchors.verticalCenter: parent.verticalCenter

            property alias _hovered: adhesionMouseArea.containsMouse

            //: Setting enable printing build-plate adhesion helper checkbox
            style: QD.Theme.styles.checkbox
            enabled: recommendedPrintSetup.settingsEnabled

            visible: platformAdhesionType.properties.enabled == "True"
            checked: platformAdhesionType.properties.value != "skirt" && platformAdhesionType.properties.value != "none"

            MouseArea
            {
                id: adhesionMouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked:
                {
                    qidiRecommendedMode.setAdhesion(!parent.checked)
                }

                onEntered:
                {
                    base.showTooltip(enableAdhesionCheckBox, Qt.point(-enableAdhesionContainer.x - QD.Theme.getSize("thick_margin").width, 0),
                        catalog.i18nc("@label", "Enable printing a brim or raft. This will add a flat area around or under your object which is easy to cut off afterwards."));
                }
                onExited: base.hideTooltip()
            }
        }
    }

    QD.SettingPropertyProvider
    {
        id: platformAdhesionType
        containerStack: QIDI.MachineManager.activeMachine
        removeUnusedValue: false //Doesn't work with settings that are resolved.
        key: "adhesion_type"
        watchedProperties: [ "value", "resolve", "enabled" ]
        storeIndex: 0
    }
}
