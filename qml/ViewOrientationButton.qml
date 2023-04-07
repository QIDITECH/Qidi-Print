
import QtQuick 2.2

import QD 1.4 as QD

QD.SimpleButton
{
    width: 25 * QD.Theme.getSize("size").width
    height: 25 * QD.Theme.getSize("size").width
    color: QD.Theme.getColor("blue_6")
    iconMargin: hovered ? QD.Theme.getSize("size").width : 3 * QD.Theme.getSize("size").width
    Rectangle
    {
        id: backgroundRect
        anchors.fill: parent
        color: QD.Theme.getColor("white_2")
        border.color: QD.Theme.getColor("gray_6")
        radius: 3 * QD.Theme.getSize("size").width
        visible: checked
    }
}