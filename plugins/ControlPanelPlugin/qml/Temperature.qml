import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
// import QtQuick.Controls 1.4 //ExclusiveGroup
// import QtQuick 2.0
// import QtQuick.Controls 2.12
import QtWebEngine 1.2


import QD 1.1 as QD
import QIDI 1.1 as QIDI
import "./"
import "../"

Item{
    id: tempbase
    height: parent.height
    width: parent.width
    property var count : 0
    property bool e1Enable: controlpanel.connectionState > 1 && (e1CheckBox.checked || e1TarCheckBox.checked)
    property bool e2Enable: controlpanel.connectionState > 1 && (e2CheckBox.checked || e2TarCheckBox.checked)
    property bool bedEnable: controlpanel.connectionState > 1 && (bedCheckBox.checked || bedTarCheckBox.checked)
    property bool volEnable: controlpanel.connectionState > 1 && (volCheckBox.checked || volTarCheckBox.checked)

	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}

    Timer{
        running: devicelist.tempTimerControl
        repeat: false
        onTriggered:
        {
            let datalist = [QD.Preferences.getValue("color/extruder0"),QD.Preferences.getValue("color/extruder1")];
            view.runJavaScript("window.setColor("+
                        JSON.stringify(datalist)+")");
            if (controlpanel.extrudernumString == "1")
            {
                e2CheckBox.checked =false
                e2TarCheckBox.checked = false
            }
            if (controlpanel.volume_enabled == "False")
            {
                volCheckBox.checked =false
                volTarCheckBox.checked = false
            }
            e1tarinput.text = Number(controlpanel.expectE1TempString)
            e2tarinput.text = Number(controlpanel.expectE2TempString)
            bedtarinput.text = Number(controlpanel.expectBedTempString)
            voltarinput.text = Number(controlpanel.expectVolTempString)

        }
    }

    Timer{
        id: getTime
        running: devicelist.tempTimerControl
        repeat: true
        interval: 3000
        onTriggered:
        {
            var currentDate = new Date()
            var value = currentDate.getTime();
            var ptDate = new Date(value)
            view.runJavaScript("window.appendData("+
                                JSON.stringify({
                                                    "date":value,
                                                    "E1":Number(controlpanel.realE1TempString),
                                                    "EE1":Number(controlpanel.expectE1TempString),
                                                    "E2":Number(controlpanel.realE2TempString),
                                                    "EE2":Number(controlpanel.expectE2TempString),
                                                    "Bed":Number(controlpanel.realBedTempString),
                                                    "EBed":Number(controlpanel.expectBedTempString),
                                                    "Vol":Number(controlpanel.realVolTempString),
                                                    "EVol":Number(controlpanel.expectVolTempString),
                                                })+")");
        }
    }

	WebEngineView{
        id:view
        // anchors.fill: parent
        anchors.top: otherGrid.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        url:"qrc:/index.html"
        // url:"G:/QIDIWrite/QIDI/build/package/plugins/ControlPanelPlugin/index.html"
        // url:"http://qd3dprinter.com/qidiprint/news.png"
        backgroundColor:"transparent"
        // onNewViewRequested: request.openIn(view)
	}

    Column{
        id:otherGrid
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 30 * QD.Theme.getSize("size").height
        anchors.right: parent.right
        anchors.rightMargin: 30 * QD.Theme.getSize("size").height
        spacing:5
        Row{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10 * QD.Theme.getSize("size").height 
            width: parent.width

            Label
            {
                height: 20 * QD.Theme.getSize("size").height
                width:40*QD.Theme.getSize("size").height
                text: catalog.i18nc("@label", "       ")
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1  ?  QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QD.RecolorImage
                    {
                        id:e1Image
                        anchors.verticalCenter: parent.verticalCenter
                        source: QD.Theme.getIcon("extruder_button","plugin")
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        color: controlpanel.connectionState > 1 && e1Enable ? QD.Preferences.getValue("color/extruder0") : QD.Theme.getColor("gray_2")//'#93CE07' : QD.Theme.getColor("gray_2")
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { 
                                if (e1Enable)
                                {
                                    e1CheckBox.checked =false
                                    e1TarCheckBox.checked = false
                                }
                                else{
                                    e1CheckBox.checked =true
                                    e1TarCheckBox.checked = true
                                }

                            }
                        }
                    }
                    Label
                    {
                        anchors.left: e1Image.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: e1Image.verticalCenter
                        width: 40*QD.Theme.getSize("size").height
                        font: QD.Theme.getFont("font1")
                        text: "E1:"
                        color: e1Enable ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QD.RecolorImage
                    {
                        id:e2Image
                        anchors.verticalCenter: parent.verticalCenter
                        source: QD.Theme.getIcon("extruder_button","plugin")
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        color: controlpanel.connectionState > 1 && e2Enable ? QD.Preferences.getValue("color/extruder1") : QD.Theme.getColor("gray_2")//'#FBDB0F' : QD.Theme.getColor("gray_2")
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { 
                                if (e2Enable)
                                {
                                    e2CheckBox.checked =false
                                    e2TarCheckBox.checked = false
                                }
                                else{
                                    e2CheckBox.checked =true
                                    e2TarCheckBox.checked = true
                                }

                            }
                        }
                    }
                    Label{
                        anchors.left: e2Image.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: e2Image.verticalCenter
                        width: 40*QD.Theme.getSize("size").height
                        font: QD.Theme.getFont("font1")
                        text: "E2:"
                        color: controlpanel.connectionState > 1 && e2Enable ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QD.RecolorImage
                    {
                        id:bedImage
                        anchors.verticalCenter: parent.verticalCenter
                        source: QD.Theme.getIcon("Bed","plugin")
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        color: controlpanel.connectionState > 1 && bedEnable ? '#0000ff' : QD.Theme.getColor("gray_2")
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { 
                                if (bedEnable)
                                {
                                    bedCheckBox.checked =false
                                    bedTarCheckBox.checked = false
                                }
                                else{
                                    bedCheckBox.checked =true
                                    bedTarCheckBox.checked = true
                                }

                            }
                        }
                    }
                    Label{
                        anchors.left: bedImage.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: bedImage.verticalCenter
                        width: 40*QD.Theme.getSize("size").height
                        font: QD.Theme.getFont("font1")
                        text: catalog.i18nc("@label", "Bed:")
                        color: controlpanel.connectionState > 1 && bedEnable ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QD.RecolorImage
                    {
                        id:volImage
                        anchors.verticalCenter: parent.verticalCenter
                        source: QD.Theme.getIcon("Volume Temp","plugin")
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        color: controlpanel.connectionState > 1 && volEnable ? '#ff55ff' : QD.Theme.getColor("gray_2")
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { 
                                if (volEnable)
                                {
                                    volCheckBox.checked =false
                                    volTarCheckBox.checked = false
                                }
                                else{
                                    volCheckBox.checked =true
                                    volTarCheckBox.checked = true
                                }

                            }
                        }
                    }
                    Label{
                        anchors.left: volImage.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: volImage.verticalCenter
                        width: 40*QD.Theme.getSize("size").height
                        font: QD.Theme.getFont("font1")
                        text: catalog.i18nc("@label", "Vol:")
                        color: controlpanel.connectionState > 1 && volEnable ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                }
            }
        }
        Rectangle{
            anchors.left: parent.left
            anchors.right: parent.right 
            color: QD.Theme.getColor("gray_2")
            height: 1 * QD.Theme.getSize("size").width
        }
        Row{
            anchors.left: parent.left
            anchors.leftMargin: 10 * QD.Theme.getSize("size").height
            anchors.right: parent.right 
            width: parent.width
            Label
            {
                id:actualLabel
                height: 20 * QD.Theme.getSize("size").height
                width:40*QD.Theme.getSize("size").height
                text: catalog.i18nc("@label", "Actual:")
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1  ?  QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: e1CheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['E1',e1CheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Label{
                        anchors.left: e1CheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: e1CheckBox.verticalCenter;
                        width: 40*QD.Theme.getSize("size").height
                        text: controlpanel.realE1TempString +"℃"
                        font: QD.Theme.getFont("font1")
                        color: controlpanel.connectionState > 1 && e1CheckBox.checked ? controlpanel.expectE1TempString > 50 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: e2CheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['E2',e2CheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Label{
                        anchors.left: e2CheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: e2CheckBox.verticalCenter;                     width: childrenRect.width
                        text: controlpanel.realE2TempString +"℃"
                        font: QD.Theme.getFont("font1")
                        color: controlpanel.connectionState > 1 && e2CheckBox.checked ? controlpanel.expectE2TempString > 50 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                    }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: bedCheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['Bed',bedCheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Label{
                        anchors.left: bedCheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: bedCheckBox.verticalCenter;                     width: childrenRect.width
                        text: controlpanel.realBedTempString +"℃"
                        font: QD.Theme.getFont("font1")
                        color: controlpanel.connectionState > 1 && bedCheckBox.checked ? controlpanel.expectBedTempString > 40 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: volCheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['Vol',volCheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Label{
                        anchors.left: volCheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: volCheckBox.verticalCenter;                     width: childrenRect.width
                        text: controlpanel.realVolTempString +"℃"
                        font: QD.Theme.getFont("font1")
                        color: controlpanel.connectionState > 1 && volCheckBox.checked ? controlpanel.expectVolTempString > 40 ? QD.Theme.getColor("red_1") :QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
                    }
                }
            }
        }
        Rectangle{
            anchors.left: parent.left
            anchors.right: parent.right 
            color: QD.Theme.getColor("gray_2")
            height: 1 * QD.Theme.getSize("size").width
        }
        Row{
            anchors.left: parent.left
            anchors.leftMargin: 10 * QD.Theme.getSize("size").height
            anchors.right: parent.right 
            width: parent.width
            Label
            {
                id:targetLabel
                width:40 * QD.Theme.getSize("size").height
                height: 20 * QD.Theme.getSize("size").height
                text: catalog.i18nc("@label", "Target:")
                font: QD.Theme.getFont("font1")
                color: controlpanel.connectionState > 1  ? QD.Theme.getColor("black_1") : QD.Theme.getColor("gray_2")
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: e1TarCheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['E1 Target',e1TarCheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Rectangle {
                        width:45 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        anchors.left: e1TarCheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: e1TarCheckBox.verticalCenter;   
                        border.color: controlpanel.connectionState > 1 && e1TarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("setting_control_disabled_border")
                        radius: QD.Theme.getSize("setting_control_radius").width
                        border.width: QD.Theme.getSize("default_lining").width
                        Label{
                            anchors
                            {

                                right: parent.right
                                rightMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                                verticalCenter: parent.verticalCenter
                            }

                            text: '°C'
                            //However the setting value is aligned, align the unit opposite. That way it stays readable with right-to-left languages.
                            // horizontalAlignment: (input.effectiveHorizontalAlignment == Text.AlignLeft) ? Text.AlignRight : Text.AlignLeft
                            textFormat: Text.PlainText
                            renderType: Text.NativeRendering
                            color: controlpanel.connectionState > 1 && e1TarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            font: QD.Theme.getFont("default")
                        }
                        TextInput{
                            id:e1tarinput
                            anchors.fill: parent
                            anchors.margins: 2
                            text: '0'
                            font: QD.Theme.getFont("font1")
                            color: controlpanel.connectionState > 1 && e1TarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            autoScroll: false //是否滚动，占据一定的宽度和高度
                            verticalAlignment: Qt.AlignCenter
                            activeFocusOnPress :controlpanel.connectionState > 1 && e1TarCheckBox.checked
                            validator: IntValidator{ bottom: 0; top: 999; }
                            onEditingFinished: {
                                if(text>360){
                                    text = 360
                                }
                                controlpanel.setextruder0t(text.toString())
                            }
                        }
                    }
                }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: e2TarCheckBox
                        anchors.verticalCenter: parent.verticalCenter 
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['E2 Target',e2TarCheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Rectangle {
                        width:45 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        anchors.left: e2TarCheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: e2TarCheckBox.verticalCenter;   
                        radius: QD.Theme.getSize("setting_control_radius").width
                        border.width: QD.Theme.getSize("default_lining").width
                        border.color: controlpanel.connectionState > 1 && e2TarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                        Label{
                            anchors
                            {
                                right: parent.right
                                rightMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                                verticalCenter: parent.verticalCenter
                            }

                            text: '°C'
                            // horizontalAlignment: (input.effectiveHorizontalAlignment == Text.AlignLeft) ? Text.AlignRight : Text.AlignLeft
                            textFormat: Text.PlainText
                            renderType: Text.NativeRendering
                            color: controlpanel.connectionState > 1 && e2TarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            font: QD.Theme.getFont("default")
                        }
                        TextInput{
                            id:e2tarinput
                            anchors.fill: parent
                            anchors.margins: 2
                            text: "0"
                            font: QD.Theme.getFont("font1")
                            color: controlpanel.connectionState > 1 && e2TarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            autoScroll: false //是否滚动，占据一定的宽度和高度
                            verticalAlignment: Qt.AlignCenter
                            activeFocusOnPress :controlpanel.connectionState > 1 && e2TarCheckBox.checked
                            validator: IntValidator{ bottom: 0; top: 999; }
                            onEditingFinished: {
                                if(text>360){
                                    text = 360
                                }
                                controlpanel.setextruder1t(text.toString())
                            }                    }
                    }
                    }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: bedTarCheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['Bed Target',bedTarCheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Rectangle {
                        width:45 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        anchors.left: bedTarCheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: bedTarCheckBox.verticalCenter;   
                        radius: QD.Theme.getSize("setting_control_radius").width
                        border.width: QD.Theme.getSize("default_lining").width
                        border.color: controlpanel.connectionState > 1 && bedTarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                        Label{
                            anchors
                            {
                                right: parent.right
                                rightMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                                verticalCenter: parent.verticalCenter
                            }

                            text: '°C'
                            // horizontalAlignment: (input.effectiveHorizontalAlignment == Text.AlignLeft) ? Text.AlignRight : Text.AlignLeft
                            textFormat: Text.PlainText
                            renderType: Text.NativeRendering
                            color: controlpanel.connectionState > 1 && bedTarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            font: QD.Theme.getFont("default")
                        }
                        TextInput{
                            id:bedtarinput
                            anchors.fill: parent
                            anchors.margins: 2
                            text: "0"
                            font: QD.Theme.getFont("font1")
                            color: controlpanel.connectionState > 1 && bedTarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            autoScroll: false //是否滚动，占据一定的宽度和高度
                            verticalAlignment: Qt.AlignCenter
                            activeFocusOnPress :controlpanel.connectionState > 1 && bedTarCheckBox.checked
                            validator: IntValidator{ bottom: 0; top: 999; }
                            onEditingFinished: {
                                if(text>120){
                                    text = 120
                                }
                                controlpanel.setbedt(text.toString())
                            }                    }
                    }
                }
            }
            Rectangle { 
                color: color; 
                width: (parent.width-50 * QD.Theme.getSize("size").height)/4; 
                height: 20 
                Rectangle { 
                    color: color; 
                    anchors.centerIn:parent
                    height: 20 
                    QIDI.CheckBox
                    {
                        id: volTarCheckBox
                        anchors.verticalCenter: parent.verticalCenter
                        width: 20 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        checked: true
                        onCheckedChanged: {
                            let datalist=['Vol Target',volTarCheckBox.checked];
                            view.runJavaScript("window.setSeleted("+
                                            JSON.stringify(datalist)+")");
                        }
                    }
                    Rectangle {
                        width:45 * QD.Theme.getSize("size").height
                        height: 20 * QD.Theme.getSize("size").height
                        anchors.left: volTarCheckBox.right
                        anchors.leftMargin: 10 * QD.Theme.getSize("size").height
                        anchors.verticalCenter: volTarCheckBox.verticalCenter;   
                        radius: QD.Theme.getSize("setting_control_radius").width
                        border.width: QD.Theme.getSize("default_lining").width
                        border.color: controlpanel.connectionState > 1 && volTarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                        Label{
                            anchors
                            {
                                right: parent.right
                                rightMargin: Math.round(QD.Theme.getSize("setting_unit_margin").width)
                                verticalCenter: parent.verticalCenter
                            }

                            text: '°C'
                            // horizontalAlignment: (input.effectiveHorizontalAlignment == Text.AlignLeft) ? Text.AlignRight : Text.AlignLeft
                            textFormat: Text.PlainText
                            renderType: Text.NativeRendering
                            color: controlpanel.connectionState > 1 && volTarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            font: QD.Theme.getFont("default")
                        }
                        TextInput{
                            id:voltarinput
                            anchors.fill: parent
                            anchors.margins: 2
                            text: "0"
                            font: QD.Theme.getFont("font1")
                            color: controlpanel.connectionState > 1 && volTarCheckBox.checked ? QD.Theme.getColor("text") : QD.Theme.getColor("gray_2")
                            autoScroll: false //是否滚动，占据一定的宽度和高度
                            verticalAlignment: Qt.AlignCenter
                            activeFocusOnPress :controlpanel.connectionState > 1 && volTarCheckBox.checked
                            validator: IntValidator{ bottom: 0; top: 999; }
                            onEditingFinished: {
                                if(text>80){
                                    text = 80
                                }
                                controlpanel.setVolumet(text.toString())
                            }                    }
                    }
                }
            }
        }
    }


}
