// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// TextArea widget for editing Gcode in the Machine Settings dialog.
//
QD.TooltipArea
{
    id: control

    QD.I18nCatalog { id: catalog; name: "qidi"; }

    text: tooltip

    property alias containerStackId: propertyProvider.containerStackId
    property alias settingKey: propertyProvider.key
    property alias settingStoreIndex: propertyProvider.storeIndex

    property string tooltip: propertyProvider.properties.description ? propertyProvider.properties.description : ""

    property alias labelText: titleLabel.text
    property alias labelFont: titleLabel.font

    QD.SettingPropertyProvider
    {
        id: propertyProvider
        watchedProperties: [ "value", "description" ]
    }

    Label   // Title Label
    {
        id: titleLabel
        anchors.top: parent.top
        anchors.left: parent.left
        font: QD.Theme.getFont("medium_bold")
        color: QD.Theme.getColor("text")
        renderType: Text.NativeRendering
    }

    ScrollView
    {
        anchors.top: titleLabel.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        background: Rectangle
        {
            color: QD.Theme.getColor("main_background")
            anchors.fill: parent

            border.color:
            {
                if (!gcodeTextArea.enabled)
                {
                    return QD.Theme.getColor("setting_control_disabled_border")
                }
                if (gcodeTextArea.hovered || gcodeTextArea.activeFocus)
                {
                    return QD.Theme.getColor("setting_control_border_highlight")
                }
                return QD.Theme.getColor("setting_control_border")
            }
        }

        TextArea
        {
            id: gcodeTextArea

            hoverEnabled: true
            selectByMouse: true

            text: (propertyProvider.properties.value) ? propertyProvider.properties.value : ""
            font: QD.Theme.getFont("fixed")
            renderType: Text.NativeRendering
            color: QD.Theme.getColor("text")
            wrapMode: TextEdit.NoWrap

            onActiveFocusChanged:
            {
                if (!activeFocus)
                {
                    propertyProvider.setPropertyValue("value", text)
                }
            }
        }
    }
}
