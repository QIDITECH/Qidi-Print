import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 //ExclusiveGroup

import QD 1.3 as QD
import QIDI 1.1 as QIDI

Item
{
    id: filebase
    height: parent.height
    width: parent.width 
    //property int progress
	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}
	
    Rectangle
    {
        id: machineActionsRow
        height: 40 * QD.Theme.getSize("size").height
        //anchors.top: parent.top
        anchors.top :progressBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").height
        //为了让边框不被覆盖
        color: QD.Theme.getColor("blue_7")

        Row
        {
            id: machineActions
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width / 40  //15 * QD.Theme.getSize("size").height / QD.Preferences.getValue("qidi/size") 
            height: 25 * QD.Theme.getSize("size").height
            width: parent.width
            spacing: parent.width / 20 
			
            QIDI.ActionButtonInControlpanel
            {
                id: printButton
                height: parent.height
                width: parent.width / 5 
                color: printButton.enabled ? QD.Theme.getColor("blue_3") : QD.Theme.getColor("gray_2")
                hoverColor: QD.Theme.getColor("blue_3")
                text: catalog.i18nc("@button", "Print")
                textFont: QD.Theme.getFont("font1")
                textColor: QD.Theme.getColor("white_1")
                backgroundRadius: Math.round(height / 2)
                leftPadding: 30 * QD.Theme.getSize("size").height
                fixedWidthMode: true
                iconSource: QD.Theme.getIcon("Printing","plugin")
				sourceSize : QD.Theme.getSize("action_button_icon")
				enabled:controlpanel.connectionState > 1 && fileList.currentItem.boxchecked && !controlpanel.isPrinting && !controlpanel.isPause
                onClicked: 
                {
					controlpanel.printSDFiles(fileList.currentItem.selectedFileName +"."+ fileList.currentItem.selectedFileType)
                }
            }

            QIDI.ActionButtonInControlpanel
            {
                id: pauseButton
                height: parent.height
                width: parent.width / 5 
                color: pauseButton.enabled ? QD.Theme.getColor("blue_3") : QD.Theme.getColor("gray_2")
                hoverColor: QD.Theme.getColor("blue_3")
                text: catalog.i18nc("@button", "Pause")
                textFont: QD.Theme.getFont("font1")
                textColor: QD.Theme.getColor("white_1")
                backgroundRadius: Math.round(height / 2)
                leftPadding: 30 * QD.Theme.getSize("size").height
                fixedWidthMode: true
                iconSource: QD.Theme.getIcon("Pause","plugin")
				sourceSize : QD.Theme.getSize("action_button_icon")
                enabled: controlpanel.connectionState > 1 && controlpanel.isPrinting
                onClicked:
                {
                    controlpanel.pausePrint()
                }
            }

            QIDI.ActionButtonInControlpanel
            {
                id: continueButton
                height: parent.height
                width: parent.width / 5 
                color: continueButton.enabled ? QD.Theme.getColor("blue_3") : QD.Theme.getColor("gray_2")
                hoverColor: QD.Theme.getColor("blue_3")
                text: catalog.i18nc("@button", "Continue")
                textFont: QD.Theme.getFont("font1")
                textColor: QD.Theme.getColor("white_1")
                backgroundRadius: Math.round(height / 2)
                leftPadding: 30 * QD.Theme.getSize("size").height
                fixedWidthMode: true
                iconSource: QD.Theme.getIcon("Continue","plugin")
				sourceSize : QD.Theme.getSize("action_button_icon")
                enabled: controlpanel.connectionState > 1 && controlpanel.isPause //stateconrotl == "Pause" 
                onClicked:
                {
                    controlpanel.continuePrint()
                }
            }

            QIDI.ActionButtonInControlpanel
            {
                id: stopPrintButton
                height: parent.height
                width: parent.width / 5 
                color: stopPrintButton.enabled ? QD.Theme.getColor("blue_3") : QD.Theme.getColor("gray_2")
                hoverColor: QD.Theme.getColor("blue_3")
                text: catalog.i18nc("@button", "Stop")
                textFont: QD.Theme.getFont("font1")
                textColor: QD.Theme.getColor("white_1")
                backgroundRadius: Math.round(height / 2)
				sourceSize : QD.Theme.getSize("action_button_icon")
                leftPadding: 30 * QD.Theme.getSize("size").height
                fixedWidthMode: true
                iconSource: QD.Theme.getIcon("Stop2","plugin")
                enabled: controlpanel.connectionState > 1 && (controlpanel.isPrinting || controlpanel.isPause) //stateconrotl == "Printing"
                onClicked:
				{
                    controlpanel.cancelPrint()
				}
            }
        }
    }

    Rectangle
    {
        id: fileActionsTopLine
        height: QD.Theme.getSize("size").height
        anchors.top: machineActionsRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 0
        anchors.margins: QD.Theme.getSize("size").height
        color: QD.Theme.getColor("gray_2")
    }

    QD.ProgressBar
    {
        id: progressBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 7 * QD.Theme.getSize("size").height
        value: 0//CBDConnect.progressinsend / 100 | 0//controlpanel.progressinsend
        //indeterminate: widget.backendState == QD.Backend.NotStarted
    }


    Rectangle
    {
        id: fileActionsItem
        height: 40 * QD.Theme.getSize("size").height
        anchors.top: fileActionsTopLine.bottom
        anchors.left: parent.left
        anchors.right: parent.right        
        anchors.margins: QD.Theme.getSize("size").height
        //anchors.margins: QD.Theme.getSize("size").height



        Row
        {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width / 40  //15 * QD.Theme.getSize("size").height / QD.Preferences.getValue("qidi/size") 
            height: 25 * QD.Theme.getSize("size").height
            width: parent.width
            spacing: parent.width / 20 

            QIDI.ActionButtonInControlpanel
            {
                id: uploadButton
                height: parent.height
                width: parent.width / 5 
                color: uploadButton.enabled ? QD.Theme.getColor("white_1") : QD.Theme.getColor("gray_2")
                hoverColor: QD.Theme.getColor("white_1")
                outlineColor: QD.Theme.getColor("gray_3")
                outlineHoverColor: QD.Theme.getColor("blue_3")
                text: catalog.i18nc("@button", "Upload")
                textFont: QD.Theme.getFont("font1")
                textColor: QD.Theme.getColor("black_1")
                textHoverColor: QD.Theme.getColor("blue_3")
                backgroundRadius: Math.round(height / 3)
                // anchors.horizontalCenter : printButton.horizontalCenter
                leftPadding: 30 * QD.Theme.getSize("size").height
                fixedWidthMode: true
                iconSource: QD.Theme.getIcon("Upload","plugin")
				sourceSize : QD.Theme.getSize("action_button_icon")
                onClicked: 
                {
                    //controlpanel.setCustomControlCmd("FileUpload")
                    controlpanel.selectFileToUplload()
                }
				enabled: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)//stateconrotl == "Connect"
            }

            QIDI.ActionButtonInControlpanel
            {
                id: downloadButton
                height: parent.height
                width: parent.width / 5 
                color: downloadButton.enabled ? QD.Theme.getColor("white_1") : QD.Theme.getColor("gray_2")
                hoverColor: QD.Theme.getColor("white_1")
                outlineColor: QD.Theme.getColor("gray_3")
                outlineHoverColor: QD.Theme.getColor("blue_3")
                text: catalog.i18nc("@button", "Download")
                textFont: QD.Theme.getFont("font1")
                textColor: QD.Theme.getColor("black_1")
                textHoverColor: QD.Theme.getColor("blue_3")
                backgroundRadius: Math.round(height / 3)
                // anchors.horizontalCenter : pauseButton.horizontalCenter
                leftPadding: 30 * QD.Theme.getSize("size").height
                fixedWidthMode: true
                iconSource: QD.Theme.getIcon("Download","plugin")
				sourceSize : QD.Theme.getSize("action_button_icon")
                //enabled: controlpanel.printState == "Connect"
                onClicked: controlpanel.selectFileToDownload(fileList.currentItem.selectedFileName +"."+ fileList.currentItem.selectedFileType)//controlpanel.setCustomControlCmd("FileDownload" + "/" + fileList.currentItem.selectedFileName +"."+ fileList.currentItem.selectedFileType)
				enabled: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)//stateconrotl == "Connect"
			}

            QIDI.ActionButtonInControlpanel
            {
                id: deleteButton
                height: parent.height
                width: parent.width / 5 
                color: deleteButton.enabled ? QD.Theme.getColor("white_1") : QD.Theme.getColor("gray_2")
                hoverColor: QD.Theme.getColor("white_1")
                outlineColor: QD.Theme.getColor("gray_3")
                outlineHoverColor: QD.Theme.getColor("blue_3")
                text: catalog.i18nc("@button", "Delete")
                textFont: QD.Theme.getFont("font1")
                textColor: QD.Theme.getColor("black_1")
                textHoverColor: QD.Theme.getColor("blue_3")
                // anchors.horizontalCenter : continueButton.horizontalCenter
                backgroundRadius: Math.round(height / 3)
                leftPadding: 30 * QD.Theme.getSize("size").height
                fixedWidthMode: true
                iconSource: QD.Theme.getIcon("Delete","plugin")
				sourceSize : QD.Theme.getSize("action_button_icon")
                //enabled: controlpanel.printState == "Connect"
                onClicked:
                {
                    //controlpanel.setCustomControlCmd("FileDelete" + "/" + fileList.currentItem.selectedFileName +"."+ fileList.currentItem.selectedFileType)
                    //fileList.currentIndex = -1    //清空列表
                    controlpanel.deleteSDFiles(fileList.currentItem.selectedFileName +"."+ fileList.currentItem.selectedFileType)
                    fileList.currentIndex = -1
                }
				enabled: controlpanel.connectionState > 1 && !(controlpanel.isPrinting || controlpanel.isPause)//stateconrotl == "Connect"
            }

            QIDI.ToolbarButton
            {
                id: refreshButton
                width: parent.width / 5 
                height: parent.height
                hoverColor: QD.Theme.getColor("white_1")
                enabled: controlpanel.connectionState > 1
                // anchors.horizontalCenter : stopPrintButton.horizontalCenter
                toolItem: QD.RecolorImage
                {
                    source: QD.Theme.getIcon("Refresh","plugin")
                    color: QD.Theme.getColor("gray_6")
                    width: refreshButton.hovered ? 18 * QD.Theme.getSize("size").height : 16 * QD.Theme.getSize("size").height
                    height: refreshButton.hovered ? 18 * QD.Theme.getSize("size").height : 16 * QD.Theme.getSize("size").height
                }
                onClicked:
                {
                    controlpanel.refreshSDFiles()
                }
            }
        }
    }

    Rectangle
    {
        id: folderActionsButtomLine
        height: QD.Theme.getSize("size").height
        anchors.top: fileActionsItem.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 0
        anchors.margins: QD.Theme.getSize("size").height
        color: QD.Theme.getColor("gray_2")
    }

    Timer
    {
        id: refreshTimer
        running: false
        repeat: false
        interval: 1000
        onTriggered: fileList.enabled = refreshButton.enabled = true
    }

    Item
    {
        id: fileListTitle
        height: 30 * QD.Theme.getSize("size").height
        anchors.top: folderActionsButtomLine.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 0
        anchors.margins: QD.Theme.getSize("size").height
        Row
        {
            id: fileListTitleRow
            height: parent.height
            width: parent.width

            Label
            {
                height: parent.height
                width: parent.width / 2  - 2 * QD.Theme.getSize("size").height 
                text: catalog.i18nc("@label", "File Name")
                font: QD.Theme.getFont("font1")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle
            {
                width: QD.Theme.getSize("size").height
                height: parent.height
                color: QD.Theme.getColor("gray_2")
            }

            Label
            {
                height: parent.height
                width: parent.width / 4 *　QD.Theme.getSize("size").height / QD.Preferences.getValue("qidi/imagesize")
                text: catalog.i18nc("@label", "File Type")
                font: QD.Theme.getFont("font1")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle
            {
                width: QD.Theme.getSize("size").height
                height: parent.height
                color: QD.Theme.getColor("gray_2")
            }

            Label
            {
                height: parent.height
                width: parent.width / 4 *　QD.Theme.getSize("size").height / QD.Preferences.getValue("qidi/imagesize")
                text:  catalog.i18nc("@label", "File Size")
                font: QD.Theme.getFont("font1")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Rectangle
    {
        id: fileListTitleButtomLine
        height: QD.Theme.getSize("size").height
        anchors.top: fileListTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 0
        anchors.margins: QD.Theme.getSize("size").height
        color: QD.Theme.getColor("gray_2")
    }

    QIDI.ScrollView
    {
        id: fileview
        anchors.top: fileListTitleButtomLine.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: QD.Theme.getSize("size").height

        ListView
        {
            id: fileList
            anchors.fill: parent
            model: controlpanel.FileList
            ExclusiveGroup { id: checkedGroup }
            delegate: Item
            {
                height: 30 * QD.Theme.getSize("size").height
                width: fileview.width

                MouseArea
                {
                    id: mouse_area
                    anchors.fill: parent
                    onClicked:
                    {
                        forceActiveFocus()
                        fileList.currentIndex = index
                        fileCheckBox.checked = !fileCheckBox.checked
                    }
                }

                property alias boxchecked: fileCheckBox.checked
                CheckBox
                {
                    id: fileCheckBox
                    width: 18 * QD.Theme.getSize("size").height
                    height: 18 * QD.Theme.getSize("size").height
                    anchors.left: parent.left
                    anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                    anchors.verticalCenter: parent.verticalCenter
                    checked: false
                    exclusiveGroup: checkedGroup
                    visible: fileName.text != ""
					onCheckedChanged: {
						if(fileCheckBox.checked == true)
						{
							fileList.currentIndex = index
						}
					}
                }

                property alias selectedFileName: fileName.text
                Label
                {
                    id: fileName
                    height: parent.height
                    width: parent.width / 2  - 30 * QD.Theme.getSize("size").height
                    anchors.left: fileCheckBox.right
                    anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                    text: controlpanel.FileList[index].substring( 0 , controlpanel.FileList[index].indexOf('/'))
                    font: QD.Theme.getFont("font1")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                property alias selectedFileType: fileType.text
                Label
                {
                    id: fileType
                    height: parent.height
                    width: parent.width / 4 
                    anchors.left: fileName.right
                    text: controlpanel.FileList[index].substring( controlpanel.FileList[index].indexOf('/') + 1 , controlpanel.FileList[index].indexOf('+'))
                    font: QD.Theme.getFont("font1")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                Label
                {
                    id: fileSize
                    height: parent.height
                    width: parent.width / 4 
                    anchors.right: parent.right
                    text: controlpanel.FileList[index].substring( controlpanel.FileList[index].indexOf('+') + 1 , controlpanel.FileList[index].length)
                    font: QD.Theme.getFont("font1")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    topPadding: 5 * QD.Theme.getSize("size").height
                }
            }
        }
    }
}
