import QtQuick 2.10
import QtQuick.Controls 2.3 as NewControls
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 //ExclusiveGroup
import QtQuick.Window 2.2
import QD 1.1 as QD
import QIDI 1.1 as QIDI


Rectangle{
    id: base
    width: 400 * QD.Theme.getSize("size").height
    height: parent.height
    border.color: QD.Theme.getColor("gray_2")
    border.width: QD.Theme.getSize("size").height
    radius: 5 * QD.Theme.getSize("size").height

    property bool tempTimerControl: controlpanel.connectionState > 1 //&& Number(controlpanel.realE1TempString)>0
    property alias deviceView: deviceView
	property bool inputip:false
	property string connectedip: ""

	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}
		
    Rectangle{
        id: actionButtonsReg
        height: 40 * QD.Theme.getSize("size").height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").height
        color: QD.Theme.getColor("blue_7")
        radius: 5 * QD.Theme.getSize("size").height
    }
	
	Rectangle{
        id: iProwReg
        height: 110 * QD.Theme.getSize("size").height
        anchors.top: actionButtonsReg.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: QD.Theme.getSize("size").height
		anchors.rightMargin: QD.Theme.getSize("size").height
        color: QD.Theme.getColor("blue_7")
		visible: inputip
        Rectangle
        {
            width: parent.width
            height: 5 * QD.Theme.getSize("size").height
            anchors.bottom: parent.bottom
            color: QD.Theme.getColor("blue_7")
        }
    }
	
    Row{
        id: actionButtons
        height: 30 * QD.Theme.getSize("size").height
        // width:actionButtonsReg.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10*QD.Theme.getSize("size").height
		anchors.rightMargin: 10*QD.Theme.getSize("size").height
        anchors.verticalCenter: actionButtonsReg.verticalCenter
        // anchors.horizontalCenter: actionButtonsReg.horizontalCenter
        spacing: 10 * QD.Theme.getSize("size").height
        QIDI.PrimaryButtonInControl{
            id: connectButton
            width: (parent.width)/2.5
            height: parent.height
            fixedWidthMode: true //添加之后文字居中
            color: check_Connect(deviceView.currentItem.ip) ? QD.Theme.getColor("orange_1") : QD.Theme.getColor("green_2")
            hoverColor: check_Connect(deviceView.currentItem.ip) ? QD.Theme.getColor("orange_1") : QD.Theme.getColor("green_2")
            text: check_Connect(deviceView.currentItem.ip) ? catalog.i18nc("@Button:Disconnect", "Disconnect") : catalog.i18nc("@Button:connect", "Connect")
            textFont: QD.Theme.getFont("font1")
            leftPadding: 35 * QD.Theme.getSize("size").height
            iconSource: deviceView.currentItem ? !check_Connect(deviceView.currentItem.ip) ? QD.Theme.getIcon("Connect","plugin") : QD.Theme.getIcon("DisConnect","plugin"): QD.Theme.getIcon("DisConnect","plugin")
            sourceSize : QD.Theme.getSize("section_icon")
            // QD.RecolorImage{
            //     source: deviceView.currentItem ? !check_Connect(deviceView.currentItem.ip) ? QD.Theme.getIcon("Connect","plugin") : QD.Theme.getIcon("DisConnect","plugin"): QD.Theme.getIcon("DisConnect","plugin")
            //     color: QD.Theme.getColor("white_1")
            //     width: 18 * QD.Theme.getSize("size").height
            //     height: width
            //     anchors.verticalCenter: parent.verticalCenter
            //     anchors.left: parent.left
            //     anchors.leftMargin: connectButton.width/2 -36 * QD.Theme.getSize("size").height//15 * QD.Theme.getSize("size").height
            // }
            backgroundRadius: Math.round(height / 2)
            onClicked:
            {
				if(!check_Connect(deviceView.currentItem.ip))
				{
                    if (tempTimerControl){
                        controlpanel.disconnect()
                        connectedip = ""
                    }
					controlpanel.connect(QIDI.WifiSend.FullNameIPList[deviceView.currentIndex])
                    connectedip = QIDI.WifiSend.FullNameIPList[deviceView.currentIndex].substring( QIDI.WifiSend.FullNameIPList[deviceView.currentIndex].indexOf('/') + 1 , QIDI.WifiSend.FullNameIPList[deviceView.currentIndex].length-4)
					// tempTimerControl = true
				}
				else
				{
					controlpanel.disconnect()
                    connectedip = ""
					// tempTimerControl = false
				}
            }
        }

        QIDI.PrimaryButtonInControl{
            id: devicesRefresh
            width: (parent.width)/2.5
            height: parent.height
            fixedWidthMode: true
            text: catalog.i18nc("@Button:refresh", "Refresh")
            textFont: QD.Theme.getFont("font1")
            iconSource: QD.Theme.getIcon("Refresh","plugin")
            sourceSize : QD.Theme.getSize("section_icon")
            // QD.RecolorImage{
            //     source: QD.Theme.getIcon("Refresh","plugin")
            //     color: QD.Theme.getColor("white_1")
            //     width: 18 * QD.Theme.getSize("size").height
            //     height: width
            //     anchors.verticalCenter: parent.verticalCenter
            //     anchors.left: parent.left
            //     anchors.leftMargin: connectButton.width/2 -36 * QD.Theme.getSize("size").height//15 * QD.Theme.getSize("size").height
            // }
            leftPadding: 35 * QD.Theme.getSize("size").height
            backgroundRadius: Math.round(height / 2)
            
            onClicked:
            {
                //若是连接之后，并没有断开连接，不允许刷新，有一个bug若第一次不连接就刷新呢？没有反应
                deviceView.currentIndex = -1            //清空列表
                QIDI.WifiSend.scanDeviceThread()              //扫描设备线程 和 Printer IP使用的是同一个，刷新没办法分开
                enabled = false
                deviceView.enabled = false
                refreshTimer.start()
            }
            enabled:controlpanel.connectionState ==0
        }
		
        QIDI.PrimaryButton{
            id: showIPButton
            width : (parent.width-100*QD.Theme.getSize("size").height)/5
            height: parent.height
            fixedWidthMode: true
            textFont: QD.Theme.getFont("font1")
            QD.RecolorImage{
                source: inputip ? QD.Theme.getIcon("ChevronSingleUp","plugin") : QD.Theme.getIcon("Pen")
                color: QD.Theme.getColor("white_1")
                width: 25 * QD.Theme.getSize("size").height
                height: width
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
            leftPadding: 35 * QD.Theme.getSize("size").height
            backgroundRadius: Math.round(height / 2)
            onClicked:
            {
				inputip = !inputip
            }
        }
		
        Timer{
            id: refreshTimer
            running: false
            repeat: false
            interval: 3000
            onTriggered: 
			{
				devicesRefresh.enabled = deviceView.enabled = true
			}
        }
		
    }
	
	Text{
		anchors.verticalCenter: inputiprow.verticalCenter
		anchors.left: parent.left
		anchors.leftMargin: 10 * QD.Theme.getSize("size").height
		text : "IP:"
		font: QD.Theme.getFont("font1")
	}
	IpInput{
		id: ipinput
		anchors.top: actionButtons.bottom
		anchors.topMargin: 10 * QD.Theme.getSize("size").height
		anchors.horizontalCenter: parent.horizontalCenter

		height: 20 * QD.Theme.getSize("size").height
		width: 150 * QD.Theme.getSize("size").height
		visible: inputip
    }
	Text{
		anchors.verticalCenter: sminput.verticalCenter
		anchors.left: parent.left
		anchors.leftMargin: 10 * QD.Theme.getSize("size").height
		text : "Subnet Mask:"
		font: QD.Theme.getFont("font1")
		visible: inputip
	}
	IpInput{
		id: sminput
		anchors.top: ipinput.bottom
		anchors.topMargin: 10 * QD.Theme.getSize("size").height
		anchors.horizontalCenter: parent.horizontalCenter

		height: 20 * QD.Theme.getSize("size").height
		width: 150 * QD.Theme.getSize("size").height
		visible: inputip
    }
	TextField{
		id:inputiprow
		anchors.top: actionButtons.bottom
		anchors.topMargin: 10 * QD.Theme.getSize("size").height
		anchors.horizontalCenter: parent.horizontalCenter
		placeholderText:catalog.i18nc("@textField", "Please input the printer IP.")
		height: 30 * QD.Theme.getSize("size").height
		width: 200 * QD.Theme.getSize("size").height
		validator:RegExpValidator{regExp: /^(([01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])\.){3}([01]{0,1}\d{0,1}\d|2[0-4]\d|25[0-5])$/}
		visible: false//inputip
	}
	
	QIDI.PrimaryButton{
		id: applyButton
		anchors.top: actionButtons.bottom
		anchors.topMargin: 23 * QD.Theme.getSize("size").height
		anchors.left: inputiprow.right
		anchors.leftMargin: 10 * QD.Theme.getSize("size").height
		width: 80 * QD.Theme.getSize("size").height
		height: 23 * QD.Theme.getSize("size").height
		fixedWidthMode: true //添加之后文字居中
		text: catalog.i18nc("@button", "Apply")
		textFont: QD.Theme.getFont("font1")
		backgroundRadius: Math.round(height / 2)
		onClicked:
		{
			QIDI.WifiSend.setInputIp(ipinput.iptext)
			QIDI.WifiSend.setInputSM(sminput.iptext)

			deviceView.currentIndex = -1            //清空列表
			QIDI.WifiSend.scanDeviceThread()              //扫描设备线程 和 Printer IP使用的是同一个，刷新没办法分开
			inputip=!inputip
		}
		visible: inputip
	}
	
	Text {
		id: inputIPText
		text: catalog.i18nc("@text", "Unable to get IP,please try to input the following IP.")
		font: QD.Theme.getFont("font1")
		visible: inputip
		anchors.top: applyButton.bottom
		anchors.topMargin: 30 * QD.Theme.getSize("size").height
		anchors.left: parent.left
		anchors.leftMargin: 10 * QD.Theme.getSize("size").height
	}
	
	Text {
		id: inputIPListText
		text :controlpanel.getalliplist
		font: QD.Theme.getFont("font1")
		wrapMode: Text.WordWrap
		color: QD.Theme.getColor("blue_6")
		visible: inputip
		anchors.top: inputIPText.bottom
		anchors.topMargin: 5 * QD.Theme.getSize("size").height
		anchors.horizontalCenter: parent.horizontalCenter
	}
	
    Item{
        id: deviceViewTitle
        height: 28 * QD.Theme.getSize("size").height
        // width: 348 * QD.Theme.getSize("size").height
        width:parent.width - 2 * QD.Theme.getSize("size").height
        anchors.top: inputip ? inputIPListText.bottom : actionButtons.bottom
		anchors.topMargin: inputip ? 0 * QD.Theme.getSize("size").height : 5 * QD.Theme.getSize("size").height
        anchors.left: parent.left
        anchors.margins: QD.Theme.getSize("size").height

        Rectangle{
            anchors.fill: deviceViewTitle
            color: QD.Theme.getColor("blue_4")
        }

        Label{
            id: nameLabel
            anchors.left: parent.left
            width: 200 * QD.Theme.getSize("size").height
            anchors.verticalCenter: parent.verticalCenter
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@label", "Name")
            horizontalAlignment: Text.AlignHCenter
        }

        Label{
            id: ipLabel
            anchors.left: nameLabel.right
            anchors.verticalCenter: parent.verticalCenter
            width: 120 * QD.Theme.getSize("size").height
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@label", "IP")
            horizontalAlignment: Text.AlignHCenter
        }

        Label{
            id: stateLabel
            anchors.left: ipLabel.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            font: QD.Theme.getFont("font1")
            text: catalog.i18nc("@label", "State")
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle{
            width: QD.Theme.getSize("size").height
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: ipLabel.left
            color: QD.Theme.getColor("gray_2")
        }

        Rectangle{
            width: QD.Theme.getSize("size").height
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: stateLabel.left
            color: QD.Theme.getColor("gray_2")
        }

        Rectangle{
            height: QD.Theme.getSize("size").height
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: QD.Theme.getColor("gray_2")
        }

        Rectangle{
            height: QD.Theme.getSize("size").height
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: QD.Theme.getColor("gray_2")
        }
    }

    ListView{
        id: deviceView
        width: parent.width - 2 * QD.Theme.getSize("size").height
        anchors.bottom:parent.bottom
        anchors.top:  deviceViewTitle.bottom
        anchors.left: parent.left
        anchors.margins: QD.Theme.getSize("size").height
        model: QIDI.WifiSend.FullNameIPList
        delegate: deviceViewDelegate
        // interactive: false
        focus: true
        clip:true
        ExclusiveGroup { id: checkedGroup }
		
    }

    Component{
        id: deviceViewDelegate
        QIDI.RadioButtonInControl
        {
            id: radioButton
            anchors.left: parent.left
            anchors.leftMargin: QD.Theme.getSize("standard_list_lineheight").width
            anchors.right: parent.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            height: 30 * QD.Theme.getSize("size").height//QD.Theme.getSize("standard_list_lineheight").height
            ip:QIDI.WifiSend.FullNameIPList[index].substring( QIDI.WifiSend.FullNameIPList[index].indexOf('/') + 1 , QIDI.WifiSend.FullNameIPList[index].length-4)
            source:check_State(ip)
            checked: ListView.view.currentIndex == index
            connected:QIDI.WifiSend.FullNameIPList[index].substring( QIDI.WifiSend.FullNameIPList[index].indexOf('/') + 1 , QIDI.WifiSend.FullNameIPList[index].length-4) == connectedip
            text: QIDI.WifiSend.FullNameIPList[index].substring( 0 , QIDI.WifiSend.FullNameIPList[index].indexOf('/'))
            onClicked: {
                if (controlpanel.connectionState ==0)
                {
                    ListView.view.currentIndex = index
                }
            }
            Rectangle{
                height: QD.Theme.getSize("size").height
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                color: QD.Theme.getColor("gray_2")
                visible:  radioButton.text != ""
            }
        }
    }

    function check_Connect(ip)
    {
        if (ip == connectedip && !(controlpanel.connectionState < 2))
        {
            return true
        }
        else
        {
            return false
        }
    }

    function check_State(ip)
    {
        if (ip == connectedip && !(controlpanel.connectionState < 2))
        {
            if(controlpanel.isPrinting){
                return QD.Theme.getIcon("Printing","plugin")
            }
            else if(controlpanel.isPause){
                return QD.Theme.getIcon("Pause","plugin")
            }
            return QD.Theme.getIcon("Connect","plugin")
        }
        else
        {
            return QD.Theme.getIcon("DisConnect","plugin")
        }
    }
}
