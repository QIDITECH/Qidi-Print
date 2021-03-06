// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import UM 1.1 as UM
import Cura 1.0 as Cura

SettingItem
{
    id: base
    property var focusItem: control

    enabled:// provider.properties.enabled == "True"
    {
        if (!Cura.ExtruderManager.activeExtruderStackId && machineExtruderCount.properties.value > 1)
        {
            // disable all controls on the global tab, except categories
            return model.type == "category"
        }
        return provider.properties.enabled == "True"
    }

    contents: ComboBox
    {
        id: control

        model: definition.options
        textRole: "value"

        anchors.fill: parent

        MouseArea
        {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel.accepted = true
        }

        background: Rectangle
        {
            color:
            {
                if (!enabled) {
                    return UM.Theme.getColor("color1")
                }

                if (control.hovered || control.activeFocus) {
                    return UM.Theme.getColor("color7")
                }

                return UM.Theme.getColor("color7")
            }

            radius: 3 * UM.Theme.getSize("default_margin").width/10
            border.width: 1 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("default_lining").width
            border.color:
            {
                if (!enabled) {
                    return UM.Theme.getColor("color2")
                }

                if (control.hovered || control.activeFocus) {
                    return UM.Theme.getColor("color16")
                }

                return UM.Theme.getColor("color2")
            }
        }

        indicator: UM.RecolorImage
        {
            id: downArrow
            x: control.width - width - control.rightPadding
            y: control.topPadding + Math.round((control.availableHeight - height) / 2)

            source: UM.Theme.getIcon("arrow_bottom")
            width: UM.Theme.getSize("standard_arrow").width
            height: UM.Theme.getSize("standard_arrow").height
            sourceSize.width: width + 5 * screenScaleFactor
            sourceSize.height: width + 5 * screenScaleFactor

            color: !enabled ? UM.Theme.getColor("color8") : UM.Theme.getColor("color4")
        }

        contentItem: Label
        {
            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("setting_unit_margin").width
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: downArrow.left

            text: control.currentText
            renderType: Text.NativeRendering
            font: UM.Theme.getFont("default")
            color: !enabled ? UM.Theme.getColor("color8") : UM.Theme.getColor("color4")
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        popup: Popup {
            y: control.height - UM.Theme.getSize("default_lining").height
            width: control.width
            implicitHeight: contentItem.implicitHeight + 2 * UM.Theme.getSize("default_margin").width/10
            padding: UM.Theme.getSize("default_lining").width

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: control.popup.visible ? control.delegateModel : null
                currentIndex: control.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                color: UM.Theme.getColor("color7")
                border.color: UM.Theme.getColor("color16")
                radius: 3 * UM.Theme.getSize("default_margin").width/10
            }
        }

        delegate: ItemDelegate
        {
            width: control.width - 2 * UM.Theme.getSize("default_lining").width
            height: control.height
            highlighted: control.highlightedIndex == index

            contentItem: Label
            {
                text: modelData.value
                renderType: Text.NativeRendering
                color: control.contentItem.color
                font: UM.Theme.getFont("default")
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                anchors.left: parent.left
                anchors.leftMargin: UM.Theme.getSize("setting_unit_margin").width
                anchors.verticalCenter: parent.verticalCenter
            }

            background: Rectangle
            {
                color: parent.highlighted ? UM.Theme.getColor("color7") : "transparent"
                border.color: parent.hovered ? UM.Theme.getColor("color16") : "transparent"
                radius: 3 * UM.Theme.getSize("default_margin").width/10
                border.width: 1 * UM.Theme.getSize("default_margin").width/10
            }
        }

        onActivated:
        {
            forceActiveFocus()
            propertyProvider.setPropertyValue("value", definition.options[index].key)
        }

        onActiveFocusChanged:
        {
            if(activeFocus)
            {
                base.focusReceived()
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

        Binding
        {
            target: control
            property: "currentIndex"
            value:
            {
                // FIXME this needs to go away once 'resolve' is combined with 'value' in our data model.
                var value = undefined;
                if ((base.resolve != "None") && (base.stackLevel != 0) && (base.stackLevel != 1)) {
                    // We have a resolve function. Indicates that the setting is not settable per extruder and that
                    // we have to choose between the resolved value (default) and the global value
                    // (if user has explicitly set this).
                    value = base.resolve;
                }

                if (value == undefined) {
                    value = propertyProvider.properties.value;
                }

                for(var i = 0; i < control.model.length; ++i) {
                    if(control.model[i].key == value) {
                        return i;
                    }
                }

                return -1;
            }
        }
    }
}
