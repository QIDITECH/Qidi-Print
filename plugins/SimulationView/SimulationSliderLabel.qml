// Copyright (c) 2017 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.
import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import QD 1.0 as QD
import QIDI 1.0 as QIDI

QD.PointingRectangle {
    id: sliderLabelRoot

    // custom properties
    property real maximumValue: 100
    property real value: 0
    property var setValue // Function
    property bool busy: false
    property int startFrom: 1

    target: Qt.point(parent.width, y + height / 2)
    arrowSize: QD.Theme.getSize("button_tooltip_arrow").height
    height: parent.height
    width: valueLabel.width
    visible: false

    color: QD.Theme.getColor("tool_panel_background")
    borderColor: QD.Theme.getColor("lining")
    borderWidth: QD.Theme.getSize("default_lining").width

    Behavior on height {
        NumberAnimation {
            duration: 50
        }
    }

    // catch all mouse events so they're not handled by underlying 3D scene
    MouseArea {
        anchors.fill: parent
    }

    TextMetrics {
        id:     maxValueMetrics
        font:   valueLabel.font
        text:   maximumValue + 1 // layers are 0 based, add 1 for display value

    }

    TextField {
        id: valueLabel

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
            alignWhenCentered: false
        }

        width: maxValueMetrics.width + 1.1*QD.Theme.getSize("default_margin").width
        text: sliderLabelRoot.value + startFrom // the current handle value, add 1 because layers is an array
        horizontalAlignment: TextInput.AlignHCenter

        // key bindings, work when label is currenctly focused (active handle in LayerSlider)
        Keys.onUpPressed: sliderLabelRoot.setValue(sliderLabelRoot.value + ((event.modifiers & Qt.ShiftModifier) ? 10 : 1))
        Keys.onDownPressed: sliderLabelRoot.setValue(sliderLabelRoot.value - ((event.modifiers & Qt.ShiftModifier) ? 10 : 1))

        style: TextFieldStyle {
            textColor: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default")
            renderType: Text.NativeRendering
            background: Item {  }
        }

        onEditingFinished: {

            // Ensure that the cursor is at the first position. On some systems the text isn't fully visible
            // Seems to have to do something with different dpi densities that QML doesn't quite handle.
            // Another option would be to increase the size even further, but that gives pretty ugly results.
            cursorPosition = 0

            if (valueLabel.text != "") {
                // -startFrom because we need to convert back to an array structure
                sliderLabelRoot.setValue(parseInt(valueLabel.text) - startFrom)

            }
        }

        validator: IntValidator {
            bottom: startFrom
            top: sliderLabelRoot.maximumValue + startFrom // +startFrom because maybe we want to start in a different value rather than 0
        }
    }

    BusyIndicator {
        id: busyIndicator

        anchors {
            left: parent.right
            leftMargin: Math.round(QD.Theme.getSize("default_margin").width / 2)
            verticalCenter: parent.verticalCenter
        }

        width: sliderLabelRoot.height
        height: width

        visible: sliderLabelRoot.busy
        running: sliderLabelRoot.busy
    }
}
