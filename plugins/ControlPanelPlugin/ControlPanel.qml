import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1
import QD 1.1 as QD
import QIDI 1.1 as QIDI
import "./qml"






ApplicationWindow
{
    id: baseWindow
    minimumWidth: 1220  * QD.Theme.getSize("size").width  | 0
    minimumHeight: 705 * QD.Theme.getSize("size").width   | 0
    width: minimumWidth
    height: minimumHeight
	property string stateconrotl: "DisConnect"
	property Item  lastitem
	
	
    title: "Control Panel"/*catalog.i18nc("@title:window", "Control Panel")*/
//    modality: Qt.ApplicationModal;//使得窗口一直置前（模拟窗口），若窗口被缩小，焦点也还会在该窗口上，对于其他的无法操作

    Rectangle
    {
        id: backGround
        anchors.fill: parent
        color: QD.Theme.getColor("gray_5")
    }

    DevicesList
    {
        id: devicelist
        height: parent.height - deviceInfo.height - 15 * QD.Theme.getSize("size").height
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 5 * QD.Theme.getSize("size").height
    }

    DeviceInfo
    {
        id: deviceInfo
        height: 280 * QD.Theme.getSize("size").height
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 5 * QD.Theme.getSize("size").height
    }

    /*XYZControl
    {
        id: xyzControl
        height: 230 * QD.Theme.getSize("size").height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5 * QD.Theme.getSize("size").height
    }

    HeatingControl
    {
        id: heatingControl
        anchors.top: xyzControl.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5 * QD.Theme.getSize("size").height
    }*/

    MiddleSpace
    {
        id: middleSpace
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: devicelist.right
        anchors.right: parent.right
        anchors.margins: 5 * QD.Theme.getSize("size").height
    }

    QD.MessageStack
    {
        anchors
        {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        primaryButton: Component
        {
            QIDI.PrimaryButton
            {
                text: model.name
                height: QD.Theme.getSize("message_action_button").height
            }
        }

        secondaryButton: Component
        {
            QIDI.SecondaryButton
            {
                text: model.name
                height: QD.Theme.getSize("message_action_button").height
            }
        }
    }
}
