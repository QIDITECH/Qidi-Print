// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import QD 1.2 as QD
import QIDI 1.0 as QIDI


//
// Infill
//
Item
{
    id: infillRow
    height: childrenRect.height

    property real labelColumnWidth: Math.round(width / 3)

    // Create a binding to update the icon when the infill density changes
    Binding
    {
        target: infillRowTitle
        property: "source"
        value:
        {
            var density = parseInt(infillDensity.properties.value)
            if (parseInt(infillSteps.properties.value) != 0)
            {
                return QD.Theme.getIcon("InfillGradual")
            }
            if (density <= 0)
            {
                return QD.Theme.getIcon("Infill0")
            }
            if (density < 40)
            {
                return QD.Theme.getIcon("Infill3")
            }
            if (density < 90)
            {
                return QD.Theme.getIcon("Infill2")
            }
            return QD.Theme.getIcon("Solid")
        }
    }

    // We use a binding to make sure that after manually setting infillSlider.value it is still bound to the property provider
    Binding
    {
        target: infillSlider
        property: "value"
        value: parseInt(infillDensity.properties.value)
    }

    // Here are the elements that are shown in the left column
    QIDI.IconWithText
    {
        id: infillRowTitle
        anchors.top: parent.top
        anchors.left: parent.left
        source: QD.Theme.getIcon("Infill1")
        text: catalog.i18nc("@label", "Infill") + " (%)"
        font: QD.Theme.getFont("medium")
        width: labelColumnWidth
    }

    Item
    {
        id: infillSliderContainer
        height: childrenRect.height

        anchors
        {
            left: infillRowTitle.right
            right: parent.right
            verticalCenter: infillRowTitle.verticalCenter
        }

        Slider
        {
            id: infillSlider

            width: parent.width
            height: QD.Theme.getSize("print_setup_slider_handle").height // The handle is the widest element of the slider

            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            tickmarksEnabled: true

            // disable slider when gradual support is enabled
            enabled: parseInt(infillSteps.properties.value) == 0

            // set initial value from stack
            value: parseInt(infillDensity.properties.value)

            style: SliderStyle
            {
                //Draw line
                groove: Item
                {
                    Rectangle
                    {
                        height: QD.Theme.getSize("print_setup_slider_groove").height
                        width: control.width - QD.Theme.getSize("print_setup_slider_handle").width
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: control.enabled ? QD.Theme.getColor("quality_slider_available") : QD.Theme.getColor("quality_slider_unavailable")
                    }
                }

                handle: Rectangle
                {
                    id: handleButton
                    color: control.enabled ? QD.Theme.getColor("primary") : QD.Theme.getColor("quality_slider_unavailable")
                    implicitWidth: QD.Theme.getSize("print_setup_slider_handle").width
                    implicitHeight: implicitWidth
                    radius: Math.round(implicitWidth / 2)
                }

                tickmarks: Repeater
                {
                    id: repeater
                    model: control.maximumValue / control.stepSize + 1

                    Rectangle
                    {
                        color: control.enabled ? QD.Theme.getColor("quality_slider_available") : QD.Theme.getColor("quality_slider_unavailable")
                        implicitWidth: QD.Theme.getSize("print_setup_slider_tickmarks").width
                        implicitHeight: QD.Theme.getSize("print_setup_slider_tickmarks").height
                        anchors.verticalCenter: parent.verticalCenter

                        // Do not use Math.round otherwise the tickmarks won't be aligned
                        x: ((styleData.handleWidth / 2) - (implicitWidth / 2) + (index * ((repeater.width - styleData.handleWidth) / (repeater.count-1))))
                        radius: Math.round(implicitWidth / 2)
                        visible: (index % 10) == 0 // Only show steps of 10%

                        Label
                        {
                            text: index
                            font: QD.Theme.getFont("default")
                            visible: (index % 20) == 0 // Only show steps of 20%
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: QD.Theme.getSize("thin_margin").height
                            renderType: Text.NativeRendering
                            color: QD.Theme.getColor("quality_slider_available")
                        }
                    }
                }
            }

            onValueChanged:
            {
                // Don't round the value if it's already the same
                if (parseInt(infillDensity.properties.value) == infillSlider.value)
                {
                    return
                }

                // Round the slider value to the nearest multiple of 10 (simulate step size of 10)
                var roundedSliderValue = Math.round(infillSlider.value / 10) * 10

                // Update the slider value to represent the rounded value
                infillSlider.value = roundedSliderValue

                // Update value only if the Recomended mode is Active,
                // Otherwise if I change the value in the Custom mode the Recomended view will try to repeat
                // same operation
                var active_mode = QD.Preferences.getValue("qidi/active_mode")

                if (active_mode == 0 || active_mode == "simple")
                {
                    QIDI.MachineManager.setSettingForAllExtruders("infill_sparse_density", "value", roundedSliderValue)
                    QIDI.MachineManager.resetSettingForAllExtruders("infill_line_distance")
                }
            }
        }
    }

    //  Gradual Support Infill Checkbox
    CheckBox
    {
        id: enableGradualInfillCheckBox
        property alias _hovered: enableGradualInfillMouseArea.containsMouse

        anchors.top: infillSliderContainer.bottom
        anchors.topMargin: QD.Theme.getSize("wide_margin").height
        anchors.left: infillSliderContainer.left

        text: catalog.i18nc("@label", "Gradual infill")
        style: QD.Theme.styles.checkbox
        enabled: recommendedPrintSetup.settingsEnabled
        visible: infillSteps.properties.enabled == "True"
        checked: parseInt(infillSteps.properties.value) > 0

        MouseArea
        {
            id: enableGradualInfillMouseArea

            anchors.fill: parent
            hoverEnabled: true
            enabled: true

            property var previousInfillDensity: parseInt(infillDensity.properties.value)

            onClicked:
            {
                // Set to 90% only when enabling gradual infill
                var newInfillDensity;
                if (parseInt(infillSteps.properties.value) == 0)
                {
                    previousInfillDensity = parseInt(infillDensity.properties.value)
                    newInfillDensity = 90
                } else {
                    newInfillDensity = previousInfillDensity
                }
                QIDI.MachineManager.setSettingForAllExtruders("infill_sparse_density", "value", String(newInfillDensity))

                var infill_steps_value = 0
                if (parseInt(infillSteps.properties.value) == 0)
                {
                    infill_steps_value = 5
                }

                QIDI.MachineManager.setSettingForAllExtruders("gradual_infill_steps", "value", infill_steps_value)
            }

            onEntered: base.showTooltip(enableGradualInfillCheckBox, Qt.point(-infillSliderContainer.x - QD.Theme.getSize("thick_margin").width, 0),
                    catalog.i18nc("@label", "Gradual infill will gradually increase the amount of infill towards the top."))

            onExited: base.hideTooltip()
        }
    }

    QD.SettingPropertyProvider
    {
        id: infillDensity
        containerStackId: QIDI.MachineManager.activeStackId
        key: "infill_sparse_density"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }

    QD.SettingPropertyProvider
    {
        id: infillSteps
        containerStackId: QIDI.MachineManager.activeStackId
        key: "gradual_infill_steps"
        watchedProperties: ["value", "enabled"]
        storeIndex: 0
    }
}
