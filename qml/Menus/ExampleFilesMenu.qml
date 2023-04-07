// Copyright (c) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1

import QD 1.3 as QD
import QIDI 1.0 as QIDI

import "../Dialogs"

Menu
{
    id: menu
    title: catalog.i18nc("@title:menu menubar:file", "Examples")
    enabled: QIDIApplication.exampleFiles.length > 0;

    Instantiator
    {
        model: QIDIApplication.exampleFiles
        MenuItem
        {
            text:
            {
                var path = decodeURIComponent(modelData.toString())
                return (index + 1) + ". " + path.slice(path.lastIndexOf("/") + 1);
            }
            onTriggered: QIDIApplication.readLocalFile(modelData)
        }
        onObjectAdded: menu.insertItem(index, object)
        onObjectRemoved: menu.removeItem(object)
    }

    QIDI.AskOpenAsProjectOrModelsDialog
    {
        id: askOpenAsProjectOrModelsDialog
    }
}