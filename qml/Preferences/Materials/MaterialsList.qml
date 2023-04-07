// Copyright (c) 2019 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    id: materialList
    height: childrenRect.height

    // Children
    QD.I18nCatalog { id: catalog; name: "qidi"; }
    QIDI.MaterialBrandsModel
    {
        id: materialsModel
        extruderPosition:  QIDI.ExtruderManager.activeExtruderIndex
    }

    QIDI.MaterialUsersModel
    {
        id: materialsUsersModel
        extruderPosition:  QIDI.ExtruderManager.activeExtruderIndex
    }


    QIDI.GenericMaterialsModel
    {
        id: genericMaterialsModel
        extruderPosition:  QIDI.ExtruderManager.activeExtruderIndex
    }
    property var currentSelectType: "QIDI"
    property var currentType: null
    property var currentBrand: null
    property var expandedBrands: QD.Preferences.getValue("qidi/expanded_brands").split(";")
    property var expandedTypes: QD.Preferences.getValue("qidi/expanded_types").split(";")

    // Store information about which parts of the tree are expanded
    function persistExpandedCategories()
    {
        QD.Preferences.setValue("qidi/expanded_brands", materialList.expandedBrands.join(";"))
        QD.Preferences.setValue("qidi/expanded_types", materialList.expandedTypes.join(";"))
    }

    // Expand the list of materials in order to select the current material
    function expandActiveMaterial(search_root_id)
    {
        if (search_root_id == "")
        {
            // When this happens it means that the information of one of the materials has changed, so the model
            // was updated and the list has to highlight the current item.
            var currentItemId = base.currentItem == null ? "" : base.currentItem.root_material_id
            search_root_id = currentItemId
        }
		materialList.expandedBrands.push("Generic")
		materialList.expandedBrands.push("Custom")
        for (var material_idx = 0; material_idx < genericMaterialsModel.count; material_idx++)
        {
            var material = genericMaterialsModel.getItem(material_idx)
            if (material.root_material_id == search_root_id)
            {

                materialList.currentBrand = "Generic"
                base.currentItem = material
				base.containerId = material.root_material_id
				base.editingEnabled = ! material.is_read_only
				base.currentMaterialNode = material.container_node
                persistExpandedCategories()
                return true
            }
        }
        for (var brand_idx = 0; brand_idx < materialsModel.count; brand_idx++)
        {
            var material = materialsModel.getItem(brand_idx)
            if (material.root_material_id == search_root_id)
            {

                materialList.currentBrand = "Custom"
                base.currentItem = material
				base.containerId = material.root_material_id
				base.editingEnabled = ! material.is_read_only
				base.currentMaterialNode = material.container_node

                persistExpandedCategories()
                return true
            }
        }
        for (var brand_idx = 0; brand_idx < materialsUsersModel.count; brand_idx++)
        {
            var material = materialsUsersModel.getItem(brand_idx)
            if (material.root_material_id == search_root_id)
            {

                materialList.currentBrand = "Custom"
                base.currentItem = material
				base.containerId = material.root_material_id
				base.editingEnabled = ! material.is_read_only
				base.currentMaterialNode = material.container_node

                persistExpandedCategories()
                return true
            }
        }
        base.currentItem = null
        return false
    }

    function updateAfterModelChanges()
    {
        var correctlyExpanded = materialList.expandActiveMaterial(base.newRootMaterialIdToSwitchTo)
        if (correctlyExpanded)
        {
            if (base.toActivateNewMaterial)
            {
                var position = QIDI.ExtruderManager.activeExtruderIndex
                QIDI.MachineManager.setMaterialById(position, base.newRootMaterialIdToSwitchTo)
            }
            base.newRootMaterialIdToSwitchTo = ""
            base.toActivateNewMaterial = false
        }
    }

    Connections
    {
        target: materialsUsersModel
        function onItemsChanged() { updateAfterModelChanges() }
    }

    Connections
    {
        target: materialsModel
        function onItemsChanged() { updateAfterModelChanges() }
    }

    Connections
    {
        target: genericMaterialsModel
        function onItemsChanged() { updateAfterModelChanges() }
    }
    
    Column
    {
        width: materialList.width
        height: childrenRect.height
        Rectangle
        {
            height:currentSelectType =="QIDI" ? 20*QD.Theme.getSize("size").height : 0
            width:parent.width
            Label{
                id:qidilabel
                anchors.left: parent.left
                anchors.leftMargin:10*QD.Theme.getSize("size").height
                text:"QIDI"
                font: QD.Theme.getFont("font2")
                color:QD.Theme.getColor("blue_6")
                visible:currentSelectType =="QIDI"
            }

            Rectangle
            {
                height: QD.Theme.getSize("default_lining").height
                anchors.left: qidilabel.right
                anchors.leftMargin:10*QD.Theme.getSize("size").height
                anchors.right: parent.right
                anchors.verticalCenter:qidilabel.verticalCenter
                color: QD.Theme.getColor("blue_6")
                visible:currentSelectType =="QIDI"
            }
        }

        MaterialsBrandSection
        {
            id: brandSection
            sectionName: "Custom"
            elementsModel: materialsModel
            hasMaterialTypes: false
            visible:currentSelectType =="QIDI"
        }

        Rectangle
        {
            height:currentSelectType =="QIDI" ? 20*QD.Theme.getSize("size").height : 0
            width:parent.width
            Label{
                id:genericlabel
                anchors.left: parent.left
                anchors.leftMargin:10*QD.Theme.getSize("size").height
                text:"Generic"
                font: QD.Theme.getFont("font2")
                color:QD.Theme.getColor("blue_6")
                visible:currentSelectType =="QIDI"
            }

            Rectangle
            {
                height: QD.Theme.getSize("default_lining").height
                anchors.left: genericlabel.right
                anchors.leftMargin:10*QD.Theme.getSize("size").height
                anchors.right: parent.right
                anchors.verticalCenter:genericlabel.verticalCenter
                color: QD.Theme.getColor("blue_6")
                visible:currentSelectType =="QIDI"
            }
        }

        MaterialsBrandSection
        {
            id: genericSection
            sectionName: "Generic"
            elementsModel: genericMaterialsModel
            hasMaterialTypes: false
            visible:currentSelectType =="QIDI"
        }

        MaterialsBrandSection
        {
            id: brandUserSection
            sectionName: "Custom"
            elementsModel: materialsUsersModel
            hasMaterialTypes: false
            visible:currentSelectType =="Custom"
        }
    }
}