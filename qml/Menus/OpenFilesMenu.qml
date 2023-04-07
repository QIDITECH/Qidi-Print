// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1

import QD 1.6 as QD
import QIDI 1.0 as QIDI

import "../Dialogs"

Menu
{
    id: openFilesMenu
    title: catalog.i18nc("@title:menu menubar:file", "Open File(s)...")
    iconName: "document-open-recent";

    Instantiator
    {
        id: fileProviders
        model: QIDIApplication.getFileProviderModel()
        MenuItem
        {
            text:
            {
                return model.displayText;
            }
            onTriggered:
            {
                if (model.index == 0)  // The 0th element is the "From Disk" option, which should activate the open local file dialog
                {
                    QIDI.Actions.open.trigger()
                }
                else
                {
                    QIDIApplication.getFileProviderModel().trigger(model.name);
                }
            }
            // Unassign the shortcuts when the submenu is invisible (i.e. when there is only one file provider) to avoid ambiguous shortcuts.
            // When there is a signle file provider, the openAction is assigned with the Ctrl+O shortcut instead.
            shortcut: openFilesMenu.visible ? model.shortcut : ""
        }
        onObjectAdded: openFilesMenu.insertItem(index, object)
        onObjectRemoved: openFilesMenu.removeItem(object)
    }
}
