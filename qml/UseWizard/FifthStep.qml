
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
        id: fifthStep
        anchors.fill: parent

        MouseArea 
        {
            anchors.fill: parent
            onClicked: base.showNextPage()
        }

        Rectangle
        {
            id: fifthStepShadow
            anchors.fill: parent
            anchors.rightMargin: printSetupSelector.width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: fifthStepShadow2
            anchors.top: parent.top
            anchors.right: parent.right
            height:20 * QD.Theme.getSize("size").width
            width: printSetupSelector.width
            color: QD.Theme.getColor("gray_6")
        }

        Rectangle
        {
            id: selectMachineBox
            height:84 * QD.Theme.getSize("size").height
            anchors.top: parent.top
            anchors.topMargin: applicationMenu.height//20 * QD.Theme.getSize("size").width
            anchors.right: parent.right
            width: printSetupSelector.width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        Rectangle
        {
            id: profileBox
            height: 34 * QD.Theme.getSize("size").width
            anchors.top: selectMachineBox.bottom
            anchors.topMargin:  QD.Theme.getSize("default_margin").width - 2 * QD.Theme.getSize("size").width
            anchors.right: parent.right
            width: selectMachineBox.width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        Rectangle
        {
            id: configureParametersBox
            anchors.top: profileBox.bottom
            anchors.topMargin: QD.Theme.getSize("size").width
			anchors.bottom: fileNameBox.top
			anchors.bottomMargin: 2 * QD.Theme.getSize("size").width
            //height: parent.height - 272 * QD.Theme.getSize("size").width
            anchors.right: parent.right
            width: selectMachineBox.width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        Rectangle
        {
            id: fileNameBox
            anchors.bottom: sliceBox.top
            anchors.bottomMargin: 2 * QD.Theme.getSize("size").width
            height: 72 * QD.Theme.getSize("size").width
            anchors.right: parent.right
            width: selectMachineBox.width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        Rectangle
        {
            id: sliceBox
            height: 50 * QD.Theme.getSize("size").width
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: selectMachineBox.width
            color: QD.Theme.getColor("white_2")
            border.width: 2 * QD.Theme.getSize("size").width
            border.color: QD.Theme.getColor("red_1")
        }

        QD.RecolorImage
        {
            id: selectMachineArrow
            anchors.verticalCenter: selectMachineBox.verticalCenter
            anchors.right: fifthStepShadow.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_right")
        }

        Label
        {
            id: selectMachineLabel
            anchors.right: selectMachineArrow.right
            anchors.rightMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: selectMachineArrow.verticalCenter
            anchors.verticalCenterOffset: -QD.Theme.getSize("size").width
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "6. Select the Printer")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }

        QD.RecolorImage
        {
            id: profileArrow
            anchors.verticalCenter: profileBox.verticalCenter
            anchors.right: fifthStepShadow.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_right")
        }

        Label
        {
            id: profileLabel
            anchors.right: profileArrow.right
            anchors.rightMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: profileArrow.verticalCenter
            anchors.verticalCenterOffset: -QD.Theme.getSize("size").width
            width: 380 * QD.Theme.getSize("size").width
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "7. Select the configuration")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }

        QD.RecolorImage
        {
            id: configureParametersArrow
            //anchors.top: parent.top
            //anchors.topMargin: 350 * QD.Theme.getSize("size").width
			anchors.verticalCenter: configureParametersBox.verticalCenter

            anchors.right: fifthStepShadow.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_right")
        }

        Label
        {
            id: configureParametersLabe
            anchors.right: configureParametersArrow.right
            anchors.rightMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: configureParametersArrow.verticalCenter
            anchors.verticalCenterOffset: -QD.Theme.getSize("size").width
            width: 380 * QD.Theme.getSize("size").width
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "8. Adjust the parameters");
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }

        QD.RecolorImage
        {
            id: sliceArrow
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20 * QD.Theme.getSize("size").width
            anchors.right: fifthStepShadow.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_right")
        }

        Label
        {
            id: sliceLabel
            anchors.right: sliceArrow.right
            anchors.rightMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: sliceArrow.verticalCenter
            width: 480 * QD.Theme.getSize("size").width
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label", "10. Begin to slice")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }

        QD.RecolorImage
        {
            id: fileNameArrow
            anchors.verticalCenter: fileNameBox.verticalCenter
            anchors.verticalCenterOffset:  QD.Theme.getSize("size").width
            anchors.right: fifthStepShadow.right
            anchors.rightMargin: QD.Theme.getSize("default_margin").width
            width: 15 * QD.Theme.getSize("size").width
            height: 15 * QD.Theme.getSize("size").width
            sourceSize.width: width
            sourceSize.height: width
            color: QD.Theme.getColor("white_1")
            source: QD.Theme.getIcon("arrow_right")
        }

        Label
        {
            id: fileNameLabel
            anchors.right: fileNameArrow.right
            anchors.rightMargin: 30 * QD.Theme.getSize("size").width
            anchors.verticalCenter: fileNameArrow.verticalCenter
            anchors.verticalCenterOffset: -1 * QD.Theme.getSize("size").width
            width: 380 * QD.Theme.getSize("size").width
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("white_1")
            font: QD.Theme.getFont("font2")
            text: catalog.i18nc("@action:label","9. Rename")
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
        }

        Rectangle
        {
            id: mouseWizardButton
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

			anchors.horizontalCenterOffset: -50 * QD.Theme.getSize("size").width

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
            text: catalog.i18nc("@action:label","Start")
        }
    }
}