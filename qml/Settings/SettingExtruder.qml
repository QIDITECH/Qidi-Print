// Copyright (c) 2016 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.1 as QD
import QIDI 1.0 as QIDI

SettingItem
{
    id: base
    property var focusItem: control

    contents: ComboBox
    {
        id: control
        anchors.fill: parent

        property var extrudersModel: QIDIApplication.getExtrudersModel()

        model: extrudersModel

        Connections
        {
            target: extrudersModel
            function onModelChanged()
            {
                control.color = extrudersModel.getItem(control.currentIndex).color
            }
        }

        textRole: "name"

        // knowing the extruder position, try to find the item index in the model
        function getIndexByPosition(position)
        {
            for (var item_index in model.items)
            {
                var item = model.getItem(item_index)
                if (item.index == position)
                {
                    return item_index
                }
            }
            return -1
        }

        onActivated:
        {
            if (model.getItem(index).enabled)
            {
                forceActiveFocus();
                propertyProvider.setPropertyValue("value", model.getItem(index).index);
            } else
            {
                currentIndex = propertyProvider.properties.value;  // keep the old value
            }
        }

        onActiveFocusChanged:
        {
            if(activeFocus)
            {
                base.focusReceived();
            }
        }

        Keys.onTabPressed:
        {
            base.setActiveFocusToNextSetting(true)
        }
        Keys.onBacktabPressed:
        {
            base.setActiveFocusToNextSetting(false)
        }

        currentIndex: propertyProvider.properties.value !== undefined ? propertyProvider.properties.value : 0

        property string color: "#fff"

        Binding
        {
            // We override the color property's value when the ExtruderModel changes. So we need to use an
            // explicit binding here otherwise we do not handle value changes after the model changes.
            target: control
            property: "color"
            value: control.currentText != "" ? control.model.getItem(control.currentIndex).color : ""
        }

        Binding
        {
            target: control
            property: "currentIndex"
            value: control.getIndexByPosition(propertyProvider.properties.value)
            // Sometimes when the value is already changed, the model is still being built.
            // The when clause ensures that the current index is not updated when this happens.
            when: control.model.items.length > 0
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

            color: QD.Theme.getColor("setting_control_button");
        }

        background: Rectangle
        {
            color:
            {
                if (!enabled)
                {
                    return QD.Theme.getColor("setting_control_disabled")
                }
                if (control.hovered || base.activeFocus)
                {
                    return QD.Theme.getColor("setting_control_highlight")
                }
                return QD.Theme.getColor("setting_control")
            }
            radius: QD.Theme.getSize("setting_control_radius").width
            border.width: QD.Theme.getSize("default_lining").width
            border.color:
            {
                if (!enabled)
                {
                    return QD.Theme.getColor("setting_control_disabled_border")
                }
                if (control.hovered || control.activeFocus)
                {
                    return QD.Theme.getColor("setting_control_border_highlight")
                }
                return QD.Theme.getColor("setting_control_border")
            }
        }

        contentItem: Label
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
            anchors.right: downArrow.left
            rightPadding: swatch.width + QD.Theme.getSize("setting_unit_margin").width

            text: control.currentText
            textFormat: Text.PlainText
            renderType: Text.NativeRendering
            font: QD.Theme.getFont("default")
            color: enabled ? QD.Theme.getColor("setting_control_text") : QD.Theme.getColor("setting_control_disabled_text")

            elide: Text.ElideLeft
            verticalAlignment: Text.AlignVCenter

            background: QD.RecolorImage
            {
                id: swatch
                height: Math.round(parent.height / 2)
                width: height
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: QD.Theme.getSize("thin_margin").width

                sourceSize.width: width
                sourceSize.height: height
                source: QD.Theme.getIcon("ExtruderSolid", "medium")
                color: control.color
            }
        }

        popup: Popup
        {
            y: control.height - QD.Theme.getSize("default_lining").height
            width: control.width
            implicitHeight: contentItem.implicitHeight + 2 * QD.Theme.getSize("default_lining").width
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
            width: control.width - 2 * QD.Theme.getSize("default_lining").width
            height: control.height
            highlighted: control.highlightedIndex == index

            contentItem: Label
            {
                anchors.fill: parent
                anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
                anchors.rightMargin: QD.Theme.getSize("setting_unit_margin").width

                text: model.name
                renderType: Text.NativeRendering
                color:
                {
                    if (model.enabled)
                    {
                        QD.Theme.getColor("setting_control_text")
                    } else
                    {
                        QD.Theme.getColor("action_button_disabled_text");
                    }
                }
                font: QD.Theme.getFont("default")
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                rightPadding: swatch.width + QD.Theme.getSize("setting_unit_margin").width

                background: QD.RecolorImage
                {
                    id: swatch
                    height: Math.round(parent.height / 2)
                    width: height
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: QD.Theme.getSize("thin_margin").width

                    sourceSize.width: width
                    sourceSize.height: height
                    source: QD.Theme.getIcon("ExtruderSolid", "medium")
                    color: control.model.getItem(index).color
                }
            }

            background: Rectangle
            {
                color: parent.highlighted ? QD.Theme.getColor("setting_control_highlight") : "transparent"
                border.color: parent.highlighted ? QD.Theme.getColor("setting_control_border_highlight") : "transparent"
            }
        }
    }
}
