// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

import UM 1.3 as UM
import Cura 1.0 as Cura

import "Menus"

UM.MainWindow
{
    id: base
    //: Cura application window title
    title: {
        if (PrintInformation.jobName)
        {
            return catalog.i18nc("@title:window","Qidi Print") + " - " + PrintInformation.jobName
        }
        else
        {
            return catalog.i18nc("@title:window","Qidi Print")
        }
    }
    viewportRect: sidebar.visible ? Qt.rect(0, 0, (base.width-sidebar.width)/ base.width, 1.0) : Qt.rect(0, 0, base.width/ base.width, 1.0)
    property bool showPrintMonitor: false
    property bool setEnable: false

    // This connection is here to support legacy printer output devices that use the showPrintMonitor signal on Application to switch to the monitor stage
    // It should be phased out in newer plugin versions.
/*
    Connections
    {
        target: CuraApplication
        onShowPrintMonitor: {
            if (show) {
                UM.Controller.setActiveStage("MonitorStage")
            } else {
                UM.Controller.setActiveStage("PrepareStage")
            }
        }
    }
*/
/*
    onWidthChanged:
    {
        // If slidebar is collapsed then it should be invisible
        // otherwise after the main_window resize the sidebar will be fully re-drawn
        if (sidebar.collapsed){
            if (sidebar.visible == true){
                sidebar.visible = false
                sidebar.initialWidth = 0
            }
        }
        else{
            if (sidebar.visible == false){
                sidebar.visible = true
                sidebar.initialWidth = UM.Theme.getSize("sidebar").width
            }
        }
    }*/

    Component.onCompleted:
    {
        CuraApplication.setMinimumWindowSize(UM.Theme.getSize("window_minimum_size"))
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
        Cura.Actions.parent = backgroundItem
        CuraApplication.purgeWindows()
    }

    Item
    {
        id: backgroundItem;
        anchors.fill: parent;
        UM.I18nCatalog{id: catalog; name:"cura"}

        signal hasMesh(string name) //this signal sends the filebase name so it can be used for the JobSpecs.qml
        function getMeshName(path){
            //takes the path the complete path of the meshname and returns only the filebase
            var fileName = path.slice(path.lastIndexOf("/") + 1)
            var fileBase = fileName.slice(0, fileName.indexOf("."))
            return fileBase
        }

        //DeleteSelection on the keypress backspace event
        Keys.onPressed: {
            if (event.key == Qt.Key_Backspace)
            {
                Cura.Actions.deleteSelection.trigger()
            }
        }

        UM.ApplicationMenu
        {
            id: menu
            window: base
            Menu
            {
               id: fileMenu
                title: catalog.i18nc("@title:menu menubar:toplevel","&File");

                MenuItem
                {
                    action: Cura.Actions.newProject;
                }

                MenuItem
                {
                    action: Cura.Actions.open;
                }

                RecentFilesMenu { }

                ExampleFilesMenu { }

                MenuSeparator { }

                MenuItem
                {
                    text: catalog.i18nc("@action:inmenu menubar:file", "&Save Selection to File");
                    enabled: UM.Selection.hasSelection;
                    iconName: "document-save-as";
                    onTriggered: UM.OutputDeviceManager.requestWriteSelectionToDevice("local_file", "", { "filter_by_machine": false, "preferred_mimetype": "application/vnd.ms-package.3dmanufacturing-3dmodel+xml"});
                }

                /*MenuItem
                {
                    id: saveAsMenu
                    text: catalog.i18nc("@title:menu menubar:file", "Save &As...")
                    onTriggered:
                    {
                        var localDeviceId = "local_file";
                        UM.OutputDeviceManager.requestWriteToDevice(localDeviceId, "", { "filter_by_machine": false, "preferred_mimetype": "application/vnd.ms-package.3dmanufacturing-3dmodel+xml"});
                    }
                }*/

                MenuItem
                {
                    id: saveWorkspaceMenu
                    text: catalog.i18nc("@title:menu menubar:file","Save &Project...")
                    onTriggered:
                    {
                        if(UM.Preferences.getValue("cura/dialog_on_project_save"))
                        {
                            saveWorkspaceDialog.open()
                        }
                        else
                        {
                            UM.OutputDeviceManager.requestWriteToDevice("local_file", PrintInformation.jobName, { "filter_by_machine": false, "file_type": "workspace" })
                        }
                    }
                }
                MenuItem { action: Cura.Actions.reloadAll; }

                MenuSeparator { }

                MenuItem { action: Cura.Actions.quit; }
            }


            Menu
            {
                title: catalog.i18nc("@title:menu menubar:toplevel","&Edit");

                MenuItem { action: Cura.Actions.undo; }
                MenuItem { action: Cura.Actions.redo; }
                MenuSeparator { }
                MenuItem { action: Cura.Actions.selectAll; }
                MenuItem { action: Cura.Actions.arrangeAll; }
                MenuItem { action: Cura.Actions.deleteSelection; }
                MenuItem { action: Cura.Actions.deleteAll; }
                MenuItem { action: Cura.Actions.resetAllTranslation; }
                MenuItem { action: Cura.Actions.resetAll; }
                MenuSeparator { }
                MenuItem { action: Cura.Actions.groupObjects;}
                MenuItem { action: Cura.Actions.mergeObjects;}
                MenuItem { action: Cura.Actions.unGroupObjects;}
            }

            ViewMenu { title: catalog.i18nc("@title:menu", "&View") }

            Menu
            {
                id: settingsMenu
                title: catalog.i18nc("@title:menu", "&Settings")

                PrinterMenu { title: catalog.i18nc("@title:menu menubar:toplevel", "&Printer") }

                Instantiator
                {
                    model: Cura.ExtrudersModel { simpleNames: true }
                    Menu {
                        title: model.name

                        //NozzleMenu { title: Cura.MachineManager.activeDefinitionVariantsName; visible: Cura.MachineManager.hasVariants; extruderIndex: index }
                        MaterialMenu { title: catalog.i18nc("@title:menu", "&Material"); visible: Cura.MachineManager.hasMaterials; extruderIndex: index }

                        MenuSeparator
                        {
                            visible: Cura.MachineManager.hasVariants || Cura.MachineManager.hasMaterials
                        }

                        MenuItem
                        {
                            text: catalog.i18nc("@action:inmenu", "Set as Active Extruder")
                            onTriggered: Cura.MachineManager.setExtruderIndex(model.index)
                        }

                        MenuItem
                        {
                            text: catalog.i18nc("@action:inmenu", "Enable Extruder")
                            onTriggered: Cura.MachineManager.setExtruderEnabled(model.index, true)
                            visible: !Cura.MachineManager.getExtruder(model.index).isEnabled
                        }

                        MenuItem
                        {
                            text: catalog.i18nc("@action:inmenu", "Disable Extruder")
                            onTriggered: Cura.MachineManager.setExtruderEnabled(model.index, false)
                            visible: Cura.MachineManager.getExtruder(model.index).isEnabled
                            enabled: Cura.MachineManager.numberExtrudersEnabled > 1
                        }

                    }
                    onObjectAdded: settingsMenu.insertItem(index, object)
                    onObjectRemoved: settingsMenu.removeItem(object)
                }

                // TODO Temporary hidden, add back again when feature ready
//                BuildplateMenu { title: catalog.i18nc("@title:menu", "&Build plate"); visible: Cura.MachineManager.hasVariantBuildplates }
                ProfileMenu { title: catalog.i18nc("@title:menu", "&Profile"); }
            }

            Menu
            {
                id: controlPanelMenu
                title: catalog.i18nc("@title:menu menubar:toplevel","C&ontrol Panel")
                visible: Cura.MachineManager.activeMachineDefinitionName == "QIDI I" ? false : Cura.MachineManager.activeMachineDefinitionName == "X-one2" ? false : true
                MenuItem
                {
                    text: catalog.i18nc("@action:inmenu", "Control Panel")
                    onTriggered: CuraApplication.showControlPanel()
                }
            }

            Menu
            {
                id: extensionMenu
                title: catalog.i18nc("@title:menu menubar:toplevel","E&xtensions");

                Instantiator
                {
                    id: extensions
                    model: UM.ExtensionModel { }

                    Menu
                    {
                        id: subMenu
                        title: model.name;
                        visible: actions != null
                        enabled: actions != null
                        Instantiator
                        {
                            model: actions
                            MenuItem
                            {
                                text: model.text
                                onTriggered: extensions.model.subMenuTriggered(name, model.text)
                            }
                            onObjectAdded: subMenu.insertItem(index, object)
                            onObjectRemoved: subMenu.removeItem(object)
                        }
                    }

                    onObjectAdded: extensionMenu.insertItem(index, object)
                    onObjectRemoved: extensionMenu.removeItem(object)
                }
            }

            Menu
            {
                title: catalog.i18nc("@title:menu menubar:toplevel","P&references");
                MenuItem { action: Cura.Actions.preferences }
                MenuItem { action: Cura.Actions.configureSettingVisibility }
            }

            Menu
            {
                //: Help menu
                title: catalog.i18nc("@title:menu menubar:toplevel","&Help");

                MenuItem {
                    id: firstRunWizard
                    text: catalog.i18nc("@action:inmenu menubar:profile","First Run Wizard");
                    onTriggered: {
                        useWizard.visible = true
                    }
                }
                MenuItem { action: Cura.Actions.showProfileFolder; }
                MenuItem {
                    id: factorySettingMenu
                    text: catalog.i18nc("@action:inmenu menubar:profile","Factory setting");
                    onTriggered: {
                        factorySettingDialog.visible = true
                    }
                }
                /*MenuItem { action: Cura.Actions.documentation; }
                MenuItem { action: Cura.Actions.reportBug; }
                MenuSeparator { }
                MenuItem { action: Cura.Actions.about; }*/
            }
        }

        UM.SettingPropertyProvider
        {
            id: machineExtruderCount

            containerStackId: Cura.MachineManager.activeMachineId
            key: "machine_extruder_count"
            watchedProperties: [ "value" ]
            storeIndex: 0
        }

        Item
        {
            id: contentItem;

            y: menu.height
            width: parent.width;
            height: parent.height - menu.height;

            Keys.forwardTo: menu

            DropArea
            {
                anchors.fill: parent;
                onDropped:
                {
                    if (drop.urls.length > 0)
                    {
                        openDialog.handleOpenFileUrls(drop.urls);
                    }
                }
            }
/*
            JobSpecs
            {
                id: jobSpecs
                anchors
                {
                    bottom: parent.bottom;
                    right: parent.right;
                    bottomMargin: UM.Theme.getSize("default_margin").height;
                    rightMargin: UM.Theme.getSize("default_margin").width;
                }
                z:1
            }
*/
            Rectangle
            {
                id: toolbarbackgrand
                anchors{
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }
                width: 60 * UM.Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color1")
            }

            Rectangle
            {
                id: toolbarborder
                anchors{
                    top: parent.top
                    left: toolbarbackgrand.right
                    bottom: parent.bottom
                }
                width: 1
                color: UM.Theme.getColor("color2")
            }

            Button
            {
                id: openFileButton;
                text: catalog.i18nc("@action:button","Open File");
                iconSource: UM.Theme.getIcon("load")
                style: UM.Theme.styles.tool_button
                tooltip: ""
                anchors
                {
                    top: toolbarbackgrand.top;
                    left: parent.left;
                }
                action: Cura.Actions.open;
            }

            Toolbar
            {
                id: toolbar;

                property int mouseX: base.mouseX
                property int mouseY: base.mouseY

                anchors {
                    top: openFileButton.bottom;
                    left: parent.left;
                }
                height: parent.height
            }

            ObjectsList
            {
                id: objectsList;
                visible: CuraApplication.platformActivity
                anchors
                {
                    top: parent.top
                    topMargin: UM.Theme.getSize("default_margin").width
                    right: sidebar.visible ? sidebar.left : separator1.left
                    rightMargin: UM.Theme.getSize("default_margin").width
                }
            }

            Rectangle
            {
                id: bottombarborder
                anchors{
                    bottom: bottombar.top
                    left: bottombar.left
                    right: bottombar.right
                }
                height: 1
                color: UM.Theme.getColor("color2")
            }

            Bottombar
            {
                id: bottombar
                anchors.left: toolbarborder.right
                anchors.right: sidebar.visible ? sidebar.left : parent.right
                anchors.bottom: parent.bottom
                color: UM.Theme.getColor("color1")
            }

            Loader
            {
                id: main

                anchors
                {
                    top: sidebarButton.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                MouseArea
                {
                    visible: UM.Controller.activeStage.mainComponent != ""
                    anchors.fill: parent
                    acceptedButtons: Qt.AllButtons
                    onWheel: wheel.accepted = true
                }

                source: UM.Controller.activeStage.mainComponent
            }



            Rectangle
            {
                id: separator1
                visible: sidebar.visible ? false : true
                width: UM.Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color2")
                anchors.right: sidebarButton.left
                anchors.top: sidebarButton.top
                anchors.bottom: sidebarButton.bottom
                anchors.bottomMargin: -UM.Theme.getSize("default_margin").width/10
            }

            Rectangle
            {
                id: separator2
                height: UM.Theme.getSize("default_margin").width/10
                color: UM.Theme.getColor("color2")
                anchors.right: parent.right
                anchors.left: sidebarButton.left
                anchors.top: sidebarButton.bottom
            }

            Rectangle
            {
                id: sidebarborder
                anchors{
                    top: parent.top
                    right: sidebar.left
                    bottom: parent.bottom
                }
                width: 1
                color: UM.Theme.getColor("color2")
                visible: sidebar.visible
            }

            Sidebar {
                id: sidebar
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    right: parent.right
                }
                width: UM.Theme.getSize("sidebar").width
            }

            Button
            {
                id: sidebarButton
                iconSource:
                {
                    if(sidebar.visible == false)
                    {
                        UM.Theme.getIcon("hidden_left")
                    }
                    else
                    {
                        UM.Theme.getIcon("hidden_right")
                    }

                }
                style: UM.Theme.styles.sidebar_button
                tooltip: ''
                anchors
                {
                    top: parent.top
                    right: parent.right
                }
                onClicked: {
                    if(sidebar.visible == false)
                    {
                        sidebar.visible = true
                    }
                    else
                    {
                        sidebar.visible = false
                    }
                }
            }

            UseWizard
            {
                id: useWizard
                anchors.fill: parent
                visible: false
            }

/*
            Loader
            {
                id: sidebar

                property bool collapsed: false;
                property var initialWidth: UM.Theme.getSize("sidebar").width;

                function callExpandOrCollapse() {
                    if (collapsed) {
                        sidebar.visible = true;
                        sidebar.initialWidth = UM.Theme.getSize("sidebar").width;
                        viewportRect = Qt.rect(0, 0, (base.width - sidebar.width) / base.width, 1.0);
                        expandSidebarAnimation.start();
                    } else {
                        viewportRect = Qt.rect(0, 0, 1, 1.0);
                        collapseSidebarAnimation.start();
                    }
                    collapsed = !collapsed;
                    UM.Preferences.setValue("cura/sidebar_collapsed", collapsed);
                }

                anchors
                {
                    top: topbar.top
                    bottom: parent.bottom
                }

                width: initialWidth
                x: base.width - sidebar.width
                source: UM.Controller.activeStage.sidebarComponent

                NumberAnimation {
                    id: collapseSidebarAnimation
                    target: sidebar
                    properties: "x"
                    to: base.width
                    duration: 100
                }

                NumberAnimation {
                    id: expandSidebarAnimation
                    target: sidebar
                    properties: "x"
                    to: base.width - sidebar.width
                    duration: 100
                }

                Component.onCompleted:
                {
                    var sidebar_collapsed = UM.Preferences.getValue("cura/sidebar_collapsed");

                    if (sidebar_collapsed)
                    {
                        sidebar.collapsed = true;
                        viewportRect = Qt.rect(0, 0, 1, 1.0)
                        collapseSidebarAnimation.start();
                    }
                }

                MouseArea
                {
                    visible: UM.Controller.activeStage.sidebarComponent != ""
                    anchors.fill: parent
                    acceptedButtons: Qt.AllButtons
                    onWheel: wheel.accepted = true
                }
            }
*/
            UM.MessageStack
            {
                id:messageStack
                anchors
                {
                    horizontalCenter: parent.horizontalCenter
                    //verticalCenter: parent.verticalCenter
                    top: parent.top
                    bottom: parent.bottom
                    bottomMargin: base.height / 2
                }
            }
        }
    }

    // Expand or collapse sidebar
    Connections
    {
        target: Cura.Actions.expandSidebar
        onTriggered: sidebar.callExpandOrCollapse()
    }


    UM.PreferencesDialog
    {
        id: preferences

        Component.onCompleted:
        {
            //; Remove & re-add the general page as we want to use our own instead of uranium standard.
            removePage(0);
            insertPage(0, catalog.i18nc("@title:tab","General"), Qt.resolvedUrl("Preferences/GeneralPage.qml"));

            removePage(1);
            insertPage(1, catalog.i18nc("@title:tab","Settings"), Qt.resolvedUrl("Preferences/SettingVisibilityPage.qml"));

            insertPage(2, catalog.i18nc("@title:tab", "Printers"), Qt.resolvedUrl("Preferences/MachinesPage.qml"));

            insertPage(3, catalog.i18nc("@title:tab", "Materials"), Qt.resolvedUrl("Preferences/MaterialsPage.qml"));

            insertPage(4, catalog.i18nc("@title:tab", "Profiles"), Qt.resolvedUrl("Preferences/ProfilesPage.qml"));

            // Remove plug-ins page because we will use the shiny new plugin browser:
            removePage(5);

            //Force refresh
            setPage(0);
        }

        onVisibleChanged:
        {
            // When the dialog closes, switch to the General page.
            // This prevents us from having a heavy page like Setting Visiblity active in the background.
            setPage(0);
        }
    }

    UM.ParameterDialog
    {
        id: parameter

        Component.onCompleted:
        {
            //; Remove & re-add the general page as we want to use our own instead of uranium standard.
            removePage(0);
            insertPage(0, "Extruder", Qt.resolvedUrl("Parameter/ExtruderPage.qml"));

            removePage(1);
            insertPage(1, "Layer", Qt.resolvedUrl("Parameter/LayerPage.qml"));

            insertPage(2, "Infill", Qt.resolvedUrl("Parameter/InfillPage.qml"));

            insertPage(3, "Additions", Qt.resolvedUrl("Parameter/AdditionsPage.qml"));

            insertPage(4, "Speeds", Qt.resolvedUrl("Parameter/SpeedsPage.qml"));

            insertPage(5, "Temperature", Qt.resolvedUrl("Parameter/TemperaturePage.qml"));

            insertPage(6, "Cooling", Qt.resolvedUrl("Parameter/CoolingPage.qml"));

            insertPage(7, "Support", Qt.resolvedUrl("Parameter/SupportPage.qml"));

            insertPage(8, "Advanced", Qt.resolvedUrl("Parameter/AdvancedPage.qml"));

            //insertPage(9, catalog.i18nc("@title:tab", "Other"), Qt.resolvedUrl("Parameter/OtherPage.qml"));

            //insertPage(10, catalog.i18nc("@title:tab", "Machine"), Qt.resolvedUrl("Parameter/MachinePage.qml"));

            // Remove plug-ins page because we will use the shiny new plugin browser:
            removePage(9);

            //Force refresh
            setPage(0);
        }

        onVisibleChanged:
        {
            // When the dialog closes, switch to the General page.
            // This prevents us from having a heavy page like Setting Visiblity active in the background.
            setPage(0);
        }
    }

    WorkspaceSummaryDialog
    {
        id: saveWorkspaceDialog
        onYes: UM.OutputDeviceManager.requestWriteToDevice("local_file", PrintInformation.jobName, { "filter_by_machine": false, "file_type": "workspace" })
    }

    Connections
    {
        target: Cura.Actions.preferences
        onTriggered: preferences.visible = true
    }

    Connections
    {
        target: CuraApplication
        onShowPreferencesWindow: preferences.visible = true
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
            CuraApplication.deleteAll();
            Cura.Actions.resetProfile.trigger();
            PrintInformation.jobName = ''
        }
    }

    MessageDialog
    {
        id: defaultconfigurationDialog
        modality: Qt.ApplicationModal
        title: catalog.i18nc("@title:window", "Default Configuration")
        text: catalog.i18nc("@info:question", "Are you sure you want to default all configuration? This will only clear print configuration, build plate will not be clear.")
        standardButtons: StandardButton.Yes | StandardButton.No
        icon: StandardIcon.Question
        onYes:
        {
            //CuraApplication.deleteAll();
            Cura.Actions.resetProfile.trigger();
            PrintInformation.jobName = ''
        }
    }

    MessageDialog {
        id: factorySettingDialog
        modality: Qt.ApplicationModal
        title: catalog.i18nc("@title:window", "Factory setting")
        text: catalog.i18nc(
                  "@info:question",
                  "Are you sure to restore the factory setting? You have to restart the software manually.")
        standardButtons: StandardButton.Yes | StandardButton.No
        icon: StandardIcon.Question
        onYes: {
            CuraApplication.factorySetting()
        }
    }

    Connections
    {
        target: Cura.Actions.newProject
        onTriggered:
        {
            if(Printer.platformActivity || Cura.MachineManager.hasUserSettings)
            {
                newProjectDialog.visible = true
            }
        }
    }

    Connections
    {
        target: Cura.Actions.addProfile
        onTriggered:
        {

            preferences.show();
            preferences.setPage(4);
            // Create a new profile after a very short delay so the preference page has time to initiate
            createProfileTimer.start();
        }
    }

    Connections
    {
        target: Cura.Actions.configureMachines
        onTriggered:
        {
            preferences.visible = true;
            preferences.setPage(2);
        }
    }

    Connections
    {
        target: Cura.Actions.manageProfiles
        onTriggered:
        {
            preferences.visible = true;
            preferences.setPage(4);
        }
    }

    Connections
    {
        target: Cura.Actions.manageMaterials
        onTriggered:
        {
            preferences.visible = true;
            preferences.setPage(3)
        }
    }

    Connections
    {
        target: Cura.Actions.configureSettingVisibility
        onTriggered:
        {
            preferences.visible = true;
            preferences.setPage(1);
            if(source && source.key)
            {
                preferences.getCurrentItem().scrollToSection(source.key);
            }
        }
    }

    UM.ExtensionModel {
        id: curaExtensions
    }

    // show the plugin browser dialog
    Connections
    {
        target: Cura.Actions.browsePackages
        onTriggered: {
            curaExtensions.callExtensionMethod("Toolbox", "browsePackages")
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
        target: Cura.MachineManager
        onBlurSettings:
        {
            contentItem.forceActiveFocus()
        }
    }

    ContextMenu {
        id: contextMenu
    }

    Connections
    {
        target: Cura.Actions.quit
        onTriggered: CuraApplication.closeApplication();
    }

    Connections
    {
        target: Cura.Actions.toggleFullScreen
        onTriggered: base.toggleFullscreen();
    }

    FileDialog
    {
        id: openDialog;

        //: File open dialog title
        title: catalog.i18nc("@title:window","Open file(s)")
        modality: UM.Application.platform == "linux" ? Qt.NonModal : Qt.WindowModal;
        selectMultiple: true
        nameFilters: UM.MeshFileHandler.supportedReadFileTypes;
        folder: CuraApplication.getDefaultPath("dialog_load_path")
        onAccepted:
        {
            // Because several implementations of the file dialog only update the folder
            // when it is explicitly set.
            var f = folder;
            folder = f;

            CuraApplication.setDefaultPath("dialog_load_path", folder);

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
                else if (CuraApplication.checkIsValidProjectFile(fileUrlList[i]))
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
                var choice = UM.Preferences.getValue("cura/choice_on_open_project");
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
                    askOpenAsProjectOrModelsDialog.show();
                }
            }
            else
            {
                openFilesIncludingProjectsDialog.loadModelFiles(fileUrlList.slice());
            }
        }
    }

    MessageDialog {
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
        target: Cura.Actions.open
        onTriggered: openDialog.open()
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
        target: CuraApplication
        onOpenProjectFile:
        {
            askOpenAsProjectOrModelsDialog.fileUrl = project_file;
            askOpenAsProjectOrModelsDialog.show();
        }
    }

    EngineLog
    {
        id: engineLog;
    }

    Connections
    {
        target: Cura.Actions.showProfileFolder
        onTriggered:
        {
            var path = UM.Resources.getPath(UM.Resources.Preferences, "");
            if(Qt.platform.os == "windows") {
                path = path.replace(/\\/g,"/");
            }
            Qt.openUrlExternally(path);
        }
    }

    AddMachineDialog
    {
        id: addMachineDialog
        onMachineAdded:
        {
            machineActionsWizard.firstRun = addMachineDialog.firstRun
            machineActionsWizard.start(id)
        }
    }

    // Dialog to handle first run machine actions
    UM.Wizard
    {
        id: machineActionsWizard;

        title: catalog.i18nc("@title:window", "Add Printer")
        property var machine;

        function start(id)
        {
            var actions = Cura.MachineActionManager.getFirstStartActions(id)
            resetPages() // Remove previous pages

            for (var i = 0; i < actions.length; i++)
            {
                actions[i].displayItem.reset()
                machineActionsWizard.appendPage(actions[i].displayItem, catalog.i18nc("@title", actions[i].label));
            }

            //Only start if there are actions to perform.
            if (actions.length > 0)
            {
                machineActionsWizard.currentPage = 0;
                show()
            }
        }
    }

    MessageDialog
    {
        id: messageDialog
        modality: Qt.ApplicationModal
        onAccepted: CuraApplication.messageBoxClosed(clickedButton)
        onApply: CuraApplication.messageBoxClosed(clickedButton)
        onDiscard: CuraApplication.messageBoxClosed(clickedButton)
        onHelp: CuraApplication.messageBoxClosed(clickedButton)
        onNo: CuraApplication.messageBoxClosed(clickedButton)
        onRejected: CuraApplication.messageBoxClosed(clickedButton)
        onReset: CuraApplication.messageBoxClosed(clickedButton)
        onYes: CuraApplication.messageBoxClosed(clickedButton)
    }

    Connections
    {
        target: CuraApplication
        onShowMessageBox:
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

    DiscardOrKeepProfileChangesDialog
    {
        id: discardOrKeepProfileChangesDialog
    }

    Connections
    {
        target: CuraApplication
        onShowDiscardOrKeepProfileChanges:
        {
            discardOrKeepProfileChangesDialog.show()
        }
    }

    Connections
    {
        target: Cura.Actions.addMachine
        onTriggered: addMachineDialog.visible = true;
    }

    AboutDialog
    {
        id: aboutDialog
    }

    Connections
    {
        target: Cura.Actions.about
        onTriggered: aboutDialog.visible = true;
    }

    Connections
    {
        target: CuraApplication
        onRequestAddPrinter:
        {
            addMachineDialog.visible = true
            addMachineDialog.firstRun = false
        }
    }

    Timer
    {
        id: startupTimer;
        interval: 100;
        repeat: false;
        running: true;
        onTriggered:
        {
            if(!base.visible)
            {
                base.visible = true;
            }

            // check later if the user agreement dialog has been closed
            if (CuraApplication.needToShowUserAgreement)
            {
                restart();
                useWizard.visible = true
            }
            else if(Cura.MachineManager.activeMachineId == null || Cura.MachineManager.activeMachineId == "")
            {
                addMachineDialog.open();
            }
        }
    }

    UM.SettingPropertyProvider
    {
        id: wifivisible
        containerStackId: Cura.MachineManager.activeStackId
        key: "wifi_visible"
        watchedProperties: [ "value" ]
        storeIndex: 0
    }
}
