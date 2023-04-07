
import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI

CheckBox
{
    id: control

    hoverEnabled: true

    indicator: Rectangle
    {
        width: control.height
        height: control.height

        color:
        {
            if (!control.enabled)
            {
                return QD.Theme.getColor("setting_control_disabled")
            }
            if (control.hovered || control.activeFocus)
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
                return QD.Theme.getColor("blue_6")
            }
            return QD.Theme.getColor("setting_control_border")
        }

        QD.RecolorImage
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.round(parent.width / 2)
            height: Math.round(parent.height / 2)
            sourceSize.height: width
            color: !enabled ? QD.Theme.getColor("setting_control_disabled_text") : QD.Theme.getColor("blue_6")
            source: QD.Theme.getIcon("Check")
            opacity: control.checked ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100; } }
        }
    }

    contentItem: Label
    {
        id: textLabel
        leftPadding: control.indicator.width
        text: control.text
        font: control.font
        color: QD.Theme.getColor("black_1")
        renderType: Text.NativeRendering
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
