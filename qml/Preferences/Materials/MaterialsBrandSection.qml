// Copyright (c) 2019 Ultimaker B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI

// An expandable list of materials. Includes both the header (this file) and the items (brandMaterialList)

Item
{
    id: brand_section

    property var sectionName: ""
    property var elementsModel   // This can be a MaterialTypesModel or GenericMaterialsModel or FavoriteMaterialsModel
    property var hasMaterialTypes: true  // It indicates whether it has material types or not
    property var expanded: materialList.expandedBrands.indexOf(sectionName) > -1

    height: childrenRect.height
    width: parent.width
    /*Rectangle
    {
        id: brand_header_background
        color:
        {
            if(!expanded && sectionName == materialList.currentBrand)
            {
                return QD.Theme.getColor("favorites_row_selected")
            }
            else
            {
                return QD.Theme.getColor("favorites_header_bar")
            }
        }
        anchors.fill: brand_header
    }*/
    /*Row
    {
        id: brand_header
        width: parent.width
        Label
        {
            id: brand_name
            text: sectionName
            height: QD.Theme.getSize("favorites_row").height
            width: parent.width - QD.Theme.getSize("favorites_button").width
            verticalAlignment: Text.AlignVCenter
            leftPadding: (QD.Theme.getSize("default_margin").width / 2) | 0
        }
        Item
        {
            implicitWidth: QD.Theme.getSize("favorites_button").width
            implicitHeight: QD.Theme.getSize("favorites_button").height
            QD.RecolorImage
            {
                anchors
                {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
                width: QD.Theme.getSize("standard_arrow").width
                height: QD.Theme.getSize("standard_arrow").height
                color: "black"
                source: brand_section.expanded ? QD.Theme.getIcon("ChevronSingleDown") : QD.Theme.getIcon("ChevronSingleLeft")
            }
        }
    }*/
    /*MouseArea
    {
        anchors.fill: brand_header
        onPressed:
        {
            const i = materialList.expandedBrands.indexOf(sectionName)
            if (i > -1)
            {
                // Remove it
                materialList.expandedBrands.splice(i, 1)
                brand_section.expanded = false
            }
            else
            {
                // Add it
                materialList.expandedBrands.push(sectionName)
                brand_section.expanded = true
            }
            QD.Preferences.setValue("qidi/expanded_brands", materialList.expandedBrands.join(";"));
        }
    }*/
    Column
    {
        id: brandMaterialList
        anchors.top: parent.top
        width: parent.width
        anchors.left: parent ? parent.left : undefined
        height: brand_section.expanded ? childrenRect.height : 0
        visible: brand_section.expanded

        Repeater
        {
            model: elementsModel
            delegate: Loader
            {
                id: loader
                width: parent ? parent.width : 0
                property var element: model
                sourceComponent: hasMaterialTypes ? materialsTypeSection : materialSlot
            }
        }
    }

    Component
    {
        id: materialsTypeSection
        MaterialsTypeSection
        {
            materialType: element
        }
    }

    Component
    {
        id: materialSlot
        MaterialsSlot
        {
            material: element
        }
    }

    Connections
    {
        target: QD.Preferences
        function onPreferenceChanged(preference)
        {
            if (preference !== "qidi/expanded_types" && preference !== "qidi/expanded_brands")
            {
                return;
            }

            expanded = materialList.expandedBrands.indexOf(sectionName) > -1
        }
    }
}
