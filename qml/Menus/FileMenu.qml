// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1

import QD 1.6 as QD
import QIDI 1.0 as QIDI

Menu
{
    id: base
    title: catalog.i18nc("@title:menu menubar:toplevel", "&File")
    property var fileProviderModel: QIDIApplication.getFileProviderModel()

    MenuItem
    {
        id: newProjectMenu
        action: QIDI.Actions.newProject
    }

    MenuItem
    {
        id: openMenu
        action: QIDI.Actions.open
        visible: (base.fileProviderModel.count == 1)
    }

    OpenFilesMenu
    {
        id: openFilesMenu
        visible: (base.fileProviderModel.count > 1)
    }

    RecentFilesMenu { }

    ExampleFilesMenu { }

    MenuItem
    {
        id: saveWorkspaceMenu
        shortcut: visible ? StandardKey.Save : ""
        text: catalog.i18nc("@title:menu menubar:file", "&Save Project...")
        visible: saveProjectMenu.model.count == 1
        enabled: QD.WorkspaceFileHandler.enabled
        onTriggered:
        {
            var args = { "filter_by_machine": false, "file_type": "workspace", "preferred_mimetypes": "application/vnd.ms-package.3dmanufacturing-3dmodel+xml" };
            if(QD.Preferences.getValue("qidi/dialog_on_project_save"))
            {
                saveWorkspaceDialog.args = args
                saveWorkspaceDialog.open()
            }
            else
            {
                QD.OutputDeviceManager.requestWriteToDevice("local_file", PrintInformation.jobName, args)
            }
        }
    }

    QD.ProjectOutputDevicesModel { id: projectOutputDevicesModel }

    SaveProjectMenu
    {
        id: saveProjectMenu
        model: projectOutputDevicesModel
        visible: model.count > 1
        enabled: QD.WorkspaceFileHandler.enabled
    }

    MenuSeparator { }

    MenuItem
    {
        id: saveAsMenu
        text: catalog.i18nc("@title:menu menubar:file", "&Export...")
        onTriggered:
        {
            var localDeviceId = "local_file"
            QD.OutputDeviceManager.requestWriteToDevice(localDeviceId, PrintInformation.jobName, { "filter_by_machine": false, "preferred_mimetypes": "application/vnd.ms-package.3dmanufacturing-3dmodel+xml"})
        }
    }

    MenuItem
    {
        id: exportSelectionMenu
        text: catalog.i18nc("@action:inmenu menubar:file", "Export Selection...")
        enabled: QD.Selection.hasSelection
        iconName: "document-save-as"
        onTriggered: QD.OutputDeviceManager.requestWriteSelectionToDevice("local_file", PrintInformation.jobName, { "filter_by_machine": false, "preferred_mimetypes": "application/vnd.ms-package.3dmanufacturing-3dmodel+xml"})
    }

    MenuSeparator { }

    MenuItem
    {
        id: reloadAllMenu
        action: QIDI.Actions.reloadAll
    }

    MenuSeparator { }

    MenuItem { action: QIDI.Actions.quit }
}
