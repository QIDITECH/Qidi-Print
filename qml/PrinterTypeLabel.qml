// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1

import QD 1.1 as QD

// This component creates a label with the abbreviated name of a printer, with a rectangle surrounding the label.
// It is created in a separated place in order to be reused whenever needed.
Item
{
    property alias text: printerTypeLabel.text

    property bool autoFit: false

    width: autoFit ? (printerTypeLabel.width + QD.Theme.getSize("default_margin").width) : QD.Theme.getSize("printer_type_label").width
    height: QD.Theme.getSize("printer_type_label").height

    Rectangle
    {
        anchors.fill: parent
        color: QD.Theme.getColor("printer_type_label_background")
        radius: QD.Theme.getSize("checkbox_radius").width
    }

    Label
    {
        id: printerTypeLabel
        text: "CFFFP" // As an abbreviated name of the Custom FFF Printer
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        renderType: Text.NativeRendering
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text")
    }
}