// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0  // For the DropShadow

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This is an Item that tries to mimic a dialog for showing the welcome process.
//
Item
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    id: dialog

    anchors.centerIn: parent

    width: QD.Theme.getSize("modal_window_minimum").width*1.07//*1.30 + 30*QD.Theme.getSize("size").width
    height: QD.Theme.getSize("modal_window_minimum").height * 1.07 //*0.92

    property int shadowOffset: 1 * screenScaleFactor

    property alias progressBarVisible: wizardPanel.progressBarVisible
    property var model: QIDIApplication.getWelcomePagesModel()

    onVisibleChanged:
    {
        if (visible)
        {
            model.resetState()
        }
    }

    WizardPanel
    {
        id: wizardPanel
        anchors.fill: parent
        model: dialog.model
    }

    // Drop shadow around the panel
    DropShadow
    {
        id: shadow
        radius: QD.Theme.getSize("first_run_shadow_radius").width
        anchors.fill: wizardPanel
        source: wizardPanel
        horizontalOffset: shadowOffset
        verticalOffset: shadowOffset
        color: QD.Theme.getColor("first_run_shadow")
        transparentBorder: true
    }

    // Close this dialog when there's no more page to show
    Connections
    {
        target: model
        function onAllFinished() { dialog.visible = false }
    }
}
