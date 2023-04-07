// Copyright (c) 2018 Ultimaker B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI

// A single material row, typically used in a MaterialsBrandSection

Rectangle
{
    id: materialSlot
    property var material: null
    property var hovered: false
    property var is_favorite: material != null && material.is_favorite

    height: QD.Theme.getSize("favorites_row").height
    width: parent.width
    //color: material != null ? (base.currentItem.root_material_id == material.root_material_id ? QD.Theme.getColor("favorites_row_selected") : "transparent") : "transparent"
    color:
    {
        if(material !== null && base.currentItem !== null)
        {
            if(base.currentItem.root_material_id === material.root_material_id)
            {
                return QD.Theme.getColor("favorites_row_selected")
            }
        }
        return "transparent"
    }
	Item
	{
		id:iconItem
		anchors.verticalCenter: parent.verticalCenter
        anchors.left: materialSlot.left
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
        width: QD.Theme.getSize("favorites_button_icon").width
        height: QD.Theme.getSize("favorites_button_icon").height
		QD.RecolorImage
		{
			id: materialIcon
			anchors.fill: parent

			//anchors.fill: parent
			//anchors.left: meterialLabel.right
			//anchors.verticalCenter: parent.verticalCenter
			//width: 30 * QD.Theme.getSize("size").width
			source: QD.Theme.getIcon("ExtruderSolid", "medium")
			color:material != null ? material.color_code : "transparent"
		}
	}

    Label
    {
        text: material != null ? material.name : ""
        verticalAlignment: Text.AlignVCenter
        height: parent.height
        anchors.left: iconItem.right
        anchors.verticalCenter: materialSlot.verticalCenter
        anchors.leftMargin: QD.Theme.getSize("narrow_margin").width
        //font.italic: material != null && QIDI.MachineManager.currentRootMaterialId[QIDI.ExtruderManager.activeExtruderIndex] == material.root_material_id
		font: QD.Theme.getFont("font1")
    }
    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            materialList.currentBrand = material.brand
            materialList.currentType = material.brand + "_" + material.material
            base.setExpandedActiveMaterial(material.root_material_id)
			//base.containerId =material.root_material_id
			//QIDIApplication.writeToLog("e",material.is_read_only)
			//base.editingEnabled = ! material.is_read_only
        }
        hoverEnabled: true
        onEntered: { materialSlot.hovered = true }
        onExited: { materialSlot.hovered = false }
    }
}
