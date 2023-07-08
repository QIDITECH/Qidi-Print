// Copyright (c) 2018 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.2

import QD 1.1 as QD
import QIDI 1.1 as QIDI

Item
{
    id: base
    width: childrenRect.width
    height: childrenRect.height
    QD.I18nCatalog { id: catalog; name: "qdtech"}

    // We use properties for the text as doing the bindings indirectly doesn't cause any breaks
    // Javascripts don't seem to play well with the bindings (and sometimes break em)
    property string xPercentageText;
    property string yPercentageText;
    property string zPercentageText;

    property string heightText
    property string depthText
    property string widthText

    function getPercentage(scale){
        return scale * 100;
    }

    //Rounds a floating point number to 4 decimals. This prevents floating
    //point rounding errors.
    //
    //input:    The number to round.
    //decimals: The number of decimals (digits after the radix) to round to.
    //return:   The rounded number.
    function roundFloat(input, decimals)
    {
        //First convert to fixed-point notation to round the number to 4 decimals and not introduce new floating point errors.
        //Then convert to a string (is implicit). The fixed-point notation will be something like "3.200".
        //Then remove any trailing zeroes and the radix.
        if(input)
        {
            return input.toFixed(decimals).replace(/\.?0*$/, ""); //Match on periods, if any ( \.? ), followed by any number of zeros ( 0* ), then the end of string ( $ ).
        }
        else
        {
            return 0
        }
    }

    function selectTextInTextfield(selected_item)
    {
        selected_item.selectAll()
        selected_item.focus = true
    }

    Grid
    {
        id: textfields;

        anchors.top: parent.top;

        columns: 3;
        flow: Grid.TopToBottom;
        spacing: Math.round(QD.Theme.getSize("default_margin").width / 2);

        Label
        {
            height: QD.Theme.getSize("setting_control").height;
            text: "X";
            font: QD.Theme.getFont("default");
            color: QD.Theme.getColor("x_axis");
            verticalAlignment: Text.AlignVCenter;
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth) //Make sure that the grid cells have an integer width.
        }

        Label
        {
            height: QD.Theme.getSize("setting_control").height;
            text: "Y";
            font: QD.Theme.getFont("default");
            color: QD.Theme.getColor("z_axis"); // This is intentional. The internal axis are switched.
            verticalAlignment: Text.AlignVCenter;
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth) //Make sure that the grid cells have an integer width.
        }

        Label
        {
            height: QD.Theme.getSize("setting_control").height;
            text: "Z";
            font: QD.Theme.getFont("default");
            color: QD.Theme.getColor("y_axis"); // This is intentional. The internal axis are switched.
            verticalAlignment: Text.AlignVCenter;
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth) //Make sure that the grid cells have an integer width.
        }

        TextField
        {
            id: widthTextField
            width: QD.Theme.getSize("setting_control").width;
            height: QD.Theme.getSize("setting_control").height;
            property string unit: "mm";
            style: QD.Theme.styles.text_field;
            text: widthText
            validator: DoubleValidator
            {
                bottom: 0.1
                decimals: 4
                locale: "en_US"
            }

            onEditingFinished:
            {
                var modified_text = text.replace(",", ".") // User convenience. We use dots for decimal values
                QD.ActiveTool.setProperty("ObjectWidth", modified_text);
            }
            Keys.onBacktabPressed: selectTextInTextfield(yPercentage)
            Keys.onTabPressed: selectTextInTextfield(xPercentage)
        }

        TextField
        {
            id: depthTextField
            width: QD.Theme.getSize("setting_control").width;
            height: QD.Theme.getSize("setting_control").height;
            property string unit: "mm";
            style: QD.Theme.styles.text_field;
            text: depthText
            validator: DoubleValidator
            {
                bottom: 0.1
                decimals: 4
                locale: "en_US"
            }

            onEditingFinished:
            {
                var modified_text = text.replace(",", ".") // User convenience. We use dots for decimal values
                QD.ActiveTool.setProperty("ObjectDepth", modified_text);
            }
            Keys.onBacktabPressed: selectTextInTextfield(xPercentage)
            Keys.onTabPressed: selectTextInTextfield(zPercentage)
        }
        
        TextField
        {
            id: heightTextField
            width: QD.Theme.getSize("setting_control").width;
            height: QD.Theme.getSize("setting_control").height;
            property string unit: "mm";
            style: QD.Theme.styles.text_field;
            text: heightText
            validator: DoubleValidator
            {
                bottom: 0.1
                decimals: 4
                locale: "en_US"
            }

            onEditingFinished:
            {
                var modified_text = text.replace(",", ".") // User convenience. We use dots for decimal values
                QD.ActiveTool.setProperty("ObjectHeight", modified_text);
            }
            Keys.onBacktabPressed: selectTextInTextfield(zPercentage)
            Keys.onTabPressed: selectTextInTextfield(yPercentage)
        }

        // To ensure that the new size after scaling matches is still validate (size cannot be less than 0.1 mm).
        // This function checks that by applying the new scale to the original size and checks if the new size is
        // valid. If valid, the new size will be returned, otherwise -1 which means not valid.
        function validateMinimumSize(newValue, lastValue, currentModelSize)
        {
            var modifiedText = newValue.replace(",", ".") // User convenience. We use dots for decimal values
            var parsedNewValue = parseFloat(modifiedText)
            var originalSize = (100 * currentModelSize) / lastValue // model size without scaling
            var newSize = (parsedNewValue * originalSize) / 100
            const minAllowedSize = 0.1 // The new size cannot be lower than this value

            if (newSize >= minAllowedSize)
            {
                return parsedNewValue
            }

            return -1
        }

        function evaluateTextChange(text, lastEnteredValue, valueName, scaleName)
        {
            var currentModelSize = QD.ActiveTool.properties.getValue(valueName);
            var parsedValue = textfields.validateMinimumSize(text, lastEnteredValue, currentModelSize);
            if (parsedValue > 0 && ! QD.ActiveTool.properties.getValue("NonUniformScale"))
            {
                var scale = parsedValue / lastEnteredValue;
                var x = QD.ActiveTool.properties.getValue("ScaleX") * 100;
                var y = QD.ActiveTool.properties.getValue("ScaleY") * 100;
                var z = QD.ActiveTool.properties.getValue("ScaleZ") * 100;
                var newX = textfields.validateMinimumSize(
                    (x * scale).toString(), x, QD.ActiveTool.properties.getValue("ObjectWidth"));
                var newY = textfields.validateMinimumSize(
                    (y * scale).toString(), y, QD.ActiveTool.properties.getValue("ObjectHeight"));
                var newZ = textfields.validateMinimumSize(
                    (z * scale).toString(), z, QD.ActiveTool.properties.getValue("ObjectDepth"));
                if (newX <= 0 || newY <= 0 || newZ <= 0)
                {
                    parsedValue = -1;
                }
            }
            if (parsedValue > 0)
            {
                QD.ActiveTool.setProperty(scaleName, parsedValue / 100);
                lastEnteredValue = parsedValue;
            } // 'else' the value is not valid (the object will become too small)
            return lastEnteredValue;
        }

        TextField
        {
            id: xPercentage
            width: QD.Theme.getSize("setting_control").width;
            height: QD.Theme.getSize("setting_control").height;
            property string unit: "%";
            style: QD.Theme.styles.text_field;
            text: xPercentageText
            validator: DoubleValidator
            {
                decimals: 4
                locale: "en_US"
            }
            property var lastEnteredValue: parseFloat(xPercentageText)
            onEditingFinished:
                lastEnteredValue = textfields.evaluateTextChange(text, lastEnteredValue, "ObjectWidth", "ScaleX")
            Keys.onBacktabPressed: selectTextInTextfield(widthTextField)
            Keys.onTabPressed: selectTextInTextfield(depthTextField)
        }
        TextField
        {
            id: zPercentage
            width: QD.Theme.getSize("setting_control").width;
            height: QD.Theme.getSize("setting_control").height;
            property string unit: "%";
            style: QD.Theme.styles.text_field;
            text: zPercentageText
            validator: DoubleValidator
            {
                decimals: 4
                locale: "en_US"
            }
            property var lastEnteredValue: parseFloat(zPercentageText)
            onEditingFinished:
                lastEnteredValue = textfields.evaluateTextChange(text, lastEnteredValue, "ObjectDepth", "ScaleZ")
            Keys.onBacktabPressed: selectTextInTextfield(depthTextField)
            Keys.onTabPressed: selectTextInTextfield(heightTextField)
        }
        TextField
        {
            id: yPercentage
            width: QD.Theme.getSize("setting_control").width;
            height: QD.Theme.getSize("setting_control").height;
            property string unit: "%";
            style: QD.Theme.styles.text_field;

            text: yPercentageText
            validator: DoubleValidator
            {
                decimals: 4
                locale: "en_US"
            }
            property var lastEnteredValue: parseFloat(yPercentageText)
            onEditingFinished:
                lastEnteredValue = textfields.evaluateTextChange(text, lastEnteredValue, "ObjectHeight", "ScaleY")
            Keys.onBacktabPressed: selectTextInTextfield(heightTextField)
            Keys.onTabPressed: selectTextInTextfield(widthTextField)

        }

        // We have to use indirect bindings, as the values can be changed from the outside, which could cause breaks
        // (for instance, a value would be set, but it would be impossible to change it).
        // Doing it indirectly does not break these.
        Binding
        {
            target: base
            property: "heightText"
            value: base.roundFloat(QD.ActiveTool.properties.getValue("ObjectHeight"), 4)
        }

        Binding
        {
            target: base
            property: "widthText"
            value: base.roundFloat(QD.ActiveTool.properties.getValue("ObjectWidth"), 4)
        }

        Binding
        {
            target: base
            property: "depthText"
            value:base.roundFloat(QD.ActiveTool.properties.getValue("ObjectDepth"), 4)
        }

        Binding
        {
            target: base
            property: "xPercentageText"
            value: base.roundFloat(100 * QD.ActiveTool.properties.getValue("ScaleX"), 4)
        }

        Binding
        {
            target: base
            property: "yPercentageText"
            value: base.roundFloat(100 * QD.ActiveTool.properties.getValue("ScaleY"), 4)
        }

        Binding
        {
            target: base
            property: "zPercentageText"
            value: base.roundFloat(100 * QD.ActiveTool.properties.getValue("ScaleZ"), 4)
        }
    }

    QIDI.ToolbarButton
    {
        id: inchesMiliButton
        anchors.top: textfields.bottom
        anchors.topMargin: 15 * QD.Theme.getSize("size").width
        anchors.left: textfields.left
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        width: 30 * QD.Theme.getSize("size").width
        height: 30 * QD.Theme.getSize("size").width
        z: 1
        text: catalog.i18nc("@action:button","Scale Inches to Milimeters")
        hasBorderElement: true
        toolItem: QD.RecolorImage
        {
            source: QD.Theme.getIcon("InchesMili")
            color: QD.Theme.getColor("blue_6")
            width: inchesMiliButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
            height: inchesMiliButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
        }
        onClicked: 
        {
            QD.ActiveTool.setProperty("ScaleX", parseFloat(xPercentage.text) / 100 * 25.4)
			if(!uniformScalingCheckbox.checked)
			{
				QD.ActiveTool.setProperty("ScaleZ", parseFloat(zPercentage.text) / 100 * 25.4)
				QD.ActiveTool.setProperty("ScaleY", parseFloat(yPercentage.text) / 100 * 25.4)
			}
        }
    }

    QIDI.ToolbarButton
    {
        id: resetScaleButton
        anchors.top: inchesMiliButton.top
        anchors.left: inchesMiliButton.right
        anchors.leftMargin: 8 * QD.Theme.getSize("size").width
        width: 30 * QD.Theme.getSize("size").width
        height: 30 * QD.Theme.getSize("size").width
        z: 1
        text: catalog.i18nc("@action:button","Reset")
        hasBorderElement: true
        toolItem: QD.RecolorImage
        {
            source: QD.Theme.getIcon("ArrowReset")
            color: QD.Theme.getColor("blue_6")
            width: resetScaleButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
            height: resetScaleButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
        }
        onClicked: QD.ActiveTool.triggerAction("resetScale")
    }

    Column
    {
        id: checkboxes;

        anchors.left: resetScaleButton.right
        anchors.leftMargin: 8 * QD.Theme.getSize("size").width
        anchors.right: parent.right
        anchors.top: textfields.bottom
        anchors.topMargin: 8 * QD.Theme.getSize("size").width

        spacing: 8 * QD.Theme.getSize("size").height

        QIDI.CheckBox
        {
            id: snapScalingCheckbox
            height: 18 * QD.Theme.getSize("size").height
            width: parent.width
            text: catalog.i18nc("@option:check", "Snap Scaling")
            checked: QD.ActiveTool.properties.getValue("ScaleSnap");
            onClicked:
            {
                QD.ActiveTool.setProperty("ScaleSnap", checked);
                if (snapScalingCheckbox.checked)
                {
                    QD.ActiveTool.setProperty("ScaleX", parseFloat(xPercentage.text) / 100);
                    QD.ActiveTool.setProperty("ScaleY", parseFloat(yPercentage.text) / 100);
                    QD.ActiveTool.setProperty("ScaleZ", parseFloat(zPercentage.text) / 100);
                }
            }
        }

        Binding
        {
            target: snapScalingCheckbox
            property: "checked"
            value: QD.ActiveTool.properties.getValue("ScaleSnap")
        }

        QIDI.CheckBox
        {
            id: uniformScalingCheckbox
            height: 18 * QD.Theme.getSize("size").height
            width: parent.width
            text: catalog.i18nc("@option:check", "Uniform Scaling")
            checked: !QD.ActiveTool.properties.getValue("NonUniformScale");
            onClicked: QD.ActiveTool.setProperty("NonUniformScale", !checked);
        }

        Binding
        {
            target: uniformScalingCheckbox
            property: "checked"
            value: !QD.ActiveTool.properties.getValue("NonUniformScale")
        }
    }
}
