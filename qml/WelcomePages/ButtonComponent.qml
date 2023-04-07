
import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QD 1.3 as QD
import QIDI 1.0 as QIDI



Button
{
	id:buttonComponentItem

	property alias atext:  buttonText.text
	//property alias textColor: buttonText.color
	property var   borderColor: "#6495ED"
	property var   pressedColor: "#1575F2"
	property var   fontSize:  10
	property var   onClick: null
	property var   textColor: "black"
	property bool   checked: false
	property bool   hot: false
	//id:buttonComponent
	//anchors.fill: parent
	
	Label
	{
		anchors.left:parent.left
		anchors.leftMargin: 10 * QD.Theme.getSize("size").height
		anchors.verticalCenter: parent.verticalCenter

		id: buttonText
		font: QD.Theme.getFont("font1")
		wrapMode: Text.WrapAnywhere

		color: checked? textColor :  "black"
	}
	QD.RecolorImage{
		anchors.right:parent.right
		anchors.rightMargin: 10 * QD.Theme.getSize("size").height
		//anchors.bottom:parent.bottom
		anchors.verticalCenter: parent.verticalCenter
		height:15 * QD.Theme.getSize("size").height
		width:15 * QD.Theme.getSize("size").height
		source:QD.Theme.getIcon("hot","default")
		color:QD.Theme.getColor("red_1")
		visible:hot
	}
	style: ButtonStyle
	{
		background: Rectangle
		{
			id:butstyle
			//border.width: control.hovered?2:0
			//border.color: control.hovered?"#D3D3D3":buttonComponentItem.borderColor
			color:checked?  QD.Theme.getColor("gray_12") : control.hovered? QD.Theme.getColor("gray_12"): QD.Theme.getColor("white_1")//"#6495ED" 
			//radius: 6

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


	/*onHoveredChanged:
	{
		if (buttonComponentItem.hovered)
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
	ScaleAnimator
	{
		id:buttonScaleAnimator
		target: buttonComponentItem
		duration: 200
	}*/
}





