// Copyright (c) 2017 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 2.0

import QD 1.2 as QD
import QIDI 1.0 as QIDI

QIDI.ToolbarButton
{
    id: base

    property var extruder

    text: catalog.i18ncp("@label %1 is filled in with the name of an extruder", "Print Selected Model with %1", "Print Selected Models with %1", QD.Selection.selectionCount).arg(extruder.name)

    checked: QIDI.ExtruderManager.selectedObjectExtruders.indexOf(extruder.id) != -1
    enabled: QD.Selection.hasSelection && extruder.stack.isEnabled

    toolItem: ExtruderIcon
    {
        materialColor: extruder.color
        extruderEnabled: extruder.stack.isEnabled
        property int index: extruder.index
    }

    onClicked:
    {
        forceActiveFocus() //First grab focus, so all the text fields are updated
        QIDIActions.setExtruderForSelection(extruder.id)
    }
}
