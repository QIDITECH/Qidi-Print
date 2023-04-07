import QtQuick 2.0
import QD 1.1 as QD
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3

Rectangle {
    id: root
    color: "transparent"
    opacity: 0.0
    //property alias enabled: mouseArea.enabled
    property int dialogWidth: 300
    property int dialogHeight: 100
    state: enabled ? "on" : "baseState"

    states: [
        State {
            name: "on"
            PropertyChanges {
                target: root
                opacity: 1.0
            }
        }
    ]

    transitions: [
        Transition {
            from: "*"
            to: "*"
            NumberAnimation {
                properties: "opacity"
                easing.type: Easing.OutQuart
                duration: 500
            }
        }
    ]

    Rectangle {
        anchors.fill: parent
        color: QD.Theme.getColor("white_2")
        opacity: 0.75
    }

    Rectangle {
        anchors.centerIn: parent
        width: dialogWidth
        height: dialogHeight
        radius: 5
        color: QD.Theme.getColor("white_3")
        border.width: 1
        border.color: "black"
        Text {
            id: text
            anchors.fill: parent
            anchors.margins: 10
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "black"
            wrapMode: Text.WordWrap
        }
        Button
        {
            id: closeButton
            width: QD.Theme.getSize("message_close").width
            height: QD.Theme.getSize("message_close").height

            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            style: ButtonStyle
            {
                background: QD.RecolorImage
                {
                    width: QD.Theme.getSize("message_close").width
                    sourceSize.width: width
                    color: control.hovered ? QD.Theme.getColor("message_close_hover") : QD.Theme.getColor("message_close")
                    source: QD.Theme.getIcon("Cancel")
                }

                label: Item {}
            }

            onClicked: root.enabled = false
        }
    }

    //MouseArea {
    //    id: mouseArea
    //    anchors.fill: parent
    //    onClicked: root.enabled = false
    //}

    function show(msg) {
        text.text = "<b>Dialog</b><br><br>" + msg
        root.enabled = true
    }
}
