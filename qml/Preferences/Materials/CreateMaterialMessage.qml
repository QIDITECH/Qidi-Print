// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3
import QtQuick.Controls 1.4 as OldControls
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.1
import QtQuick.Window 2.2



import QD 1.3 as QD
import QIDI 1.0 as QIDI

QD.Dialog
{
    id: base
    property bool multipleExtruders: extrudersModel.count > 1
	property var materialManagementModel: QIDIApplication.getMaterialManagementModel()
    property var currentItem: null
	property bool is_create:false
    property var hasCurrentItem: base.currentItem != null
	title: catalog.i18nc("@title:window","Material Management")

    property var materialPreferenceValues: QD.Preferences.getValue("qidi/material_settings") ? JSON.parse(QD.Preferences.getValue("qidi/material_settings")) : {}
    property string currency: QD.Preferences.getValue("qidi/currency") ? QD.Preferences.getValue("qidi/currency") : "€"

    property double spoolLength: calculateSpoolLength()
    property real costPerMeter: calculateCostPerMeter()

    property var extrudersModel: QIDIApplication.getExtrudersModel()
	property string containerId: ""
    property bool editingEnabled: false
	property int extruderIndexinbase: 0
	property var currentMaterialNode: null
    color: QD.Theme.getColor("white_1")
	property bool deletemessage : false
	
    property string newRootMaterialIdToSwitchTo: ""
    property bool toActivateNewMaterial: false
	minimumHeight:390	 * QD.Theme.getSize("size").width   | 0
	maximumHeight:390	 * QD.Theme.getSize("size").width
    height: 390	 * QD.Theme.getSize("size").width
    width: 660	 * QD.Theme.getSize("size").width
	maximumWidth:660	 * QD.Theme.getSize("size").width
	minimumWidth:660	 * QD.Theme.getSize("size").width
    property var currentSelectType: "QIDI"

    property var extruder_position: QIDI.ExtruderManager.activeExtruderIndex

    property var active_root_material_id: QIDI.MachineManager.currentRootMaterialId[extruder_position]

    function resetExpandedActiveMaterial()
    {
        materialListView.expandActiveMaterial(active_root_material_id)
    }

    function setExpandedActiveMaterial(root_material_id)
    {
        materialListView.expandActiveMaterial(root_material_id)
    }

    property var isCurrentItemActivated:
    {
        if (!hasCurrentItem)
        {
            return false
        }
        const extruder_position = QIDI.ExtruderManager.activeExtruderIndex
        const root_material_id = QIDI.MachineManager.currentRootMaterialId[extruder_position]
        return base.currentItem.root_material_id == root_material_id
    }

    Component.onCompleted:
    {
        resetExpandedActiveMaterial()
        base.newRootMaterialIdToSwitchTo = active_root_material_id
    }


	Rectangle
    {
		anchors.top: parent.top
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.left: parent.left
		anchors.leftMargin:5 * QD.Theme.getSize("size").height
        anchors.right: listViewBack.left
		anchors.rightMargin:-QD.Theme.getSize("size").height
		height: sMessageListView.count * 25 * QD.Theme.getSize("size").width + 195 * QD.Theme.getSize("size").width
		color:QD.Theme.getColor("white_1")
        border.width: QD.Theme.getSize("size").width
		border.color:QD.Theme.getColor("blue_6")
	}
	Rectangle
    {
		id:selectbutton
        anchors.left: parent.left
		anchors.leftMargin:15 * QD.Theme.getSize("size").height
        anchors.right: listViewBack.left
		anchors.rightMargin:15 * QD.Theme.getSize("size").height
        anchors.top: parent.top
        anchors.topMargin: 15 * QD.Theme.getSize("size").height
		height: 30 * QD.Theme.getSize("size").height
		color:QD.Theme.getColor("gray_10")
		radius: 5 * QD.Theme.getSize("size").height
		Rectangle
		{
			height: parent.height
			width:parent.width/2
			color:base.currentSelectType == "QIDI"? QD.Theme.getColor("blue_6"):QD.Theme.getColor("gray_10")
			radius: 5 * QD.Theme.getSize("size").height
			Text
			{
				text: catalog.i18nc("@button", "QIDI")
				font: QD.Theme.getFont("font2")
				color: base.currentSelectType == "QIDI" ? QD.Theme.getColor("white_1"):QD.Theme.getColor("black_1")
				anchors.centerIn: parent
			}
			MouseArea{
				anchors.fill:parent
				onClicked:{
					base.currentSelectType = "QIDI";
				}
			}
		}
		Rectangle
		{
			anchors.right:parent.right
			height: parent.height
			width:parent.width/2
			color:base.currentSelectType == "Custom"? QD.Theme.getColor("blue_6"):QD.Theme.getColor("gray_10")
			radius: 5 * QD.Theme.getSize("size").height
			Text
			{
				text: catalog.i18nc("@button", "Custom")
				font: QD.Theme.getFont("font2")
				color: base.currentSelectType == "Custom" ? QD.Theme.getColor("white_1"):QD.Theme.getColor("black_1")
				anchors.centerIn: parent
			}
			MouseArea{
				anchors.fill:parent
				onClicked:{
					base.currentSelectType = "Custom";
				}
			}
		}
	}

	
	Rectangle
	{
		id:listrec
        anchors
        {
            top: selectbutton.bottom
            topMargin: 0.5* QD.Theme.getSize("default_margin").height
            left: parent.left
			leftMargin : QD.Theme.getSize("default_margin").height
			bottom: listViewBack.bottom
        }
		width: 180 * QD.Theme.getSize("size").width
		color: QD.Theme.getColor("white_2")
		border.width: QD.Theme.getSize("size").width
		border.color:QD.Theme.getColor("blue_6")
		visible:false
		
	}

    Item
    {
		id: materialList
		
        anchors
        {
            top: listrec.top
            topMargin: 5* QD.Theme.getSize("size").height
            left: listrec.left
			leftMargin : QD.Theme.getSize("size").height
			bottom: listViewBack.bottom
			bottomMargin: QD.Theme.getSize("default_margin").height

        }
		width: 190 * QD.Theme.getSize("size").width
        SystemPalette { id: palette }
		MessageDialog
		{
			id: confirmRemoveMaterialDialog
			icon: StandardIcon.Question;
			title: catalog.i18nc("@title:window", "Confirm Remove")

			text: catalog.i18nc("@label (%1 is object name)", "Are you sure you wish to remove %1? This cannot be undone!").arg(base.currentItem ? base.currentItem.name : "")
			standardButtons: StandardButton.Yes | StandardButton.No
			modality: Qt.ApplicationModal
			onYes:
			{
				// Set the active material as the fallback. It will be selected when the current material is deleted
				base.materialManagementModel.removeMaterial(base.currentItem.container_node);
				base.setExpandedActiveMaterial(QIDI.MachineManager.currentRootMaterialId[QIDI.ExtruderManager.activeExtruderIndex])
			}
		}
		QD.I18nCatalog
		{
			id: catalog
			name: "qidi"
		}
		QD.RecolorImage
		{
			id: createButton
			source:  QD.Theme.getIcon("add","low") 
			color: QD.Theme.getColor("blue_6")
			width: 40 * QD.Theme.getSize("size").height
			height: 40 * QD.Theme.getSize("size").height
			anchors.left: parent.left
			anchors.leftMargin:25 * QD.Theme.getSize("size").height
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 5 * QD.Theme.getSize("size").height
			visible:base.currentSelectType == "Custom"
			MouseArea
			{
				anchors.fill:parent
				onClicked:{
					forceActiveFocus();
					base.newRootMaterialIdToSwitchTo = base.materialManagementModel.createMaterial();
					base.toActivateNewMaterial = true;
				}
			}
		}
		QD.RecolorImage
		{
			source:  QD.Theme.getIcon("subtract","low") 
			color: (  base.hasCurrentItem && !base.currentItem.is_read_only && !base.isCurrentItemActivated && base.materialManagementModel.canMaterialBeRemoved(base.currentItem.container_node)) ? QD.Theme.getColor("red_1") : QD.Theme.getColor("gray_1")
			width: 40 * QD.Theme.getSize("size").height
			height: 40 * QD.Theme.getSize("size").height
			anchors.left: createButton.right
			anchors.leftMargin:40 * QD.Theme.getSize("size").height
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 5 * QD.Theme.getSize("size").height
			visible:base.editingEnabled && base.currentSelectType == "Custom"
			MouseArea
			{
				anchors.fill:parent
				onClicked:{
					confirmRemoveMaterialDialog.open()
				}
				enabled:  base.hasCurrentItem && !base.currentItem.is_read_only && !base.isCurrentItemActivated && base.materialManagementModel.canMaterialBeRemoved(base.currentItem.container_node)
			}
		}
		OldControls.ScrollView
        {
            id: materialScrollView
            anchors
            {
                top:  parent.top
                topMargin:  0
                bottom: base.currentSelectType == "Custom" ? createButton.top : parent.bottom
				bottomMargin: 5 *QD.Theme.getSize("size").height
				left: parent.left
            }
            Rectangle
            {
                parent: viewport
                anchors.top: parent.top
				anchors.bottom:base.currentSelectType == "Custom" ? createButton.top : parent.bottom
				anchors.bottomMargin: 5 *QD.Theme.getSize("size").height
				anchors.left:parent.left
				anchors.right:parent.right
                color: QD.Theme.getColor("white_1")
            }
			
            width: parent.width*0.8 
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
			verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
		
            MaterialsList
            {
                id: materialListView
                width: materialScrollView.viewport.width
				currentSelectType:base.currentSelectType
            }
        }
    }
    Rectangle
    {
        id: listViewBack
		anchors
        {
			top :parent.top
            topMargin: 5 * QD.Theme.getSize("size").height
			left:materialList.right
			leftMargin: -2*QD.Theme.getSize("default_margin").height
			right:parent.right
			rightMargin:5 * QD.Theme.getSize("size").height
        }
        height: sMessageListView.count * 25 * QD.Theme.getSize("size").width + 195 * QD.Theme.getSize("size").width
        color: QD.Theme.getColor("white_1")
        border.width: QD.Theme.getSize("size").width
		border.color:QD.Theme.getColor("blue_6")

		Rectangle
		{
			anchors.left:parent.left
			anchors.top:parent.top
			anchors.topMargin:QD.Theme.getSize("size").height
			width:QD.Theme.getSize("size").height
			height:10*QD.Theme.getSize("size").height
			color:QD.Theme.getColor("white_1")
		}
		Rectangle
		{
			anchors.left:parent.left
			anchors.bottom:parent.bottom
			anchors.bottomMargin:QD.Theme.getSize("size").height
			width:QD.Theme.getSize("size").height
			height:10*QD.Theme.getSize("size").height
			color:QD.Theme.getColor("white_1")
		}
		Rectangle
		{
			id: parameterspage
			height: 30 * QD.Theme.getSize("size").height
			width : parent.width/3 - 15* QD.Theme.getSize("size").height
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.leftMargin: 10 * QD.Theme.getSize("size").height
			anchors.topMargin: 10 * QD.Theme.getSize("size").height
			radius: 15 * QD.Theme.getSize("size").height
			color: QD.Theme.getColor("blue_6")
			border.width: QD.Theme.getSize("size").width
			border.color:QD.Theme.getColor("blue_6")
			QD.TabRowButtonForControl
			{
				id:parametersPageButton
				height: parent.height
				width: parent.width   - 2 * QD.Theme.getSize("size").height
				backgroundColor: QD.Theme.getColor("small_button")
				borderColor: QD.Theme.getColor("small_button")
				contentItem: Item
				{
					Text
					{
						id:parameterstext
						text: catalog.i18nc("@button", "Parameters")
						font: QD.Theme.getFont("font2")
						color: parameterspage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
						anchors.centerIn: parent
					}
				}
				onClicked:
				{
					parameterspage.color =QD.Theme.getColor("blue_6")
					informationpage.color = QD.Theme.getColor("white_1")
					propertiepage.color = QD.Theme.getColor("white_1")
					namelabel.visible = true
					densitylabel.visible = false
					humiditylabel.visible = false
				}
			}
		}
		Rectangle
		{
			id: informationpage
			height: 30 * QD.Theme.getSize("size").height
			width : parent.width/3 - 15* QD.Theme.getSize("size").height 
			anchors.top: parent.top
			anchors.horizontalCenter:parent.horizontalCenter
			anchors.topMargin: 10 * QD.Theme.getSize("size").height
			radius: 15 * QD.Theme.getSize("size").height
			color: QD.Theme.getColor("white_1")
			border.width: QD.Theme.getSize("size").width
			border.color:QD.Theme.getColor("blue_6")
			QD.TabRowButtonForControl
			{
				id:informationPageButton

				height: parent.height
				width: parent.width   - 2 * QD.Theme.getSize("size").height
				backgroundColor: QD.Theme.getColor("small_button")
				borderColor: QD.Theme.getColor("small_button")

				contentItem: Item
				{
					Text
					{
						id:informationtext

						text: catalog.i18nc("@button", "Information")
						font: QD.Theme.getFont("font2")
						color: informationpage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
						anchors.centerIn: parent
					}
				}
				onClicked:
				{
					parameterspage.color =QD.Theme.getColor("white_1")
					informationpage.color = QD.Theme.getColor("blue_6")
					propertiepage.color = QD.Theme.getColor("white_1")
					namelabel.visible = false
					densitylabel.visible = true
					humiditylabel.visible = false
				}
			}
		}


		Rectangle
		{
			id: propertiepage
			height: 30 * QD.Theme.getSize("size").height
			width : parent.width/3 - 15* QD.Theme.getSize("size").height 
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.rightMargin: 10 * QD.Theme.getSize("size").height
			anchors.topMargin: 10 * QD.Theme.getSize("size").height
			radius: 15 * QD.Theme.getSize("size").height
			color: QD.Theme.getColor("white_1")
			border.width: QD.Theme.getSize("size").width
			border.color:QD.Theme.getColor("blue_6")
			QD.TabRowButtonForControl
			{
				id:propertiePageButton

				height: parent.height
				width: parent.width   - 2 * QD.Theme.getSize("size").height
				backgroundColor: QD.Theme.getColor("small_button")
				borderColor: QD.Theme.getColor("small_button")

				contentItem: Item
				{
					Text
					{
						id:propertietext

						text: catalog.i18nc("@button", "Propertie")
						font: QD.Theme.getFont("font2")
						color: propertiepage.color == QD.Theme.getColor("blue_6") ? QD.Theme.getColor("white_1") : QD.Theme.getColor("blue_6")
						anchors.centerIn: parent
					}
				}
				onClicked:
				{
					parameterspage.color =QD.Theme.getColor("white_1")
					informationpage.color = QD.Theme.getColor("white_1")
					propertiepage.color = QD.Theme.getColor("blue_6")
					namelabel.visible = false
					densitylabel.visible = false
					humiditylabel.visible = true
				}
			}
		}

		Label
		{
			id : namelabel
			anchors.top: parameterspage.bottom
			anchors.topMargin: 15 * QD.Theme.getSize("size").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Material name")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering

		}

		QIDI.ReadOnlyTextField
		{
			id: displayNameTextField;
			anchors.left: namelabel.right
			anchors.verticalCenter: namelabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: base.currentItem !== null ? base.currentItem.name : ""
			readOnly: !base.editingEnabled
			onEditingFinished: base.updateMaterialDisplayName(QIDI.MachineManager.activeStack.material.name, text)
			visible:namelabel.visible
		}
		Label
		{
			id : humiditylabel
			anchors.top: parameterspage.bottom
			anchors.topMargin: 15 * QD.Theme.getSize("size").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Humidity")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:false
		}
		QIDI.ReadOnlyTextField
		{
			id: displayHumidityTextField;
			anchors.left: humiditylabel.right
			anchors.verticalCenter: humiditylabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height//base.width*0.23;
			text: (base.currentItem !== null ? base.currentItem.humidity : "")+ " %"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.humidity =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/humidity", base.currentItem.humidity, text)
			visible:humiditylabel.visible
		}
		Label
		{
			id : waterresistantlabel
            anchors.top: humiditylabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Water Resistant")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}
		Rectangle
		{
			id:waterresistantRectanglelow
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			// anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.left: waterresistantlabel.right
			anchors.bottom:waterresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.water_resistant) > 0 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					if(base.editingEnabled && base.currentItem.water_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/water_resistant", base.currentItem.water_resistant, "1")
					}
				}
			}
		}
		Rectangle
		{
			id:waterresistantRectanglemedium
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.left: waterresistantRectanglelow.right
			anchors.bottom:waterresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.water_resistant) > 1 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					if(base.editingEnabled && base.currentItem.water_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/water_resistant", base.currentItem.water_resistant, "2")
					}
				}
			}
		}
		Rectangle
		{
			id:waterresistantRectanglehign
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.left: waterresistantRectanglemedium.right
			anchors.bottom:waterresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.water_resistant) > 2 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					console.log("click")
					if(base.editingEnabled && base.currentItem.water_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/water_resistant", base.currentItem.water_resistant, "3")
					}
				}
			}
		}

		Label
		{
			id :chemicallyresistantlabel
            anchors.top: waterresistantlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Chemically Resistant")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}
		Rectangle
		{
			id:chemicallyresistantRectanglelow
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			// anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.left:chemicallyresistantlabel.right
			anchors.bottom:chemicallyresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.chemically_resistant) > 0 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")

			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					if(base.editingEnabled && base.currentItem.chemically_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/chemically_resistant", base.currentItem.chemically_resistant, "1")
					}
				}
			}
		}
		Rectangle
		{
			id:chemicallyresistantRectanglemedium
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.left: chemicallyresistantRectanglelow.right
			anchors.bottom:chemicallyresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.chemically_resistant) > 1 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					if(base.editingEnabled && base.currentItem.chemically_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/chemically_resistant", base.currentItem.chemically_resistant, "2")
					}
				}
			}
		}
		Rectangle
		{
			id:chemicallyresistantRectanglehign
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.left: chemicallyresistantRectanglemedium.right
			anchors.bottom: chemicallyresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.chemically_resistant) > 2 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					console.log("click")
					if(base.editingEnabled && base.currentItem.chemically_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/chemically_resistant", base.currentItem.chemically_resistant, "3")
					}
				}
			}
		}
		Label
		{
			id :creepresistantlabel
            anchors.top: chemicallyresistantlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Creep Resistant")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}
		Rectangle
		{
			id:creepresistantRectanglelow
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			// anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.left:creepresistantlabel.right
			anchors.bottom:creepresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.creep_resistant) > 0 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					if(base.editingEnabled && base.currentItem.creep_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/creep_resistant", base.currentItem.creep_resistant, "1")
					}
				}
			}
		}
		Rectangle
		{
			id:creepresistantRectanglemedium
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			anchors.left: creepresistantRectanglelow.right
			anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.bottom:creepresistantlabel.bottom
			color:hasCurrentItem ? Number(base.currentItem.creep_resistant) > 1 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					if(base.editingEnabled && base.currentItem.creep_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/creep_resistant", base.currentItem.creep_resistant, "2")
					}
				}
			}
		}
		Rectangle
		{
			id:creepresistantRectanglehign
			width: 50 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			anchors.left: creepresistantRectanglemedium.right
			anchors.leftMargin: 2 * QD.Theme.getSize("size").height
			anchors.bottom: creepresistantlabel.bottom
			// anchors.verticalCenter: waterresistantlabel.verticalCenter
			color:hasCurrentItem ? Number(base.currentItem.creep_resistant) > 2 ? QD.Theme.getColor("blue_6") :QD.Theme.getColor("gray_7"):QD.Theme.getColor("gray_7")
			visible:humiditylabel.visible
			MouseArea{
				anchors.fill:parent
				onClicked: {
					if(base.editingEnabled && base.currentItem.creep_resistant !="Cannot find this")
					{
						base.setMetaDataEntry("properties/creep_resistant", base.currentItem.creep_resistant, "3")
					}
				}
			}
		}

		Label
		{
			id :anneallabel
            anchors.top: creepresistantlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Anneal")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}
		QIDI.CheckBox
		{
			id: annealCheckBox
			width: 18 * QD.Theme.getSize("size").height
			height: 18 * QD.Theme.getSize("size").height
			anchors.left: anneallabel.right
			anchors.verticalCenter: anneallabel.verticalCenter
			checked: hasCurrentItem ? base.currentItem.anneal == "yes" ? true : false :false
			visible:humiditylabel.visible
			enabled:base.editingEnabled && base.currentItem.anneal !="Cannot find this"
			onCheckedChanged: {
				if (base.editingEnabled && base.currentItem.anneal !="Cannot find this")
				{
					if(annealCheckBox.checked == true)
					{
						base.setMetaDataEntry("properties/anneal", base.currentItem.anneal, "yes")
					}
					else
					{
						base.setMetaDataEntry("properties/anneal", base.currentItem.anneal, "no")
					}
				}

			}
		}
		Label
		{
			id :hdt_045label
            anchors.top: anneallabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Heat Distortion Temp(0.45MPa)")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}


		QIDI.ReadOnlyTextField
		{
			id: displayHdt_045TextField;
			anchors.left: hdt_045label.right
			anchors.verticalCenter: hdt_045label.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.hdt_045 : "") + " ℃"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.hdt_045 =="Cannot find this")
			onEditingFinished: {
				base.setMetaDataEntry("properties/HDT_0.45", base.currentItem.hdt_045, text.replace(/(.*) ℃/,"$1"))
			}
			visible:humiditylabel.visible
		}

		Label
		{
			id :hdt_180label
            anchors.top: hdt_045label.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Heat Distortion Temp(1.80MPa)")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}

		QIDI.ReadOnlyTextField
		{
			id: displayHdt_180TextField;
			anchors.left: hdt_180label.right
			anchors.verticalCenter: hdt_180label.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.hdt_180 : "")+ " ℃"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.hdt_180 =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/HDT_1.80", base.currentItem.hdt_180, text.replace(/(.*) ℃/,"$1"))
			visible:humiditylabel.visible
		}
		Label
		{
			id :tensile_strengthlabel
            anchors.top: hdt_180label.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Tensile Strength")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}
		QIDI.ReadOnlyTextField
		{
			id: displayTensile_strengthTextField;
			anchors.left: tensile_strengthlabel.right
			anchors.verticalCenter: tensile_strengthlabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.tensile_strength : "")+ " MPa"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.tensile_strength =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/tensile_strength", base.currentItem.tensile_strength, text.replace(/(.*) MPa/,"$1"))
			visible:humiditylabel.visible
		}
		Label
		{
			id :tensile_moduluslabel
            anchors.top: tensile_strengthlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Tensile Modulus")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}
		QIDI.ReadOnlyTextField
		{
			id: displayTensile_modulusTextField;
			anchors.left: tensile_moduluslabel.right
			anchors.verticalCenter: tensile_moduluslabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.tensile_modulus : "")+ " MPa"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.tensile_modulus =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/tensile_modulus", base.currentItem.tensile_modulus, text.replace(/(.*) MPa/,"$1"))
			visible:humiditylabel.visible
		}
		Label
		{
			id :elongation_at_breaklabel
            anchors.top: tensile_moduluslabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Elongation at Break")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}

		QIDI.ReadOnlyTextField
		{
			id: displayElongation_at_breakTextField;
			anchors.left: elongation_at_breaklabel.right
			anchors.verticalCenter: elongation_at_breaklabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.elongation_at_break : "") + " %"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.elongation_at_break =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/elongation_at_break", base.currentItem.elongation_at_break, text.replace(/(.*) %/,"$1"))
			visible:humiditylabel.visible
		}
		Label
		{
			id :flexural_strengthlabel
            anchors.top: elongation_at_breaklabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Flexural Strength")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}

		QIDI.ReadOnlyTextField
		{
			id: displayFlexural_strengthTextField;
			anchors.left: flexural_strengthlabel.right
			anchors.verticalCenter: flexural_strengthlabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.flexural_strength : "")+ " MPa"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.flexural_strength =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/flexural_strength", base.currentItem.flexural_strength, text.replace(/(.*) MPa/,"$1"))
			visible:humiditylabel.visible
		}

		Label
		{
			id :flexural_moduluslabel
            anchors.top: flexural_strengthlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Flexural Modulus")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}
		QIDI.ReadOnlyTextField
		{
			id: displayFlexural_modulusTextField;
			anchors.left: flexural_moduluslabel.right
			anchors.verticalCenter: flexural_moduluslabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.flexural_modulus : "")+ " MPa"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.flexural_modulus =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/flexural_modulus", base.currentItem.flexural_modulus, text.replace(/(.*) MPa/,"$1"))
			visible:humiditylabel.visible
		}

		Label
		{
			id :impact_strengthlabel
            anchors.top: flexural_moduluslabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Impact Strength")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:humiditylabel.visible
		}


		QIDI.ReadOnlyTextField
		{
			id: displayImpact_strengthTextField;
			anchors.left: impact_strengthlabel.right
			anchors.verticalCenter: impact_strengthlabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: (base.currentItem !== null ? base.currentItem.impact_strength : "")+ " kJ/㎡"
			readOnly: (!base.editingEnabled) || (base.editingEnabled && base.currentItem.impact_strength =="Cannot find this")
			onEditingFinished: base.setMetaDataEntry("properties/impact_strength", base.currentItem.impact_strength, text.replace(/(.*) kJ[^\s]*/,"$1"))
			visible:humiditylabel.visible
		}

		Label
		{
			id : densitylabel
			anchors.top: parameterspage.bottom
			anchors.topMargin: 15 * QD.Theme.getSize("size").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Density")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:false
		}
		QIDI.ReadOnlySpinBox
		{
			id: densitySpinBox
			anchors.left: densitylabel.right
			anchors.verticalCenter: densitylabel.verticalCenter
			width: 154 * QD.Theme.getSize("size").height;
			value: hasCurrentItem ? base.currentItem.density ? base.currentItem.density : 0 :0
			decimals: 2
			suffix: " g/cm³"
			stepSize: 0.01
			readOnly: !base.editingEnabled
			visible:densitylabel.visible
			onEditingFinished:{
				base.setMetaDataEntry("properties/density", base.currentItem.density, value)
			}
			onValueChanged: updateCostPerMeter()
		}
		Label
		{
			id : diameterlabel
            anchors.top: densitylabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Diameter")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:densitylabel.visible
		}
		QIDI.ReadOnlySpinBox
		{
			id: diameterSpinBox
			anchors.left: diameterlabel.right
			anchors.verticalCenter: diameterlabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			value: hasCurrentItem ? base.currentItem.diameter ? base.currentItem.diameter : 0 :0
			decimals: 2
			suffix: " mm"
			stepSize: 0.01
			readOnly: !base.editingEnabled
			visible:densitylabel.visible
			onEditingFinished:
			{
				base.setMetaDataEntry("properties/diameter", base.currentItem.diameter, value);
			}
			onValueChanged: updateCostPerMeter()
		}
		Label
		{
			id : spoolCostlabel
            anchors.top: diameterlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Filament Cost")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:densitylabel.visible
		}
		QIDI.ReadOnlySpinBox
		{
			id: spoolCostSpinBox
			anchors.left: spoolCostlabel.right
			anchors.verticalCenter: spoolCostlabel.verticalCenter

			width: 122 * QD.Theme.getSize("size").height;
			value: base.currentItem !== null ?  base.getMaterialPreferenceValue(base.currentItem.GUID, "spool_cost") : "0"
			decimals: 2
			suffix:  " "
			maximumValue: 10000

			readOnly: false
			visible:densitylabel.visible
			onValueChanged: 
			{
				base.setMaterialPreferenceValue(base.currentItem.GUID, "spool_cost", parseFloat(value))
				updateCostPerMeter()
			}
		}
		QIDI.ReadOnlyTextField
		{
			id: currencyField;
			anchors.left: spoolCostSpinBox.right
			anchors.leftMargin: 2 *QD.Theme.getSize("size").height
			anchors.verticalCenter: spoolCostSpinBox.verticalCenter

			width: 30 * QD.Theme.getSize("size").height//base.width*0.1 -2 *QD.Theme.getSize("size").height;
			text: QD.Preferences.getValue("qidi/currency")
			readOnly: false
			onEditingFinished: 
			{
				base.currency = text
				QD.Preferences.setValue("qidi/currency", text)
			}
			visible:densitylabel.visible
		}
		Label
		{
			id : spoolWeightlabel
            anchors.top: spoolCostlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Filament weight")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:densitylabel.visible
		}
		QIDI.ReadOnlySpinBox
		{
			id: spoolWeightSpinBox
			anchors.left: spoolWeightlabel.right
			anchors.verticalCenter: spoolWeightlabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			value: base.currentItem !== null ?  base.getMaterialPreferenceValue(base.currentItem.GUID, "spool_weight") : ""
			stepSize: 100
			decimals: 0
			maximumValue: 10000
			suffix: " g"
			readOnly: false
			visible:densitylabel.visible
			onValueChanged: 
			{
				base.setMaterialPreferenceValue(base.currentItem.GUID, "spool_weight", parseFloat(value))
				updateCostPerMeter()
			}
		}
		Label
		{
			id : spoolLengthlabel
            anchors.top: spoolWeightlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Filament length")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:densitylabel.visible
		}
		Label
		{
			anchors.left: spoolLengthlabel.right
			anchors.verticalCenter: spoolLengthlabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: "~ %1 m".arg(Math.round(base.spoolLength))
			verticalAlignment: Qt.AlignVCenter
			height: spoolLengthlabel.height
			visible:densitylabel.visible

		}
		Label
		{
			id : costPerMeterlabel
            anchors.top: spoolLengthlabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;
			text: catalog.i18nc("@label", "Cost per Meter")
			verticalAlignment: Qt.AlignVCenter
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			visible:densitylabel.visible
		}
		Label
		{
			anchors.left: costPerMeterlabel.right
			anchors.verticalCenter: costPerMeterlabel.verticalCenter

			width: 154 * QD.Theme.getSize("size").height;
			text: "~ %1 %2/m".arg(base.costPerMeter.toFixed(2)).arg(base.currency)
			verticalAlignment: Qt.AlignVCenter
			height: costPerMeterlabel.height
			visible:densitylabel.visible
		}
		Label 
		{ 
			id : colorlabel
            anchors.top: namelabel.bottom;
			anchors.topMargin:0.6 * QD.Theme.getSize("default_margin").height
			anchors.left: parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			width: base.width*0.42;

			verticalAlignment: Qt.AlignVCenter; 
			font: QD.Theme.getFont("default")
			renderType: Text.NativeRendering
			text: catalog.i18nc("@label", "Color") 
			visible:namelabel.visible

		}
		Rectangle
		{
			id: colorSelector
			color: base.currentItem !== null ? base.currentItem.color_code : ""
			radius: Math.round(height / 2)
			anchors.left: colorlabel.right
			width: 154 * QD.Theme.getSize("size").height
			height: displayNameTextField.height*0.75
			border.width: QD.Theme.getSize("default_lining").height

			anchors.verticalCenter: colorlabel.verticalCenter
			visible:namelabel.visible

			// open the color selection dialog on click
			MouseArea
			{
				anchors.fill: parent
				onClicked: colorDialog.open()
				enabled: base.editingEnabled
			}
		}
		ColorDialog
		{
			id: colorDialog
			color: base.currentItem!== null ? base.currentItem.color_code : ""
			onAccepted:	
			{
				base.setMetaDataEntry("color_code", base.currentItem.color_code, color)
			}
		}
		Rectangle
		{
			id:materialparam
			anchors.top: colorlabel.bottom;
			anchors.topMargin:QD.Theme.getSize("size").height
			anchors.left:parent.left
			anchors.leftMargin:10*QD.Theme.getSize("size").height
			anchors.right:parent.right
			anchors.bottom : parent.bottom
			anchors.bottomMargin:5*QD.Theme.getSize("size").height
			visible:namelabel.visible

			color: QD.Theme.getColor("white_2")
			ScrollView
			{
				anchors.fill: parent;
				ScrollBar.vertical.policy: ScrollBar.AlwaysOff
				ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
				ListView
				{
					id: sMessageListView
					model: QD.SettingDefinitionsModel
					{
						containerId: QIDI.MachineManager.activeMachine != null ? QIDI.MachineManager.activeMachine.definition.id: "i-fast"
						visibilityHandler: QIDI.MaterialSettingsVisibilityHandler { }
						expanded: ["*"]
						exclude: ["material_bed_temperature_layer_0"]
					}

					delegate: QD.TooltipArea
					{
						width: childrenRect.width
						height: childrenRect.height
						text: model.description
						Label
						{
							id: label
							width: base.width*0.42;
							height: spinBox.height + QD.Theme.getSize("default_lining").height
							text: model.label
							verticalAlignment: Qt.AlignVCenter
							font: QD.Theme.getFont("font1")
							renderType: Text.NativeRendering
						}
						QIDI.ReadOnlySpinBox
						{
							id: spinBox
							anchors.left: label.right
							value:
							{
								// In case the setting is not in the material...
								if (!isNaN(parseFloat(materialPropertyProvider.properties.value)))
								{
									return parseFloat(materialPropertyProvider.properties.value);
								}
								// ... we search in the variant, and if it is not there...
								if (!isNaN(parseFloat(variantPropertyProvider.properties.value)))
								{
									return parseFloat(variantPropertyProvider.properties.value);
								}
								// ... then look in the definition container.
								if (!isNaN(parseFloat(machinePropertyProvider.properties.value)))
								{
									return parseFloat(machinePropertyProvider.properties.value);
								}
								return 0;
							}
							width: 154 * QD.Theme.getSize("size").height
							readOnly: !base.editingEnabled
							suffix: " " + model.unit
							maximumValue: 99999
							decimals: model.unit == "mm" ? 2 : 0

							onEditingFinished: materialPropertyProvider.setPropertyValue("value", value)
						}

						QD.ContainerPropertyProvider
						{
							id: materialPropertyProvider
							containerId: base.containerId
							watchedProperties: [ "value" ]
							key: model.key
						}
						QD.ContainerPropertyProvider
						{
							id: variantPropertyProvider
							containerId: QIDI.MachineManager.activeStack.variant.id
							watchedProperties: [ "value" ]
							key: model.key
						}
						QD.ContainerPropertyProvider
						{
							id: machinePropertyProvider
							containerId: QIDI.MachineManager.activeMachine != null ? QIDI.MachineManager.activeMachine.definition.id: ""
							watchedProperties: [ "value" ]
							key: model.key
						}
					}
				}

			}
        }
    }


    function setMetaDataEntry(entry_name, old_value, new_value)
    {
        if (old_value != new_value)
        {
            QIDI.ContainerManager.setContainerMetaDataEntry(base.currentItem.container_node, entry_name, new_value)
            // make sure the UI properties are updated as well since we don't re-fetch the entire model here
            // When the entry_name is something like properties/diameter, we take the last part of the entry_name
            var list = entry_name.split("/")
            var key = list[list.length - 1]
			QIDI.MachineManager.setMaterialtest(0,"")

        }
    }

    function setMaterialPreferenceValue(material_guid, entry_name, new_value)
    {
        if(!(material_guid in materialPreferenceValues))
        {
            materialPreferenceValues[material_guid] = {};
        }
        if(entry_name in materialPreferenceValues[material_guid] && materialPreferenceValues[material_guid][entry_name] == new_value)
        {
            // value has not changed
            return;
        }
        if (entry_name in materialPreferenceValues[material_guid] && new_value.toString() == 0)
        {
            // no need to store a 0, that's the default, so remove it
            materialPreferenceValues[material_guid].delete(entry_name);
            if (!(materialPreferenceValues[material_guid]))
            {
                // remove empty map
                materialPreferenceValues.delete(material_guid);
            }
        }
        if (new_value.toString() != 0)
        {
            // store new value
            materialPreferenceValues[material_guid][entry_name] = new_value;
        }

        // store preference
        QD.Preferences.setValue("qidi/material_settings", JSON.stringify(materialPreferenceValues));
    }

    function getMaterialPreferenceValue(material_guid, entry_name, default_value)
    {
        if(material_guid in materialPreferenceValues && entry_name in materialPreferenceValues[material_guid])
        {
            return materialPreferenceValues[material_guid][entry_name];
        }
        default_value = default_value | 0;
        return default_value;
    }

    function updateMaterialDisplayName(old_name, new_name)
    {
        // don't change when new name is the same
        if (old_name == new_name)
        {
            return
        }

        // update the values
        base.materialManagementModel.setMaterialName(base.currentItem.container_node, new_name)
    }
	
	function updateCostPerMeter()
	{
		base.spoolLength = base.calculateSpoolLength(diameterSpinBox.value, densitySpinBox.value, spoolWeightSpinBox.value);
		base.costPerMeter = base.calculateCostPerMeter(spoolCostSpinBox.value);
	}
	
	function calculateSpoolLength(diameter, density, spoolWeight)
    {
        if(!diameter)
        {
            diameter = hasCurrentItem ? base.currentItem.diameter ? base.currentItem.diameter : 0 :0
        }
        if(!density)
        {
            density = hasCurrentItem ? base.currentItem.density ? base.currentItem.density : 0 :0
        }
        if(!spoolWeight)
        {
			if(hasCurrentItem)
			{
				spoolWeight = base.getMaterialPreferenceValue(base.currentItem.GUID, "spool_weight", QIDI.ContainerManager.getContainerMetaDataEntry(base.currentItem.id, "properties/weight"));
			}
			else
			{
				spoolWeight = 0
			}
        }

        if (diameter == 0 || density == 0 || spoolWeight == 0)
        {
            return 0;
        }
        var area = Math.PI * Math.pow(diameter / 2, 2); // in mm2
        var volume = (spoolWeight / density); // in cm3
        return volume / area; // in m
    }

    function calculateCostPerMeter(spoolCost)
    {
        if(!spoolCost)
        {
			if(hasCurrentItem)
			{
				spoolCost = base.getMaterialPreferenceValue(base.currentItem.GUID, "spool_cost");
			}
			else
			{
				spoolCost = 0
			}

        }

        if (spoolLength == 0)
        {
            return 0;
        }
        return spoolCost / spoolLength;
    }
	
    onVisibleChanged:
    {

		QIDI.MachineManager.setMaterialtest(0,"")
		QIDIApplication.savesettingbutton()
    }
	


}
