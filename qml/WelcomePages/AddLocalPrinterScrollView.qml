// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4//2.3
import QD 1.3 as QD
import QIDI 1.1 as QIDI
import QtGraphicalEffects 1.0


//
// This is the scroll view widget for adding a (local) printer. This scroll view shows a list view with printers
// categorized into 3 categories: "QIDI", "Custom", and "Other".
//
Rectangle
{
    id: base

    // The currently selected machine item in the local machine list.
    property var currentItem: (machineList.currentIndex >= 0)
                              ? machineList.model.getItem(machineList.currentIndex)
                              : null
    // The currently active (expanded) section/category, where section/category is the grouping of local machine items.
    property string currentSection: "i-series"
    // By default (when this list shows up) we always expand the "QIDI" section.
    property var preferredCategories: {
        "QIDI B.V.": -2,
        "Custom": -1
    }

    function updateCurrentItemUponSectionChange()
    {
        // Find the first machine from this section
        for (var i = 0; i < machineList.count; i++)
        {
            var item = machineList.model.getItem(i)
            if (item.section == base.currentSection)
            {
                machineList.currentIndex = i
                imagelabel.text = machineList.model.getItem(i).name
                QIDIApplication.setMachineDescription(imagelabel.text)
                break
            }
        }
    }

    function getMachineName()
    {
        return machineList.model.getItem(machineList.currentIndex) != undefined ? machineList.model.getItem(machineList.currentIndex).name : "";
    }

    function getMachineMetaDataEntry(key)
    {
        var metadata = machineList.model.getItem(machineList.currentIndex) != undefined ? machineList.model.getItem(machineList.currentIndex).metadata : undefined;
        if (metadata)
        {
            return metadata[key];
        }
        return undefined;
    }

    function getMachineMetaDataEntryWithIndex(index,key)
    {
        var metadata = machineList.model.getItem(index) != undefined ? machineList.model.getItem(index).metadata : undefined;
        if (metadata)
        {
            return metadata[key];
        }
        return undefined;
    }

    Component.onCompleted:
    {
        updateCurrentItemUponSectionChange()
    }

    height: image.height

    color: QD.Theme.getColor("white_2")
	Rectangle
	{
		id:titile
		anchors.top:parent.top
		anchors.left:parent.left
		anchors.right:parent.right
		height:30*QD.Theme.getSize("size").height
		color:QD.Theme.getColor("gray_14")

	}

	Rectangle
	{
		id:species
		anchors.top:parent.top
		//anchors.left:parent.left
		anchors.bottom:image.bottom
        anchors.right:machineListrec.left
        width:parent.width*4/59//40*QD.Theme.getSize("size").height
		color:QD.Theme.getColor("blue_6")
        ListView
        {
            anchors.top:parent.top
            anchors.topMargin: 10*QD.Theme.getSize("size").height
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.bottom:parent.bottom
            cacheBuffer: 0
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 20000  // To prevent the flicking behavior.
            model: QD.DefinitionContainersModel
            {
                filter: { "visible": true }
                sectionProperty: "manufacturer"
                preferredSections: preferredCategories
            }

            section.property: "section"
            section.delegate: sectionHeader
            delegate: machineButton2
        }

	}
	Rectangle
	{
		id:description
		anchors.top:parent.top
		anchors.right:parent.right
		anchors.bottom:image.bottom
		width: parent.width*20/59//200 * QD.Theme.getSize("size").width
		border.width: QD.Theme.getSize("size").width
		border.color: QD.Theme.getColor("gray_13")
		color:QD.Theme.getColor("white_2")
        Rectangle
        {
            id:descriptiontitle
            anchors.top: parent.top
            anchors.left:parent.left
            anchors.right:parent.right
            height:titile.height
            border.width: QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("gray_13")
            color:titile.color

            Text
            {
                font:QD.Theme.getFont("large_bold")
                anchors.centerIn: parent
                text: catalog.i18nc("@label", "description")
                color: QD.Theme.getColor("blue_6")
            }
        }
		ListView{
			id: deviceViewDescription
            anchors.left:parent.left
            anchors.leftMargin:5*QD.Theme.getSize("size").width
            anchors.right:parent.right
            anchors.top:descriptiontitle.bottom
            anchors.topMargin: 8*QD.Theme.getSize("size").height
            anchors.bottom:parent.bottom
            anchors.bottomMargin: QD.Theme.getSize("size").height
			model: QIDIApplication.getMachineDescription
			delegate: deviceViewDescriptionDelegate
            cacheBuffer: 0
			clip:true
            spacing: 3 * QD.Theme.getSize("size").height
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 20000  // To prevent the flicking behavior.
		}


	}
    Component{
        id: deviceViewDescriptionDelegate
        Rectangle
        {
            anchors.left:parent.left
            height: index == 0 ? buttonText.height : 15 * QD.Theme.getSize("size").height
            anchors.right:parent.right
            anchors.margins:5*QD.Theme.getSize("size").width
            // Label
            // {
            //     anchors.left:parent.left
            //     anchors.leftMargin:5*QD.Theme.getSize("size").width
            //     anchors.right:parent.right
            //     anchors.top:descriptiontitle.bottom
            //     anchors.topMargin: 8*QD.Theme.getSize("size").height
            //     id: descriptionText
            //     font: QD.Theme.getFont("font1")
            //     text: QIDIApplication.getMachineDescriptiontext(imagelabel.text)
            //     wrapMode: Text.WrapAnywhere
            //     visible: index == 0
            //     clip :true
            // }
            Rectangle
            {
                id:circleText
                anchors.top:parent.top
                anchors.topMargin:5*QD.Theme.getSize("size").width
                height:8*QD.Theme.getSize("size").width
                width:8*QD.Theme.getSize("size").width
                color: QD.Theme.getColor("text")
                border.width:QD.Theme.getSize("size").width
                border.color:QD.Theme.getColor("text")
                radius:10
                visible: !(index == 0)
            }
            Label
            {
                anchors.left: circleText.right
                anchors.leftMargin:index == 0 ?  -5*QD.Theme.getSize("size").width : 10*QD.Theme.getSize("size").width
                anchors.right:parent.right
                id: buttonText
                font: QD.Theme.getFont("font1")
                text: QIDIApplication.getMachineDescription[index]
                clip :true
                wrapMode: Text.Wrap;
                textFormat: Text.RichText
            }
        }   
    }
    Rectangle
    {
        id: image
        anchors.right: description.left
        anchors.rightMargin:-QD.Theme.getSize("size").width
        anchors.top: parent.top
        height: parent.width*25/59+titile.height//250 * QD.Theme.getSize("size").width+titile.height
        width: parent.width*25/59//250 * QD.Theme.getSize("size").width
		border.width: QD.Theme.getSize("size").width
		border.color: QD.Theme.getColor("gray_13")
        Rectangle
        {
            id:imagetitle
            anchors.top: parent.top
            anchors.left:parent.left
            anchors.right:parent.right
            height:titile.height
            border.width: QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("gray_13")
            color:titile.color

            Text
            {
                id:imagelabel
                font:QD.Theme.getFont("large_bold")
                anchors.centerIn: parent
                text: catalog.i18nc("@label", "i-fast")
                color: QD.Theme.getColor("blue_6")
                // font.bold: true
            }
        }
        Image
        {
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:imagetitle.bottom
            anchors.bottom:parent.bottom
            source: QD.Theme.getIcon(base.getMachineName())
        }
    }

    Rectangle
    {
        id:machineListrec
        anchors.top: parent.top
        width: parent.width*10/59//100 * QD.Theme.getSize("size").height
        anchors.right: image.left
        anchors.rightMargin:-QD.Theme.getSize("size").width
        anchors.bottom: image.bottom
		border.width: QD.Theme.getSize("size").width
		border.color: QD.Theme.getColor("gray_13")
        Rectangle
        {
            id:kindtitle
            anchors.top: parent.top
            anchors.left:parent.left
            anchors.right:parent.right
            height:titile.height
            border.width: QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("gray_13")
            color:titile.color

            Text
            {
                // font.pointSize: 12
                font:QD.Theme.getFont("large_bold")
                anchors.centerIn: parent
                text: base.currentSection
                color: QD.Theme.getColor("blue_6")
                // font.bold: true
            }
        }
        ListView
        {
            id: machineList
            anchors.left:parent.left
            anchors.leftMargin: QD.Theme.getSize("size").height
            anchors.right:parent.right
            anchors.rightMargin: QD.Theme.getSize("size").height
            anchors.top:kindtitle.bottom
            anchors.bottom:parent.bottom
            anchors.bottomMargin: QD.Theme.getSize("size").height
            cacheBuffer: 0
            clip:true
            spacing: 3 * QD.Theme.getSize("size").height
            boundsBehavior: Flickable.StopAtBounds
            flickDeceleration: 20000  // To prevent the flicking behavior.
            model: QD.DefinitionContainersModel
            {
                id: machineDefinitionsModel
                filter: { "visible": true }
                sectionProperty: "manufacturer"
                preferredSections: preferredCategories
            }
            delegate: machineButton
        }
    }


    Component
    {
        id: sectionHeader
        QD.RecolorImageWithRec{
            width: species.width//50*QD.Theme.getSize("size").width
            height: species.width
            anchors.horizontalCenter: parent.horizontalCenter
            source:QD.Theme.getIcon(section[0],"default")
            color: base.currentSection == section ? QD.Theme.getColor("blue_9") : QD.Theme.getColor("blue_6")
            color2: base.currentSection == section ? QD.Theme.getColor("white_1"):QD.Theme.getColor("gray_11")
            MouseArea {
               anchors.fill: parent
               hoverEnabled: true
                onExited:  oncover = false
                onEntered: oncover = true
                onClicked:
                {
                    base.currentSection = section
                    base.updateCurrentItemUponSectionChange()
                }
            }

        }
    }



    Component
    {
        id: machineButton

        ButtonComponent
        {
            id: radioButton
            width:parent.width
            height: visible ? 20 : -3*QD.Theme.getSize("size").height
            checked: ListView.view.currentIndex == index
            atext: name
            textColor: QD.Theme.getColor("blue_6")
            visible: base.currentSection == section
            hot:getMachineMetaDataEntryWithIndex(index,"hot") != undefined ? getMachineMetaDataEntryWithIndex(index,"hot"):false
            onClicked: {
                // console.log(getMachineMetaDataEntryWithIndex(index,"hot"))
                ListView.view.currentIndex = index
                imagelabel.text = atext
                QIDIApplication.setMachineDescription(atext)

            }
        }
    }
    Component
    {
        id: machineButton2

        Button
        {
            id: radioButton
            anchors.left: sectionHeader.right
            anchors.right: parent.right
            height: visible ? QD.Theme.getSize("standard_list_lineheight").height : 0

            checked: ListView.view.currentIndex == index
            text: name
            visible: false
            onClicked: ListView.view.currentIndex = index
        }
    }
}
