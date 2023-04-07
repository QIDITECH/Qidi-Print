// Copyright (c) 2019 QIDI B.V.
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
    property string xRotateText
    property string yRotateText
    property string zRotateText
    function roundFloat(input, decimals)
    {
        var output = ""
        if (input !== undefined)
        {
            output = input.toFixed(decimals).replace(/\.?0*$/, "")
        }
        if (output == "-0")
        {
            output = "0"
        }
        return output
    }

    function selectTextInTextfield(selected_item){
        selected_item.selectAll()
        selected_item.focus = true
    }

    Grid
    {
        id: textfields

        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        anchors.top: parent.top

        columns: 4
        flow: Grid.TopToBottom
        spacing: Math.round(QD.Theme.getSize("default_margin").width / 2)

        Label
        {
            height: QD.Theme.getSize("setting_control").height
            text: "X";
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("x_axis")
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth)
        }

        Label
        {
            height: QD.Theme.getSize("setting_control").height
            text: "Y";
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("z_axis")
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth)
        }

        Label
        {
            height: QD.Theme.getSize("setting_control").height
            text: "Z";
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("y_axis")
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth)
        }

        TextField
        {
            id: xTextField
            width: QD.Theme.getSize("setting_control").width
            height: QD.Theme.getSize("setting_control").height
            property string unit: "°"
            style: QD.Theme.styles.text_field
            text: xRotateText
            validator: DoubleValidator
            {
                decimals: 4
                locale: "en_US"
            }

            onEditingFinished:
            {
                var modified_text = text.replace(",", ".")
                QD.ActiveTool.setProperty("RotateX", modified_text)
            }
            onActiveFocusChanged:
            {
                if(!activeFocus && text =="")
                {
                    xRotateText = 0.1
                    xRotateText = 0
                }
            }
            Keys.onBacktabPressed: selectTextInTextfield(zTextField)
            Keys.onTabPressed: selectTextInTextfield(yTextField)
        }

        TextField
        {
            id: zTextField
            width: QD.Theme.getSize("setting_control").width
            height: QD.Theme.getSize("setting_control").height
            property string unit: "°"
            style: QD.Theme.styles.text_field
            text: zRotateText
            validator: DoubleValidator
            {
                decimals: 4
                locale: "en_US"
            }
            onEditingFinished:
            {
                var modified_text = text.replace(",", ".")
                QD.ActiveTool.setProperty("RotateZ", modified_text)
            }

            onActiveFocusChanged:
            {
                if(!activeFocus && text =="")
                {
                    zRotateText = 0.1
                    zRotateText = 0
                }
            }
            Keys.onBacktabPressed: selectTextInTextfield(yTextField)
            Keys.onTabPressed: selectTextInTextfield(xTextField)
        }

        TextField
        {
            id: yTextField
            width: QD.Theme.getSize("setting_control").width
            height: QD.Theme.getSize("setting_control").height
            property string unit: "°"
            style: QD.Theme.styles.text_field
            text: yRotateText
            validator: DoubleValidator
            {
                decimals: 4
                locale: "en_US"
            }
            onEditingFinished:
            {
                var modified_text = text.replace(",", ".")
                QD.ActiveTool.setProperty("RotateY", modified_text)
            }

            onActiveFocusChanged:
            {
                if(!activeFocus && text =="")
                {
                    yRotateText = 0.1
                    yRotateText = 0
                }
            }
            Keys.onBacktabPressed: selectTextInTextfield(xTextField)
            Keys.onTabPressed: selectTextInTextfield(zTextField)
        }

        QIDI.ActionButton
        {
            id: addXAngleButton
            width: 35 * QD.Theme.getSize("size").width
            height: 20 * QD.Theme.getSize("size").width
            textColor: QD.Theme.getColor("black_1")
            color: QD.Theme.getColor("white_1")
            hoverColor: QD.Theme.getColor("blue_4")
            outlineColor: QD.Theme.getColor("gray_3")
            outlineHoverColor: QD.Theme.getColor("gray_3")
            textFont: QD.Theme.getFont("font1")
            backgroundRadius: 3 * QD.Theme.getSize("size").width
            text: "+ 15"
            leftPadding: 7 * QD.Theme.getSize("size").height
            onClicked: QD.ActiveTool.triggerAction("addXAngle")
        }

        QIDI.ActionButton
        {
            id: addYAngleButton
            width: 35 * QD.Theme.getSize("size").width
            height: 20 * QD.Theme.getSize("size").width
            textColor: QD.Theme.getColor("black_1")
            color: QD.Theme.getColor("white_1")
            hoverColor: QD.Theme.getColor("blue_4")
            outlineColor: QD.Theme.getColor("gray_3")
            outlineHoverColor: QD.Theme.getColor("gray_3")
            textFont: QD.Theme.getFont("font1")
            backgroundRadius: 3 * QD.Theme.getSize("size").width
            text: "+ 15"
            leftPadding: 7 * QD.Theme.getSize("size").height
            onClicked: QD.ActiveTool.triggerAction("addYAngle")
        }

        QIDI.ActionButton
        {
            id: addZAngleButton
            width: 35 * QD.Theme.getSize("size").width
            height: 20 * QD.Theme.getSize("size").width
            textColor: QD.Theme.getColor("black_1")
            color: QD.Theme.getColor("white_1")
            hoverColor: QD.Theme.getColor("blue_4")
            outlineColor: QD.Theme.getColor("gray_3")
            outlineHoverColor: QD.Theme.getColor("gray_3")
            textFont: QD.Theme.getFont("font1")
            backgroundRadius: 3 * QD.Theme.getSize("size").width
            text: "+ 15"
            leftPadding: 7 * QD.Theme.getSize("size").height
            onClicked: QD.ActiveTool.triggerAction("addZAngle")
        }

        QIDI.ActionButton
        {
            id: subtractXAngleButton
            width: 35 * QD.Theme.getSize("size").width
            height: 20 * QD.Theme.getSize("size").width
            textColor: QD.Theme.getColor("black_1")
            color: QD.Theme.getColor("white_1")
            hoverColor: QD.Theme.getColor("blue_4")
            outlineColor: QD.Theme.getColor("gray_3")
            outlineHoverColor: QD.Theme.getColor("gray_3")
            textFont: QD.Theme.getFont("font1")
            backgroundRadius: 3 * QD.Theme.getSize("size").width
            text: "- 15"
            leftPadding: 7 * QD.Theme.getSize("size").height
            onClicked: QD.ActiveTool.triggerAction("subtractXAngle")
        }

        QIDI.ActionButton
        {
            id: subtractYAngleButton
            width: 35 * QD.Theme.getSize("size").width
            height: 20 * QD.Theme.getSize("size").width
            textColor: QD.Theme.getColor("black_1")
            color: QD.Theme.getColor("white_1")
            hoverColor: QD.Theme.getColor("blue_4")
            outlineColor: QD.Theme.getColor("gray_3")
            outlineHoverColor: QD.Theme.getColor("gray_3")
            textFont: QD.Theme.getFont("font1")
            backgroundRadius: 3 * QD.Theme.getSize("size").width
            text: "- 15"
            leftPadding: 7 * QD.Theme.getSize("size").height
            onClicked: QD.ActiveTool.triggerAction("subtractYAngle")
        }

        QIDI.ActionButton
        {
            id: subtractZAngleButton
            width: 35 * QD.Theme.getSize("size").width
            height: 20 * QD.Theme.getSize("size").width
            textColor: QD.Theme.getColor("black_1")
            color: QD.Theme.getColor("white_1")
            hoverColor: QD.Theme.getColor("blue_4")
            outlineColor: QD.Theme.getColor("gray_3")
            outlineHoverColor: QD.Theme.getColor("gray_3")
            textFont: QD.Theme.getFont("font1")
            backgroundRadius: 3 * QD.Theme.getSize("size").width
            text: "- 15"
            leftPadding: 7 * QD.Theme.getSize("size").height
            onClicked: QD.ActiveTool.triggerAction("subtractZAngle")
        }
    }

    QIDI.ToolbarButton
    {
        id: resetRotationButton
        width: 30 * QD.Theme.getSize("size").width
        height: 30 * QD.Theme.getSize("size").width
        anchors.top: textfields.bottom
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.left: parent.left
        text: catalog.i18nc("@action:button", "Reset")
        hasBorderElement: true
        toolItem: QD.RecolorImage
        {
            source: QD.Theme.getIcon("ArrowReset")
            color: QD.Theme.getColor("blue_6")
            width: resetRotationButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
            height: resetRotationButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
        }
        onClicked: QD.ActiveTool.triggerAction("resetRotation")
    }

    QIDI.ToolbarButton
    {
        id: layFlatButton
        width: 30 * QD.Theme.getSize("size").width
        height: 30 * QD.Theme.getSize("size").width
        anchors.top: resetRotationButton.top
        anchors.left: resetRotationButton.right
        anchors.leftMargin: 8 * QD.Theme.getSize("size").height
        text: catalog.i18nc("@action:button", "Lay flat")
        hasBorderElement: true
        toolItem: QD.RecolorImage
        {
            source: QD.Theme.getIcon("LayFlat")
            color: QD.Theme.getColor("blue_6")
            width: layFlatButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
            height: layFlatButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
        }
        onClicked: QD.ActiveTool.triggerAction("layFlat");
    }

    QIDI.ToolbarButton
    {
        id: alignFaceButton
        width: 30 * QD.Theme.getSize("size").width
        height: 30 * QD.Theme.getSize("size").width
        anchors.top: resetRotationButton.top
        anchors.left: layFlatButton.right
        anchors.leftMargin: 8 * QD.Theme.getSize("size").height
        text: catalog.i18nc("@action:button", "Select face to align to the build plate")
        hasBorderElement: true
        toolItem: QD.RecolorImage
        {
            source: QD.Theme.getIcon("LayFlatOnFace")
            color: QD.Theme.getColor("blue_6")
            width: alignFaceButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
            height: alignFaceButton.hovered ? 22 * QD.Theme.getSize("size").height : 20 * QD.Theme.getSize("size").height
        }
        enabled: QD.Selection.selectionCount == 1
        checked: QD.ActiveTool.properties.getValue("SelectFaceToLayFlatMode")
        onClicked: 
		{
			QD.ActiveTool.setProperty("SelectFaceToLayFlatMode", !QD.ActiveTool.properties.getValue("SelectFaceToLayFlatMode"))
		}
        visible:true
    }

    QIDI.CheckBox
    {
        id: snapRotationCheckbox
        height: 18 * QD.Theme.getSize("size").height
        //width: parent.width - 95 * QD.Theme.getSize("size").height
        anchors.left: alignFaceButton.right;
        anchors.leftMargin: 8 * QD.Theme.getSize("size").width
        anchors.right: parent.right
        anchors.verticalCenter: alignFaceButton.verticalCenter

        //: Snap Rotation checkbox
        text: catalog.i18nc("@action:checkbox","Snap Rotation");

        checked: QD.ActiveTool.properties.getValue("RotationSnap");
        onClicked: QD.ActiveTool.setProperty("RotationSnap", checked);
    }

    Binding
    {
        target: snapRotationCheckbox
        property: "checked"
        value: QD.ActiveTool.properties.getValue("RotationSnap")
    }

    Binding
    {
        target: alignFaceButton
        property: "checked"
        value: QD.ActiveTool.properties.getValue("SelectFaceToLayFlatMode")
    }

    Binding
    {
        target: base
        property: "xRotateText"
        value: base.roundFloat(QD.ActiveTool.properties.getValue("RotateX"), 4)
    }

    Binding
    {
        target: base
        property: "yRotateText"
        value: base.roundFloat(QD.ActiveTool.properties.getValue("RotateY"), 4)
    }

    Binding
    {
        target: base
        property: "zRotateText"
        value:base.roundFloat(QD.ActiveTool.properties.getValue("RotateZ"), 4)
    }
}
