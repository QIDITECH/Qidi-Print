// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import UM 1.1 as UM

QtObject {
    property Component sidebar_header_button: Component {
        ButtonStyle {
            background: Rectangle {
                color: Theme.getColor("color7")
                /*{
                    if(control.enabled)
                    {
                        if(control.valueError)
                        {
                            return Theme.getColor("setting_validation_error_background");
                        }
                        else if(control.valueWarning)
                        {
                            return Theme.getColor("setting_validation_warning_background");
                        }
                        else
                        {
                            return Theme.getColor("setting_control");
                        }
                    }
                    else
                    {
                        return Theme.getColor("setting_control_disabled");
                    }
                }*/

                radius: 3 * UM.Theme.getSize("default_margin").width/10
                border.width: 1 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("default_lining").width
                border.color: Theme.getColor("color2")
                /*{
                    if (control.enabled)
                    {
                        if (control.valueError)
                        {
                            return Theme.getColor("setting_validation_error");
                        }
                        else if (control.valueWarning)
                        {
                            return Theme.getColor("setting_validation_warning");
                        }
                        else if (control.hovered)
                        {
                            return Theme.getColor("setting_control_border_highlight");
                        }
                        else
                        {
                            return Theme.getColor("setting_control_border");
                        }
                    }
                    else
                    {
                        return Theme.getColor("setting_control_disabled_border");
                    }
                }*/

                Rectangle
                {
                    id:rightborder
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 28 * UM.Theme.getSize("default_margin").width/10
                    clip: true
                    Rectangle
                    {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 40 * UM.Theme.getSize("default_margin").width/10
                        radius: 3 * UM.Theme.getSize("default_margin").width/10
                        border.width: 1 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("default_lining").width
                        border.color: Theme.getColor("color2")
                        gradient: Gradient
                        {
                            GradientStop
                            {
                                position: 0.0;
                                color: UM.Theme.getColor("color10")
                            }
                            GradientStop
                            {
                                position: 1.0;
                                color: UM.Theme.getColor("color9")
                            }
                        }

                    }
                }

                Rectangle
                {
                    anchors.right: rightborder.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1 * UM.Theme.getSize("default_margin").width/10
                    color: Theme.getColor("color2")
                }

                UM.RecolorImage {
                    id: downArrow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.getSize("default_margin").width
                    width: Theme.getSize("standard_arrow").width
                    height: Theme.getSize("standard_arrow").height
                    sourceSize.width: width
                    sourceSize.height: width
                    color: control.enabled ? Theme.getColor("color4") : Theme.getColor("setting_category_disabled_text")
                    source: Theme.getIcon("arrow_bottom")
                }
                Label {
                    id: sidebarComboBoxLabel
                    color: control.enabled ? Theme.getColor("color4") : Theme.getColor("setting_control_disabled_text")
                    text: control.text;
                    elide: Text.ElideRight;
                    anchors.left: parent.left;
                    anchors.leftMargin: Theme.getSize("setting_unit_margin").width
                    anchors.right: downArrow.left;
                    anchors.rightMargin: control.rightMargin;
                    anchors.verticalCenter: parent.verticalCenter;
                    font: Theme.getFont("default")
                }
            }
            label: Label{}
        }
    }

    property Component topbar_header_tab_no_overlay: Component {
        ButtonStyle {
            background: Rectangle {
                implicitHeight: Theme.getSize("topbar_button").height
                implicitWidth: Theme.getSize("topbar_button").width
                color: "transparent"
                anchors.fill: parent

                Rectangle
                {
                    id: underline

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: Theme.getSize("sidebar_header_highlight").height
                    color: control.checked ? UM.Theme.getColor("sidebar_header_highlight") : UM.Theme.getColor("sidebar_header_highlight_hover")
                    visible: control.hovered || control.checked
                }
            }

            label: Rectangle {
                implicitHeight: Theme.getSize("topbar_button_icon").height
                implicitWidth: Theme.getSize("topbar_button").width
                color: "transparent"
                anchors.fill: parent

                Item
                {
                    anchors.centerIn: parent
                    width: Math.round(textLabel.width + icon.width + Theme.getSize("default_margin").width / 2)
                    Label
                    {
                        id: textLabel
                        text: control.text
                        anchors.right: icon.visible ? icon.left : parent.right
                        anchors.rightMargin: icon.visible ? Math.round(Theme.getSize("default_margin").width / 2) : 0
                        anchors.verticalCenter: parent.verticalCenter;
                        font: control.checked ? UM.Theme.getFont("large") : UM.Theme.getFont("large_nonbold")
                        color:
                        {
                            if(control.hovered)
                            {
                                return UM.Theme.getColor("topbar_button_text_hovered");
                            }
                            if(control.checked)
                            {
                                return UM.Theme.getColor("topbar_button_text_active");
                            }
                            else
                            {
                                return UM.Theme.getColor("topbar_button_text_inactive");
                            }
                        }
                    }
                    Image
                    {
                        id: icon
                        visible: control.iconSource != ""
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: !control.enabled ? 0.2 : 1.0
                        source: control.iconSource
                        width: visible ? Theme.getSize("topbar_button_icon").width : 0
                        height: Theme.getSize("topbar_button_icon").height

                        sourceSize: Theme.getSize("topbar_button_icon")
                    }
                }
            }
        }
    }

    property Component topbar_header_tab: Component {
        ButtonStyle {
            background: Item {
                implicitHeight: Theme.getSize("topbar_button").height
                implicitWidth: Theme.getSize("topbar_button").width + Theme.getSize("topbar_button_icon").width

                Rectangle {
                    id: buttonFace;
                    anchors.fill: parent;

                    color: "transparent"
                    Behavior on color { ColorAnimation { duration: 50; } }

                    Rectangle {
                        id: underline;

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: Theme.getSize("topbar_button").width + Theme.getSize("topbar_button_icon").width
                        height: Theme.getSize("sidebar_header_highlight").height
                        color: control.checked ? UM.Theme.getColor("sidebar_header_highlight") : UM.Theme.getColor("sidebar_header_highlight_hover")
                        visible: control.hovered || control.checked
                    }
                }
            }

            label: Item
            {
                implicitHeight: Theme.getSize("topbar_button_icon").height
                implicitWidth: Theme.getSize("topbar_button").width + Theme.getSize("topbar_button_icon").width
                Item
                {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter;
                    width: childrenRect.width
                    height: Theme.getSize("topbar_button_icon").height
                    Label
                    {
                        id: button_label
                        text: control.text;
                        anchors.verticalCenter: parent.verticalCenter;
                        font: control.checked ? UM.Theme.getFont("large") : UM.Theme.getFont("large_nonbold")
                        color:
                        {
                            if(control.hovered)
                            {
                                return UM.Theme.getColor("topbar_button_text_hovered");
                            }
                            if(control.checked)
                            {
                                return UM.Theme.getColor("topbar_button_text_active");
                            }
                            else
                            {
                                return UM.Theme.getColor("topbar_button_text_inactive");
                            }
                        }
                    }
                    UM.RecolorImage
                    {
                        visible: control.iconSource != ""
                        id: icon
                        anchors.left: button_label.right
                        anchors.leftMargin: (icon.visible || overlayIcon.visible) ? Theme.getSize("default_margin").width : 0
                        color: UM.Theme.getColor("text_emphasis")
                        opacity: !control.enabled ? 0.2 : 1.0
                        source: control.iconSource
                        width: visible ? Theme.getSize("topbar_button_icon").width : 0
                        height: Theme.getSize("topbar_button_icon").height

                        sourceSize: Theme.getSize("topbar_button_icon")
                    }
                    UM.RecolorImage
                    {
                        id: overlayIcon
                        anchors.left: button_label.right
                        anchors.leftMargin: (icon.visible || overlayIcon.visible) ? Theme.getSize("default_margin").width : 0
                        visible: control.overlayIconSource != "" && control.iconSource != ""
                        color: control.overlayColor
                        opacity: !control.enabled ? 0.2 : 1.0
                        source: control.overlayIconSource
                        width: visible ? Theme.getSize("topbar_button_icon").width : 0
                        height: Theme.getSize("topbar_button_icon").height

                        sourceSize: Theme.getSize("topbar_button_icon")
                    }
                }
            }
        }
    }

    property Component savebutton: Component {
        ButtonStyle {
            background: Item {
                //implicitWidth: 100//Theme.getSize("button").width;
                implicitWidth: textLabel.contentWidth + (UM.Theme.getSize("sidebar_margin").width * 2)
                implicitHeight: 26 * UM.Theme.getSize("default_margin").width/10
                Label {
                    id: textLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter;
                    text: control.text
                    font: Theme.getFont("font2");
                    color:
                    {
                        if(!control.enabled)
                            return UM.Theme.getColor("color8");
                        else
                            return UM.Theme.getColor("color7");
                    }
                    z: 1
                }

                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);
                    gradient: Gradient
                    {
                        GradientStop
                        {
                            position: 0.0;
                            color:// UM.Theme.getColor("color11")
                            {
                                if(!control.enabled)
                                    return UM.Theme.getColor("color9");
                                else if(control.pressed)
                                    return UM.Theme.getColor("color12");
                                else if(control.hovered)
                                    return UM.Theme.getColor("color11");
                                else
                                    return UM.Theme.getColor("color11");
                            }
                        }
                        GradientStop
                        {
                            position: 1.0;
                            color:// UM.Theme.getColor("color12")
                            {
                                if(!control.enabled)
                                    return UM.Theme.getColor("color9");
                                else if(control.pressed)
                                    return UM.Theme.getColor("color26");
                                else if(control.hovered)
                                    return UM.Theme.getColor("color12");
                                else
                                    return UM.Theme.getColor("color12");
                            }
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }

                    radius: 13 * UM.Theme.getSize("default_margin").width/10
                    border.width: control.enabled ? 2 * UM.Theme.getSize("default_margin").width/10 : UM.Theme.getSize("default_margin").width/10
                    border.color:
                    {
                        if(!control.enabled)
                            return UM.Theme.getColor("color2");
                        else if(control.pressed)
                            return UM.Theme.getColor("color26");
                        else if(control.hovered)
                            return UM.Theme.getColor("color19");
                        else
                            return UM.Theme.getColor("color19");
                    }
                }
            }
            label: Item { }
        }
    }

    property Component parameterbutton: Component {
        ButtonStyle {
            background: Item {
                //implicitWidth: 100//Theme.getSize("button").width;
                implicitWidth: textLabel.contentWidth + (UM.Theme.getSize("sidebar_margin").width * 2)
                implicitHeight: Theme.getSize("button").height;
                Label {
                    id: textLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter;
                    text: control.text
                    font: Theme.getFont("font1");
                    color: Theme.getColor("color4");
                    z: 1
                }

                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);
                    gradient: Gradient
                    {
                        GradientStop { position: 0.0; color: UM.Theme.getColor("color10")}
                        GradientStop { position: 1.0; color: UM.Theme.getColor("color9")}
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }

                    radius: parent.width/2
                    border.width: 1 * UM.Theme.getSize("default_margin").width/10//(control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color: Theme.getColor("color2")
                }
            }
            label: Item { }
        }
    }

    property Component tool_button: Component {
        ButtonStyle {
            background: Item {
                implicitWidth: 60 * Theme.getSize("default_margin").width/10//Theme.getSize("button").width;
                implicitHeight: 50 * Theme.getSize("default_margin").width/10//Theme.getSize("button").height;

                UM.PointingRectangle {
                    id: button_tooltip

                    anchors.left: parent.right
                    anchors.leftMargin: Theme.getSize("button_tooltip_arrow").width * 2
                    anchors.verticalCenter: parent.verticalCenter

                    //target: Qt.point(parent.x, y + Math.round(height/2))
                    //arrowSize: Theme.getSize("button_tooltip_arrow").width
                    color: Theme.getColor("color9")
                    opacity: control.hovered ? 1.0 : 0.0;
                    visible: control.text != ""

                    width: control.hovered ? button_tip.width + Theme.getSize("button_tooltip").width : 0
                    height: Theme.getSize("button_tooltip").height

                    Behavior on width { NumberAnimation { duration: 100; } }
                    Behavior on opacity { NumberAnimation { duration: 100; } }

                    Label {
                        id: button_tip

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter;

                        text: control.text;
                        font: Theme.getFont("button_tooltip");
                        color: Theme.getColor("color4");
                    }
                }

                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);

                    color:
                    {
                        if(control.customColor !== undefined && control.customColor !== null)
                        {
                            return control.customColor
                        }
                        else if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color6");
                        }
                        else
                        {
                            return Theme.getColor("color1");
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }

                    border.width: (control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color: Theme.getColor("tool_button_border")

                    UM.RecolorImage {
                        id: tool_button_arrow
                        anchors.right: parent.right;
                        anchors.rightMargin: Theme.getSize("button").width - Math.round(Theme.getSize("button_icon").width / 4)
                        anchors.bottom: parent.bottom;
                        anchors.bottomMargin: Theme.getSize("button").height - Math.round(Theme.getSize("button_icon").height / 4)
                        width: Theme.getSize("standard_arrow").width
                        height: Theme.getSize("standard_arrow").height
                        sourceSize.width: width
                        sourceSize.height: width
                        visible: control.menu != null;
                        color:
                        {
                            if(control.checkable && control.checked && control.hovered)
                            {
                                return Theme.getColor("color2");
                            }
                            else if(control.pressed || (control.checkable && control.checked))
                            {
                                return Theme.getColor("color2");
                            }
                            else if(control.hovered)
                            {
                                return Theme.getColor("color2");
                            }
                            else
                            {
                                return Theme.getColor("color2");
                            }
                        }
                        source: Theme.getIcon("arrow_bottom")
                    }
                }
            }

            label: Item {
                UM.RecolorImage {
                    anchors.centerIn: parent;
                    opacity: !control.enabled ? 0.2 : 1.0
                    source: control.iconSource;
                    width: Theme.getSize("button_icon").width;
                    height: Theme.getSize("button_icon").height;
                    color:
                    {
                        if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else
                        {
                            return Theme.getColor("color8");
                        }
                    }
                    sourceSize: Theme.getSize("button_icon")
                }
            }
        }
    }

    property Component sidebar_button: Component {
        ButtonStyle {
            background: Item {
                implicitWidth: 50 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").width;
                implicitHeight: 50 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").height;

                UM.PointingRectangle {
                    id: button_tooltip

                    anchors.left: parent.right
                    anchors.leftMargin: Theme.getSize("button_tooltip_arrow").width * 2
                    anchors.verticalCenter: parent.verticalCenter

                    target: Qt.point(parent.x, y + Math.round(height/2))
                    arrowSize: Theme.getSize("button_tooltip_arrow").width
                    color: Theme.getColor("color9")
                    opacity: control.hovered ? 1.0 : 0.0;
                    visible: control.text != ""

                    width: control.hovered ? button_tip.width + Theme.getSize("button_tooltip").width : 0
                    height: Theme.getSize("button_tooltip").height

                    Behavior on width { NumberAnimation { duration: 100; } }
                    Behavior on opacity { NumberAnimation { duration: 100; } }

                    Label {
                        id: button_tip

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter;

                        text: control.text;
                        font: Theme.getFont("button_tooltip");
                        color: Theme.getColor("color4");
                    }
                }

                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);

                    gradient: Gradient
                    {
                        GradientStop
                        {
                            position: 0.0;
                            color: //UM.Theme.getColor("color10")
                            {
                                if (control.pressed)
                                {
                                    return UM.Theme.getColor("color5");
                                }
                                else if (control.hovered)
                                {
                                    return UM.Theme.getColor("color6");
                                }
                                else
                                {
                                    return UM.Theme.getColor("color10");
                                }
                            }
                        }
                        GradientStop
                        {
                            position: 1.0;
                            color: //UM.Theme.getColor("color9")
                            {
                                if (control.pressed)
                                {
                                    return UM.Theme.getColor("color5");
                                }
                                else if (control.hovered)
                                {
                                    return UM.Theme.getColor("color6");
                                }
                                else {
                                    return UM.Theme.getColor("color9");
                                }
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 50; } }

                    border.width: (control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color: Theme.getColor("tool_button_border")

                    UM.RecolorImage {
                        id: tool_button_arrow
                        anchors.right: parent.right;
                        anchors.rightMargin: Theme.getSize("button").width - Math.round(Theme.getSize("button_icon").width / 4)
                        anchors.bottom: parent.bottom;
                        anchors.bottomMargin: Theme.getSize("button").height - Math.round(Theme.getSize("button_icon").height / 4)
                        width: Theme.getSize("standard_arrow").width
                        height: Theme.getSize("standard_arrow").height
                        sourceSize.width: width
                        sourceSize.height: width
                        visible: control.menu != null;
                        color:
                        {
                            if(control.checkable && control.checked && control.hovered)
                            {
                                return Theme.getColor("color2");
                            }
                            else if(control.pressed || (control.checkable && control.checked))
                            {
                                return Theme.getColor("color2");
                            }
                            else if(control.hovered)
                            {
                                return Theme.getColor("color2");
                            }
                            else
                            {
                                return Theme.getColor("color2");
                            }
                        }
                        source: Theme.getIcon("arrow_bottom")
                    }
                }
            }

            label: Item {
                UM.RecolorImage {
 //                   anchors.centerIn: parent;
                    //anchors.top: parent.top;
                    //anchors.topMargin: 7
                    //anchors.right:parent.right
                    //anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 2 * UM.Theme.getSize("default_margin").width/10
                    opacity: !control.enabled ? 0.2 : 1.0
                    source: control.iconSource;
                    width: 20 * UM.Theme.getSize("default_margin").width/10
                    height: 20 * UM.Theme.getSize("default_margin").width/10
                    color:
                    {
                        if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else
                        {
                            return Theme.getColor("color8");
                        }
                    }

                    sourceSize: Theme.getSize("button_icon")
                }
            }
        }
    }

    property Component small_tool_button: Component {
        ButtonStyle {
            background: Item {
                implicitWidth: Theme.getSize("small_button").width;
                implicitHeight: Theme.getSize("small_button").height;

                UM.PointingRectangle {
                    id: small_button_tooltip

                    anchors.bottom: parent.top
                    anchors.bottomMargin: Theme.getSize("button_tooltip_arrow").width + 9
                    anchors.horizontalCenter: parent.horizontalCenter

                    target: Qt.point(parent.x, y + Math.round(height/2))
                    arrowSize: Theme.getSize("button_tooltip_arrow").width
                    color: Theme.getColor("color21")
                    //opacity: control.hovered ? 1.0 : 0.0;
                    visible: control.text != ""

                    width: button_tip.width + Theme.getSize("button_tooltip").width//control.hovered ? button_tip.width + Theme.getSize("button_tooltip").width : 0
                    height: Theme.getSize("button_tooltip").height

                    Behavior on width { NumberAnimation { duration: 100; } }
                    Behavior on opacity { NumberAnimation { duration: 100; } }

                    Label {
                        id: button_tip

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter;

                        text: control.text;
                        font: Theme.getFont("button_tooltip");
                        color: //Theme.getColor("color4")
                        {
                            if(control.customColor !== undefined && control.customColor !== null)
                            {
                                return control.customColor
                            }
                            else if(control.checkable && control.checked && control.hovered)
                            {
                                return Theme.getColor("color12");
                            }
                            else if(control.pressed || (control.checkable && control.checked))
                            {
                                return Theme.getColor("color12");
                            }
                            else if(control.hovered)
                            {
                                return Theme.getColor("color4");
                            }
                            else
                            {
                                return Theme.getColor("color4");
                            }
                        }
                    }
                }

                Rectangle {
                    id: smallButtonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);

                    color:
                    {
                        if(control.customColor !== undefined && control.customColor !== null)
                        {
                            return control.customColor
                        }
                        else if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color6");
                        }
                        else
                        {
                            return Theme.getColor("color21");
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }

                    border.width: (control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color: Theme.getColor("tool_button_border")

                    UM.RecolorImage {
                        id: smallToolButtonArrow

                        width: 5 * UM.Theme.getSize("default_margin").width/10
                        height: 5 * UM.Theme.getSize("default_margin").width/10
                        sourceSize.width: 5 * UM.Theme.getSize("default_margin").width/10
                        sourceSize.height: 5 * UM.Theme.getSize("default_margin").width/10
                        visible: control.menu != null;
                        color:
                        {
                            if(control.checkable && control.checked && control.hovered)
                            {
                                return Theme.getColor("small_button_text_active_hover");
                            }
                            else if(control.pressed || (control.checkable && control.checked))
                            {
                                return Theme.getColor("small_button_text_active");
                            }
                            else if(control.hovered)
                            {
                                return Theme.getColor("small_button_text_hover");
                            }
                            else
                            {
                                return Theme.getColor("small_button_text");
                            }
                        }
                        source: Theme.getIcon("arrow_bottom")
                    }
                }
            }

            label: Item {
                UM.RecolorImage {
                    anchors.centerIn: parent;
                    opacity: !control.enabled ? 0.2 : 1.0
                    source: control.iconSource;
                    width: Theme.getSize("small_button_icon").width;
                    height: Theme.getSize("small_button_icon").height;
                    color:
                    {
                        if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else
                        {
                            return Theme.getColor("color8");
                        }
                    }

                    sourceSize: Theme.getSize("small_button_icon")
                }
            }
        }
    }

    property Component progressbar: Component{
        ProgressBarStyle {
            background: Rectangle {
                implicitWidth: Theme.getSize("message").width - (Theme.getSize("default_margin").width * 2)
                implicitHeight: Theme.getSize("progressbar").height
                color: control.hasOwnProperty("backgroundColor") ? control.backgroundColor : Theme.getColor("progressbar_background")
            }
            progress: Rectangle {
                color:
                {
                    if(control.indeterminate)
                    {
                        return "transparent";
                    }
                    else if(control.hasOwnProperty("controlColor"))
                    {
                        return  Theme.getColor("color9")//control.controlColor;
                    }
                    else
                    {
                        return Theme.getColor("color9");
                    }
                }
                radius: Theme.getSize("progressbar_radius").width
                Rectangle{
                    radius: Theme.getSize("progressbar_radius").width
                    color: Theme.getColor("color16")//control.hasOwnProperty("controlColor") ? control.controlColor : Theme.getColor("color16")
                    width: Theme.getSize("progressbar_control").width
                    height: Theme.getSize("progressbar_control").height
                    visible: control.indeterminate

                    SequentialAnimation on x {
                        id: xAnim
                        property int animEndPoint: Theme.getSize("message").width - (Theme.getSize("default_margin").width * 2) - Theme.getSize("progressbar_control").width
                        running: control.indeterminate && control.visible
                        loops: Animation.Infinite
                        NumberAnimation { from: 0; to: xAnim.animEndPoint; duration: 2000;}
                        NumberAnimation { from: xAnim.animEndPoint; to: 0; duration: 2000;}
                    }
                }
            }
        }
    }

    property Component sidebar_category: Component {
        ButtonStyle {
            background: Rectangle {
                anchors.fill: parent;
                anchors.left: parent.left
                anchors.leftMargin: Theme.getSize("sidebar_margin").width
                anchors.right: parent.right
                anchors.rightMargin: Theme.getSize("sidebar_margin").width
                implicitHeight: Theme.getSize("section").height;
                color: {
                    if(control.color) {
                        return control.color;
                    } else if(!control.enabled) {
                        return Theme.getColor("setting_category_disabled");
                    } else if(control.hovered && control.checkable && control.checked) {
                        return Theme.getColor("setting_category_active_hover");
                    } else if(control.pressed || (control.checkable && control.checked)) {
                        return Theme.getColor("setting_category_active");
                    } else if(control.hovered) {
                        return Theme.getColor("setting_category_hover");
                    } else {
                        return Theme.getColor("setting_category");
                    }
                }
                Behavior on color { ColorAnimation { duration: 50; } }
                Rectangle {
                    height: Theme.getSize("default_lining").height
                    width: parent.width
                    anchors.bottom: parent.bottom
                    color: {
                        if(!control.enabled) {
                            return Theme.getColor("setting_category_disabled_border");
                        } else if((control.hovered || control.activeFocus) && control.checkable && control.checked) {
                            return Theme.getColor("setting_category_active_hover_border");
                        } else if(control.pressed || (control.checkable && control.checked)) {
                            return Theme.getColor("setting_category_active_border");
                        } else if(control.hovered || control.activeFocus) {
                            return Theme.getColor("setting_category_hover_border");
                        } else {
                            return Theme.getColor("setting_category_border");
                        }
                    }
                }
            }
            label: Item {
                anchors.fill: parent;
                anchors.left: parent.left
                Item{
                    id: icon;
                    anchors.left: parent.left
                    height: parent.height
                    width: Theme.getSize("section_icon_column").width
                    UM.RecolorImage {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.getSize("sidebar_margin").width
                        color:
                        {
                            if(!control.enabled)
                            {
                                return Theme.getColor("setting_category_disabled_text");
                            }
                            else if((control.hovered || control.activeFocus) && control.checkable && control.checked)
                            {
                                return Theme.getColor("setting_category_active_hover_text");
                            }
                            else if(control.pressed || (control.checkable && control.checked))
                            {
                                return Theme.getColor("setting_category_active_text");
                            }
                            else if(control.hovered || control.activeFocus)
                            {
                                return Theme.getColor("setting_category_hover_text");
                            }
                            else
                            {
                                return Theme.getColor("setting_category_text");
                            }
                        }
                        source: control.iconSource;
                        width: Theme.getSize("section_icon").width;
                        height: Theme.getSize("section_icon").height;
                        sourceSize.width: width + 15 * screenScaleFactor
                        sourceSize.height: width + 15 * screenScaleFactor
                    }
                }

                Label {
                    anchors {
                        left: icon.right;
                        leftMargin: Theme.getSize("default_margin").width;
                        right: parent.right;
                        verticalCenter: parent.verticalCenter;
                    }
                    text: control.text;
                    font: Theme.getFont("setting_category");
                    color:
                    {
                        if(!control.enabled)
                        {
                            return Theme.getColor("setting_category_disabled_text");
                        }
                        else if((control.hovered || control.activeFocus) && control.checkable && control.checked)
                        {
                            return Theme.getColor("setting_category_active_hover_text");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("setting_category_active_text");
                        }
                        else if(control.hovered || control.activeFocus)
                        {
                            return Theme.getColor("setting_category_hover_text");
                        }
                        else
                        {
                            return Theme.getColor("setting_category_text");
                        }
                    }
                    fontSizeMode: Text.HorizontalFit;
                    minimumPointSize: 8
                }
                UM.RecolorImage {
                    id: category_arrow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.getSize("default_margin").width * 3 - Math.round(width / 2)
                    width: Theme.getSize("standard_arrow").width
                    height: Theme.getSize("standard_arrow").height
                    sourceSize.width: width
                    sourceSize.height: width
                    color:
                    {
                        if(!control.enabled)
                        {
                            return Theme.getColor("setting_category_disabled_text");
                        }
                        else if((control.hovered || control.activeFocus) && control.checkable && control.checked)
                        {
                            return Theme.getColor("setting_category_active_hover_text");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("setting_category_active_text");
                        }
                        else if(control.hovered || control.activeFocus)
                        {
                            return Theme.getColor("setting_category_hover_text");
                        }
                        else
                        {
                            return Theme.getColor("setting_category_text");
                        }
                    }
                    source: control.checked ? Theme.getIcon("arrow_bottom") : Theme.getIcon("arrow_left")
                }
            }
        }
    }

    property Component scrollview: Component {
        ScrollViewStyle {
            decrementControl: Item { }
            incrementControl: Item { }

            transientScrollBars: false

            scrollBarBackground: Rectangle {
                implicitWidth: 6 * UM.Theme.getSize("default_margin").width/10
                radius: Math.round(implicitWidth / 2)
                color: Theme.getColor("color15");
            }

            handle: Rectangle {
                id: scrollViewHandle
                implicitWidth: 6 * UM.Theme.getSize("default_margin").width/10
                radius: Math.round(implicitWidth / 2)

                color: styleData.pressed ? Theme.getColor("color16") : styleData.hovered ? Theme.getColor("color16") : Theme.getColor("color8");
                Behavior on color { ColorAnimation { duration: 50; } }
            }
        }
    }

    property Component combobox: Component {
        ComboBoxStyle {

            background: Rectangle {
                id: background
                implicitHeight: Theme.getSize("setting_control").height + 2 * UM.Theme.getSize("default_margin").width/10;
                implicitWidth: Theme.getSize("setting_control").width;

                color: control.hovered ? UM.Theme.getColor("setting_control_highlight") : UM.Theme.getColor("setting_control")
                Behavior on color { ColorAnimation { duration: 50; } }

                border.width: UM.Theme.getSize("default_margin").width/10
                border.color: //control.hovered ? Theme.getColor("setting_control_border_highlight") : Theme.getColor("setting_control_border");
                {
                    if(control.hovered || control.activeFocus)
                        return Theme.getColor("color16")
                    else
                        return Theme.getColor("color2")
                }
                radius: 3 * UM.Theme.getSize("default_margin").width/10
            }

            label: Item {

                Label {
                    anchors.left: parent.left;
                    anchors.leftMargin: Theme.getSize("default_lining").width
                    anchors.right: downArrow.left;
                    anchors.rightMargin: Theme.getSize("default_lining").width;
                    anchors.verticalCenter: parent.verticalCenter;

                    text: control.currentText
                    font: Theme.getFont("font1");
                    color: !enabled ? Theme.getColor("setting_control_disabled_text") : Theme.getColor("setting_control_text");

                    elide: Text.ElideMiddle;
                    verticalAlignment: Text.AlignVCenter;
                }

                UM.RecolorImage {
                    id: downArrow
                    anchors.right: parent.right;
                    anchors.rightMargin: Theme.getSize("default_lining").width * 2;
                    anchors.verticalCenter: parent.verticalCenter;

                    source: Theme.getIcon("arrow_bottom")
                    width: Theme.getSize("standard_arrow").width
                    height: Theme.getSize("standard_arrow").height
                    sourceSize.width: width + 5 * screenScaleFactor
                    sourceSize.height: width + 5 * screenScaleFactor

                    color: Theme.getColor("setting_control_text");
                }
            }
        }
    }

    // Combobox with items with colored rectangles
    property Component combobox_color: Component {

        ComboBoxStyle {

            background: Rectangle {
                id: background
                implicitHeight: Theme.getSize("setting_control").height + 2 * UM.Theme.getSize("default_margin").width/10;
                implicitWidth: Theme.getSize("setting_control").width;

                color: control.hovered ? UM.Theme.getColor("setting_control_highlight") : UM.Theme.getColor("setting_control")
                Behavior on color { ColorAnimation { duration: 50; } }

                border.width: UM.Theme.getSize("default_margin").width/10
                border.color:
                {
                    if(control.hovered || control.activeFocus)
                        return Theme.getColor("color16")
                    else
                        return Theme.getColor("color2")
                }
                radius: 3 * UM.Theme.getSize("default_margin").width/10
            }

            label: Item {

                Label {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.getSize("default_lining").width
                    anchors.right: swatch.left
                    anchors.rightMargin: Theme.getSize("default_lining").width
                    anchors.verticalCenter: parent.verticalCenter

                    text: control.currentText
                    font: Theme.getFont("font1");
                    color: !enabled ? Theme.getColor("setting_control_disabled_text") : Theme.getColor("setting_control_text")

                    elide: Text.ElideMiddle
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle
                {
                    id: swatch
                    height: Math.round(UM.Theme.getSize("setting_control").height / 2)
                    width: height
                    anchors.right: downArrow.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: Math.round(UM.Theme.getSize("default_margin").width / 4)
                    radius: 2 * UM.Theme.getSize("default_margin").width/10
                    color: UM.Preferences.getValue("color/extruder" + (control.currentIndex + 1))
                }

                UM.RecolorImage {
                    id: downArrow
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.getSize("default_lining").width * 2
                    anchors.verticalCenter: parent.verticalCenter

                    source: Theme.getIcon("arrow_bottom")
                    width: Theme.getSize("standard_arrow").width
                    height: Theme.getSize("standard_arrow").height
                    sourceSize.width: width + 5 * screenScaleFactor
                    sourceSize.height: width + 5 * screenScaleFactor

                    color: !enabled ? UM.Theme.getColor("color8") : UM.Theme.getColor("color4")
                }
            }
        }
    }

    property Component checkbox: Component {
        CheckBoxStyle {
            background: Item { }
            indicator: Rectangle {
                implicitWidth:  Theme.getSize("checkbox").width;
                implicitHeight: Theme.getSize("checkbox").height;

                color: (control.hovered || control._hovered) ? Theme.getColor("checkbox_hover") : Theme.getColor("checkbox");
                Behavior on color { ColorAnimation { duration: 50; } }

                //radius: control.exclusiveGroup ? Math.round(Theme.getSize("checkbox").width / 2) : 0

                //border.width: Theme.getSize("default_lining").width;
                //border.color: (control.hovered || control._hovered) ? Theme.getColor("checkbox_border_hover") : Theme.getColor("checkbox_border");
                radius: 3 * UM.Theme.getSize("default_margin").width/10
                border.width: 1 * UM.Theme.getSize("default_margin").width/10//UM.Theme.getSize("default_lining").width
                border.color:
                {
                    if(control.hovered || control.activeFocus)
                        return Theme.getColor("color16")
                    else
                        return Theme.getColor("color2")
                }

                UM.RecolorImage {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(parent.width / 2.5) + 2 * UM.Theme.getSize("default_margin").width/10
                    height: Math.round(parent.height / 2.5) + 2 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: Theme.getColor("color4")
                    source: Theme.getIcon("check")//control.exclusiveGroup ? Theme.getIcon("dot") : Theme.getIcon("check")
                    opacity: control.checked
                    Behavior on opacity { NumberAnimation { duration: 100; } }
                }
            }
            label: Label {
                text: control.text
                color: Theme.getColor("checkbox_text")
                font: Theme.getFont("font1")
                elide: Text.ElideRight
            }
        }
    }

    property Component small_checkbox: Component {
        CheckBoxStyle {
            background: Item { }
            indicator: Rectangle {
                implicitWidth:  Theme.getSize("checkbox").width - 6 * UM.Theme.getSize("default_margin").width/10;
                implicitHeight: Theme.getSize("checkbox").height - 6 * UM.Theme.getSize("default_margin").width/10;

                color: (control.hovered || control._hovered) ? Theme.getColor("checkbox_hover") : Theme.getColor("checkbox");
                Behavior on color { ColorAnimation { duration: 50; } }

                //radius: control.exclusiveGroup ? Math.round(Theme.getSize("checkbox").width / 2) : 0

                //border.width: Theme.getSize("default_lining").width;
                //border.color: (control.hovered || control._hovered) ? Theme.getColor("checkbox_border_hover") : Theme.getColor("checkbox_border");
                radius: 3
                border.width: 1//UM.Theme.getSize("default_lining").width
                border.color:
                {
                    if(control.hovered || control.activeFocus)
                        return Theme.getColor("color16")
                    else
                        return Theme.getColor("color2")
                }

                UM.RecolorImage {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(parent.width / 2.5) + 2 * UM.Theme.getSize("default_margin").width/10
                    height: Math.round(parent.height / 2.5) + 2 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: Theme.getColor("color4")
                    source: control.exclusiveGroup ? Theme.getIcon("dot") : Theme.getIcon("check")
                    opacity: control.checked
                    Behavior on opacity { NumberAnimation { duration: 100; } }
                }
            }
            label: Label {
                text: control.text
                color: Theme.getColor("checkbox_text")
                font: Theme.getFont("font1")
                elide: Text.ElideRight
            }
        }
    }

    property Component partially_checkbox: Component {
        CheckBoxStyle {
            background: Item { }
            indicator: Rectangle {
                implicitWidth:  Theme.getSize("checkbox").width;
                implicitHeight: Theme.getSize("checkbox").height;

                color: (control.hovered || control._hovered) ? Theme.getColor("checkbox_hover") : Theme.getColor("checkbox");
                Behavior on color { ColorAnimation { duration: 50; } }

                radius: control.exclusiveGroup ? Math.round(Theme.getSize("checkbox").width / 2) : 0

                border.width: Theme.getSize("default_lining").width;
                border.color: (control.hovered || control._hovered) ? Theme.getColor("checkbox_border_hover") : Theme.getColor("checkbox_border");

                UM.RecolorImage {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(parent.width / 2.5)
                    height: Math.round(parent.height / 2.5)
                    sourceSize.width: width
                    sourceSize.height: width
                    color: Theme.getColor("checkbox_mark")
                    source: {
                        if (control.checkbox_state == 2){
                            return Theme.getIcon("solid")
                        }
                        else{
                            return control.exclusiveGroup ? Theme.getIcon("dot") : Theme.getIcon("check")
                        }
                    }
                    opacity: control.checked
                    Behavior on opacity { NumberAnimation { duration: 100; } }
                }
            }
            label: Label {
                text: control.text;
                color: Theme.getColor("checkbox_text");
                font: Theme.getFont("default");
            }
        }
    }

    property Component slider: Component {
        SliderStyle {
            groove: Rectangle {
                implicitWidth: control.width;
                implicitHeight: Theme.getSize("slider_groove").height;

                color: Theme.getColor("slider_groove");
                border.width: Theme.getSize("default_lining").width;
                border.color: Theme.getColor("slider_groove_border");

                radius: Math.round(width / 2);

                Rectangle {
                    anchors {
                        left: parent.left;
                        top: parent.top;
                        bottom: parent.bottom;
                    }
                    color: Theme.getColor("slider_groove_fill");
                    width: Math.round((control.value / (control.maximumValue - control.minimumValue)) * parent.width);
                    radius: Math.round(width / 2);
                }
            }
            handle: Rectangle {
                width: Theme.getSize("slider_handle").width;
                height: Theme.getSize("slider_handle").height;
                color: control.hovered ? Theme.getColor("slider_handle_hover") : Theme.getColor("slider_handle");
                border.width: Theme.getSize("default_lining").width
                border.color: control.hovered ? Theme.getColor("slider_handle_hover_border") : Theme.getColor("slider_handle_border")
                radius: Math.round(Theme.getSize("slider_handle").width / 2); //Round.
                Behavior on color { ColorAnimation { duration: 50; } }
            }
        }
    }

    property Component text_field: Component {
        TextFieldStyle {
            textColor: Theme.getColor("color4")
            placeholderTextColor: Theme.getColor("color8")
            font: Theme.getFont("font1")

            background: Rectangle
            {
                id:textfieldrectangle
                implicitHeight: control.height
                implicitWidth: control.width
                color:
                {
                    if(!control.enabled)
                        return Theme.getColor("color1")
                    else
                        return Theme.getColor("setting_validation_ok")
                }
                border.width:1 * UM.Theme.getSize("default_margin").width/10
                radius: 3 * UM.Theme.getSize("default_margin").width/10
                border.color:
                {
                    if(control.hovered || control.activeFocus)
                        return Theme.getColor("color16")
                    else
                        return Theme.getColor("color2")
                }

                Label {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.getSize("setting_unit_margin").width
                    text: control.unit ? control.unit : ""
                    color: Theme.getColor("color4")
                    font: Theme.getFont("font1")
                }
            }
        }
    }

    property Component sidebar_action_button: Component {
        ButtonStyle
        {
            background: Rectangle
            {
                border.width: UM.Theme.getSize("default_lining").width
                border.color:
                {
                    if(!control.enabled)
                        return UM.Theme.getColor("action_button_disabled_border");
                    else if(control.pressed)
                        return UM.Theme.getColor("action_button_active_border");
                    else if(control.hovered)
                        return UM.Theme.getColor("action_button_hovered_border");
                    else
                        return UM.Theme.getColor("action_button_border");
                }
                color:
                {
                    if(!control.enabled)
                        return UM.Theme.getColor("action_button_disabled");
                    else if(control.pressed)
                        return UM.Theme.getColor("action_button_active");
                    else if(control.hovered)
                        return UM.Theme.getColor("action_button_hovered");
                    else
                        return UM.Theme.getColor("action_button");
                }
                Behavior on color { ColorAnimation { duration: 50; } }

                implicitWidth: actualLabel.contentWidth + (UM.Theme.getSize("sidebar_margin").width * 2)

                Label
                {
                    id: actualLabel
                    anchors.centerIn: parent
                    color:
                    {
                        if(!control.enabled)
                            return UM.Theme.getColor("action_button_disabled_text");
                        else if(control.pressed)
                            return UM.Theme.getColor("action_button_active_text");
                        else if(control.hovered)
                            return UM.Theme.getColor("action_button_hovered_text");
                        else
                            return UM.Theme.getColor("action_button_text");
                    }
                    font: UM.Theme.getFont("action_button")
                    text: control.text
                }
            }
            label: Item { }
        }
    }

    property Component toolbox_action_button: Component {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: UM.Theme.getSize("toolbox_action_button").width
                implicitHeight: UM.Theme.getSize("toolbox_action_button").height
                color:
                {
                    if (control.installed)
                    {
                        return UM.Theme.getColor("action_button_disabled")
                    }
                    else
                    {
                        if (control.hovered)
                        {
                            return UM.Theme.getColor("primary_hover")
                        }
                        else
                        {
                            return UM.Theme.getColor("primary")
                        }
                    }

                }
            }
            label: Label
            {
                text: control.text
                color:
                {
                    if (control.installed)
                    {
                        return UM.Theme.getColor("action_button_disabled_text")
                    }
                    else
                    {
                        if (control.hovered)
                        {
                            return UM.Theme.getColor("button_text_hover")
                        }
                        else
                        {
                            return UM.Theme.getColor("button_text")
                        }
                    }
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font: UM.Theme.getFont("default_bold")
            }
        }
    }

    property Component rename_button: Component {
        ButtonStyle {
            background: Item {
                //implicitWidth: 25//Theme.getSize("button").width;
                implicitHeight: 22 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").height;

                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);
                    color:
                    {
                        if (control.pressed)
                            return UM.Theme.getColor("color5");
                        else if (control.hovered)
                            return UM.Theme.getColor("color6");
                        else
                            return UM.Theme.getColor("color1");
                    }

                    Behavior on color { ColorAnimation { duration: 50; } }

                    radius: 3 * UM.Theme.getSize("default_margin").width/10
                    border.width: UM.Theme.getSize("default_margin").width/10
                    border.color: Theme.getColor("color2")
                    Label
                    {
                        text: "..."
                        color:
                        {
                            if (control.pressed)
                                return UM.Theme.getColor("color1");
                            else if (control.hovered)
                                return UM.Theme.getColor("color1");
                            else
                                return UM.Theme.getColor("color4");
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        font: UM.Theme.getFont("font1")
                    }
                }
            }
        }
    }
    property Component apply_button: Component {
        ButtonStyle {
            background: Item {
                //implicitWidth: 25//Theme.getSize("button").width;
                implicitHeight: 22 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").height;

                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);
                    color:
                    {
                        if (control.pressed)
                            return UM.Theme.getColor("color5");
                        else if (control.hovered)
                            return UM.Theme.getColor("color6");
                        else
                            return UM.Theme.getColor("color1");
                    }

                    Behavior on color { ColorAnimation { duration: 50; } }

                    radius: 3 * UM.Theme.getSize("default_margin").width/10
                    border.width: UM.Theme.getSize("default_margin").width/10
                    border.color: Theme.getColor("color2")
                }
            }
            label: Item {
                Label {
                    text: control.text
                    width: parent.width
                    color:
                    {
                        if (control.pressed)
                            return UM.Theme.getColor("color1");
                        else if (control.hovered)
                            return UM.Theme.getColor("color1");
                        else
                            return UM.Theme.getColor("color4");
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    //anchors.horizontalCenterOffset: 4 * UM.Theme.getSize("default_margin").width/10
                    font: UM.Theme.getFont("font1")
                }
            }
        }
    }
    property Component wifi_button: Component {
        ButtonStyle {
            background: Item {
                implicitWidth: 40 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").width;
                implicitHeight: 35 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").height;
                UM.PointingRectangle {
                    id: button_tooltip
                    anchors.top: parent.bottom
                    anchors.topMargin: Theme.getSize("button_tooltip_arrow").width * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Theme.getColor("color9")
                    opacity: control.hovered ? 1.0 : 0.0;
                    visible: control.text != ""
                    width: control.hovered ? button_tip.width + Theme.getSize("button_tooltip").width : 0
                    height: Theme.getSize("button_tooltip").height
                    Behavior on width { NumberAnimation { duration: 100; } }
                    Behavior on opacity { NumberAnimation { duration: 100; } }

                    Label {
                        id: button_tip
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter;
                        text: control.text;
                        font: Theme.getFont("button_tooltip");
                        color: Theme.getColor("color4");
                    }
                }
                Rectangle {
                    id: buttonFace;
                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);
                    color:
                    {
                        if(control.customColor !== undefined && control.customColor !== null)
                        {
                            return control.customColor
                        }
                        else if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color6");
                        }
                        else
                        {
                            return Theme.getColor("color21");
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }
                    radius: 5
                    border.width: (control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color: Theme.getColor("tool_button_border")

                    UM.RecolorImage {
                        id: tool_button_arrow
                        anchors.right: parent.right;
                        anchors.rightMargin: Theme.getSize("button").width - Math.round(Theme.getSize("button_icon").width / 4)
                        anchors.bottom: parent.bottom;
                        anchors.bottomMargin: Theme.getSize("button").height - Math.round(Theme.getSize("button_icon").height / 4)
                        width: Theme.getSize("standard_arrow").width
                        height: Theme.getSize("standard_arrow").height
                        sourceSize.width: width
                        sourceSize.height: width
                        visible: control.menu != null;
                        color:
                        {
                            if(control.checkable && control.checked && control.hovered)
                            {
                                return Theme.getColor("color2");
                            }
                            else if(control.pressed || (control.checkable && control.checked))
                            {
                                return Theme.getColor("color2");
                            }
                            else if(control.hovered)
                            {
                                return Theme.getColor("color2");
                            }
                            else
                            {
                                return Theme.getColor("color2");
                            }
                        }
                        source: Theme.getIcon("arrow_bottom")
                    }
                }
            }

            label: Item {
                UM.RecolorImage {
                    anchors.centerIn: parent;
                    opacity: !control.enabled ? 0.2 : 1.0
                    source: control.iconSource;
                    width: Theme.getSize("button_icon").width;
                    height: Theme.getSize("button_icon").height;
                    color:
                    {
                        if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else
                        {
                            return Theme.getColor("color12");
                        }
                    }
                    sourceSize: Theme.getSize("button_icon")
                }
            }
        }
    }

    property Component translate_button: Component {
        ButtonStyle {
            background: Item {
                implicitWidth: 25 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").width;
                implicitHeight: 25 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("button").height;

                UM.PointingRectangle {
                    id: button_tooltip

                    anchors.top: parent.bottom
                    anchors.topMargin: Theme.getSize("button_tooltip_arrow").width * 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    //target: Qt.point(parent.x, y + Math.round(height/2))
                    //arrowSize: Theme.getSize("button_tooltip_arrow").width
                    color: Theme.getColor("color9")
                    opacity: control.hovered ? 1.0 : 0.0;
                    visible: control.text != ""

                    width: control.hovered ? button_tip.width + Theme.getSize("button_tooltip").width : 0
                    height: Theme.getSize("button_tooltip").height

                    Behavior on width { NumberAnimation { duration: 100; } }
                    Behavior on opacity { NumberAnimation { duration: 100; } }

                    Label {
                        id: button_tip

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter;

                        text: control.text;
                        font: Theme.getFont("button_tooltip");
                        color: Theme.getColor("color4");
                    }
                }

                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);

                    color:
                    {
                        if(control.customColor !== undefined && control.customColor !== null)
                        {
                            return control.customColor
                        }
                        else if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color5");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color6");
                        }
                        else
                        {
                            return Theme.getColor("color21");
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }
                    radius: 5 * UM.Theme.getSize("default_margin").width/10

                    border.width: (control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color: Theme.getColor("tool_button_border")
                }
            }

            label: Item {
                UM.RecolorImage {
                    anchors.centerIn: parent;
                    opacity: !control.enabled ? 0.2 : 1.0
                    source: control.iconSource;
                    width: 20 * UM.Theme.getSize("default_margin").width/10
                    height: 20 * UM.Theme.getSize("default_margin").width/10
                    color:
                    {
                        if(control.checkable && control.checked && control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return Theme.getColor("color7");
                        }
                        else if(control.hovered)
                        {
                            return Theme.getColor("color7");
                        }
                        else
                        {
                            return Theme.getColor("color12");
                        }
                    }
                    sourceSize: Theme.getSize("button_icon")
                }
            }
        }
    }

    property Component wizardbutton: Component {
        ButtonStyle {
            background: Item {
                //implicitWidth: 100//Theme.getSize("button").width;
                implicitWidth: textLabel.contentWidth + (UM.Theme.getSize("sidebar_margin").width * 3)
                implicitHeight: Theme.getSize("button").height;
                Rectangle {
                    id: buttonFace;

                    anchors.fill: parent;
                    property bool down: control.pressed || (control.checkable && control.checked);
                    color: UM.Theme.getColor("color21")
                    /*gradient: Gradient
                    {
                        GradientStop { position: 0.0; color: UM.Theme.getColor("color10")}
                        GradientStop { position: 1.0; color: UM.Theme.getColor("color9")}
                    }*/
                    //Behavior on color { ColorAnimation { duration: 50; } }

                    radius: parent.width/2
                    border.width: 2 * UM.Theme.getSize("default_margin").width/10//(control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color: Theme.getColor("color7")
                }
                Label {
                    id: textLabel
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter;
                    text: control.text
                    font: Theme.getFont("font10");
                    color: Theme.getColor("color7");
                }
            }
            label: Item { }
        }
    }

    property Component spinbox: Component {
        SpinBoxStyle {
            font: Theme.getFont("font1");
            background: Item {
                Rectangle {
                    implicitHeight: control.height;
                    implicitWidth: control.width;
                    radius: 3 * UM.Theme.getSize("default_margin").width/10
                    border.width: UM.Theme.getSize("default_margin").width/10//(control.hasOwnProperty("needBorder") && control.needBorder) ? 2 * screenScaleFactor : 0
                    border.color:
                    {
                        if(control.hovered || control.activeFocus)
                            return Theme.getColor("color16")
                        else
                            return Theme.getColor("color2")
                    }
                    Label {
                        anchors.right: parent.right;
                        anchors.rightMargin: 18 * UM.Theme.getSize("default_margin").width/10
                        anchors.verticalCenter: parent.verticalCenter;

                        text: control.unit ? control.unit : ""
                        color: control.enabled ? Theme.getColor("color4") : Theme.getColor("color9")
                        font: Theme.getFont("default");
                    }
                }
            }
        }
    }

    property Component print_mode_button: Component {
        ButtonStyle {
            background: Item {
                implicitWidth: control.hovered ? 65 * Theme.getSize("default_margin").width/10 : 60 * Theme.getSize("default_margin").width/10
                implicitHeight: control.hovered ? 65 * Theme.getSize("default_margin").width/10 : 60 * Theme.getSize("default_margin").width/10

                UM.PointingRectangle {
                    id: button_tooltip

                    anchors.right: parent.left
                    anchors.leftMargin: Theme.getSize("button_tooltip_arrow").width * 2
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.getColor("color9")
                    opacity: control.hovered ? 1.0 : 0.0;
                    visible: control.text != ""

                    width: control.hovered ? button_tip.width + Theme.getSize("button_tooltip").width : 0
                    height: Theme.getSize("button_tooltip").height

                    Behavior on width { NumberAnimation { duration: 100; } }
                    Behavior on opacity { NumberAnimation { duration: 100; } }

                    Label {
                        id: button_tip

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter;

                        text: control.text;
                        font: Theme.getFont("button_tooltip");
                        color: Theme.getColor("color4");
                    }
                }
            }

            label: Item {
                Image {
                    anchors.centerIn: parent;
                    source: control.iconSource;
                    width: parent.width;
                    height: parent.height;
                }
            }
        }
    }
    property Component sidebar_header_button2: Component {
        ButtonStyle {
            background: Rectangle {
                color: Theme.getColor("color7")
                radius: 3 * UM.Theme.getSize("default_margin").width/10
                border.width: 1 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("default_lining").width
                border.color: Theme.getColor("color2")
                Rectangle
                {
                    id:rightborder
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 15 * UM.Theme.getSize("default_margin").width/10
                    clip: true
                    Rectangle
                    {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 40 * UM.Theme.getSize("default_margin").width/10
                        radius: 3 * UM.Theme.getSize("default_margin").width/10
                        border.width: 1 * UM.Theme.getSize("default_margin").width/10//Theme.getSize("default_lining").width
                        border.color: Theme.getColor("color2")
                        gradient: Gradient
                        {
                            GradientStop
                            {
                                position: 0.0;
                                color: UM.Theme.getColor("color10")
                            }
                            GradientStop
                            {
                                position: 1.0;
                                color: UM.Theme.getColor("color9")
                            }
                        }

                    }
                }

                Rectangle
                {
                    anchors.right: rightborder.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 1 * UM.Theme.getSize("default_margin").width/10
                    color: Theme.getColor("color2")
                }

                UM.RecolorImage {
                    id: downArrow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 4 * UM.Theme.getSize("default_margin").width/10
                    anchors.right: parent.right
                    anchors.rightMargin: 4 * Theme.getSize("default_margin").width/10
                    width: Theme.getSize("standard_arrow").width
                    height: Theme.getSize("standard_arrow").height
                    sourceSize.width: width
                    sourceSize.height: width
                    color: control.enabled ? Theme.getColor("color4") : Theme.getColor("setting_category_disabled_text")
                    source: Theme.getIcon("arrow_bottom")
                }
                Label {
                    id: sidebarComboBoxLabel
                    color: control.enabled ? Theme.getColor("color4") : Theme.getColor("setting_control_disabled_text")
                    text: control.text;
                    elide: Text.ElideRight;
                    anchors.left: parent.left;
                    anchors.leftMargin: Theme.getSize("setting_unit_margin").width
                    anchors.right: downArrow.left;
                    anchors.rightMargin: control.rightMargin;
                    anchors.verticalCenter: parent.verticalCenter;
                    font: Theme.getFont("default")
                }
            }
            label: Label{}
        }
    }

    property Component connect_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: 100 * Theme.getSize("default_margin").width/10
                implicitHeight: 30 * Theme.getSize("default_margin").width/10
                border.width: UM.Theme.getSize("default_margin").width/10
                border.color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color1")
                color: UM.Theme.getColor("color7")
                Behavior on color { ColorAnimation { duration: 50; } }
                radius: implicitHeight / 2

                Label
                {
                    id: buttonLabel
                    text: control.text
                    font: UM.Theme.getFont("font2")
                    color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color2")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 10 * UM.Theme.getSize("default_margin").width/10
                }

                UM.RecolorImage
                {
                    id: buttonImage
                    anchors.right: buttonLabel.left
                    anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    anchors.verticalCenter: parent.verticalCenter
                    source: control.iconSource
                    width: 15 * UM.Theme.getSize("default_margin").width/10
                    height: 15 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color2")
                }
            }
            label: Label { }  //用来抵消多出来的底部图片，具体原理不清楚
        }
    }

    property Component file_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: 100 * Theme.getSize("default_margin").width/10
                implicitHeight: 40 * Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color21")

                Label
                {
                    id: buttonLabel
                    text: control.text
                    font: UM.Theme.getFont("font4")
                    color: control.checked ? UM.Theme.getColor("color16") : UM.Theme.getColor("color14")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 15 * UM.Theme.getSize("default_margin").width/10
                }

                UM.RecolorImage
                {
                    id: buttonImage
                    anchors.right: buttonLabel.left
                    anchors.rightMargin: 10 * UM.Theme.getSize("default_margin").width/10
                    anchors.verticalCenter: parent.verticalCenter
                    source: control.iconSource
                    width: 20 * UM.Theme.getSize("default_margin").width/10
                    height: 20 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: control.checked ? UM.Theme.getColor("color16") : UM.Theme.getColor("color14")
                }

                Rectangle
                {
                    id: buttonRectangle
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3 * UM.Theme.getSize("default_margin").width/10
                    color: control.checked ? UM.Theme.getColor("color16") : UM.Theme.getColor("color14")
                }
            }
            label: Label { }  //用来抵消多出来的底部图片，具体原理不清楚
        }
    }

    property Component upload_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: 100 * Theme.getSize("default_margin").width/10
                implicitHeight: 30 * Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color21")
                border.width: UM.Theme.getSize("default_margin").width/10
                border.color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color21")
                radius: 3 * UM.Theme.getSize("default_margin").width/10

                Label
                {
                    id: buttonLabel
                    text: control.text
                    font: UM.Theme.getFont("font1")
                    color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color4")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 8 * UM.Theme.getSize("default_margin").width/10
                }

                UM.RecolorImage
                {
                    anchors.right: buttonLabel.left
                    anchors.rightMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    anchors.verticalCenter: parent.verticalCenter
                    source: control.iconSource
                    width: 10 * UM.Theme.getSize("default_margin").width/10
                    height: 10 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: buttonLabel.color
                }
            }
            label: Label { }  //用来抵消多出来的底部图片，具体原理不清楚
        }
    }

    property Component retrun_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: 13 * Theme.getSize("default_margin").width/10
                implicitHeight: 13 * Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color21")

                UM.RecolorImage
                {
                    anchors.centerIn: parent
                    source: control.iconSource
                    width: 13 * UM.Theme.getSize("default_margin").width/10
                    height: 13 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color4")
                }
            }
            label: Label { }  //用来抵消多出来的底部图片，具体原理不清楚
        }
    }

    property Component address_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: buttonLabel.width + 20 * Theme.getSize("default_margin").width/10
                implicitHeight: 30 * Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color21")

                Label
                {
                    id: buttonLabel
                    text: control.text
                    font: UM.Theme.getFont("font1")
                    color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color4")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -8 * UM.Theme.getSize("default_margin").width/10
                }

                UM.RecolorImage
                {
                    anchors.left: buttonLabel.right
                    anchors.leftMargin: 5 * UM.Theme.getSize("default_margin").width/10
                    anchors.verticalCenter: parent.verticalCenter
                    source: control.iconSource
                    width: 10 * UM.Theme.getSize("default_margin").width/10
                    height: 10 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: buttonLabel.color
                }
            }
            label: Label { }  //用来抵消多出来的底部图片，具体原理不清楚
        }
    }

    property Component move_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: 40 * Theme.getSize("default_margin").width/10
                implicitHeight: 40 * Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color21")
                border.width: UM.Theme.getSize("default_margin").width/10
                border.color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color14")
                radius: 5 * UM.Theme.getSize("default_margin").width/10

                UM.RecolorImage
                {
                    anchors.centerIn: parent
                    source: control.iconSource
                    width: 30 * UM.Theme.getSize("default_margin").width/10
                    height: 30 * UM.Theme.getSize("default_margin").width/10
                    sourceSize.width: width
                    sourceSize.height: width
                    color: control.hovered ? UM.Theme.getColor("color16") : UM.Theme.getColor("color14")
                }
            }
            label: Label { }  //用来抵消多出来的底部图片，具体原理不清楚
        }
    }
}
