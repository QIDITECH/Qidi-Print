// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI

import "../Widgets"


//
// ComboBox with dropdown options in the Machine Settings dialog.
//
QD.TooltipArea
{
    id: comboBoxWithOptions

    QD.I18nCatalog { id: catalog; name: "qidi"; }

    height: childrenRect.height
    width: childrenRect.width
    text: tooltipText

    property int controlWidth: QD.Theme.getSize("setting_control").width
    property int controlHeight: QD.Theme.getSize("setting_control").height

    property alias containerStackId: propertyProvider.containerStackId
    property alias settingKey: propertyProvider.key
    property alias settingStoreIndex: propertyProvider.storeIndex

    property alias labelText: fieldLabel.text
    property alias labelFont: fieldLabel.font
    property alias labelWidth: fieldLabel.width
    property alias optionModel: comboBox.model

    property string tooltipText: propertyProvider.properties.description ? propertyProvider.properties.description : ""

    // callback functions
    property var forceUpdateOnChangeFunction: dummy_func
    property var afterOnEditingFinishedFunction: dummy_func
    property var setValueFunction: null

    // a dummy function for default property values
    function dummy_func() {}

    QD.SettingPropertyProvider
    {
        id: propertyProvider
        watchedProperties: [ "value", "options", "description" ]
    }

    Label
    {
        id: fieldLabel
        anchors.left: parent.left
        anchors.verticalCenter: comboBox.verticalCenter
        visible: text != ""
        font: QD.Theme.getFont("medium")
        color: QD.Theme.getColor("text")
        renderType: Text.NativeRendering
    }

    ListModel
    {
        id: defaultOptionsModel

        function updateModel()
        {
            clear()
            // Options come in as a string-representation of an OrderedDict
            if(propertyProvider.properties.options)
            {
                var options = propertyProvider.properties.options.match(/^OrderedDict\(\[\((.*)\)\]\)$/);
                if(options)
                {
                    options = options[1].split("), (");
                    for(var i = 0; i < options.length; i++)
                    {
                        var option = options[i].substring(1, options[i].length - 1).split("', '");
                        append({ text: option[1], value: option[0] });
                    }
                }
            }
        }

        Component.onCompleted: updateModel()
    }

    // Remake the model when the model is bound to a different container stack
    Connections
    {
        target: propertyProvider
        function onContainerStackChanged() { defaultOptionsModel.updateModel() }
        function onIsValueUsedChanged() { defaultOptionsModel.updateModel() }
    }

    QIDI.ComboBox
    {
        id: comboBox
        anchors.left: fieldLabel.right
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        width: comboBoxWithOptions.controlWidth
        height: comboBoxWithOptions.controlHeight
        model: defaultOptionsModel
        textRole: "text"

        currentIndex:
        {
            var currentValue = propertyProvider.properties.value
            var index = 0
            for (var i = 0; i < model.count; i++)
            {
                if (model.get(i).value == currentValue)
                {
                    index = i
                    break
                }
            }
            return index
        }

        onActivated:
        {
            var newValue = model.get(index).value
            if (propertyProvider.properties.value != newValue)
            {
                if (setValueFunction !== null)
                {
                    setValueFunction(newValue)
                }
                else
                {
                    propertyProvider.setPropertyValue("value", newValue)
                }
                forceUpdateOnChangeFunction()
                afterOnEditingFinishedFunction()
            }
        }
    }
}
