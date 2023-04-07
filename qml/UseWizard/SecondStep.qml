
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
        id: secondStep
        anchors.fill: parent

        MouseArea 
        {
            anchors.fill: parent
            onClicked: base.showNextPage()
        }

        Rectangle
        {
            id: secondStepShadow
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            height: 21 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: secondStepShadow2
            anchors.top: secondStepShadow.bottom
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: printSetupSelector.width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: secondStepShadow3
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: secondStepShadow.bottom
            width: toolbar.width + QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: secondSteprec
            anchors.left: secondStepShadow3.right
            anchors.top: secondStepShadow.bottom
            anchors.bottom: parent.bottom
            anchors.right: secondStepShadow2.left
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        QD.RecolorImage
        {
            id: secondStepArrow
            anchors.left: secondSteprec.right
            anchors.verticalCenter: secondSteprec.verticalCenter
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_left")
        }

        Label
        {
            id: secondStepLabel
            anchors.left: secondStepArrow.left
            anchors.leftMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: secondSteprec.verticalCenter
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label","2. You can see the open model here")
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle
        {
            id: mouseWizardButton
            anchors.top: secondStepLabel.bottom
            anchors.topMargin: 40 * QD.Theme.getSize("size").width
            anchors.horizontalCenter: secondStepShadow2.horizontalCenter
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