// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Menu
{
    title: catalog.i18nc("@title:menu menubar:toplevel", "&View")
    id: base

    property var multiBuildPlateModel: QIDIApplication.getMultiBuildPlateModel()

    Menu
    {
        title: catalog.i18nc("@action:inmenu menubar:view","&Camera position");
        MenuItem { action: QIDI.Actions.view3DCamera; }
        MenuItem { action: QIDI.Actions.viewFrontCamera; }
        MenuItem { action: QIDI.Actions.viewTopCamera; }
        MenuItem { action: QIDI.Actions.viewBottomCamera; }
        MenuItem { action: QIDI.Actions.viewLeftSideCamera; }
        MenuItem { action: QIDI.Actions.viewRightSideCamera; }
    }

    Menu
    {
        id: cameraViewMenu
        property string cameraMode: QD.Preferences.getValue("general/camera_perspective_mode")
        Connections
        {
            target: QD.Preferences
            function onPreferenceChanged(preference)
            {
                if (preference !== "general/camera_perspective_mode")
                {
                    return
                }
                cameraViewMenu.cameraMode = QD.Preferences.getValue("general/camera_perspective_mode")
            }
        }

        title: catalog.i18nc("@action:inmenu menubar:view","Camera view")
        MenuItem
        {
            text: catalog.i18nc("@action:inmenu menubar:view", "Perspective")
            checkable: true
            checked: cameraViewMenu.cameraMode == "perspective"
            onTriggered:
            {
                QD.Preferences.setValue("general/camera_perspective_mode", "perspective")
                checked = cameraViewMenu.cameraMode == "perspective"
            }
            exclusiveGroup: group
        }
        MenuItem
        {
            text: catalog.i18nc("@action:inmenu menubar:view", "Orthographic")
            checkable: true
            checked: cameraViewMenu.cameraMode == "orthographic"
            onTriggered:
            {
                QD.Preferences.setValue("general/camera_perspective_mode", "orthographic")
                checked = cameraViewMenu.cameraMode == "orthographic"
            }
            exclusiveGroup: group
        }
        ExclusiveGroup { id: group }
    }

    MenuSeparator
    {
        visible: QD.Preferences.getValue("qidi/use_multi_build_plate")
    }

    Menu
    {
        id: buildPlateMenu;
        title: catalog.i18nc("@action:inmenu menubar:view","&Build plate")
        visible: QD.Preferences.getValue("qidi/use_multi_build_plate")
        Instantiator
        {
            model: base.multiBuildPlateModel
            MenuItem
            {
                text: base.multiBuildPlateModel.getItem(index).name;
                onTriggered: QIDI.SceneController.setActiveBuildPlate(base.multiBuildPlateModel.getItem(index).buildPlateNumber)
                checkable: true
                checked: base.multiBuildPlateModel.getItem(index).buildPlateNumber == base.multiBuildPlateModel.activeBuildPlate
                exclusiveGroup: buildPlateGroup
                visible: QD.Preferences.getValue("qidi/use_multi_build_plate")
            }
            onObjectAdded: buildPlateMenu.insertItem(index, object)
            onObjectRemoved: buildPlateMenu.removeItem(object)
        }
        ExclusiveGroup
        {
            id: buildPlateGroup
        }
    }

    //MenuSeparator {}

    //MenuItem
    //{
    //    action: QIDI.Actions.toggleFullScreen
    //}
}
