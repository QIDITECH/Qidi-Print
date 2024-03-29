// Copyright (c) 2022 Aldo Hoeben / fieldOfView
// MeshTools is released under the terms of the AGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1

import QD 1.3 as QD
import QIDI 1.0 as QIDI


QD.Dialog
{
    id: base

    title: catalog.i18nc("@title:window", "Mesh Tools Settings")

    minimumWidth: 300 * screenScaleFactor
    minimumHeight: contents.implicitHeight + 3 * QD.Theme.getSize("default_margin").height
    width: minimumWidth
    height: minimumHeight

    property variant catalog: QD.I18nCatalog { name: "meshtools" }

    function boolCheck(value) //Hack to ensure a good match between python and qml.
    {
        if(value == "True")
        {
            return true
        }else if(value == "False" || value == undefined)
        {
            return false
        }
        else
        {
            return value
        }
    }

    Column
    {
        id: contents
        anchors.fill: parent
        spacing: QD.Theme.getSize("default_lining").height

        QD.TooltipArea
        {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip", "Check if models are watertight when loading them")

            CheckBox
            {
                text: catalog.i18nc("@option:check", "Check models on load")
                checked: boolCheck(QD.Preferences.getValue("meshtools/check_models_on_load"))
                onCheckedChanged: QD.Preferences.setValue("meshtools/check_models_on_load", checked)
            }
        }

        QD.TooltipArea
        {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip", "Always recalculate model normals when loading them")

            CheckBox
            {
                text: catalog.i18nc("@option:check", "Fix normals on load")
                checked: boolCheck(QD.Preferences.getValue("meshtools/fix_normals_on_load"))
                onCheckedChanged: QD.Preferences.setValue("meshtools/fix_normals_on_load", checked)
            }
        }

        // spacer
        Item { height: QD.Theme.getSize("default_margin").height; width: 1 }

        QD.TooltipArea
        {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip", "Unit to convert meshes from when the file does not specify a unit (such as STL files). All units will be converted to millimeters.")

            Column
            {
                spacing: 4 * screenScaleFactor

                Label
                {
                    text: catalog.i18nc("@window:text", "Unit for files that don't specify a unit:")
                }

                ComboBox
                {
                    id: modelUnitDropDownButton
                    width: 200 * screenScaleFactor

                    model: ListModel
                    {
                        id: modelUnitModel

                        Component.onCompleted:
                        {
                            append({ text: catalog.i18nc("@option:unit", "Micron"), factor: 0.001 })
                            append({ text: catalog.i18nc("@option:unit", "Millimeter (default)"), factor: 1 })
                            append({ text: catalog.i18nc("@option:unit", "Centimeter"), factor: 10 })
                            append({ text: catalog.i18nc("@option:unit", "Meter"), factor: 1000 })
                            append({ text: catalog.i18nc("@option:unit", "Inch"), factor: 25.4 })
                            append({ text: catalog.i18nc("@option:unit", "Feet"), factor: 304.8 })
                        }
                    }

                    currentIndex:
                    {
                        var index = 0;
                        var currentChoice = QD.Preferences.getValue("meshtools/model_unit_factor");
                        for (var i = 0; i < model.count; ++i)
                        {
                            if (model.get(i).factor == currentChoice)
                            {
                                index = i;
                                break;
                            }
                        }
                        return index;
                    }

                    onActivated: QD.Preferences.setValue("meshtools/model_unit_factor", model.get(index).factor)
                }
            }
        }

        // spacer
        Item { height: QD.Theme.getSize("default_margin").height; width: 1 }

        QD.TooltipArea
        {
            width: childrenRect.width
            height: childrenRect.height
            text: catalog.i18nc("@info:tooltip", "Place models at a random location on the build plate when loading them")

            CheckBox
            {
                text: catalog.i18nc("@option:check", "Randomize position on load")
                checked: boolCheck(QD.Preferences.getValue("meshtools/randomise_location_on_load"))
                onCheckedChanged: QD.Preferences.setValue("meshtools/randomise_location_on_load", checked)
            }
        }
    }

    rightButtons: [
        Button
        {
            id: cancelButton
            text: catalog.i18nc("@action:button","Close")
            onClicked: base.reject()
        }
    ]
}

