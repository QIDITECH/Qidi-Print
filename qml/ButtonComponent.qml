
import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4



Item
{

    id:buttonComponentItem

    property alias text:  buttonText.text
    property alias textColor: buttonText.color
    property var   borderColor: "#6495ED"
    property var   pressedColor: "#1575F2"
    property var   fontSize:  12
    property var   onClick: null

    Button
    {

        id:buttonComponent
        anchors.fill: parent

        Text
        {
            id: buttonText
            font.family: "微软雅黑"
            font.pointSize: buttonComponentItem.fontSize
            anchors.centerIn: parent
            color: "white"
        }

        style: ButtonStyle
        {
            background: Rectangle
            {
                border.width: control.hovered?2:0
                border.color: control.hovered?"#D3D3D3":buttonComponentItem.borderColor
                color:control.pressed?buttonComponentItem.pressedColor:"#6495ED"
                radius: 6

                Behavior on color
                {
                    ColorAnimation
                    {
                        duration: 300
                    }
                }
            }
        }


        onClicked:
        {
            if (buttonComponentItem.onClick)
                buttonComponentItem.onClick();
        }


        onHoveredChanged:
        {
            if (buttonComponent.hovered)
            {
                buttonScaleAnimator.stop()
                buttonScaleAnimator.from = 1
                buttonScaleAnimator.to   = 1.05
                buttonScaleAnimator.start()
            }
            else
            {
                buttonScaleAnimator.stop()
                buttonScaleAnimator.from = 1.05
                buttonScaleAnimator.to   = 1
                buttonScaleAnimator.start()
            }
        }
    }

    ScaleAnimator
    {
        id:buttonScaleAnimator
        target: buttonComponent
        duration: 200
    }

}


