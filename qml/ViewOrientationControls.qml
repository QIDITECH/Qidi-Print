// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import QD 1.4 as QD
import QIDI 1.1 as QIDI
// A row of buttons that control the view direction
Row
{
    id: viewOrientationControl

    spacing: QD.Theme.getSize("narrow_margin").width
    height: childrenRect.height
    width: childrenRect.width

    ViewOrientationButton
    {
		id:view3D
        iconSource: QD.Theme.getIcon("View3D")
        onClicked: QIDI.Actions.view3DCamera.trigger()

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "3D View")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "3D View")
			x:  -3 *  QD.Theme.getSize("narrow_margin").width
            y: view3D.y + view3D.height + QD.Theme.getSize("narrow_margin").height
            z: view3D.z + 1
			//targetPoint: Qt.point(-1 * parent.x, 0 * Math.round(parent.y + parent.height / 2))
			visible: view3D.hovered
		}
    }

    ViewOrientationButton
    {
		id:viewfront
        iconSource: QD.Theme.getIcon("ViewFront")
        onClicked: QIDI.Actions.viewFrontCamera.trigger()

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "Front View")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "Front View")
			x:  -2.5 *  QD.Theme.getSize("narrow_margin").width
            y: viewfront.y + viewfront.height + QD.Theme.getSize("narrow_margin").height
            z: viewfront.z + 1
			targetPoint: Qt.point(-1 * parent.x, Math.round(parent.y + parent.height / 2))
			visible: viewfront.hovered
		}
    }

    ViewOrientationButton
    {
		id:viewtop
        iconSource: QD.Theme.getIcon("ViewTop")
        onClicked: QIDI.Actions.viewTopCamera.trigger()

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "Top View")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "Top View")
			x:  -2.5 *  QD.Theme.getSize("narrow_margin").width
            y: viewtop.y + viewtop.height + QD.Theme.getSize("narrow_margin").height
            z: viewtop.z + 1
			targetPoint: Qt.point(-1 * parent.x, Math.round(parent.y + parent.height / 2))
			visible: viewtop.hovered
		}
    }

    ViewOrientationButton
    {
		id:viewleft
        iconSource: QD.Theme.getIcon("ViewLeft")
        onClicked: QIDI.Actions.viewLeftSideCamera.trigger()

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "Left View")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "Left View")
			x:  -2.5 *  QD.Theme.getSize("narrow_margin").width
            y: viewleft.y + viewleft.height + QD.Theme.getSize("narrow_margin").height
            z: viewleft.z + 1
			targetPoint: Qt.point(-1 * parent.x, Math.round(parent.y + parent.height / 2))
			visible: viewleft.hovered
		}
    }

    ViewOrientationButton
    {
		id:viewright
        iconSource: QD.Theme.getIcon("ViewRight")
        onClicked: QIDI.Actions.viewRightSideCamera.trigger()

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "Right View")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "Right View")
			x:  -2.5 *  QD.Theme.getSize("narrow_margin").width
            y: viewright.y + viewright.height + QD.Theme.getSize("narrow_margin").height
            z: viewright.z + 1
			targetPoint: Qt.point(-1 * parent.x, Math.round(parent.y + parent.height / 2))
			visible: viewright.hovered
		}
    }

    Rectangle
    {
        id: buttonsSeparator
        width: QD.Theme.getSize("size").width
        height: parent.height
        color: QD.Theme.getColor("gray_3")
    }

    ViewOrientationButton
    {
		id:solidview
        iconSource: QD.Theme.getIcon("ViewSolid")
        onClicked: QD.Controller.setActiveView("SolidView")
        checked: QD.Controller.activeView ? QD.Controller.activeView.name == "SolidView" : false

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "Solid")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "Solid")
			x:  -1.2 *  QD.Theme.getSize("narrow_margin").width
            y: solidview.y + solidview.height + QD.Theme.getSize("narrow_margin").height
            z: solidview.z + 1
			targetPoint: Qt.point(-1 * parent.x, Math.round(parent.y + parent.height / 2))
			visible: solidview.hovered
		}
    }

    ViewOrientationButton
    {
		id:viewxRay
        iconSource: QD.Theme.getIcon("ViewXRay")
        onClicked: QD.Controller.setActiveView("XRayView")
        checked: QD.Controller.activeView ? QD.Controller.activeView.name == "XRayView" : false

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "X-Ray")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "X-Ray")
			x:  -1.2 *  QD.Theme.getSize("narrow_margin").width
            y: viewxRay.y + viewxRay.height + QD.Theme.getSize("narrow_margin").height
            z: viewxRay.z + 1
			targetPoint: Qt.point(-1 * parent.x, Math.round(parent.y + parent.height / 2))
			visible: viewxRay.hovered
		}
    }

    ViewOrientationButton
    {
		id:viewsimulation
        iconSource: QD.Theme.getIcon("ViewSimulation")
        onClicked: QD.Controller.setActiveView("SimulationView")
        checked: QD.Controller.activeView ? QD.Controller.activeView.name == "SimulationView" : false

        /*QD.TooltipArea
        {
            anchors.fill: parent
            text: catalog.i18nc("@info:tooltip", "Layer")
            acceptedButtons: Qt.NoButton
        }*/
		QIDI.ToolTip
		{
			tooltipText: catalog.i18nc("@info:tooltip", "Layer")
			//contentAlignment :  QIDI.ToolTip.ContentAlignment.AlignRight
			x:  -1.2 *  QD.Theme.getSize("narrow_margin").width
            y: viewsimulation.y + viewsimulation.height + QD.Theme.getSize("narrow_margin").height
            z: viewsimulation.z + 1
			targetPoint: Qt.point(-1 * parent.x, Math.round(parent.y + parent.height / 2))
			visible: viewsimulation.hovered
		}
    }
}
