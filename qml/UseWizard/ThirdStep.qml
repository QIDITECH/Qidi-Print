
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
        id: thirdStep
        anchors.fill: parent
        MouseArea 
        {
            anchors.fill: parent
            onClicked: base.showNextPage()
        }

        Rectangle
        {
            id: thirdStepShadow
            anchors.fill: parent
            anchors.topMargin: 55 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: thirdStepShadow2
            anchors.top: parent.top
            height: applicationMenu.height//22 * QD.Theme.getSize("size").width
            width : parent.width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: thirdStepShadow3
            anchors.top: thirdStepShadow2.bottom
            anchors.right: parent.right
            anchors.bottom: thirdStepShadow.top
            width: parent.width/2 + 55 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: thirdStepShadow4
            anchors.top: thirdStepShadow2.bottom
            anchors.bottom: thirdStepShadow.top
            anchors.left: parent.left
            anchors.right: thirdStepShadow3.left
            anchors.rightMargin:245 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: thirdSteprec1
            anchors.top: thirdStepShadow2.bottom
            anchors.left: thirdStepShadow4.right
            anchors.bottom: thirdStepShadow.top
            color: QD.Theme.getColor("white_2")
            width:150 * QD.Theme.getSize("size").width
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        Rectangle
        {
            id: thirdSteprec2
            anchors.top: thirdStepShadow2.bottom
            anchors.left: thirdSteprec1.right
            anchors.leftMargin: 5 * QD.Theme.getSize("size").width
            anchors.bottom: thirdStepShadow.top
            width: 90 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        QD.RecolorImage
        {
            id: thirdStepArrow1
            anchors.top: thirdSteprec1.bottom
            anchors.horizontalCenter: thirdSteprec1.horizontalCenter
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_top")
        }

        Label
        {
            id: thirdStepLabel1
            anchors.top: thirdStepArrow1.bottom
            anchors.topMargin: 5 * QD.Theme.getSize("size").width
            anchors.horizontalCenter: thirdStepArrow1.horizontalCenter
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label","3. Camera position")
            wrapMode: Text.WordWrap
        }

        QD.RecolorImage
        {
            id: thirdStepArrow2
            anchors.top: thirdSteprec2.bottom
            anchors.horizontalCenter:thirdSteprec2.horizontalCenter
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_top")
        }

        Label
        {
            id: thirdStepLabel2
            anchors.top: thirdStepArrow2.bottom
            anchors.topMargin: 5 * QD.Theme.getSize("size").width
            anchors.horizontalCenter: thirdStepArrow2.horizontalCenter
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label","4. View")
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
            text: catalog.i18nc("@action:label","Next")
        }
    }
}