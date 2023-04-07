//Copyright (c) 2020 QIDI B.V.
//QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.4

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Menu
{
    id: base
    title: catalog.i18nc("@title:menu menubar:toplevel", "&Settings")

    Menu
    {
        id: printerMenu
        title: catalog.i18nc("@title:menu menubar:settings", "&Printer")
        Instantiator
        {
            id: printerMenuInstantiator
            model: QIDI.GlobalStacksModel {}
            MenuItem
            {
                text: model.name
                checkable: true
                checked: QIDI.MachineManager.activeMachine !== null ? QIDI.MachineManager.activeMachine.name == model.name : false
                exclusiveGroup: group
                visible: !model.hasRemoteConnection
                onTriggered: QIDI.MachineManager.addMachine(model.id, model.name)
            }
            onObjectAdded: printerMenu.insertItem(index, object)
            onObjectRemoved: printerMenu.removeItem(object)
        }
        MenuSeparator { visible: printerMenuInstantiator.count > 0 }
        MenuItem { action: QIDI.Actions.addMachine }
        ExclusiveGroup { id: group }
    }

    property var activeMachine: QIDI.MachineManager.activeMachine
    property var extrudersModel: QIDIApplication.getExtrudersModel()
    Instantiator
    {
        id: extruderInstantiator
        model: extrudersModel//activeMachine == null ? null : activeMachine.extruderList
        Menu
        {
            title: model.name//modelData.name
            property var extruder: (base.activeMachine === null) ? null : activeMachine.extruderList[model.index]
            NozzleMenu { title: QIDI.MachineManager.activeDefinitionVariantsName; visible: QIDI.MachineManager.activeMachine.hasVariants; extruderIndex: index }
            /*MaterialMenu
            {
                //title: catalog.i18nc("@title:menu", "&Material")
                visible: QIDI.MachineManager.activeMachine.hasMaterials
                extruderIndex: index
                updateModels: false
                onAboutToShow: updateModels = true
                onAboutToHide: updateModels = false
            }*/

            /*MenuSeparator
            {
                visible: QIDI.MachineManager.activeMachine.hasVariants || QIDI.MachineManager.activeMachine.hasMaterials
            }*/

            MenuItem
            {
                text: catalog.i18nc("@action:inmenu", "Set as Active Extruder")
                onTriggered: QIDI.ExtruderManager.setActiveExtruderIndex(model.index)
            }

            MenuItem
            {
                text: catalog.i18nc("@action:inmenu", "Enable Extruder")
                onTriggered: QIDI.MachineManager.setExtruderEnabled(model.index, true)
                visible: (extruder === null || extruder === undefined) ? false : !extruder.isEnabled
            }

            MenuItem
            {
                text: catalog.i18nc("@action:inmenu", "Disable Extruder")
                onTriggered: QIDI.MachineManager.setExtruderEnabled(index, false)
                visible: (extruder === null || extruder === undefined) ? false : extruder.isEnabled
                enabled: QIDI.MachineManager.numberExtrudersEnabled > 1
            }

        }
        onObjectAdded: base.insertItem(index, object)
        onObjectRemoved: base.removeItem(object)
    }
	MenuItem
	{
		text:catalog.i18nc("@action:button", "Manage Materials")
		onTriggered:
		{
			forceActiveFocus();
			QIDIApplication.showCreateMaterial()
		}

	}
    MenuSeparator { }

    MenuItem
    {
        text: catalog.i18nc("@title:tab", "Setting Visibility")
        onTriggered: settingDialog.show()
    }

    QIDI.PreferencesDialog
    {
        id: settingDialog
        title: catalog.i18nc("@title:tab", "Setting Visibility")
        Component.onCompleted:
        {
            setPage(Qt.resolvedUrl("../Preferences/SettingVisibilityPage.qml"))
        }
    }
}