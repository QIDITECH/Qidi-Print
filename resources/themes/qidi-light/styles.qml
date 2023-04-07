
import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import QD 1.1 as QD
import QIDI 1.6 as QIDI

QtObject
{
	property bool multipleExtruders: extrudersModel.count > 1

    property var extrudersModel: QIDIApplication.getExtrudersModel()
    property Component print_setup_header_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                color:
                {
                    if(control.enabled)
                    {
                        if(control.valueError)
                        {
                            return QD.Theme.getColor("setting_validation_error_background");
                        }
                        else if(control.valueWarning)
                        {
                            return QD.Theme.getColor("setting_validation_warning_background");
                        }
                        else
                        {
                            return QD.Theme.getColor("setting_control");
                        }
                    }
                    else
                    {
                        return QD.Theme.getColor("setting_control_disabled");
                    }
                }

                radius: QD.Theme.getSize("setting_control_radius").width
                border.width: QD.Theme.getSize("default_lining").width
                border.color:
                {
                    if (control.enabled)
                    {
                        if (control.valueError)
                        {
                            return QD.Theme.getColor("setting_validation_error");
                        }
                        else if (control.valueWarning)
                        {
                            return QD.Theme.getColor("setting_validation_warning");
                        }
                        else if (control.hovered)
                        {
                            return QD.Theme.getColor("setting_control_border_highlight");
                        }
                        else
                        {
                            return QD.Theme.getColor("setting_control_border");
                        }
                    }
                    else
                    {
                        return QD.Theme.getColor("setting_control_disabled_border");
                    }
                }
                QD.RecolorImage
                {
                    id: downArrow
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: QD.Theme.getSize("default_margin").width
                    width: QD.Theme.getSize("standard_arrow").width
                    height: QD.Theme.getSize("standard_arrow").height
                    sourceSize.height: width
                    color: control.enabled ? QD.Theme.getColor("setting_control_button") : QD.Theme.getColor("setting_category_disabled_text")
                    source: QD.Theme.getIcon("ChevronSingleDown")
                }
                Label
                {
                    id: printSetupComboBoxLabel
                    color:  control.enabled ? !multipleExtruders? extrudersModel.items[0].color : QD.Theme.getColor("black_1") : QD.Theme.getColor("setting_control_disabled_text")
                    text: control.text;
                    elide: Text.ElideRight;
                    anchors.left: parent.left;
                    anchors.leftMargin: QD.Theme.getSize("setting_unit_margin").width
                    anchors.right: downArrow.left;
                    anchors.rightMargin: control.rightMargin;
                    anchors.verticalCenter: parent.verticalCenter;
                    font: QD.Theme.getFont("default")
                }
            }
            label: Label{}
        }
    }

    property Component main_window_header_tab: Component
    {
        ButtonStyle
        {
            // This property will be back-propagated when the width of the label is calculated
            property var buttonWidth: 0

            background: Rectangle
            {
                id: backgroundRectangle
                implicitHeight: control.height
                implicitWidth: buttonWidth
                radius: QD.Theme.getSize("action_button_radius").width

                color:
                {
                    if (control.checked)
                    {
                        return QD.Theme.getColor("main_window_header_button_background_active")
                    }
                    else
                    {
                        if (control.hovered)
                        {
                            return QD.Theme.getColor("main_window_header_button_background_hovered")
                        }
                        return QD.Theme.getColor("main_window_header_button_background_inactive")
                    }
                }

            }

            label: Item
            {
                id: contents
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height: control.height
                width: buttonLabel.width + 4 * QD.Theme.getSize("default_margin").width

                Label
                {
                    id: buttonLabel
                    text: control.text
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font: QD.Theme.getFont("medium")
                    color:
                    {
                        if (control.checked)
                        {
                            return QD.Theme.getColor("main_window_header_button_text_active")
                        }
                        else
                        {
                            if (control.hovered)
                            {
                                return QD.Theme.getColor("main_window_header_button_text_hovered")
                            }
                            return QD.Theme.getColor("main_window_header_button_text_inactive")
                        }
                    }
                }
                Component.onCompleted:
                {
                    buttonWidth = width
                }
            }


        }
    }

    property Component tool_button: Component
    {
        ButtonStyle
        {
            background: Item
            {
                implicitWidth: QD.Theme.getSize("button").width
                implicitHeight: QD.Theme.getSize("button").height

                QD.PointingRectangle
                {
                    id: button_tooltip

                    anchors.left: parent.right
                    anchors.leftMargin: QD.Theme.getSize("button_tooltip_arrow").width * 2
                    anchors.verticalCenter: parent.verticalCenter

                    target: Qt.point(parent.x, y + Math.round(height/2))
                    arrowSize: QD.Theme.getSize("button_tooltip_arrow").width
                    color: QD.Theme.getColor("button_tooltip")
                    opacity: control.hovered ? 1.0 : 0.0;
                    visible: control.text != ""

                    width: control.hovered ? button_tip.width + QD.Theme.getSize("button_tooltip").width : 0
                    height: QD.Theme.getSize("button_tooltip").height

                    Behavior on width { NumberAnimation { duration: 100; } }
                    Behavior on opacity { NumberAnimation { duration: 100; } }

                    Label
                    {
                        id: button_tip

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter

                        text: control.text
                        font: QD.Theme.getFont("default")
                        color: QD.Theme.getColor("tooltip_text")
                    }
                }

                Rectangle
                {
                    id: buttonFace

                    anchors.fill: parent
                    property bool down: control.pressed || (control.checkable && control.checked)

                    color:
                    {
                        if(control.customColor !== undefined && control.customColor !== null)
                        {
                            return control.customColor
                        }
                        else if(control.checkable && control.checked && control.hovered)
                        {
                            return QD.Theme.getColor("toolbar_button_active_hover")
                        }
                        else if(control.pressed || (control.checkable && control.checked))
                        {
                            return QD.Theme.getColor("toolbar_button_active")
                        }
                        else if(control.hovered)
                        {
                            return QD.Theme.getColor("toolbar_button_hover")
                        }
                        return QD.Theme.getColor("toolbar_background")
                    }
                    Behavior on color { ColorAnimation { duration: 50; } }

                    border.width: (control.hasOwnProperty("needBorder") && control.needBorder) ? QD.Theme.getSize("default_lining").width : 0
                    border.color: control.checked ? QD.Theme.getColor("icon") : QD.Theme.getColor("lining")
                }
            }

            label: Item
            {
                QD.RecolorImage
                {
                    anchors.centerIn: parent
                    opacity: control.enabled ? 1.0 : 0.2
                    source: control.iconSource
                    width: QD.Theme.getSize("button_icon").width
                    height: QD.Theme.getSize("button_icon").height
                    color: QD.Theme.getColor("icon")

                    sourceSize: QD.Theme.getSize("button_icon")
                }
            }
        }
    }

    property Component progressbar: Component
    {
        ProgressBarStyle
        {
            background: Rectangle
            {
                implicitWidth: QD.Theme.getSize("message").width - (QD.Theme.getSize("default_margin").width * 2)
                implicitHeight: QD.Theme.getSize("progressbar").height
                color: control.hasOwnProperty("backgroundColor") ? control.backgroundColor : QD.Theme.getColor("progressbar_background")
                radius: QD.Theme.getSize("progressbar_radius").width
            }
            progress: Rectangle
            {
                color:
                {
                    if(control.indeterminate)
                    {
                        return "transparent";
                    }
                    else if(control.hasOwnProperty("controlColor"))
                    {
                        return  control.controlColor;
                    }
                    else
                    {
                        return QD.Theme.getColor("progressbar_control");
                    }
                }
                radius: QD.Theme.getSize("progressbar_radius").width
                Rectangle
                {
                    radius: QD.Theme.getSize("progressbar_radius").width
                    color: control.hasOwnProperty("controlColor") ? control.controlColor : QD.Theme.getColor("progressbar_control")
                    width: QD.Theme.getSize("progressbar_control").width
                    height: QD.Theme.getSize("progressbar_control").height
                    visible: control.indeterminate

                    SequentialAnimation on x
                    {
                        id: xAnim
                        property int animEndPoint: QD.Theme.getSize("message").width - Math.round((QD.Theme.getSize("default_margin").width * 2.5)) - QD.Theme.getSize("progressbar_control").width
                        running: control.indeterminate && control.visible
                        loops: Animation.Infinite
                        NumberAnimation { from: 0; to: xAnim.animEndPoint; duration: 2000;}
                        NumberAnimation { from: xAnim.animEndPoint; to: 0; duration: 2000;}
                    }
                }
            }
        }
    }

    property Component scrollview: Component
    {
        ScrollViewStyle
        {
            decrementControl: Item { }
            incrementControl: Item { }

            transientScrollBars: false
            scrollBarBackground: Rectangle
            {
                implicitWidth: QD.Theme.getSize("scrollbar").width
                radius: Math.round(implicitWidth / 2)
                color: QD.Theme.getColor("scrollbar_background")
            }

            handle: Rectangle
            {
                id: scrollViewHandle
                implicitWidth: QD.Theme.getSize("scrollbar").width
                radius: Math.round(implicitWidth / 2)

                color: styleData.pressed ? QD.Theme.getColor("scrollbar_handle_down") : styleData.hovered ? QD.Theme.getColor("scrollbar_handle_hover") : QD.Theme.getColor("scrollbar_handle")
                Behavior on color { ColorAnimation { duration: 50; } }
            }
        }
    }

    property Component combobox: Component
    {
        ComboBoxStyle
        {

            background: Rectangle
            {
                implicitHeight: QD.Theme.getSize("setting_control").height;
                implicitWidth: QD.Theme.getSize("setting_control").width;

                color: control.hovered ? QD.Theme.getColor("setting_control_highlight") : QD.Theme.getColor("setting_control")
                Behavior on color { ColorAnimation { duration: 50; } }

                border.width: QD.Theme.getSize("default_lining").width;
                border.color: control.hovered ? QD.Theme.getColor("setting_control_border_highlight") : QD.Theme.getColor("setting_control_border");
                radius: QD.Theme.getSize("setting_control_radius").width
            }

            label: Item
            {
                Label
                {
                    anchors.left: parent.left
                    anchors.leftMargin: QD.Theme.getSize("default_lining").width
                    anchors.right: downArrow.left
                    anchors.rightMargin: QD.Theme.getSize("default_lining").width
                    anchors.verticalCenter: parent.verticalCenter

                    text: control.currentText
                    font: QD.Theme.getFont("default");
                    color: !enabled ? QD.Theme.getColor("setting_control_disabled_text") : QD.Theme.getColor("setting_control_text")

                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                QD.RecolorImage
                {
                    id: downArrow
                    anchors.right: parent.right
                    anchors.rightMargin: QD.Theme.getSize("default_lining").width * 2
                    anchors.verticalCenter: parent.verticalCenter

                    source: QD.Theme.getIcon("ChevronSingleDown")
                    width: QD.Theme.getSize("standard_arrow").width
                    height: QD.Theme.getSize("standard_arrow").height
                    sourceSize.width: width + 5 * screenScaleFactor
                    sourceSize.height: width + 5 * screenScaleFactor

                    color: QD.Theme.getColor("setting_control_button");
                }
            }
        }
    }

    property Component checkbox: Component
    {
        CheckBoxStyle
        {
            background: Item { }
            indicator: Rectangle
            {
                implicitWidth:  QD.Theme.getSize("checkbox").width
                implicitHeight: QD.Theme.getSize("checkbox").height

                color: (control.hovered || control._hovered) ? QD.Theme.getColor("checkbox_hover") : (control.enabled ? QD.Theme.getColor("checkbox") : QD.Theme.getColor("checkbox_disabled"))
                Behavior on color { ColorAnimation { duration: 50; } }

                radius: control.exclusiveGroup ? Math.round(QD.Theme.getSize("checkbox").width / 2) : QD.Theme.getSize("checkbox_radius").width

                border.width: QD.Theme.getSize("default_lining").width
                border.color: (control.hovered || control._hovered) ? QD.Theme.getColor("checkbox_border_hover") : QD.Theme.getColor("checkbox_border")

                QD.RecolorImage
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(parent.width / 2.5)
                    height: Math.round(parent.height / 2.5)
                    sourceSize.height: width
                    color: QD.Theme.getColor("checkbox_mark")
                    source: control.exclusiveGroup ? QD.Theme.getIcon("Dot") : QD.Theme.getIcon("Check")
                    opacity: control.checked
                    Behavior on opacity { NumberAnimation { duration: 100; } }
                }
            }
            label: Label
            {
                text: control.text
                color: QD.Theme.getColor("checkbox_text")
                font: QD.Theme.getFont("default")
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }
    }

    property Component partially_checkbox: Component
    {
        CheckBoxStyle
        {
            background: Item { }
            indicator: Rectangle
            {
                implicitWidth:  QD.Theme.getSize("checkbox").width
                implicitHeight: QD.Theme.getSize("checkbox").height

                color: (control.hovered || control._hovered) ? QD.Theme.getColor("checkbox_hover") : QD.Theme.getColor("checkbox");
                Behavior on color { ColorAnimation { duration: 50; } }

                radius: control.exclusiveGroup ? Math.round(QD.Theme.getSize("checkbox").width / 2) : QD.Theme.getSize("checkbox_radius").width

                border.width: QD.Theme.getSize("default_lining").width;
                border.color: (control.hovered || control._hovered) ? QD.Theme.getColor("checkbox_border_hover") : QD.Theme.getColor("checkbox_border");

                QD.RecolorImage
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.round(parent.width / 2.5)
                    height: Math.round(parent.height / 2.5)
                    sourceSize.height: width
                    color: QD.Theme.getColor("checkbox_mark")
                    source:
                    {
                        if (control.checkbox_state == 2)
                        {
                            return QD.Theme.getIcon("Solid");
                        }
                        else
                        {
                            return control.exclusiveGroup ? QD.Theme.getIcon("Dot", "low") : QD.Theme.getIcon("Check");
                        }
                    }
                    opacity: control.checked
                    Behavior on opacity { NumberAnimation { duration: 100; } }
                }
            }
            label: Label
            {
                text: control.text
                color: QD.Theme.getColor("checkbox_text")
                font: QD.Theme.getFont("default")
            }
        }
    }

    property Component text_field: Component
    {
        TextFieldStyle
        {
            textColor: QD.Theme.getColor("setting_control_text")
            placeholderTextColor: QD.Theme.getColor("setting_control_text")
            font: QD.Theme.getFont("default")

            background: Rectangle
            {
                implicitHeight: control.height;
                implicitWidth: control.width;

                border.width: QD.Theme.getSize("default_lining").width;
                border.color: control.hovered ? QD.Theme.getColor("setting_control_border_highlight") : QD.Theme.getColor("setting_control_border");
                radius: QD.Theme.getSize("setting_control_radius").width

                color: QD.Theme.getColor("setting_validation_ok");

                Label
                {
                    anchors.right: parent.right;
                    anchors.rightMargin: QD.Theme.getSize("setting_unit_margin").width;
                    anchors.verticalCenter: parent.verticalCenter;

                    text: control.unit ? control.unit : ""
                    color: QD.Theme.getColor("setting_unit");
                    font: QD.Theme.getFont("default");
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    property Component print_setup_action_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                border.width: QD.Theme.getSize("default_lining").width
                border.color:
                {
                    if(!control.enabled)
                    {
                        return QD.Theme.getColor("action_button_disabled_border");
                    }
                    else if(control.pressed)
                    {
                        return QD.Theme.getColor("action_button_active_border");
                    }
                    else if(control.hovered)
                    {
                        return QD.Theme.getColor("action_button_hovered_border");
                    }
                    else
                    {
                        return QD.Theme.getColor("action_button_border");
                    }
                }
                color:
                {
                    if(!control.enabled)
                    {
                        return QD.Theme.getColor("action_button_disabled");
                    }
                    else if(control.pressed)
                    {
                        return QD.Theme.getColor("action_button_active");
                    }
                    else if(control.hovered)
                    {
                        return QD.Theme.getColor("action_button_hovered");
                    }
                    else
                    {
                        return QD.Theme.getColor("action_button");
                    }
                }
                Behavior on color { ColorAnimation { duration: 50 } }

                implicitWidth: actualLabel.contentWidth + (QD.Theme.getSize("thick_margin").width * 2)

                Label
                {
                    id: actualLabel
                    anchors.centerIn: parent
                    color:
                    {
                        if(!control.enabled)
                        {
                            return QD.Theme.getColor("action_button_disabled_text");
                        }
                        else if(control.pressed)
                        {
                            return QD.Theme.getColor("action_button_active_text");
                        }
                        else if(control.hovered)
                        {
                            return QD.Theme.getColor("action_button_hovered_text");
                        }
                        else
                        {
                            return QD.Theme.getColor("action_button_text");
                        }
                    }
                    font: QD.Theme.getFont("medium")
                    text: control.text
                }
            }
            label: Item { }
        }
    }

    property Component toolbox_action_button: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                implicitWidth: QD.Theme.getSize("toolbox_action_button").width
                implicitHeight: QD.Theme.getSize("toolbox_action_button").height
                color:
                {
                    if (control.installed)
                    {
                        return QD.Theme.getColor("action_button_disabled");
                    }
                    else
                    {
                        if (control.hovered)
                        {
                            return QD.Theme.getColor("primary_hover");
                        }
                        else
                        {
                            return QD.Theme.getColor("primary");
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
                        return QD.Theme.getColor("action_button_disabled_text");
                    }
                    else
                    {
                        if (control.hovered)
                        {
                            return QD.Theme.getColor("button_text_hover");
                        }
                        else
                        {
                            return QD.Theme.getColor("button_text");
                        }
                    }
                }
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font: QD.Theme.getFont("default_bold")
            }
        }
    }

    property Component monitor_button_style: Component
    {
        ButtonStyle
        {
            background: Rectangle
            {
                border.width: QD.Theme.getSize("default_lining").width
                border.color:
                {
                    if(!control.enabled)
                    {
                        return QD.Theme.getColor("action_button_disabled_border");
                    }
                    else if(control.pressed)
                    {
                        return QD.Theme.getColor("action_button_active_border");
                    }
                    else if(control.hovered)
                    {
                        return QD.Theme.getColor("action_button_hovered_border");
                    }
                    return QD.Theme.getColor("action_button_border");
                }
                color:
                {
                    if(!control.enabled)
                    {
                        return QD.Theme.getColor("action_button_disabled");
                    }
                    else if(control.pressed)
                    {
                        return QD.Theme.getColor("action_button_active");
                    }
                    else if(control.hovered)
                    {
                        return QD.Theme.getColor("action_button_hovered");
                    }
                    return QD.Theme.getColor("action_button");
                }
                Behavior on color
                {
                    ColorAnimation
                    {
                        duration: 50
                    }
                }
            }

            label: Item
            {
                QD.RecolorImage
                {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: Math.floor(control.width / 2)
                    height: Math.floor(control.height / 2)
                    sourceSize.height: width
                    color:
                    {
                        if(!control.enabled)
                        {
                            return QD.Theme.getColor("action_button_disabled_text");
                        }
                        else if(control.pressed)
                        {
                            return QD.Theme.getColor("action_button_active_text");
                        }
                        else if(control.hovered)
                        {
                            return QD.Theme.getColor("action_button_hovered_text");
                        }
                        return QD.Theme.getColor("action_button_text");
                    }
                    source: control.iconSource
                }
            }
        }
    }

    property Component monitor_checkable_button_style: Component
    {
        ButtonStyle {
            background: Rectangle {
                border.width: control.checked ? QD.Theme.getSize("default_lining").width * 2 : QD.Theme.getSize("default_lining").width
                border.color:
                {
                    if(!control.enabled)
                    {
                        return QD.Theme.getColor("action_button_disabled_border");
                    }
                    else if (control.checked || control.pressed)
                    {
                        return QD.Theme.getColor("action_button_active_border");
                    }
                    else if(control.hovered)
                    {
                        return QD.Theme.getColor("action_button_hovered_border");
                    }
                    return QD.Theme.getColor("action_button_border");
                }
                color:
                {
                    if(!control.enabled)
                    {
                        return QD.Theme.getColor("action_button_disabled");
                    }
                    else if (control.checked || control.pressed)
                    {
                        return QD.Theme.getColor("action_button_active");
                    }
                    else if (control.hovered)
                    {
                        return QD.Theme.getColor("action_button_hovered");
                    }
                    return QD.Theme.getColor("action_button");
                }
                Behavior on color { ColorAnimation { duration: 50; } }
                Label {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: QD.Theme.getSize("default_lining").width * 2
                    anchors.rightMargin: QD.Theme.getSize("default_lining").width * 2
                    color:
                    {
                        if(!control.enabled)
                        {
                            return QD.Theme.getColor("action_button_disabled_text");
                        }
                        else if (control.checked || control.pressed)
                        {
                            return QD.Theme.getColor("action_button_active_text");
                        }
                        else if (control.hovered)
                        {
                            return QD.Theme.getColor("action_button_hovered_text");
                        }
                        return QD.Theme.getColor("action_button_text");
                    }
                    font: QD.Theme.getFont("default")
                    text: control.text
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideMiddle
                }
            }
            label: Item { }
        }
    }
}
