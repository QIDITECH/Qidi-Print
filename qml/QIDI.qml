// Copyright (c) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.0

import QD 1.3 as QD
import QIDI 1.1 as QIDI

import "Dialogs"
import "Menus"
import "MainWindow"
import "WelcomePages"

QD.MainWindow
{
    id: base

    // QIDI application window title
    title:
    {
        let result = QIDIApplication.applicationDisplayName
        if(PrintInformation !== null && PrintInformation.jobName != "")
        {
            result += " - " + PrintInformation.jobName;
        }
        return result
    }
	//flags:Qt.WindowStaysOnBottomHint
    viewportRect: printSetupSelector.visible ? Qt.rect(0, 0, (base.width - printSetupSelector.width) / base.width, 1.0) : Qt.rect(0, 0, 1.0, 1.0)

    backgroundColor: QD.Theme.getColor("blue_5")

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    function showTooltip(item, position, text)
    {
        tooltip.text = text;
        position = item.mapToItem(backgroundItem, position.x - QD.Theme.getSize("default_arrow").width, position.y);
        tooltip.show(position);
    }


    function hideTooltip()
    {
        tooltip.hide();
    }

    Rectangle
    {
        id: greyOutBackground
        anchors.fill: parent
        visible: welcomeDialogItem.visible
        color: QD.Theme.getColor("white_2")
        opacity: 0.7
        z: useWizard.z + 1

        MouseArea
        {
            // Prevent all mouse events from passing through.
            enabled: parent.visible
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
        }
    }



    WelcomeDialogItem
    {
        id: welcomeDialogItem
        visible: false
        z: greyOutBackground.z + 1
    }

    Component.onCompleted:
    {
        QIDIApplication.setMinimumWindowSize(QD.Theme.getSize("window_minimum_size"))
        QIDIApplication.purgeWindows()
    }

    Connections
    {
        // This connection is used when there is no ActiveMachine and the user is logged in
        target: QIDIApplication
        function onShowAddPrintersUncancellableDialog()
        {
            QIDI.Actions.parent = backgroundItem

            // Reuse the welcome dialog item to show "Add a printer" only.
            welcomeDialogItem.model = QIDIApplication.getAddPrinterPagesModelWithoutCancel()
            welcomeDialogItem.progressBarVisible = false
            welcomeDialogItem.visible = true
        }
    }

    Connections
    {
        target: QIDIApplication
        function onInitializationFinished()
        {
            // Workaround silly issues with QML Action's shortcut property.
            //
            // Currently, there is no way to define shortcuts as "Application Shortcut".
            // This means that all Actions are "Window Shortcuts". The code for this
            // implements a rather naive check that just checks if any of the action's parents
            // are a window. Since the "Actions" object is a singleton it has no parent by
            // default. If we set its parent to something contained in this window, the
            // shortcut will activate properly because one of its parents is a window.
            //
            // This has been fixed for QtQuick Controls 2 since the Shortcut item has a context property.
            QIDI.Actions.parent = backgroundItem

            if (QIDIApplication.shouldShowWelcomeDialog())
            {
                welcomeDialogItem.visible = true
                useWizard.visible = true
            }
            else
            {
                welcomeDialogItem.visible = false
            }

            // Reuse the welcome dialog item to show "What's New" only.
            if (QIDIApplication.shouldShowWhatsNewDialog())
            {
                welcomeDialogItem.model = QIDIApplication.getWhatsNewPagesModel()
                welcomeDialogItem.progressBarVisible = false
                welcomeDialogItem.visible = true
            }

            // Reuse the welcome dialog item to show the "Add printers" dialog. Triggered when there is no active
            // machine and the user is logged in.
            if (!QIDI.MachineManager.activeMachine && QIDI.API.account.isLoggedIn)
            {
                welcomeDialogItem.model = QIDIApplication.getAddPrinterPagesModelWithoutCancel()
                welcomeDialogItem.progressBarVisible = false
                welcomeDialogItem.visible = true
            }
        }
    }

    Item
    {
        id: backgroundItem
        anchors.fill: parent

        //DeleteSelection on the keypress backspace event
        Keys.onPressed:
        {
            if (event.key == Qt.Key_Backspace)
            {
                QIDI.Actions.deleteSelection.trigger()
            }
        }

        ApplicationMenu
        {
            id: applicationMenu
            window: base
        }

        Item
        {
            id: contentItem

            anchors
            {
                top: applicationMenu.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            Keys.forwardTo: applicationMenu

            DropArea
            {
                // The drop area is here to handle files being dropped onto QIDI.
                anchors.fill: parent
                onDropped:
                {
                    if (drop.urls.length > 0)
                    {

                        var nonPackages = [];
                        for (var i = 0; i < drop.urls.length; i++)
                        {
                            var filename = drop.urls[i];
                            if (filename.toLowerCase().endsWith(".qidipackage"))
                            {
                                // Try to install plugin & close.
                                QIDIApplication.installPackageViaDragAndDrop(filename);
                                packageInstallDialog.text = catalog.i18nc("@label", "This package will be installed after restarting.");
                                packageInstallDialog.icon = StandardIcon.Information;
                                packageInstallDialog.open();
                            }
                            else
                            {
                                nonPackages.push(filename);
                            }
                        }
						//QIDIApplication.writeToLog("e", nonPackages)
                        openDialog.handleOpenFileUrls(nonPackages);
                    }
                }
            }

            ObjectSelector
            {
                id: objectSelector
                visible: QIDIApplication.platformActivity
                anchors
                {
                    bottom: jobSpecs.top
                    left: toolbar.right
                    leftMargin: QD.Theme.getSize("default_margin").width
                    rightMargin: QD.Theme.getSize("default_margin").width
                    bottomMargin: QD.Theme.getSize("narrow_margin").height
                }
            }

            JobSpecs
            {
                id: jobSpecs
                visible: QIDIApplication.platformActivity
                anchors
                {
                    left: toolbar.right
                    bottom: parent.bottom
                    leftMargin: QD.Theme.getSize("default_margin").width
                    rightMargin: QD.Theme.getSize("default_margin").width
                    bottomMargin: QD.Theme.getSize("thin_margin").width
                    topMargin: QD.Theme.getSize("thin_margin").width
                }
            }

            ViewOrientationControls
            {
                id: viewOrientationControls

                anchors.top: parent.top
                anchors.topMargin: 5 * QD.Theme.getSize("size").height
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -printSetupSelector.width / 2
            }

            Loader
            {
                id: viewPanel
                anchors.top: parent.top
                anchors.topMargin: 10 * QD.Theme.getSize("size").width
                anchors.right: printSetupSelector.left
                anchors.rightMargin: 40 * QD.Theme.getSize("size").width
                source: QD.Controller.activeView != null && QD.Controller.activeView.stageMenuComponent != null ? QD.Controller.activeView.stageMenuComponent : ""
            }

            Loader
            {
                id: previewMain
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: printSetupSelector.left
                source: QD.Controller.activeView != null && QD.Controller.activeView.mainComponent != null ? QD.Controller.activeView.mainComponent : ""
            }

            ToolbarButton
            {
                id: openFileButton
                anchors.top: parent.top
                anchors.left: parent.left
                height: width
                width: toolbar.width
                text: catalog.i18nc("@button","Open File(s)")
                toolItem: QD.RecolorImage
                {
                    source: QD.Theme.getIcon("Folder")
                    color: QD.Theme.getColor("blue_6")
                    width: openFileButton.hovered ? 32 * QD.Theme.getSize("size").height : 30 * QD.Theme.getSize("size").height
                    height: openFileButton.hovered ? 32 * QD.Theme.getSize("size").height : 30 * QD.Theme.getSize("size").height
                }
                onClicked: QIDI.Actions.open.trigger()
            }

            Toolbar
            {
                id: toolbar
                property int mouseX: base.mouseX
                property int mouseY: base.mouseY
                anchors.top: openFileButton.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
            }

            Rectangle
            {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: toolbar.right
                width: QD.Theme.getSize("size").width
                color: QD.Theme.getColor("gray_3")
            }

            // A hint for the loaded content view. Overlay items / controls can safely be placed in this area
            Item {
                id: mainSafeArea
                anchors.left: viewOrientationControls.right
                anchors.right: main.right
                anchors.top: main.top
                anchors.bottom: main.bottom
            }

            Loader
            {
                // A stage can control this area. If nothing is set, it will therefore show the 3D view.
                id: main

                anchors
                {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                source: QD.Controller.activeStage != null ? QD.Controller.activeStage.mainComponent : ""

                onLoaded:
                {
                    if (main.item.safeArea !== undefined){
                       main.item.safeArea = Qt.binding(function() { return mainSafeArea });
                    }
                }
            }

            QIDI.PrintSetupSelector
            {
                id: printSetupSelector
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
				//resizeTarget:backgroundItem
				//minimumWidth: 300 * QD.Theme.getSize("size").height
                width: QD.Preferences.getValue("general/setting_veiw_width") ? QD.Preferences.getValue("general/setting_veiw_width") : 350 * QD.Theme.getSize("size").height
            }

            QD.MessageStack
            {
                anchors
                {
                    horizontalCenter: parent.horizontalCenter
                    //verticalCenter: parent.verticalCenter
					top: parent.top
                    bottom: parent.verticalCenter
                    //bottomMargin:  QD.Theme.getSize("default_margin").height
                }

                primaryButton: Component
                {
                    QIDI.PrimaryButton
                    {
                        text: model.name
                        height: QD.Theme.getSize("message_action_button").height
                    }
                }

                secondaryButton: Component
                {
                    QIDI.SecondaryButton
                    {
                        text: model.name
                        height: QD.Theme.getSize("message_action_button").height
                    }
                }
            }
        }

        PrintSetupTooltip
        {
            id: tooltip
            sourceWidth: QD.Theme.getSize("print_setup_widget").width
        }
        ButtonTooltip
        {
            id: buttontooltip
			//sourceWidth: QD.Theme.getSize("print_setup_widget").width
		}
    }

    QD.PreferencesDialog
    {
        id: preferences

        Component.onCompleted:
        {
            //; Remove & re-add the general page as we want to use our own instead of qdtech standard.
            removePage(0);
            insertPage(0, catalog.i18nc("@title:tab","General"), Qt.resolvedUrl("Preferences/GeneralPage.qml"));

            removePage(1);
            insertPage(1, catalog.i18nc("@title:tab","Settings"), Qt.resolvedUrl("Preferences/SettingVisibilityPage.qml"));

            insertPage(2, catalog.i18nc("@title:tab", "Printers"), Qt.resolvedUrl("Preferences/MachinesPage.qml"));

            insertPage(3, catalog.i18nc("@title:tab", "Materials"), Qt.resolvedUrl("Preferences/Materials/MaterialsPage.qml"));

            insertPage(4, catalog.i18nc("@title:tab", "Profiles"), Qt.resolvedUrl("Preferences/ProfilesPage.qml"));
            currentPage = 0;
        }

        onVisibleChanged:
        {
            // When the dialog closes, switch to the General page.
            // This prevents us from having a heavy page like Setting Visibility active in the background.
            setPage(0);
        }
    }

    Connections
    {
        target: QIDI.Actions.preferences
        function onTriggered() { preferences.visible = true }
    }

    Connections
    {
        target: QIDIApplication
        function onShowPreferencesWindow() { preferences.visible = true }
    }

    Connections
    {
        target: QIDI.Actions.addProfile
        function onTriggered()
        {
            preferences.show();
            preferences.setPage(4);
            // Create a new profile after a very short delay so the preference page has time to initiate
            createProfileTimer.start();
        }
    }

    Connections
    {
        target: QIDI.Actions.configureMachines
        function onTriggered()
        {
            preferences.visible = true;
            preferences.setPage(2);
        }
    }

    Connections
    {
        target: QIDI.Actions.manageProfiles
        function onTriggered()
        {
            preferences.visible = true;
            preferences.setPage(4);
        }
    }

    Connections
    {
        target: QIDI.Actions.manageMaterials
        function onTriggered()
        {
            preferences.visible = true;
            preferences.setPage(3)
        }
    }

    Connections
    {
        target: QIDI.Actions.configureSettingVisibility
        function onTriggered(source)
        {
            preferences.visible = true;
            preferences.setPage(1);
            if(source && source.key)
            {
                preferences.getCurrentItem().scrollToSection(source.key);
            }
        }
    }

    Timer
    {
        id: createProfileTimer
        repeat: false
        interval: 1

        onTriggered: preferences.getCurrentItem().createProfile()
    }

    // BlurSettings is a way to force the focus away from any of the setting items.
    // We need to do this in order to keep the bindings intact.
    Connections
    {
        target: QIDI.MachineManager
        function onBlurSettings()
        {
            contentItem.forceActiveFocus()
        }
    }

    ContextMenu
    {
        id: contextMenu
    }

    onPreClosing:
    {
        close.accepted = QIDIApplication.getIsAllChecksPassed();
        if (!close.accepted)
        {
            QIDIApplication.checkAndExitApplication();
        }
    }

    MessageDialog
    {
        id: exitConfirmationDialog
        title: catalog.i18nc("@title:window %1 is the application name", "Closing %1").arg(QIDIApplication.applicationDisplayName)
        text: catalog.i18nc("@label %1 is the application name", "Are you sure you want to exit %1?").arg(QIDIApplication.applicationDisplayName)
        icon: StandardIcon.Question
        modality: Qt.ApplicationModal
        standardButtons: StandardButton.Yes | StandardButton.No
        onYes: QIDIApplication.callConfirmExitDialogCallback(true)
        onNo: QIDIApplication.callConfirmExitDialogCallback(false)
        onRejected: QIDIApplication.callConfirmExitDialogCallback(false)
        onVisibilityChanged:
        {
            if (!visible)
            {
                // reset the text to default because other modules may change the message text.
                text = catalog.i18nc("@label %1 is the application name", "Are you sure you want to exit %1?").arg(QIDIApplication.applicationDisplayName);
            }
        }
    }

    Connections
    {
        target: QIDIApplication
        function onShowConfirmExitDialog(message)
        {
            exitConfirmationDialog.text = message;
            exitConfirmationDialog.open();
        }
    }

    Connections
    {
        target: QIDI.Actions.quit
        function onTriggered() { QIDIApplication.checkAndExitApplication(); }
    }

    Connections
    {
        target: QIDI.Actions.toggleFullScreen
        function onTriggered() { base.toggleFullscreen() }
    }

    Connections
    {
        target: QIDI.Actions.exitFullScreen
        function onTriggered() { base.exitFullscreen() }
    }

    FileDialog
    {
        id: openDialog;

        //: File open dialog title
        title: catalog.i18nc("@title:window","Open file(s)")
        modality: Qt.WindowModal
        selectMultiple: true
        nameFilters: QD.MeshFileHandler.supportedReadFileTypes;
        folder:
        {
            //Because several implementations of the file dialog only update the folder when it is explicitly set.
            folder = QIDIApplication.getDefaultPath("dialog_load_path");
            return QIDIApplication.getDefaultPath("dialog_load_path");
        }
        onAccepted:
        {
            // Because several implementations of the file dialog only update the folder
            // when it is explicitly set.
            var f = folder;
            folder = f;

            QIDIApplication.setDefaultPath("dialog_load_path", folder);

            handleOpenFileUrls(fileUrls);
        }

        // Yeah... I know... it is a mess to put all those things here.
        // There are lots of user interactions in this part of the logic, such as showing a warning dialog here and there,
        // etc. This means it will come back and forth from time to time between QML and Python. So, separating the logic
        // and view here may require more effort but make things more difficult to understand.
        function handleOpenFileUrls(fileUrlList)
        {
            // look for valid project files
            var projectFileUrlList = [];
            var hasGcode = false;
            var nonGcodeFileList = [];
            for (var i in fileUrlList)
            {
                var endsWithG = /\.g$/;
                var endsWithGcode = /\.gcode$/;
                if (endsWithG.test(fileUrlList[i]) || endsWithGcode.test(fileUrlList[i]))
                {
                    continue;
                }
                else if (QIDIApplication.checkIsValidProjectFile(fileUrlList[i]))
                {
					projectFileUrlList.push(fileUrlList[i]);
                }
                nonGcodeFileList.push(fileUrlList[i]);
            }
            hasGcode = nonGcodeFileList.length < fileUrlList.length;

            // show a warning if selected multiple files together with Gcode
            var hasProjectFile = projectFileUrlList.length > 0;
            var selectedMultipleFiles = fileUrlList.length > 1;
            if (selectedMultipleFiles && hasGcode)
            {
                infoMultipleFilesWithGcodeDialog.selectedMultipleFiles = selectedMultipleFiles;
                infoMultipleFilesWithGcodeDialog.hasProjectFile = hasProjectFile;
                infoMultipleFilesWithGcodeDialog.fileUrls = nonGcodeFileList.slice();
                infoMultipleFilesWithGcodeDialog.projectFileUrlList = projectFileUrlList.slice();
                infoMultipleFilesWithGcodeDialog.open();
            }
            else
            {
                handleOpenFiles(selectedMultipleFiles, hasProjectFile, fileUrlList, projectFileUrlList);
            }
        }

        function handleOpenFiles(selectedMultipleFiles, hasProjectFile, fileUrlList, projectFileUrlList)
        {
            // Make sure the files opened through the openFilesIncludingProjectDialog are added to the recent files list
            openFilesIncludingProjectsDialog.addToRecent = true;

            // we only allow opening one project file
            if (selectedMultipleFiles && hasProjectFile)
            {
                openFilesIncludingProjectsDialog.fileUrls = fileUrlList.slice();
                openFilesIncludingProjectsDialog.show();
                return;
            }

            if (hasProjectFile)
            {
                var projectFile = projectFileUrlList[0];
                // check preference
                var choice = QD.Preferences.getValue("qidi/choice_on_open_project");
                if (choice == "open_as_project")
                {
                    openFilesIncludingProjectsDialog.loadProjectFile(projectFile);
                }
                else if (choice == "open_as_model")
                {
                    openFilesIncludingProjectsDialog.loadModelFiles([projectFile].slice());
                }
                else    // always ask
                {
                    // ask whether to open as project or as models
                    askOpenAsProjectOrModelsDialog.fileUrl = projectFile;
                    askOpenAsProjectOrModelsDialog.addToRecent = true;
                    askOpenAsProjectOrModelsDialog.show();
                }
            }
            else
            {
                openFilesIncludingProjectsDialog.loadModelFiles(fileUrlList.slice());
            }
        }
    }

    MessageDialog
    {
        id: packageInstallDialog
        title: catalog.i18nc("@window:title", "Install Package");
        standardButtons: StandardButton.Ok
        modality: Qt.ApplicationModal
    }

    MessageDialog
    {
        id: infoMultipleFilesWithGcodeDialog
        title: catalog.i18nc("@title:window", "Open File(s)")
        icon: StandardIcon.Information
        standardButtons: StandardButton.Ok
        text: catalog.i18nc("@text:window", "We have found one or more G-Code files within the files you have selected. You can only open one G-Code file at a time. If you want to open a G-Code file, please just select only one.")

        property var selectedMultipleFiles
        property var hasProjectFile
        property var fileUrls
        property var projectFileUrlList

        onAccepted:
        {
            openDialog.handleOpenFiles(selectedMultipleFiles, hasProjectFile, fileUrls, projectFileUrlList);
        }
    }

    Connections
    {
        target: QIDI.Actions.open
        function onTriggered() { openDialog.open() }
    }
    OpenFilesIncludingProjectsDialog
    {
        id: openFilesIncludingProjectsDialog
    }

    AskOpenAsProjectOrModelsDialog
    {
        id: askOpenAsProjectOrModelsDialog
    }

    Connections
    {
        target: QIDIApplication
        function onOpenProjectFile(project_file, add_to_recent_files)
        {
            askOpenAsProjectOrModelsDialog.fileUrl = project_file;
            askOpenAsProjectOrModelsDialog.addToRecent = add_to_recent_files;
            askOpenAsProjectOrModelsDialog.show();
        }
    }
	
	
    /*Connections
    {
        target: QIDIApplication
        function onShowButtonTip(x,y,text)
        {
			//base.showTooltip(sliceMessageConfirm, Qt.point(x-QD.Theme.getSize("thick_margin").width, y),  "test")
			if (buttontooltip.tooltipText !=text && text)
			{
				buttontooltip.x = x+2*QD.Theme.getSize("thick_margin").width
				buttontooltip.y = y-QD.Theme.getSize("thick_margin").width
				//buttontooltip.x = x
				//buttontooltip.y = y
			}
			buttontooltip.tooltipText = text;
			buttontooltip.show();

        }
    }*/
	
    Connections
    {
        target: QIDIApplication
        function onShowButtonTip()
        {
			buttontooltip.x = QIDIApplication.getShowX()+2*QD.Theme.getSize("thick_margin").width;
			buttontooltip.y = QIDIApplication.getShowY()-QD.Theme.getSize("thick_margin").width;
			buttontooltip.tooltipText = QIDIApplication.getShowText();
			buttontooltip.show();

        }
    }
	
    Connections
    {
        target: QIDIApplication
        function onHideButtonTip()
        {
			buttontooltip.hide()
        }
    }
	
	
	
    Connections
    {
        target: QIDI.Actions.showProfileFolder
        function onTriggered()
        {
            var path = QD.Resources.getPath(QD.Resources.Preferences, "");
            if(Qt.platform.os == "windows")
            {
                path = path.replace(/\\/g,"/");
            }
            Qt.openUrlExternally(path);
            if(Qt.platform.os == "linux")
            {
                Qt.openUrlExternally(QD.Resources.getPath(QD.Resources.Resources, ""));
            }
        }
    }

    MessageDialog
    {
        id: messageDialog
        modality: Qt.ApplicationModal
        onAccepted: QIDIApplication.messageBoxClosed(clickedButton)
        onApply: QIDIApplication.messageBoxClosed(clickedButton)
        onDiscard: QIDIApplication.messageBoxClosed(clickedButton)
        onHelp: QIDIApplication.messageBoxClosed(clickedButton)
        onNo: QIDIApplication.messageBoxClosed(clickedButton)
        onRejected: QIDIApplication.messageBoxClosed(clickedButton)
        onReset: QIDIApplication.messageBoxClosed(clickedButton)
        onYes: QIDIApplication.messageBoxClosed(clickedButton)
    }

    Connections
    {
        target: QIDIApplication
        function onShowMessageBox(title, text, informativeText, detailedText, buttons, icon)
        {
            messageDialog.title = title
            messageDialog.text = text
            messageDialog.informativeText = informativeText
            messageDialog.detailedText = detailedText
            messageDialog.standardButtons = buttons
            messageDialog.icon = icon
            messageDialog.visible = true
        }
    }

    Component
    {
        id: discardOrKeepProfileChangesDialogComponent
        DiscardOrKeepProfileChangesDialog { }
    }
    Loader
    {
        id: discardOrKeepProfileChangesDialogLoader
    }
    Connections
    {
        target: QIDIApplication
        function onShowDiscardOrKeepProfileChanges()
        {
            discardOrKeepProfileChangesDialogLoader.sourceComponent = discardOrKeepProfileChangesDialogComponent
            discardOrKeepProfileChangesDialogLoader.item.show()
        }
    }


    QIDI.CreateMaterialMessage
    {
        id:creatematerialmessage         
    }


    QIDI.WizardDialog
    {
        id: addMachineDialog
        title: catalog.i18nc("@title:window", "Add Printer")
        model: QIDIApplication.getAddPrinterPagesModel()
        progressBarVisible: false
    }

    QIDI.WizardDialog
    {
        id: whatsNewDialog
        title: catalog.i18nc("@title:window", "What's New")
        minimumWidth: QD.Theme.getSize("welcome_wizard_window").width
        minimumHeight: QD.Theme.getSize("welcome_wizard_window").height
        model: QIDIApplication.getWhatsNewPagesModel()
        progressBarVisible: false
        visible: false
    }

    QIDI.WizardDialog
    {
        id: reportBugDialog
        title: catalog.i18nc("@title:window", "Report a Bug")
        minimumWidth: QD.Theme.getSize("report_wizard_window").width + 30*QD.Theme.getSize("size").height
        minimumHeight: QD.Theme.getSize("report_wizard_window").height
        model: QIDIApplication.getReportABugModel()
        progressBarVisible: false
        visible: false
    }

    QIDI.UseWizard
    {
        id: useWizard
        model: QIDIApplication.getUseWizardsModel()
        visible: false
    }

    Connections
    {
        target: QIDI.Actions.whatsNew
        function onTriggered() { whatsNewDialog.show() }
    }
    Connections
    {
        target: QIDI.Actions.reportBug
        function onTriggered() { reportBugDialog.show() }
    }

    Connections
    {
        target: QIDI.Actions.addMachine
        function onTriggered()
        {
            // Make sure to show from the first page when the dialog shows up.
            addMachineDialog.resetModelState()
            addMachineDialog.show()
        }
    }

    Connections
    {
        target: QIDI.Actions.useWizard
        function onTriggered()
        {
            // Make sure to show from the first page when the dialog shows up.
            useWizard.resetModelState()
            useWizard.show()
        }
    }

    AboutDialog
    {
        id: aboutDialog
    }

	SliceMessageConfirm
	{
		id: sliceMessageConfirm
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		visible: false
	}
	
	/*QIDI.CreateMaterialMessage
	{
		id: creatematerialmessage
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		extruderIndexinbase : 0
		currentMaterialNode: null
		containerId: ""
		visible: false
	}*/
	
    Connections
    {
        target: QIDI.Actions.about
        function onTriggered() { aboutDialog.visible = true; }
    }

    Timer
    {
        id: startupTimer
        interval: 100
        repeat: false
        running: true
        onTriggered:
        {
            if (!base.visible)
            {
                base.visible = true
            }
        }
    }

    Connections
    {
        target: QIDIApplication
        function onOpenFile()
        {
			openDialog.open()
			//base.showTooltip(sliceMessageConfirm, Qt.point(-QD.Theme.getSize("thick_margin").width, 0),  "test")
        }
    }	

	Connections
    {
        target: QIDIApplication
        function onFlatFile()
        {
			QD.ActiveTool.triggerAction("layFlat")
        }
    }

    function qmlTypeOf(obj, class_name)
    {
        //className plus "(" is the class instance without modification.
        //className plus "_QML" is the class instance with user-defined properties.
        var str = obj.toString();
        return str.indexOf(class_name + "(") == 0 || str.indexOf(class_name + "_QML") == 0;
    }
}
