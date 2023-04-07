// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Window 2.2

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This is a dialog for showing a set of processes that's defined in a WelcomePagesModel or some other Qt ListModel with
// a compatible interface.
//
Window
{
    QD.I18nCatalog { id: catalog; name: "qidi" }

    id: dialog

    flags: Qt.Dialog
    modality: Qt.ApplicationModal

    minimumWidth: QD.Theme.getSize("modal_window_minimum").width +30 * QD.Theme.getSize("size").width
    minimumHeight: QD.Theme.getSize("modal_window_minimum").height//*0.90
    maximumWidth: minimumWidth
    maximumHeight: minimumHeight

    color: QD.Theme.getColor("main_background")

    property var model: null  // Needs to be set by whoever is using this dialog.
    property alias progressBarVisible: wizardPanel.progressBarVisible

    function resetModelState()
    {
        model.resetState()
    }

    WizardPanel
    {
        id: wizardPanel
        anchors.fill: parent
        model: dialog.model
        visible: dialog.visible
    }

    // Close this dialog when there's no more page to show
    Connections
    {
        target: model
        function onAllFinished() { dialog.hide() }
    }
}
