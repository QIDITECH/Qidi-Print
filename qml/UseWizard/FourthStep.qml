
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
        id: fourthStep
        anchors.fill: parent

        MouseArea
        {
            anchors.fill: parent
            onClicked: base.showNextPage()
        }

        Rectangle
        {
            id: fourthStepShadow
            anchors.top: parent.top
            anchors.left: parent.left
            width: 51 * QD.Theme.getSize("size").width
            height: 65 * QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: fourthStepShadow2
            anchors.fill: parent
            anchors.leftMargin: toolbar.width + QD.Theme.getSize("size").width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: fourthSteprec
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.top: fourthStepShadow.bottom
            width: toolbar.width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        QD.RecolorImage
        {
            id: fourthStepArrow
            anchors.top: parent.top
            anchors.topMargin: 230 * QD.Theme.getSize("size").width
            anchors.left: fourthStepShadow.right
            anchors.leftMargin: QD.Theme.getSize("default_margin").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_left")
        }

        Label
        {
            id: fourthStepLabel
            anchors.left: fourthStepArrow.left
            anchors.leftMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: fourthStepArrow.verticalCenter
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label","5. Tools")
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