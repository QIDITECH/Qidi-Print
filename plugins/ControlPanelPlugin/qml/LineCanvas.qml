import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 //ExclusiveGroup
import QtQuick 2.0
import QtQuick.Controls 2.12

import QD 1.1 as QD
import QIDI 1.1 as QIDI
Canvas
{
    id: linecanvas
    visible: true
    anchors.fill: parent
    antialiasing: true //反锯齿

    property var isPointLine: false
    property var lineColor: ""
    property var color: ""
    property var dataArray: []
    property var cLearCurrenIndex: 2
    property var spacing: 0

    Timer
    {
        id: likeClearTimer
        running: cLearCurrenIndex > 0
        repeat: true
        interval: 2000
        onTriggered:
        {
            cLearCurrenIndex -= 1
            if(cLearCurrenIndex == 0)
            {
                likeClearTimer.stop()
            }
        }
    }

    onPaint: {
        var foldline = getContext("2d");
        var width = linecanvas.width - 40 * QD.Theme.getSize("size").width
        var height = linecanvas.height - 40 * QD.Theme.getSize("size").width

        foldline.fillStyle = QD.Theme.getColor("white_2");
        foldline.fillRect(30, 20, width, height);

        //起点的x,y
        var Qwidth = 30
        var Qheight = 20

        //终点的x,y
        var Zwidth = width + 30
        var Zheight = height + 20

        //横线高度间隔
        var ySpacing = height / 7
        //竖线宽度间隔
        var xSpacing = width / 10

        spacing = ySpacing / 50

        //画折线
        var startx = 0
        var starty = 0
        var endx = 0
        var endy = 0

        var a = 0
        var time = 0
        var first = dataArray[0]

        //温度数组限制10个数，时间限制在20秒，每2秒一次，在每一次的 requestPaint（）中都将画布中增长的全部的数据重新更新，即为重新绘制数据做准备
        //上一个2秒是另外的一组10个数据，会全部被绘制出来，下一个2秒是另外一组数据，会再次被绘画出来，而上一个2秒的绘制图形则被clear()清除
        while(time < 52)
        {
            if(cLearCurrenIndex > time)
            {
                color = QD.Theme.getColor("white_2")
                likeClearTimer.start()
            }
            else
            {
                color = lineColor
            }
            if(time == 0)
            {
                // 点击连接开始到显示有2秒时间 (time + 2) 若加上没有办法正常进行
                startx = Qwidth + time * (xSpacing / 5)
                starty = Zheight - first * (ySpacing / 50)
                endx = Qwidth + time * (xSpacing / 5)
                endy = Zheight - dataArray[a] * (ySpacing / 50)
                linecanvas.drawLine(foldline, color == "" ? QD.Theme.getColor("text") : color, isPointLine ? 2 : 0.5,  startx, starty, endx, endy);
            }
            else
            {
                startx = Qwidth + (time - 2) * (xSpacing / 5)
                starty = Zheight - first * (ySpacing / 50)
                endx = Qwidth + time * (xSpacing / 5)
                endy = Zheight - dataArray[a] * (ySpacing / 50)
                linecanvas.drawLine(foldline, color == "" ? QD.Theme.getColor("text") : color, isPointLine ? 2 : 0.5,  startx, starty, endx, endy);
            }

            first = dataArray[a]
            time += 2
            a ++
        }
    }

    //画笔，颜色，宽度，起点x，起点y，终点x，终点y
    function drawLine(ctx, color, width, startX, startY, endX, endY)
    {
        //画虚线设置
        if(isPointLine)
            //设置有问题，设置为2 的话，在缩小的窗口看起来是紊乱的，但是放大后确是正常的；
            //设置为 3 的话，是在缩小的范围是正常的，但是在放大的窗口确是不正常的
            //设置成一个单位也是不正常，所以可以考虑换个颜色，虚线有很多的紊乱，不确定
            //[实线部分，虚线部分]
            ctx.setLineDash([2,8])
        else
            ctx.setLineDash([])
        ctx.strokeStyle = color;
        ctx.lineWidth = width;
        ctx.beginPath();
        ctx.moveTo(startX, startY);
        ctx.lineTo(endX, endY);
        ctx.closePath();
        ctx.stroke();
    }

    function clear()
    {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
    }
}
