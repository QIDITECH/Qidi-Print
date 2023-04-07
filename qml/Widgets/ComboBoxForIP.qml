// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// ComboBox with QIDI styling.
//
ComboBox
{
    id: control

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    property var defaultTextOnEmptyModel: catalog.i18nc("@label", "No items to select from")  // Text displayed in the combobox when the model is empty
    property var defaultTextOnEmptyIndex: ""  // Text displayed in the combobox when the model has items but no item is selected
    enabled: delegateModel.count > 0

    onVisibleChanged: { popup.close() }

    states: [
        State
        {
            name: "disabled"
            when: !control.enabled
            PropertyChanges { target: backgroundRectangle.border; color: QD.Theme.getColor("setting_control_disabled_border")}
            PropertyChanges { target: backgroundRectangle; color: QD.Theme.getColor("setting_control_disabled")}
            PropertyChanges { target: contentLabel; color: QD.Theme.getColor("setting_control_disabled_text")}
        },
        State
        {
            name: "highlighted"
            when: control.hovered || control.activeFocus
            PropertyChanges { target: backgroundRectangle.border; color: QD.Theme.getColor("setting_control_border_highlight") }
            PropertyChanges { target: backgroundRectangle; color: QD.Theme.getColor("setting_control_highlight")}
        }
    ]

    background: Rectangle
    {
        id: backgroundRectangle
        color: QD.Theme.getColor("setting_control")

        radius: QD.Theme.getSize("setting_control_radius").width
        border.width: QD.Theme.getSize("default_lining").width
        border.color: QD.Theme.getColor("setting_control_border")

    }

    indicator: QD.RecolorImage
    {
        id: downArrow
        x: control.width - width - control.rightPadding
        y: control.topPadding + Math.round((control.availableHeight - height) / 2)

        source: QD.Theme.getIcon("ChevronSingleDown")
        width: QD.Theme.getSize("standard_arrow").width
        height: QD.Theme.getSize("standard_arrow").height
        sourceSize.width: width + 5 * screenScaleFactor
        sourceSize.height: width + 5 * screenScaleFactor

        color: QD.Theme.getColor("setting_control_button")
    }

    contentItem: Label
    {
        id: contentLabel
        anchors.left: parent.left
        anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: downArrow.left

        text:
        {
            if (control.delegateModel.count == 0)
            {
                return control.defaultTextOnEmptyModel != "" ? control.defaultTextOnEmptyModel : control.defaultTextOnEmptyIndex
            }
            else
            {
                return control.currentIndex == -1 ? control.defaultTextOnEmptyIndex : control.currentText
            }
        }

        textFormat: Text.PlainText
        renderType: Text.NativeRendering
        font: QD.Theme.getFont("default")
        color: QIDI.WifiSend.nameable == "true"  ? QD.Theme.getColor("setting_control_text") : QD.Theme.getColor("gray_1")
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    popup: Popup
    {
        y: control.height - QD.Theme.getSize("default_lining").height
        width: control.width
        implicitHeight: contentItem.implicitHeight + 2 * QD.Theme.getSize("default_lining").width
        bottomMargin: QD.Theme.getSize("default_margin").height
        padding: QD.Theme.getSize("default_lining").width

        contentItem: ListView
        {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle
        {
            color: QD.Theme.getColor("setting_control")
            border.color: QD.Theme.getColor("setting_control_border")
        }
    }

    delegate: ItemDelegate
    {
        id: delegateItem
        width: control.width - 2 * QD.Theme.getSize("default_lining").width
        height: control.height
        highlighted: control.highlightedIndex == index
        text:
        // FIXME: Maybe there is a better way to do this. Check model and modelData doc page:
        // https://doc.qt.io/qt-5/qtquick-modelviewsdata-modelview.html
        {
            var _val = undefined
            if (typeof _val === 'undefined')  // try to get textRole from "model".
            {
                _val = model[textRole]
            }
            if (typeof _val === 'undefined')  // try to get textRole from "modelData" if it's still undefined.
            {
                _val = modelData[textRole]
            }
            return (typeof _val !== 'undefined') ? _val : modelData
        }

        contentItem: Label
        {
            id: delegateLabel
            // FIXME: Somehow the top/bottom anchoring is not correct on Linux and it results in invisible texts.
            anchors.fill: parent
            anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
            anchors.rightMargin: QD.Theme.getSize("setting_unit_margin").width

            text: delegateItem.text
            textFormat: Text.PlainText
            renderType: Text.NativeRendering
            //color: QD.Theme.getColor("setting_control_text")
			color: QD.Theme.getColor(QIDIApplication.ip_color(delegateItem.text))
            font: QD.Theme.getFont("default")
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: QD.TooltipArea
        {
            Rectangle
            {
                color: delegateItem.highlighted ? QD.Theme.getColor("setting_control_highlight") : "transparent"
                border.color: delegateItem.highlighted ? QD.Theme.getColor("setting_control_border_highlight") : "transparent"
                anchors.fill: parent
            }
            text: delegateLabel.truncated ? delegateItem.text : ""
        }
    }
}
