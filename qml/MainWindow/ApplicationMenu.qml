// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import QD 1.3 as QD
import QIDI 1.1 as QIDI

import "../Menus"
import "../Dialogs"

Item
{
    id: menu
    width: applicationMenu.width
    height: applicationMenu.height
    property alias window: applicationMenu.window

    QD.ApplicationMenu
    {
        id: applicationMenu

        FileMenu { title: catalog.i18nc("@title:menu menubar:toplevel", "&File") }

        Menu
        {
            title: catalog.i18nc("@title:menu menubar:toplevel", "&Edit")

            MenuItem { action: QIDI.Actions.undo }
            MenuItem { action: QIDI.Actions.redo }
            MenuSeparator { }
            MenuItem { action: QIDI.Actions.selectAll }
            MenuItem { action: QIDI.Actions.arrangeAll }
            MenuItem { action: QIDI.Actions.multiplySelection }
            MenuItem { action: QIDI.Actions.deleteSelection }
            MenuItem { action: QIDI.Actions.deleteAll }
            MenuItem { action: QIDI.Actions.resetAllTranslation }
            MenuItem { action: QIDI.Actions.resetAll }
            MenuSeparator { }
            MenuItem { action: QIDI.Actions.groupObjects }
            MenuItem { action: QIDI.Actions.mergeObjects }
            MenuItem { action: QIDI.Actions.unGroupObjects }
        }

        ViewMenu { title: catalog.i18nc("@title:menu menubar:toplevel", "&View") }

        SettingsMenu { title: catalog.i18nc("@title:menu menubar:toplevel", "&Settings") }

        Menu
        {
            id: extensionMenu
            title: catalog.i18nc("@title:menu menubar:toplevel", "E&xtensions")

            Instantiator
            {
                id: extensions
                model: QD.ExtensionModel { }

                Menu
                {
                    id: sub_menu
                    title: model.name;
                    visible: actions != null
                    enabled: actions != null
                    Instantiator
                    {
                        model: actions
                        Loader
                        {
                            property var extensionsModel: extensions.model
                            property var modelText: model.text
                            property var extensionName: name

                            sourceComponent: modelText.trim() == "" ? extensionsMenuSeparator : extensionsMenuItem
                        }

                        onObjectAdded: sub_menu.insertItem(index, object.item)
                        onObjectRemoved: sub_menu.removeItem(object.item)
                    }
                }

                onObjectAdded: extensionMenu.insertItem(index, object)
                onObjectRemoved: extensionMenu.removeItem(object)
            }
        }

        Menu
        {
            id: preferencesMenu
            title: catalog.i18nc("@title:menu menubar:toplevel", "P&references")

            //MenuItem { action: QIDI.Actions.preferences }
            MenuItem
            {
                text: catalog.i18nc("@title:tab", "General")
                onTriggered: generalDialog.show()
            }
        }

        Menu
        {
            id: helpMenu
            title: catalog.i18nc("@title:menu menubar:toplevel", "&Help")

            MenuItem { action: QIDI.Actions.useWizard }
            MenuItem { action: QIDI.Actions.showProfileFolder }
            MenuItem { action: QIDI.Actions.whatsNew }
			MenuItem { action: QIDI.Actions.reportBug }
            MenuItem
            {
                text: catalog.i18nc("@action:inmenu menubar:help", "Factory Setting")
                onTriggered: factorySettingDialog.visible = true
            }
        }
    }

    Component
    {
        id: extensionsMenuItem

        MenuItem
        {
            text: modelText
            onTriggered: extensionsModel.subMenuTriggered(extensionName, modelText)
        }
    }

    Component
    {
        id: extensionsMenuSeparator

        MenuSeparator {}
    }

    QIDI.PreferencesDialog
    {
        id: generalDialog
        title: catalog.i18nc("@title:tab", "General")
        Component.onCompleted:
        {
            setPage(Qt.resolvedUrl("../Preferences/GeneralPage.qml"))
        }
    }

    MessageDialog
    {
        id: factorySettingDialog
        modality: Qt.ApplicationModal
        title: catalog.i18nc("@title:window", "Factory setting")
        text: catalog.i18nc(
                  "@info:question",
                  "Are you sure to restore the factory setting? You have to restart the software manually.")
        standardButtons: StandardButton.Yes | StandardButton.No
        icon: StandardIcon.Question
        onYes: {
            QIDIActions.factorySetting()
        }
    }


    // ###############################################################################################
    // Definition of other components that are linked to the menus
    // ###############################################################################################

    WorkspaceSummaryDialog
    {
        id: saveWorkspaceDialog
        property var args
        onYes: QD.OutputDeviceManager.requestWriteToDevice("local_file", PrintInformation.jobName, args)
    }

    MessageDialog
    {
        id: newProjectDialog
        modality: Qt.ApplicationModal
        title: catalog.i18nc("@title:window", "New project")
        text: catalog.i18nc("@info:question", "Are you sure you want to start a new project? This will clear the build plate and any unsaved settings.")
        standardButtons: StandardButton.Yes | StandardButton.No
        icon: StandardIcon.Question
        onYes:
        {
            QIDIApplication.resetWorkspace()
            QIDI.Actions.resetProfile.trigger()
            QD.Controller.setActiveStage("PrepareStage")
        }
    }

    QD.ExtensionModel
    {
        id: qidiExtensions
    }

    // ###############################################################################################
    // Definition of all the connections
    // ###############################################################################################

    Connections
    {
        target: QIDI.Actions.newProject
        function onTriggered()
        {
            if(Printer.platformActivity || QIDI.MachineManager.hasUserSettings)
            {
                newProjectDialog.visible = true
            }
        }
    }

    // show the Toolbox
    Connections
    {
        target: QIDI.Actions.browsePackages
        function onTriggered()
        {
            qidiExtensions.callExtensionMethod("Toolbox", "launch")
        }
    }

    // Show the Marketplace dialog at the materials tab
    Connections
    {
        target: QIDI.Actions.marketplaceMaterials
        function onTriggered()
        {
            qidiExtensions.callExtensionMethod("Toolbox", "launch")
            qidiExtensions.callExtensionMethod("Toolbox", "setViewCategoryToMaterials")
        }
    }
}