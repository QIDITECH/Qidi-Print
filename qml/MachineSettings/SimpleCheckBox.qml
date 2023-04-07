// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// CheckBox widget for the on/off or true/false settings in the Machine Settings Dialog.
//
QD.TooltipArea
{
    id: simpleCheckBox

    QD.I18nCatalog { id: catalog; name: "qidi"; }

    property int controlHeight: QD.Theme.getSize("setting_control").height

    height: childrenRect.height
    width: childrenRect.width
    text: tooltip

    property alias containerStackId: propertyProvider.containerStackId
    property alias settingKey: propertyProvider.key
    property alias settingStoreIndex: propertyProvider.storeIndex

    property alias labelText: fieldLabel.text
    property alias labelFont: fieldLabel.font
    property alias labelWidth: fieldLabel.width

    property string tooltip: propertyProvider.properties.description ? propertyProvider.properties.description : ""

    // callback functions
    property var forceUpdateOnChangeFunction: dummy_func

    // a dummy function for default property values
    function dummy_func() {}

    QD.SettingPropertyProvider
    {
        id: propertyProvider
        watchedProperties: [ "value", "description" ]
    }

    Label
    {
        id: fieldLabel
        anchors.left: parent.left
        anchors.verticalCenter: checkBox.verticalCenter
        visible: text != ""
        font: QD.Theme.getFont("medium")
        color: QD.Theme.getColor("text")
        renderType: Text.NativeRendering
    }

    QIDI.CheckBox
    {
        id: checkBox
        anchors.left: fieldLabel.right
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        checked: String(propertyProvider.properties.value).toLowerCase() != 'false'
        height: simpleCheckBox.controlHeight
        text: ""
        onClicked:
        {
            propertyProvider.setPropertyValue("value", checked)
            forceUpdateOnChangeFunction()
        }
    }
}
