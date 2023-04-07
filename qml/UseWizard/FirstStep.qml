
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
        id: firstStep
        anchors.fill: parent

        MouseArea 
        {
            anchors.fill: parent
            onClicked: base.showNextPage()
        }

        Rectangle
        {
            id: firstStepShadow
            anchors.top: parent.top
            anchors.left: parent.left
            width: 51 * QD.Theme.getSize("size").width
            height: 20 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: firstStepShadow2
            anchors.fill: parent
            anchors.leftMargin: toolbar.width + QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: firstStepShadow3
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: firstStepShadow2.left
            anchors.top: parent.top
            anchors.topMargin: 75 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: firstSteprec
            anchors.left: parent.left
            anchors.top: firstStepShadow.bottom
            anchors.bottom: firstStepShadow3.top
            anchors.right:firstStepShadow2.left
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        QD.RecolorImage
        {
            id: firstStepArrow
            anchors.left: firstSteprec.right
            anchors.verticalCenter: firstSteprec.verticalCenter
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_left")
        }

        Label
        {
            id: firstStepLabel
            anchors.left: firstStepArrow.left
            anchors.leftMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: firstStepArrow.verticalCenter
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label","1. Open the file")
            verticalAlignment: Text.AlignVCenter
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