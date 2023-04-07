// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This is the widget for editing min and max X and Y for the print head.
// The print head is internally stored as a JSON array or array, representing a polygon of the print head.
// The polygon array is stored in the format illustrated below:
//      [  [ -x_min,  y_max ],
//         [ -x_min, -y_min ],
//         [  x_max,  y_max ],
//         [  x_max, -y_min ],
//       ]
//
// In order to modify each field, the widget is configurable via "axisName" and "axisMinOrMax", where
//     - axisName is "x" or "y"
//     - axisMinOrMax is "min" or "max"
//
NumericTextFieldWithUnit
{
    id: printerHeadMinMaxField
    QD.I18nCatalog { id: catalog; name: "qidi" }

    containerStackId: QIDI.MachineManager.activeMachine.id
    settingKey: "machine_head_with_fans_polygon"
    settingStoreIndex: 1

    property string axisName: "x"
    property string axisMinOrMax: "min"
    property var axisValue:
    {
        if(propertyProvider.properties.value === undefined) { //PropertyProvider not initialised yet or there is no global stack.
            return 0;
        }
        var polygon = JSON.parse(propertyProvider.properties.value);
        var item = (axisName == "x") ? 0 : 1;
        var result = polygon[0][item];
        var func = (axisMinOrMax == "min") ? Math.min : Math.max;
        for (var i = 1; i < polygon.length; i++)
        {
            result = func(result, polygon[i][item]);
        }
        return result;
    }

    valueText: axisValue

    Connections
    {
        target: textField
        function onActiveFocusChanged()
        {
            // When this text field loses focus and the entered text is not valid, make sure to recreate the binding to
            // show the correct value.
            if (!textField.activeFocus && !textField.acceptableInput)
            {
                valueText = Qt.binding(function() { return printerHeadMinMaxField.axisValue })
            }
        }
    }

    editingFinishedFunction: function()
    {
        var polygon = JSON.parse(propertyProvider.properties.value)
        var newValue = parseFloat(valueText.replace(',', '.'))

        if (axisName == "x")  // x min/x max
        {
            var start_i1 = (axisMinOrMax == "min") ? 0 : 2
            polygon[start_i1][0] = newValue
            polygon[start_i1 + 1][0] = newValue
        }
        else  // y min/y max
        {
            var start_i1 = (axisMinOrMax == "min") ? 1 : 0
            polygon[start_i1][1] = newValue
            polygon[start_i1 + 2][1] = newValue
        }
        var polygon_string = JSON.stringify(polygon)
        if (polygon_string != propertyProvider.properties.value)
        {
            propertyProvider.setPropertyValue("value", polygon_string)
            forceUpdateOnChangeFunction()
        }

        // Recreate the binding to show the correct value.
        valueText = Qt.binding(function() { return axisValue })
    }
}
