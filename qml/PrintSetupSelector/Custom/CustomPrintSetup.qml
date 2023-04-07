// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls 1.4 as OldControls
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2

import QD 1.3 as QD
import QIDI 1.6 as QIDI

Item
{
    id: customPrintSetup

    property real padding: QD.Theme.getSize("default_margin").width
    property bool multipleExtruders: extrudersModel.count > 1

    property var extrudersModel: QIDIApplication.getExtrudersModel()

    Item
    {
        id: intent
        height: childrenRect.height

        anchors
        {
            top: parent.top
            topMargin: QD.Theme.getSize("default_margin").height
            left: parent.left
            leftMargin: parent.padding
            right: parent.right
            rightMargin: parent.padding
        }

        Label
        {
            id: profileLabel
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: catalog.i18nc("@label", "Profile")
            font: QD.Theme.getFont("font1")
            renderType: Text.NativeRendering
            color: QD.Theme.getColor("black_1")
            verticalAlignment: Text.AlignVCenter
        }

        Button
        {
            id: intentSelection
            onClicked: menu.opened ? menu.close() : menu.open()
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: profileLabel.right
            anchors.leftMargin: 10 * QD.Theme.getSize("size").height
            anchors.right: parent.right
            height: 25 * QD.Theme.getSize("size").height
            hoverEnabled: true

            contentItem: RowLayout
            {
                spacing: 0
                anchors.left: parent.left
                anchors.right: downArrow.left
                anchors.leftMargin: QD.Theme.getSize("default_margin").width

                Label
                {
                    id: textLabel
                    text: QIDI.MachineManager.activeQualityDisplayNameMap["main"]
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    Layout.margins: 0
                    Layout.maximumWidth: Math.floor(parent.width * 0.7)  // Always leave >= 30% for the rest of the row.
                    height: contentHeight
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    elide: Text.ElideRight
                }

                Label
                {
                    text: activeQualityDetailText()
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text_detail")
                    Layout.margins: 0
                    Layout.fillWidth: true

                    height: contentHeight
                    verticalAlignment: Text.AlignVCenter
                    renderType: Text.NativeRendering
                    elide: Text.ElideRight

                    function activeQualityDetailText()
                    {
                        var resultMap = QIDI.MachineManager.activeQualityDisplayNameMap
                        var resultSuffix = resultMap["suffix"]
                        var result = ""

                        if (QIDI.MachineManager.isActiveQualityExperimental)
                        {
                            resultSuffix += " (Experimental)"
                        }

                        if (QIDI.MachineManager.isActiveQualitySupported)
                        {
                            if (QIDI.MachineManager.activeQualityLayerHeight > 0)
                            {
                                if (resultSuffix)
                                {
                                    result += " - " + resultSuffix
                                }
                                result += " - "
                                result += QIDI.MachineManager.activeQualityLayerHeight + "mm"
                            }
                        }

                        return result
                    }
                }
            }

            background: Rectangle
            {
                id: backgroundItem
                border.color: intentSelection.hovered ? QD.Theme.getColor("setting_control_border_highlight") : QD.Theme.getColor("setting_control_border")
                border.width: QD.Theme.getSize("default_lining").width *1.25
                radius: QD.Theme.getSize("default_radius").width
                color: QD.Theme.getColor("main_background")
            }

            QD.RecolorImage
            {
                id: downArrow

                source: QD.Theme.getIcon("ChevronSingleDown")
                width: QD.Theme.getSize("standard_arrow").width
                height: QD.Theme.getSize("standard_arrow").height

                anchors
                {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    rightMargin: QD.Theme.getSize("default_margin").width
                }

                color: QD.Theme.getColor("setting_control_button")
            }
        }

        QualitiesWithIntentMenu
        {
            id: menu
            y: intentSelection.y + intentSelection.height
            x: intentSelection.x
            width: intentSelection.width
        }
    }

    Item
    {
        id: materialItem
        anchors.top: intent.bottom
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.left: intent.left
        anchors.right: intent.right
        height: materialSelection.height
        visible: !multipleExtruders

        Label
        {
            id: meterialLabel
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            text: catalog.i18nc("@label", "Material")
            font: QD.Theme.getFont("font1")
            renderType: Text.NativeRendering
            color: QD.Theme.getColor("black_1")
            verticalAlignment: Text.AlignVCenter
        }
		Item
		{
			id:iconitem
			anchors.left: meterialLabel.right
			anchors.leftMargin:5 * QD.Theme.getSize("size").width
			width: 30 * QD.Theme.getSize("size").width
			height: 30 * QD.Theme.getSize("size").height
			QD.RecolorImage
			{
				id: materialIcon
				anchors.fill: parent

				source: QD.Theme.getIcon("ExtruderSolid", "medium")
				color:extrudersModel.items[0].color
			}
		}

        OldControls.ToolButton
        {
            id: materialSelection
            anchors.left: iconitem.right
            anchors.leftMargin: 5 * QD.Theme.getSize("size").height
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: QIDI.MachineManager.activeStack !== null ? QIDI.MachineManager.activeStack.material.name : ""
            tooltip: text
            height: 25 * QD.Theme.getSize("size").height
            style: QD.Theme.styles.print_setup_header_button
            activeFocusOnPress: true
            onClicked:materialmenu.opened ? materialmenu.close() : materialmenu.open()
        }
		MaterialsWithIntentMenu
		{
			id: materialmenu
			y: materialSelection.y + materialSelection.height
			x: materialSelection.x
			width: materialSelection.width
			extruderIndex: 0
			updateModels: materialSelection.visible
		}
    }
	
	
    QD.TabRow
    {
        id: tabBar

        visible: multipleExtruders
        anchors.top: intent.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height
        anchors.left: parent.left
        anchors.leftMargin: parent.padding
        anchors.right: parent.right
        anchors.rightMargin: parent.padding
        height: 35 * QD.Theme.getSize("size").height
		
        contentItem: ListView
        {
            model: tabBar.contentModel
            currentIndex: tabBar.currentIndex 
			
            spacing: tabBar.spacing
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds
            snapMode: ListView.SnapToItem
            rotation: 180

            highlightMoveDuration: 0
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: 40
            preferredHighlightEnd: width - 40
        }

        Repeater
        {
            id: repeater
            model: extrudersModel
            delegate: QD.TabRowButton
            {
                rotation: 180
                contentItem: Item
                {
                    QIDI.ExtruderIcon
                    {
                        id: extruderIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 5 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: parent.verticalCenter
                        materialColor: model.color
                        extruderEnabled: model.enabled
                        MouseArea
                        {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: colorDialog.open()
                            enabled: model.enabled
                        }
                    }
                    OldControls.ToolButton
                    {
                        id: materialSelection
                        anchors.left: extruderIcon.right
                        anchors.right: parent.right
                        anchors.margins: 5 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.material
                        tooltip: text
                        height: parent.height
                        style: QD.Theme.styles.print_setup_header_button
                        activeFocusOnPress: true
						onClicked:materialmenudouble.opened ? materialmenudouble.close() : materialmenudouble.open()
                    }
					MaterialsWithIntentMenu
					{
						id: materialmenudouble
						y: materialSelection.y + materialSelection.height
						x: materialSelection.width > 150*QD.Theme.getSize("size").width ? materialSelection.x : model.index == 0 ? materialSelection.x + materialSelection.width- 150*QD.Theme.getSize("size").width:materialSelection.x
						width: materialSelection.width > 150*QD.Theme.getSize("size").width ? materialSelection.width :150*QD.Theme.getSize("size").width//materialSelection.width
						extruderIndex: model.index
						updateModels: materialSelection.visible
					}
                    ColorDialog
                    {
                        id: colorDialog
                        title: qsTr(catalog.i18nc("@label", "Choose a color"))
                        color: model.color
                        onAccepted:
                        {
                            QD.Preferences.setValue("color/extruder" + model.index, color.toString())
                            QIDI.MachineManager.setMaterialtest(model.index,"")
                        }
                    }
                }
                onClicked:
                {
                    QIDI.ExtruderManager.setActiveExtruderIndex(tabBar.currentIndex)
                }
            }
        }

        //When active extruder changes for some other reason, switch tabs.
        //Don't directly link currentIndex to QIDI.ExtruderManager.activeExtruderIndex!
        //This causes a segfault in Qt 5.11. Something with VisualItemModel removing index -1. We have to use setCurrentIndex instead.
        Connections
        {
            target: QIDI.ExtruderManager
            function onActiveExtruderChanged()
            {
                tabBar.setCurrentIndex(QIDI.ExtruderManager.activeExtruderIndex);
            }
        }

        //When the model of the extruders is rebuilt, the list of extruders is briefly emptied and rebuilt.
        //This causes the currentIndex of the tab to be in an invalid position which resets it to 0.
        //Therefore we need to change it back to what it was: The active extruder index.
        Connections
        {
            target: repeater.model
            function onModelChanged()
            {
                tabBar.setCurrentIndex(QIDI.ExtruderManager.activeExtruderIndex)
            }
        }
    }

	Rectangle
	{
		anchors.bottom: tabBar.bottom
		anchors.left: parent.left
		width: (parent.width - tabBar.width)/2
		height:  2*QD.Theme.getSize("size").height
		color: QD.Theme.getColor("blue_2")
		visible: multipleExtruders
	}
	
	Rectangle
	{
		anchors.bottom: tabBar.bottom
		anchors.right: parent.right
		width: (parent.width - tabBar.width)/2 +2*QD.Theme.getSize("size").width
		height:  2*QD.Theme.getSize("size").height
		color: QD.Theme.getColor("blue_2")
		visible: multipleExtruders
	}
	
	Rectangle
	{
		anchors.bottom: tabBar.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		width:	QD.Theme.getSize("narrow_margin").width + 3*QD.Theme.getSize("size").width
		height:  2*QD.Theme.getSize("size").height 
		color: QD.Theme.getColor("blue_2")
		visible: multipleExtruders
	}
	
    Rectangle
    {
        anchors
        {
            top: tabBar.visible ? tabBar.bottom : materialItem.bottom
            topMargin: tabBar.visible ? -QD.Theme.getSize("size").height : 5 * QD.Theme.getSize("size").height
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        z: tabBar.z - 1
        color: QD.Theme.getColor("white_1")

        QIDI.SettingView
        {
			id:settingview
            anchors
            {
                fill: parent
                topMargin: QD.Theme.getSize("default_margin").height
                bottomMargin: 20*QD.Theme.getSize("default_lining").width
            }
        }
		Rectangle
		{
			id:block
			anchors.top: settingview.bottom
			anchors.left: parent.left
			anchors.leftMargin: (parent.width-60*QD.Theme.getSize("size").width)/2 
			height: 10*QD.Theme.getSize("size").height
			width :QIDI.ExtruderManager.activeExtruderIndex == 1 ? 40*QD.Theme.getSize("size").width : 20*QD.Theme.getSize("size").width
			radius: 5*QD.Theme.getSize("size").height
			color: (QIDI.ExtruderManager.activeExtruderIndex == 1 && multipleExtruders )? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_3")
			MouseArea
			{
				anchors.fill: parent
				onClicked: QIDI.ExtruderManager.setActiveExtruderIndex(1)
			}
			visible: multipleExtruders
		}
		
		Rectangle
		{
			anchors.top: settingview.bottom
			anchors.left: block.right
			anchors.leftMargin: 5 * QD.Theme.getSize("size").width
			height: 10*QD.Theme.getSize("size").height
			width :QIDI.ExtruderManager.activeExtruderIndex == 0 ? 40*QD.Theme.getSize("size").width : 20*QD.Theme.getSize("size").width
			radius: 5*QD.Theme.getSize("size").height
			color: (QIDI.ExtruderManager.activeExtruderIndex == 0 && multipleExtruders )? QD.Theme.getColor("blue_6") : QD.Theme.getColor("gray_3")
			MouseArea
			{
				anchors.fill: parent
				onClicked: QIDI.ExtruderManager.setActiveExtruderIndex(0)
			}
			visible: multipleExtruders
		}
    }
}
