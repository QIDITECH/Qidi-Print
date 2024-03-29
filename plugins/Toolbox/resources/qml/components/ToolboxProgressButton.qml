// Copyright (c) 2019 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.1 as QD
import QIDI 1.0 as QIDI


QIDI.PrimaryButton
{
    id: button

    property var active: false
    property var complete: false

    property var readyLabel: catalog.i18nc("@action:button", "Install")
    property var activeLabel: catalog.i18nc("@action:button", "Cancel")
    property var completeLabel: catalog.i18nc("@action:button", "Installed")

    signal readyAction() // Action when button is ready and clicked (likely install)
    signal activeAction() // Action when button is active and clicked (likely cancel)
    signal completeAction() // Action when button is complete and clicked (likely go to installed)

    width: QD.Theme.getSize("toolbox_action_button").width
    height: QD.Theme.getSize("toolbox_action_button").height
    fixedWidthMode: true
    text:
    {
        if (complete)
        {
            return completeLabel
        }
        else if (active)
        {
            return activeLabel
        }
        else
        {
            return readyLabel
        }
    }
    onClicked:
    {
        if (complete)
        {
            completeAction()
        }
        else if (active)
        {
            activeAction()
        }
        else
        {
            readyAction()
        }
    }
    busy: active
}
