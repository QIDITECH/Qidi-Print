// Copyright (c) 2019 Ultimaker B.V.
// Copyright (c) 2022 Aldo Hoeben / fieldOfView
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 2.0

import QD 1.5 as QD
import QIDI 1.0 as QIDI

QD.Dialog
{
    id: base

    function setName(new_name) {
        nameField.text = new_name;
        nameField.selectAll();
        nameField.forceActiveFocus();
    }

    buttonSpacing: QD.Theme.getSize("default_margin").width

    property bool validName: true
    property string validationError
    property string dialogTitle: catalog.i18nc("@title:window", "Rename")
    property string explanation: catalog.i18nc("@info", "Please provide a new name.")

    title: dialogTitle

    minimumWidth: QD.Theme.getSize("small_popup_dialog").width
    minimumHeight: QD.Theme.getSize("small_popup_dialog").height
    width: minimumWidth
    height: minimumHeight

    property variant catalog: QD.I18nCatalog { name: "uranium" }

    onAccepted:
    {
        manager.setSelectedMeshName(nameField.text)
    }

    Column
    {
        anchors.fill: parent

        QD.Label
        {
            text: base.explanation + "\n" //Newline to make some space using system theming.
            width: parent.width
            wrapMode: Text.WordWrap
        }

        QIDI.TextField
        {
            id: nameField
            width: parent.width
            text: base.object
            maximumLength: 40
        }
    }

    rightButtons: [
        QIDI.SecondaryButton
        {
            id: cancelButton
            text: catalog.i18nc("@action:button","Cancel")
            onClicked: base.reject()
        },
        QIDI.PrimaryButton
        {
            id: okButton
            text: catalog.i18nc("@action:button", "OK")
            onClicked: base.accept()
            enabled: base.validName
        }
    ]
}

