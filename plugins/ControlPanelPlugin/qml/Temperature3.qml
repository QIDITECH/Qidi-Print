import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 //ExclusiveGroup
import QtQuick 2.0
import QtQuick.Controls 2.12

import QD 1.1 as QD
import QIDI 1.1 as QIDI
import "./"
import "../"

Item
{
    id: tempbase
    height: parent.height
    width: parent.width

    property var currenIndex: 0
//    不用再动，已经可以实时更新温度了

	QD.I18nCatalog
	{
		id: catalog
		name: "qidi"
	}


    function addData()
    {
        if(currenIndex < 26)
        {
            e1Line.dataArray.push(Number(controlpanel.realE1TempString))
            e1ExpectLine.dataArray.push(Number(controlpanel.expectE1TempString))
            e2Line.dataArray.push(Number(controlpanel.realE2TempString))
            e2ExpectLine.dataArray.push(Number(controlpanel.expectE2TempString))
            bedLine.dataArray.push(Number(controlpanel.realBedTempString))
            bedExpectLine.dataArray.push(Number(controlpanel.expectBedTempString))
            currenIndex ++
        }
        else
        {
            e1Line.dataArray.shift()
            e1ExpectLine.dataArray.shift()
            e2Line.dataArray.shift()
            e2ExpectLine.dataArray.shift()
            bedLine.dataArray.shift()
            bedExpectLine.dataArray.shift()

            e1Line.dataArray.push(Number(controlpanel.realE1TempString))
            e1ExpectLine.dataArray.push(Number(controlpanel.expectE1TempString))
            e2Line.dataArray.push(Number(controlpanel.realE2TempString))
            e2ExpectLine.dataArray.push(Number(controlpanel.expectE2TempString))
            bedLine.dataArray.push(Number(controlpanel.realBedTempString))
            bedExpectLine.dataArray.push(Number(controlpanel.expectBedTempString))

            currenIndex = 26
        }
    }

    function rePaint()
    {
        e1Line.clear()
        e1ExpectLine.clear()
        e2Line.clear()
        e2ExpectLine.clear()
        bedLine.clear()
        bedExpectLine.clear()

        e1Line.requestPaint()
        e1ExpectLine.requestPaint()
        e2Line.requestPaint()
        e2ExpectLine.requestPaint()
        bedLine.requestPaint()
        bedExpectLine.requestPaint()
    }

    function stopClear()
    {
        e1Line.dataArray = []
        e1ExpectLine.dataArray = []
        e2Line.dataArray = []
        e2ExpectLine.dataArray = []
        bedLine.dataArray = []
        bedExpectLine.dataArray = []
    }

    Timer
    {
        id: getTime
        running: devicelist.tempTimerControl
        repeat: true
        interval: 2000
        onTriggered:
        {
            addData()
            rePaint()
            //controlpanel.realE1TempString == "0" 是为了避免掉突然被其他IP所连接而导致的连接失败
            if(devicelist.tempTimerControlStop /*| controlpanel.realE1TempString == "0"*/)
            {
                stopClear()
                rePaint()
                currenIndex = 0
                devicelist.tempTimerControl = false
                //返回控制温度定时器不再计时的值，在下一个2秒被计时器读取到false，即不在自动计时
            }
        }
    }

    Grid
    {
        id: tempLineView
        height: 60 * QD.Theme.getSize("size").height
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 50 * QD.Theme.getSize("size").width
        anchors.margins: QD.Theme.getSize("size").width
        columns: 4
        columnSpacing: 50 * QD.Theme.getSize("size").width
        rowSpacing: 2 * QD.Theme.getSize("size").width

        // 默认 所有checked: devicelist.tempTimerControl 未连接时是全未选中，连接时是全选中
        QIDI.CheckBox
        {
            id: e1CheckBox
            width: 80 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            checked: true
            text: catalog.i18nc("@checkBox", "E1 Temp")
            font: QD.Theme.getFont("font1")
            MouseArea
            {
                anchors.fill: e1CheckBox
                onClicked:
                {
                    e1Line.visible = !e1Line.visible
                    e1CheckBox.checked = !e1CheckBox.checked
                }
            }
        }

        Item
        {
            id: e1colorItem
            width: 50 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            Rectangle
            {
                height: 2 * QD.Theme.getSize("size").height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                color: QD.Theme.getColor("blue_1")
            }
        }

        QIDI.CheckBox
        {
            id: e1ExpectCheckBox
            width: 120 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            checked: true
            text: catalog.i18nc("@checkBox", "E1 Expect Temp")
            font: QD.Theme.getFont("font1")
            MouseArea
            {
                anchors.fill: e1ExpectCheckBox
                onClicked:
                {
                    e1ExpectLine.visible = ! e1ExpectLine.visible
                    e1ExpectCheckBox.checked = !e1ExpectCheckBox.checked
                }
            }
        }

        Item
        {
            id: e1ExpectcolorItem
            width: 50 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            Row
            {
                height: 2 * QD.Theme.getSize("size").height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: width / 4

                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("blue_1")
                }
                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("blue_1")
                }
                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("blue_1")
                }
            }
        }

        QIDI.CheckBox
        {
            id: e2CheckBox
            visible: controlpanel.extrudernumString == "2"
            width: 80 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            checked: controlpanel.extrudernumString == "2"
            text: catalog.i18nc("@checkBox", "E2 Temp")
            font: QD.Theme.getFont("font1")
            MouseArea
            {
                anchors.fill: e2CheckBox
                onClicked:
                {
                    e2Line.visible = !e2Line.visible
                    e2CheckBox.checked = !e2CheckBox.checked
                }
            }

        }

        Item
        {
            id: e2colorItem
            visible: controlpanel.extrudernumString == "2"
            width: 50 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            Rectangle
            {
                height: 2 * QD.Theme.getSize("size").height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                color: QD.Theme.getColor("green_1")
            }
        }

        QIDI.CheckBox
        {
            id: e2ExpectCheckBox
            visible: controlpanel.extrudernumString == "2"
            width: 120 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            checked: controlpanel.extrudernumString == "2"
            text: catalog.i18nc("@checkBox", "E2 Expect Temp")
            font: QD.Theme.getFont("font1")
            MouseArea
            {
                anchors.fill: e2ExpectCheckBox
                onClicked:
                {
                    e2ExpectLine.visible = !e2ExpectLine.visible
                    e2ExpectCheckBox.checked = !e2ExpectCheckBox.checked
                }
            }
        }

        Item
        {
            id: e2ExpectcolorItem
            visible: controlpanel.extrudernumString == "2"
            width: 50 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            Row
            {
                height: 2 * QD.Theme.getSize("size").height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: width / 4

                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("green_1")
                }
                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("green_1")
                }
                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("green_1")
                }
            }
        }

        QIDI.CheckBox
        {
            id: bedCheckBox
            width: 90 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            checked: true
            text:  catalog.i18nc("@checkBox", "Bed Temp")
            font: QD.Theme.getFont("font1")
            MouseArea
            {
                anchors.fill: bedCheckBox
                onClicked:
                {
                    bedLine.visible = !bedLine.visible
                    bedCheckBox.checked = !bedCheckBox.checked
                }
            }
        }

        Item
        {
            id: bedcolorItem
            width: 50 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            Rectangle
            {
                height: 2 * QD.Theme.getSize("size").height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                color: QD.Theme.getColor("red_1")
            }
        }

        QIDI.CheckBox
        {
            id: bedExpectCheckBox
            width: 130 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            checked: true
            text: catalog.i18nc("@checkBox", "Bed Expect Temp")
            font: QD.Theme.getFont("font1")
            MouseArea
            {
                anchors.fill: bedExpectCheckBox
                onClicked:
                {
                    bedExpectLine.visible = !bedExpectLine.visible
                    bedExpectCheckBox.checked = !bedExpectCheckBox.checked
                }
            }
        }

        Item
        {
            id: bedExpectcolorItem
            width: 50 * QD.Theme.getSize("size").height
            height: 18 * QD.Theme.getSize("size").height
            Row
            {
                height: 2 * QD.Theme.getSize("size").height
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
                spacing: width / 4

                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("red_1")
                }
                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("red_1")
                }
                Rectangle
                {
                    height: parent.height
                    width: parent.width / 4
                    color: QD.Theme.getColor("red_1")
                }
            }
        }
    }


    Label
    {
        id: temTitle
        height: 20 * QD.Theme.getSize("size").width
        anchors.top: tempLineView.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").width
        text: "" //catalog.i18nc("@label", "Bed SetPoint  Extruder SetPoint")
        font: QD.Theme.getFont("font1")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Text
    {
        id: yUnit
        text:  catalog.i18nc("@text", "Temperature(℃)")
        width: 20* QD.Theme.getSize("size").width
        font: QD.Theme.getFont("font1")
        anchors.left: tempbase.left
        anchors.verticalCenter: mycanvasItem.verticalCenter
        rotation: - 90 * QD.Theme.getSize("size").width
    }

    Text
    {
        id: xUnit
        text:  catalog.i18nc("@text", "Time(S)")
        font: QD.Theme.getFont("font1")
        anchors.top: mycanvasItem.bottom
        anchors.topMargin: 10 * QD.Theme.getSize("size").width
        anchors.horizontalCenter: mycanvasItem.horizontalCenter
    }

    Item
    {
        id: mycanvasItem
        anchors.top: temTitle.bottom
        anchors.bottom: lastItem.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottomMargin: 40 * QD.Theme.getSize("size").width
        anchors.topMargin: 10 * QD.Theme.getSize("size").width
        anchors.margins: 20 * QD.Theme.getSize("size").width

        //坐标系画布
        Canvas
        {
            id: mycanvas
            anchors.fill: parent
            antialiasing: true //反锯齿
            onPaint: {
                //注意原Canvas的坐标是从上往下(0 -> height)，从左往右(0 -> width)
                //自定义的坐标系是按照原来的来定义，所以实现后肉眼看见的坐标位置是和实际上自定义的坐标位置相差很多的

                //二维坐标系
                var ctx = getContext("2d");
                var width = mycanvas.width - 40 * QD.Theme.getSize("size").width
                var height = mycanvas.height - 40 * QD.Theme.getSize("size").width
                ctx.fillStyle = QD.Theme.getColor("white_1");
                //ctx画布的范围为 （40-30） * （40 -20），以（30，20）为起点，不让 ctx 充满父级范围，
                //是为了刻度线和刻度值的存在，若让画布充满了mycanvas，那么，超出了mycanvas，所画的东西都没有办法显示

                //定义一个以 （30，20）为起点，宽为width，高为height的矩形画布
                //起点20 的话，刻度值显示不全，没办法只能再挪一挪位置了
                ctx.fillRect(30, 20, width, height);
                //起点的x,y
                var Qwidth = 30
                var Qheiight = 20

                //终点的x,y
                var Zwidth = width + 30
                var Zheight = height + 20

                // ySpacing ，是y轴横线的高度间隔，lingKey 是 刻度值
                var ySpacing = height / 7
                var temKey = 0

                //y轴，x不变
                drawLine(ctx, QD.Theme.getColor("red_1"), 0.5 , Qwidth , Qheiight , Qwidth , Zheight);

                //当x轴刻度线，每一点的 x 为画布宽度，y 起终变5点以及当y轴刻度线，每一点的 y 为画布高度，x 起终变5点时，网格就会出现
                //y轴刻度线，每一点的 y 起终不变，x 起终变5点，若将x终点设置为起点的 Zwidth，便得到了横线
                //i = 20 ，是起点值
                for(var i = 20 ; i < height ; i += ySpacing)
                {
                    if(i == 20)
                    {
                        drawLine(ctx, QD.Theme.getColor("text"), 0.5, (Qwidth - 4) , (Zheight - (i - 20)) , Qwidth , (Zheight - (i - 20)));
                    }
                    else
                    {
                        drawLine(ctx, QD.Theme.getColor("text"), 0.5, (Qwidth - 4) , (Zheight - (i - 20)) , Zwidth , (Zheight - (i - 20)));
                    }
                    //(Zheight - (i - 20)) + 5 是为了让文字在距离刻度线高度 再高5点的位置显示，居中效果
                    //（刻度值，x ，y）
                    ctx.strokeText(temKey , (Qwidth - 25), (Zheight - (i - 20)) + 5)
                    ctx.font="12px Arial";
                    temKey = temKey + 50;
                }

                // xSpacing ，是x轴竖线的宽度间隔，lingKey 是 刻度值
                var xSpacing = width / 10
                var timeKey = 0

                //x轴，y不变
                drawLine(ctx, QD.Theme.getColor("red_1"), 0.5 , Qwidth , Zheight , Zwidth , Zheight );

                //x轴刻度线，每一点的 x 起终不变，y 起终变5点，若将x终点设置为终点的Qheiight，便得到了竖线
                for(var j = 30 ; j < width ; j += xSpacing)
                {
                    if(j == 30)
                    {
                        drawLine(ctx, QD.Theme.getColor("text"), 0.5, j, (Zheight + 4) , j, Zheight);
                    }
                    else
                    {
                        drawLine(ctx, QD.Theme.getColor("text"), 0.5, j, (Zheight + 4) , j, Qheiight);
                    }
                    //(Zheight + 15) 也与 (Zheight - (i - 20)) + 5 同等效果
                    //（刻度值，x ，y）
                    ctx.strokeText(timeKey , j - 5, (Zheight + 15))
                    ctx.font="12px Arial";
                    timeKey = timeKey + 5;
                }
            }

            //画笔，颜色，宽度，起点x，起点y，终点x，终点y
            function drawLine(ctx, color, width, startX, startY, endX, endY)
            {
                ctx.strokeStyle = color;
                ctx.lineWidth = width;
                ctx.beginPath();
                ctx.moveTo(startX, startY);
                ctx.lineTo(endX, endY);
                ctx.closePath();
                ctx.stroke();
            }
        }

        LineCanvas
        {
            id: e1Line
            visible: controlpanel.realE1TempString != "0" | controlpanel.realE2TempString != "0"
            anchors.fill: parent
            lineColor: QD.Theme.getColor("blue_1")
        }

        LineCanvas
        {
            id: e1ExpectLine
            visible: controlpanel.realE1TempString != "0" | controlpanel.realE2TempString != "0"
            anchors.fill: parent
            lineColor: QD.Theme.getColor("blue_1")
            isPointLine: true
        }

        LineCanvas
        {
            id: e2Line
            visible: e2CheckBox.checked & (controlpanel.realE1TempString != "0" | controlpanel.realE2TempString != "0")
            anchors.fill: parent
            lineColor: QD.Theme.getColor("green_1")
        }

        LineCanvas
        {
            id: e2ExpectLine
            visible: e2ExpectCheckBox.checked & (controlpanel.realE1TempString != "0" | controlpanel.realE2TempString != "0")
            anchors.fill: parent
            lineColor: QD.Theme.getColor("green_1")
            isPointLine: true
        }

        LineCanvas
        {
            id: bedLine
            visible: (controlpanel.realE1TempString != "0" | controlpanel.realE2TempString != "0")
            anchors.fill: parent
            lineColor: QD.Theme.getColor("red_1")
        }

        LineCanvas
        {
            id: bedExpectLine
            visible: (controlpanel.realE1TempString != "0" | controlpanel.realE2TempString != "0")
            anchors.fill: parent
            lineColor: QD.Theme.getColor("red_1")
            isPointLine: true
        }
    }

    Item
    {
        id: lastItem
        height: 40 * QD.Theme.getSize("size").width
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: QD.Theme.getSize("size").width

        QIDI.SecondaryButton
        {
            id: temButton
            height: 21 * QD.Theme.getSize("size").height
            text:  catalog.i18nc("@button", "Clear Plot Data")
            font: QD.Theme.getFont("font1")
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            backgroundRadius: Math.round(height / 2)
            leftPadding: 10 * QD.Theme.getSize("size").height
            onClicked:
            {
                e1Line.cLearCurrenIndex = currenIndex * 2
                e1ExpectLine.cLearCurrenIndex = currenIndex * 2
                e2Line.cLearCurrenIndex = currenIndex * 2
                e2ExpectLine.cLearCurrenIndex = currenIndex * 2
                bedLine.cLearCurrenIndex = currenIndex * 2
                bedExpectLine.cLearCurrenIndex = currenIndex * 2
                rePaint()
            }
        }
    }
}
