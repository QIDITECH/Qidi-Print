
import QtQuick 2.2
import QtQuick.Controls 1.2

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Item
{
    id: base
    width: childrenRect.width
    height: childrenRect.height

    Grid
    {
        id: supportSettingGrid
        anchors.top: parent.top
        anchors.left: parent.left
        columns: 2
        flow: Grid.TopToBottom
        rowSpacing: 5 * QD.Theme.getSize("size").height
        columnSpacing: 10 * QD.Theme.getSize("size").height

        Label
        {
            height: 22 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@label","Support Type")
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("black_1")
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth)
        }

        Label
        {
            height: 22 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@label","Support Size")
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("black_1")
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth)
        }

        Label
        {
            height: 22 * QD.Theme.getSize("size").height
            text: catalog.i18nc("@label","Support Base")
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("black_1")
            verticalAlignment: Text.AlignVCenter
            renderType: Text.NativeRendering
            width: Math.ceil(contentWidth)
        }

        QIDI.ComboBox
        {
            height: 22 * QD.Theme.getSize("size").height
            width: 100 * QD.Theme.getSize("size").height
            model: ListModel
            {
                Component.onCompleted: {
                    append({ text: catalog.i18nc("@label", "Cube"), type: "cube" })
                    append({ text: catalog.i18nc("@label", "Cylinder"), type: "cylinder" })
                }
            }
            textRole: "text"
            currentIndex: QD.ActiveTool.properties.getValue("SupportType") === 'cube' ? 0 : 1
            onActivated: QD.ActiveTool.setProperty("SupportType", model.get(index).type)
        }

        TextField
        {
            height: 22 * QD.Theme.getSize("size").height
            width: 100 * QD.Theme.getSize("size").height
            property string unit: "mm"
            style: QD.Theme.styles.text_field
            text: QD.ActiveTool.properties.getValue("SupportSize")
            validator: DoubleValidator
            {
                decimals: 2
                bottom: 0.1
                locale: "en_US"
            }
            onEditingFinished:
            {
                var modified_text = text.replace(",", ".")
                QD.ActiveTool.setProperty("SupportSize", modified_text)
            }
        }

        TextField
        {
            height: 22 * QD.Theme.getSize("size").height
            width: 100 * QD.Theme.getSize("size").height
            property string unit: "mm"
            style: QD.Theme.styles.text_field
            text: QD.ActiveTool.properties.getValue("SupportBaseSize")
            validator: DoubleValidator
            {
                decimals: 2
                bottom: 0.1
                locale: "en_US"
            }
            onEditingFinished:
            {
                var modified_text = text.replace(",", ".")
                QD.ActiveTool.setProperty("SupportBaseSize", modified_text)
            }
        }
    }

    QIDI.PrimaryButton
    {
        id: removeAllButton
        height: 20 * QD.Theme.getSize("size").height
        backgroundRadius: height / 2
        anchors.top: supportSettingGrid.bottom
        anchors.topMargin: 5 * QD.Theme.getSize("size").height
        anchors.right: supportSettingGrid.right
        text: catalog.i18nc("@button", "Remove All Support")
        onClicked: QD.ActiveTool.triggerAction("removeAllSupportMesh");
    }
}
