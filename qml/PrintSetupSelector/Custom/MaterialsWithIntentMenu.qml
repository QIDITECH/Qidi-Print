// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.6 as QIDI

Popup
{
    id: popup
    implicitWidth: 400
    property var dataModel: QIDI.IntentCategoryModel {}

    property int defaultMargin: QD.Theme.getSize("default_margin").width
    property color backgroundColor: QD.Theme.getColor("main_background")
    property color borderColor: QD.Theme.getColor("lining")

    topPadding: QD.Theme.getSize("narrow_margin").height
    rightPadding: QD.Theme.getSize("default_lining").width
    leftPadding: QD.Theme.getSize("default_lining").width

    property int extruderIndex: 0
    property bool updateModels: true


    property string currentRootMaterialId:
    {
        var value = QIDI.MachineManager.currentRootMaterialId[extruderIndex]
        return (value === undefined) ? "" : value
    }

    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    background: QIDI.RoundedRectangle
    {
        color: backgroundColor
        border.width: QD.Theme.getSize("default_lining").width
        border.color: borderColor
        cornerSide: QIDI.RoundedRectangle.Direction.Down
    }

    ButtonGroup
    {
        id: buttonGroup
        exclusive: true
        onClicked: popup.visible = false
    }

    QIDI.MaterialBrandsModel
    {
        id: brandModel
        extruderPosition: popup.extruderIndex
        enabled: updateModels
    }
	
    QIDI.GenericMaterialsModel
    {
        id: genericMaterialsModel
        extruderPosition: popup.extruderIndex
        enabled: updateModels
    }
	QIDI.MaterialUsersModel
    {
        id: userModel
        extruderPosition: popup.extruderIndex
        enabled: updateModels
    }

    contentItem: Column
    {
        // This repeater adds the intent labels
        ScrollView
        {
            property real maximumHeight: screenScaleFactor * 400
            contentHeight: brandMaterialColumn.height 
            height: Math.min(contentHeight, maximumHeight)
            clip: true

            ScrollBar.vertical.policy: height == maximumHeight ? ScrollBar.AlwaysOn: ScrollBar.AlwaysOff

            Column
            {
                id: brandMaterialColumn
                width: parent.width
				Item
				{
					// We need to set it like that, otherwise we'd have to set the sub model with model: model.qualities
					// Which obviously won't work due to naming conflicts.
					// property variant subItemModel: model.qualities

					height: childrenRect.height
					width: popup.contentWidth > 150*QD.Theme.getSize("size").width ? popup.contentWidth :150*QD.Theme.getSize("size").width

					Label
					{
						id: headerLabel
						text: "QIDI"
						color: QD.Theme.getColor("text_inactive")
						renderType: Text.NativeRendering
						width: parent.width > 150*QD.Theme.getSize("size").width ? parent.width :150*QD.Theme.getSize("size").width
						height: visible ? contentHeight: 0
						visible: qualitiesList.visibleChildren.length > 0
						anchors.left: parent.left
						anchors.leftMargin: QD.Theme.getSize("default_margin").width
					}

					Column
					{
						id: qualitiesList
						anchors.top: headerLabel.bottom
						anchors.left: parent.left
						anchors.right: parent.right

						// Add the qualities that belong to the intent
						Repeater
						{
							visible: false
							model: brandModel
							MenuButton
							{
								id: button

								onClicked: QIDI.MachineManager.setMaterial(extruderIndex, model.container_node)//QIDI.IntentManager.selectIntent(model.intent_category, model.quality_type)

								width: parent.width > 150*QD.Theme.getSize("size").width ? parent.width :150*QD.Theme.getSize("size").width
								checkable: true
								visible: true
								text: model.name
								checked:model.root_material_id === popup.currentRootMaterialId
								ButtonGroup.group: buttonGroup
							}
						}
					}
				}
				Item
				{
					// We need to set it like that, otherwise we'd have to set the sub model with model: model.qualities
					// Which obviously won't work due to naming conflicts.
					// property variant subItemModel: model.qualities

					height: childrenRect.height
					width: popup.contentWidth > 150*QD.Theme.getSize("size").width ? popup.contentWidth :150*QD.Theme.getSize("size").width

					Label
					{
						id: genericheaderLabel
						text: "Generic"
						color: QD.Theme.getColor("text_inactive")
						renderType: Text.NativeRendering
						width: parent.width > 150*QD.Theme.getSize("size").width ? parent.width :150*QD.Theme.getSize("size").width
						height: visible ? contentHeight: 0
						visible: genericqualitiesList.visibleChildren.length > 0
						anchors.left: parent.left
						anchors.leftMargin: QD.Theme.getSize("default_margin").width
					}

					Column
					{
						id: genericqualitiesList
						anchors.top: genericheaderLabel.bottom
						anchors.left: parent.left
						anchors.right: parent.right

						// Add the qualities that belong to the intent
						Repeater
						{
							visible: false
							model: genericMaterialsModel
							MenuButton
							{
								id: button

								onClicked: QIDI.MachineManager.setMaterial(extruderIndex, model.container_node)//QIDI.IntentManager.selectIntent(model.intent_category, model.quality_type)

								width: parent.width > 150*QD.Theme.getSize("size").width ? parent.width :150*QD.Theme.getSize("size").width
								checkable: true
								visible: true
								text: model.name
								checked:model.root_material_id === popup.currentRootMaterialId
								ButtonGroup.group: buttonGroup
							}
						}
					}
				}
				Item
				{
					// We need to set it like that, otherwise we'd have to set the sub model with model: model.qualities
					// Which obviously won't work due to naming conflicts.
					// property variant subItemModel: model.qualities

					height: childrenRect.height
					width: popup.contentWidth > 150*QD.Theme.getSize("size").width ? popup.contentWidth :150*QD.Theme.getSize("size").width

					Label
					{
						id: userheaderLabel
						text: "User"
						color: QD.Theme.getColor("text_inactive")
						renderType: Text.NativeRendering
						width: parent.width > 150*QD.Theme.getSize("size").width ? parent.width :150*QD.Theme.getSize("size").width
						height: visible ? contentHeight: 0
						visible: userqualitiesList.visibleChildren.length > 0
						anchors.left: parent.left
						anchors.leftMargin: QD.Theme.getSize("default_margin").width
					}

					Column
					{
						id: userqualitiesList
						anchors.top: userheaderLabel.bottom
						anchors.left: parent.left
						anchors.right: parent.right

						// Add the qualities that belong to the intent
						Repeater
						{
							visible: false
							model: userModel
							MenuButton
							{
								id: userbutton

								onClicked: QIDI.MachineManager.setMaterial(extruderIndex, model.container_node)//QIDI.IntentManager.selectIntent(model.intent_category, model.quality_type)

								width: parent.width > 150*QD.Theme.getSize("size").width ? parent.width :150*QD.Theme.getSize("size").width
								checkable: true
								visible: true
								text: model.name
								checked:model.root_material_id === popup.currentRootMaterialId
								ButtonGroup.group: buttonGroup
							}
						}
					}
				}
                //Another "intent category" for custom profiles.
            }
        }

        Rectangle
        {
            height: QD.Theme.getSize("default_lining").height
            anchors.left: parent.left
            anchors.right: parent.right
            color: borderColor
        }

        MenuButton
        {
            text: catalog.i18nc("@action:button", "Manage Materials")
            anchors.left: parent.left
            anchors.right: parent.right
            onClicked:
            {
				forceActiveFocus();
				QIDIApplication.showCreateMaterial()
            }
        }
    }
}
