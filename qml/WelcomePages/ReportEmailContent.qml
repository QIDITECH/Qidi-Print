// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
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
	property string curentmachine : "i-fast"
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
                // imagelabel.text = machineList.model.getItem(i).name
				curentmachine = machineList.model.getItem(i).name
				QIDIApplication.setMachineEmail(curentmachine)
				QIDIApplication.setMachineSkype(curentmachine)

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

    Component.onCompleted:
    {
        updateCurrentItemUponSectionChange()
    }

    height: image.height

    color: QD.Theme.getColor("white_2")
    Label
    {
        id: titleLabel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: catalog.i18nc("@label", "Printer after-sales email")
        color: QD.Theme.getColor("primary_button")
        font: QD.Theme.getFont("huge")
        renderType: Text.NativeRendering
    }
	TextArea
	{
		id: notelabel
		anchors.top: titleLabel.bottom
		anchors.topMargin:0.2*QD.Theme.getSize("wide_margin").height
		anchors.left: species.left
		// anchors.leftMargin:10*QD.Theme.getSize("size").height
		anchors.right: parent.right
		text: catalog.i18nc("@label", "If you have any questions or questions about the printer, please contact us via the appropriate email address or Skype.")
		font: QD.Theme.getFont("large")
		color: QD.Theme.getColor("text")
		textFormat: Text.AutoText
		//renderType: Text.NativeRendering
		wrapMode: Text.WordWrap
		readOnly: true
		selectByMouse: true
	}

	Rectangle
	{
		id:titile
		anchors.top:notelabel.bottom
		anchors.left:parent.left
		anchors.right:parent.right
		height:30*QD.Theme.getSize("size").height
		color:QD.Theme.getColor("gray_14")

	}

	Rectangle
	{
		id:species
		anchors.top:notelabel.bottom
		// anchors.left:parent.left
        width : parent.width/16//40 *QD.Theme.getSize("size").height
		anchors.bottom:image.bottom
        anchors.right:machineListrec.left
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
		anchors.top:notelabel.bottom
		anchors.right:parent.right
		anchors.bottom:image.bottom
		width: parent.width*25/64//250 * QD.Theme.getSize("size").width
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
                text: catalog.i18nc("@label", "SKYPE")
                color: QD.Theme.getColor("blue_6")
                // font.bold: true
            }
        }
		ListView{
			id: deviceViewSkype
            anchors.left:parent.left
            anchors.leftMargin:5*QD.Theme.getSize("size").width
            anchors.right:parent.right
            anchors.top:descriptiontitle.bottom
            anchors.bottom:parent.bottom
			model: QIDIApplication.getMachineSkype
			delegate: deviceViewSkypeDelegate
			interactive: false
			focus: true
			clip:true
			
		}
		Component{
			id: deviceViewSkypeDelegate
			Rectangle
    		{
				anchors.left:parent.left
				anchors.right:parent.right
				anchors.margins:3*QD.Theme.getSize("size").width
				TextArea
				{

					id:skypeText
					// anchors.verticalCenter:parent
					text: QIDIApplication.getMachineSkype[index]
					font: QD.Theme.getFont("font1")
					color: QD.Theme.getColor("text")
					readOnly: true
					selectByMouse: true
				}
                Button
                {
                    id:copyButton
                    anchors.right: parent.right
                    // anchors.rightMargin:10*QD.Theme.getSize("size").width
                    anchors.top:parent.top
                    anchors.topMargin:5*QD.Theme.getSize("size").width
                    width : 15 *QD.Theme.getSize("size").width
                    height : 15 *QD.Theme.getSize("size").width
                    onClicked: {
                        QIDIApplication.set_clipboard(skypeText.text)
                    }
                    contentItem: Item
                    {
                        anchors.fill: parent
                        QD.RecolorImage
                        {
                            id: buttonIcon
                            anchors.centerIn: parent
                            source:QD.Theme.getIcon("copy-solid","default")
                            width:  copyButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                            height: copyButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                            color: copyButton.pressed ? QD.Theme.getColor("black_1") : QD.Theme.getColor("blue_6") 
                        }
                    }

                    background: Rectangle
                    {
                        id: background
                        anchors.centerIn: parent
                        height: parent.height
                        width: parent.height
                        color: QD.Theme.getColor("white_2")
                    }
                }
		}
		}

	}
    Rectangle
    {
        id: image
        anchors.right: description.left
        anchors.rightMargin:-QD.Theme.getSize("size").width
        anchors.top: notelabel.bottom
        height: parent.width*25/64+titile.height + 110 * QD.Theme.getSize("size").width -notelabel2.height //250 * QD.Theme.getSize("size").width+titile.height
        // anchors.bottom:notelabel2.top
        // anchors.bottomMargin:0.5*QD.Theme.getSize("wide_margin").height
        width: parent.width*25/64//250 * QD.Theme.getSize("size").width
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
                // font.pointSize: 12
                font:QD.Theme.getFont("large_bold")

                anchors.centerIn: parent
                text: catalog.i18nc("@label", "E-mail")
                color: QD.Theme.getColor("blue_6")
                // font.bold: true
            }
        }
		ListView{
			id: deviceView
            anchors.left:parent.left
            anchors.leftMargin:5*QD.Theme.getSize("size").width
            anchors.right:parent.right
            anchors.top:imagetitle.bottom
            anchors.bottom:parent.bottom
			model: QIDIApplication.getMachineEmail
			delegate: deviceViewDelegate
			interactive: false
			focus: true
			clip:true
			
		}

		Component{
			id: deviceViewDelegate

			

			Rectangle
			{
				anchors.left:parent.left
				height: 30 * QD.Theme.getSize("size").height
				anchors.right:parent.right
				anchors.margins:3*QD.Theme.getSize("size").width
				TextArea
				{
					id:emailText
					text: QIDIApplication.getMachineEmail[index]
					font: QD.Theme.getFont("font1")
					color: QD.Theme.getColor("text")
					textFormat: Text.AutoText
					wrapMode: Text.WordWrap
					readOnly: true
					selectByMouse: true
				}
                Button
                {
                    id:copyButton
                    anchors.right: parent.right
                    // anchors.rightMargin:20*QD.Theme.getSize("size").width
                    anchors.top:parent.top
                    anchors.topMargin:5*QD.Theme.getSize("size").width
                    width : 15 *QD.Theme.getSize("size").width
                    height : 15 *QD.Theme.getSize("size").width
                    onClicked: {
                        QIDIApplication.set_clipboard(emailText.text)
                    }
                    contentItem: Item
                    {
                        anchors.fill: parent
                        QD.RecolorImage
                        {
                            id: buttonIcon
                            anchors.centerIn: parent
                            source:QD.Theme.getIcon("copy-solid","default")
                            width:  copyButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                            height: copyButton.hovered ? parent.height + 2 * QD.Theme.getSize("size").height : parent.height
                            color: copyButton.pressed ? QD.Theme.getColor("black_1") : QD.Theme.getColor("blue_6") 
                        }
                    }

                    background: Rectangle
                    {
                        id: background
                        anchors.centerIn: parent
                        height: parent.height
                        width: parent.height
                        color: QD.Theme.getColor("white_2")
                    }
                }
			}
		}
	}
    Rectangle
    {
        id:machineListrec
        anchors.top: notelabel.bottom
        width: parent.width*10/64//100 * QD.Theme.getSize("size").height
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

	TextArea
	{
		id:notelabel2
		anchors.left: parent.left
		anchors.leftMargin:10*QD.Theme.getSize("size").height
        width:parent.width*45/64//450*QD.Theme.getSize("size").width
		anchors.top: machineListrec.bottom
		anchors.topMargin:0.5*QD.Theme.getSize("wide_margin").height
        // anchors.bottom : parent.bottom
        // anchors.bottomMargin:0.5*QD.Theme.getSize("wide_margin").height
		text: catalog.i18nc("@label", "  Note: please try to tell us your requirements in the form of video or pictures, and provide 3MF file, G-code file, software log, machine number and other necessary information")
		font: QD.Theme.getFont("large")
		color:"red"
		textFormat: Text.AutoText
		wrapMode: Text.WordWrap
		readOnly: true
		selectByMouse: true
	}
	QIDI.PrimaryButton
	{
		id: radioButton
        anchors.verticalCenter:notelabel2.verticalCenter
        height : parent.height * 4/50
		anchors.right: parent.right
        
		text: catalog.i18nc("@label","Open Configuration")
		onClicked: {
			var path = QD.Resources.getPath(QD.Resources.Preferences, "");
            if(Qt.platform.os == "windows")
            {
                path = path.replace(/\\/g,"/");
            }
            Qt.openUrlExternally(path);
            if(Qt.platform.os == "linux")
            {
                Qt.openUrlExternally(QD.Resources.getPath(QD.Resources.Resources, ""));
            }
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
            hot:false
            onClicked: {
                ListView.view.currentIndex = index
                // imagelabel.text = atext
				curentmachine = atext
				QIDIApplication.setMachineEmail(curentmachine)
				QIDIApplication.setMachineSkype(curentmachine)

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
