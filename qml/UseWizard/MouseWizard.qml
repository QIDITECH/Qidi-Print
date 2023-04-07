
import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import QD 1.4 as QD
import QIDI 1.0 as QIDI


Item
{
    anchors.fill: parent

    QD.I18nCatalog{id: catalog; name:"qidi"}
    Item
    {
        id: mouseWizard

        anchors.fill: parent
        MouseArea 
        {
            anchors.fill: parent
            onClicked: base.showNextPage()
        }

        Rectangle
        {
            id: mouseWizardShadow
            anchors.fill: parent
            color: QD.Theme.getColor("gray_6")
        }

        QD.RecolorImage
        {
            id: firstMouse
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 20 * QD.Theme.getSize("size").width
            width: 124 * QD.Theme.getSize("size").width
            height: 193 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: height
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("Mouse")
        }

        QD.RecolorImage
        {
            id: leftButtonArrow
            anchors.verticalCenter: firstMouse.verticalCenter
            anchors.horizontalCenter: firstMouse.horizontalCenter
            anchors.verticalCenterOffset: -70 * QD.Theme.getSize("size").width
            anchors.horizontalCenterOffset: -70 * QD.Theme.getSize("size").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_right")
        }

        Label
        {
            id: leftButtonLabel
            anchors.right: leftButtonArrow.right
            anchors.rightMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: leftButtonArrow.verticalCenter
            anchors.verticalCenterOffset: -QD.Theme.getSize("size").width
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "Left Button: Click to select and the model for operations")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignRight
        }

        QD.RecolorImage
        {
            id: rightButtonArrow
            anchors.verticalCenter: firstMouse.verticalCenter
            anchors.horizontalCenter: firstMouse.horizontalCenter
            anchors.verticalCenterOffset: -70 * QD.Theme.getSize("size").width
            anchors.horizontalCenterOffset: 70 * QD.Theme.getSize("size").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_left")
        }

        Label
        {
            id: rightButtonLabel
            anchors.left: rightButtonArrow.left
            anchors.leftMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: rightButtonArrow.verticalCenter
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "Right Button: Click and drag to change camera viewpoint")
            wrapMode: Text.WordWrap
        }

        QD.RecolorImage
        {
            id: medialButtonArrow
            anchors.verticalCenter: firstMouse.verticalCenter
            anchors.horizontalCenter: firstMouse.horizontalCenter
            anchors.verticalCenterOffset: -110 * QD.Theme.getSize("size").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_bottom")
        }

        Label
        {
            id: medialButtonLabel
            anchors.horizontalCenter: medialButtonArrow.horizontalCenter
            anchors.horizontalCenterOffset: 100 * QD.Theme.getSize("size").width
            anchors.verticalCenter: medialButtonArrow.verticalCenter
            anchors.verticalCenterOffset: -30 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "Wheel: Roll to zoom in and out \nClick and drag to pan the camera")
            wrapMode: Text.WordWrap
        }

        Rectangle
        {
            id: mouseWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 180 * QD.Theme.getSize("size").width
            width: 100 * QD.Theme.getSize("size").width
            height: 50 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("white_1")
            radius: height / 2
        }

        Label
        {
            id: mouseWizardButtonLabel
            anchors.horizontalCenter: mouseWizardButton.horizontalCenter
            anchors.verticalCenter: mouseWizardButton.verticalCenter
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "Next")
        }
    }
}