// Copyright (c) 2016 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import UM 1.1 as UM
import Cura 1.0 as Cura

SettingItem
{
    id: base
    property var focusItem: control

    contents: ComboBox
    {
        id: control
        anchors.fill: parent

        enabled:// provider.properties.enabled == "True"
            {
                if (!Cura.ExtruderManager.activeExtruderStackId && machineExtruderCount.properties.value > 1)
                {
                    // disable all controls on the global tab, except categories
                    return model.type == "category"
                }
                return provider.properties.enabled == "True"
            }

        model: Cura.ExtrudersModel
        {
            onModelChanged: {
                control.color = getItem(control.currentIndex).color;
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

        currentIndex: propertyProvider.properties.value

        MouseArea
        {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel.accepted = true;
        }

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
            value:
            {
                if(propertyProvider.properties.value == -1)
                {
                    return control.getIndexByPosition(Cura.MachineManager.defaultExtruderPosition);
                }
                return propertyProvider.properties.value
            }
            // Sometimes when the value is already changed, the model is still being built.
            // The when clause ensures that the current index is not updated when this happens.
            when: control.model.items.length > 0
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

        background: Rectangle
        {
            radius: 3 * UM.Theme.getSize("default_margin").width/10
            color:
            {
                if (!enabled)
                {
                    return UM.Theme.getColor("color1");
                }
                if (control.hovered || control.activeFocus)
                {
                    return UM.Theme.getColor("color7");
                }
                return UM.Theme.getColor("color7");
            }
            border.width: UM.Theme.getSize("default_margin").width/10
            border.color:
            {
                if (!enabled)
                {
                    return UM.Theme.getColor("color2")
                }
                if (control.hovered || control.activeFocus)
                {
                    return UM.Theme.getColor("color16")
                }
                return UM.Theme.getColor("color2")
            }
        }

        contentItem: Label
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: UM.Theme.getSize("setting_unit_margin").width
            anchors.right: downArrow.left
            rightPadding: swatch.width + UM.Theme.getSize("setting_unit_margin").width

            text: control.currentText
            renderType: Text.NativeRendering
            font: UM.Theme.getFont("default")
            color: enabled ? UM.Theme.getColor("color4") : UM.Theme.getColor("color8")

            elide: Text.ElideMiddle
            verticalAlignment: Text.AlignVCenter

            background: Rectangle
            {
                id: swatch
                height: Math.round(UM.Theme.getSize("setting_control").height / 2)
                width: height

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Math.round(UM.Theme.getSize("default_margin").width / 4)

                //border.width: UM.Theme.getSize("default_lining").width
                //border.color: enabled ? UM.Theme.getColor("setting_control_border") : UM.Theme.getColor("setting_control_disabled_border")
                radius: 2 * UM.Theme.getSize("default_margin").width/10

                color:
                {
                    if (control.currentText == "Extruder 1" || control.currentText == "Extruder R")
                    {
                        return UM.Preferences.getValue("color/extruder1")
                    }
                    else if (control.currentText == "Extruder 2" || control.currentText == "Extruder L")
                    {
                        return UM.Preferences.getValue("color/extruder2")
                    }
                    else
                    {
                        return UM.Theme.getColor("color21")
                    }
                }
            }
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
                radius: 3 * UM.Theme.getSize("default_margin").width/10
                border.color: UM.Theme.getColor("color16")
            }
        }

        delegate: ItemDelegate
        {
            width: control.width - 2 * UM.Theme.getSize("default_lining").width
            height: control.height
            highlighted: control.highlightedIndex == index

            contentItem: Label
            {
                text: model.name
                renderType: Text.NativeRendering
                color:
                {
                    if (model.enabled) {
                        UM.Theme.getColor("color4")
                    } else {
                        UM.Theme.getColor("color8");
                    }
                }
                font: UM.Theme.getFont("default")
                elide: Text.ElideMiddle
                verticalAlignment: Text.AlignVCenter
                //rightPadding: swatch.width + UM.Theme.getSize("setting_unit_margin").width
                anchors.left: parent.left
                anchors.leftMargin: UM.Theme.getSize("setting_unit_margin").width
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle
                {
                    id: swatch
                    height: Math.round(UM.Theme.getSize("setting_control").height / 2)
                    width: height

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: -1 * UM.Theme.getSize("default_margin").width/10//Math.round(UM.Theme.getSize("default_margin").width / 4)

                    //border.width: UM.Theme.getSize("default_lining").width
                    //border.color: enabled ? UM.Theme.getColor("setting_control_border") : UM.Theme.getColor("setting_control_disabled_border")
                    radius: 2 * UM.Theme.getSize("default_margin").width/10

                    color:
                    {
                        if (model.name == "Extruder 1" || model.name == "Extruder R")
                        {
                            return UM.Preferences.getValue("color/extruder1")
                        }
                        else if (model.name == "Extruder 2" || model.name == "Extruder L")
                        {
                            return UM.Preferences.getValue("color/extruder2")
                        }
                        else
                        {
                            return UM.Theme.getColor("color21")
                        }
                    }
                }
            }

            background: Rectangle
            {
                color: UM.Theme.getColor("color7")
                border.color: parent.hovered ? UM.Theme.getColor("color16") : "transparent"
                radius: 3 * UM.Theme.getSize("default_margin").width/10
                border.width: 1 * UM.Theme.getSize("default_margin").width/10
            }
        }
    }
}
