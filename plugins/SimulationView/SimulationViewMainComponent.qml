// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.4
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import QD 1.4 as QD
import QIDI 1.0 as QIDI

Item
{
    // An Item whose bounds are guaranteed to be safe for overlays to be placed.
    // Defaults to parent, ie. the entire available area
    // eg. the layer slider will not be placed in this area.
    property var safeArea: parent


    property bool isSimulationPlaying: false
    readonly property real layerSliderSafeYMin: safeArea.y
    readonly property real layerSliderSafeYMax: safeArea.y + safeArea.height
    readonly property real pathSliderSafeXMin: safeArea.x + playButton.width
    readonly property real pathSliderSafeXMax: safeArea.x + safeArea.width

    visible: QD.SimulationView.layerActivity && QIDIApplication.platformActivity && QIDIApplication.gettest

    // A slider which lets users trace a single layer (XY movements)
    PathSlider
    {
        id: pathSlider

        readonly property real preferredWidth: QD.Theme.getSize("slider_layerview_size").height // not a typo, should be as long as layerview slider
        readonly property real margin: QD.Theme.getSize("default_margin").width
        readonly property real pathSliderSafeWidth: pathSliderSafeXMax - pathSliderSafeXMin

        height: QD.Theme.getSize("slider_handle").width
        width: preferredWidth + margin * 2 < pathSliderSafeWidth ? preferredWidth : pathSliderSafeWidth - margin * 2


        anchors.bottom: parent.bottom
        anchors.bottomMargin: margin

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -(parent.width - pathSliderSafeXMax - pathSliderSafeXMin) / 2 // center between parent top and layerSliderSafeYMax


        visible: !QD.SimulationView.compatibilityMode

        // Custom properties
        handleValue: QD.SimulationView.currentPath
        maximumValue: QD.SimulationView.numPaths

        // Update values when layer data changes.
        Connections
        {
            target: QD.SimulationView
            function onMaxPathsChanged() { pathSlider.setHandleValue(QD.SimulationView.currentPath) }
            function onCurrentPathChanged()
            {
                // Only pause the simulation when the layer was changed manually, not when the simulation is running
                if (pathSlider.manuallyChanged)
                {
                    playButton.pauseSimulation()
                }
                pathSlider.setHandleValue(QD.SimulationView.currentPath)
            }
        }

        // Ensure that the slider handlers show the correct value after switching views.
        Component.onCompleted:
        {
            pathSlider.setHandleValue(QD.SimulationView.currentPath)
        }

    }
	Rectangle
	{
        anchors
        {
			horizontalCenter: pathSlider.horizontalCenter
			bottom:pathSlider.top
        }
		height: 2*QD.Theme.getSize("slider_handle").width
		color:QD.Theme.getColor("gray_5")
		radius: 5
		border.color: QD.Theme.getColor("gray_2")
        visible: !QD.SimulationView.compatibilityMode
        width: 0.8*QD.Theme.getSize("slider_layerview_size").height 
		Label
		{
			id:xlabel
			anchors.verticalCenter:parent.verticalCenter
			width:(0.8*QD.Theme.getSize("slider_layerview_size").height -40*QD.Theme.getSize("size").width)/4
			anchors.left:parent.left
			anchors.leftMargin:15*QD.Theme.getSize("size").width
			text:QIDIApplication.getHeadPosition[0]
		}
		Label
		{
			id:ylabel
			anchors.verticalCenter:parent.verticalCenter
			width:(0.8*QD.Theme.getSize("slider_layerview_size").height -40*QD.Theme.getSize("size").width)/4
			anchors.left:xlabel.right
			text:QIDIApplication.getHeadPosition[1]
		}
		Label
		{
			id:zlabel
			anchors.verticalCenter:parent.verticalCenter
			width:(0.8*QD.Theme.getSize("slider_layerview_size").height -40*QD.Theme.getSize("size").width)/4
			anchors.left:ylabel.right
			text:QIDIApplication.getHeadPosition[2]
		}
		Label
		{
			id:speedlabel
			anchors.verticalCenter:parent.verticalCenter
			width:(0.8*QD.Theme.getSize("slider_layerview_size").height -40*QD.Theme.getSize("size").width)/4
			anchors.left:zlabel.right
			text:QIDIApplication.getHeadPosition[3]
		}
	}
      

	Rectangle
	{
		id:test
		x:52
		y:150
		border.color: QD.Theme.getColor("gray_2")

		height: gcode.visible? 12*QD.Theme.getSize("slider_handle").width : 2*QD.Theme.getSize("slider_handle").width
		radius: 5
		color:QD.Theme.getColor("gray_5")
        width: gcode.visible ? 0.8*QD.Theme.getSize("slider_layerview_size").height : 0.4*QD.Theme.getSize("slider_layerview_size").height
        visible: !QD.SimulationView.compatibilityMode
		Rectangle
		{
			id:title
			anchors
			{
				top: parent.top
				topMargin:QD.Theme.getSize("size").height
				horizontalCenter: parent.horizontalCenter
			}
			height: 2*QD.Theme.getSize("slider_handle").width

			color:QD.Theme.getColor("gray_5")
			width: test.width - 2 * QD.Theme.getSize("size").height//0.8*QD.Theme.getSize("slider_layerview_size").height - 2 * QD.Theme.getSize("size").height
			Label
			{
                id:titletext
				anchors.centerIn:parent
				text:catalog.i18nc("@title", "GcodeViewer")
                color:QD.Theme.getColor("gray_2")
			}
            QD.RecolorImage
            {
                id:iconcolor
				anchors.right:parent.right
				anchors.rightMargin: 5 *QD.Theme.getSize("size").height
                anchors.verticalCenter: parent.verticalCenter
                height: QD.Theme.getSize("slider_handle").width
                width: height
                source: gcode.visible? QD.Theme.getIcon("ChevronSingleUp") : QD.Theme.getIcon("ChevronSingleDown") ;
				color: QD.Theme.getColor("gray_2")
            }
            MouseArea{
                anchors.fill:parent
                hoverEnabled: true
                onClicked:{
                    gcode.visible = !gcode.visible;
                }
                onEntered: {
                    titletext.color =  QD.Theme.getColor("black_1") 
                    iconcolor.color = QD.Theme.getColor("black_1") 
                }
                onExited: {
                    titletext.color = QD.Theme.getColor("gray_2")
                    iconcolor.color = QD.Theme.getColor("gray_2")
                }
            }
		}
		Rectangle
		{
			anchors{
				top:title.bottom
				horizontalCenter: parent.horizontalCenter
			}
			width:parent.width*0.8
			height:QD.Theme.getSize("size").height
			color:QD.Theme.getColor("gray_2")
			visible:gcode.visible
		}
		Label
		{
			id:gcode
			//anchors.centerIn:parent
			anchors{
				top:title.bottom
				left:parent.left
				topMargin:5*QD.Theme.getSize("size").height
				leftMargin:5*QD.Theme.getSize("size").height
			}
			text:QIDIApplication.getGcode
			visible:false
		}
		MouseArea{
			anchors.fill:parent
			property point clickPos: "0,0"
			propagateComposedEvents: true
			onPressed: {
				clickPos = Qt.point(mouse.x,mouse.y)
				//console.log("clicked")
			}
			onPositionChanged: {
				var delat =  Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                if ((test.x+delat.x)<50)
                {
                    test.x=50
                }
                else if((test.x+delat.x)>(QD.Preferences.getValue("general/window_width") - QD.Preferences.getValue("general/setting_veiw_width") - 300))
                {
                    test.x=QD.Preferences.getValue("general/window_width") - QD.Preferences.getValue("general/setting_veiw_width") - 300
                }
                else
                {
                    test.x=test.x+delat.x
                }
                if (test.y+delat.y<0 )
                {
				    test.y=0
                }
                else if((test.y+delat.y)>(QD.Preferences.getValue("general/window_height")-200))
                {
                    test.y=(QD.Preferences.getValue("general/window_height")-200)
                }
                else
                {
                    test.y=test.y+delat.y
                }
			}
		}

	}


    QD.SimpleButton
    {
        id: playButton
        iconSource: !isSimulationPlaying ? "./resources/Play.svg": "./resources/Pause.svg"
        width: QD.Theme.getSize("small_button").width
        height: QD.Theme.getSize("small_button").height
        hoverColor: QD.Theme.getColor("slider_handle_active")
        color: QD.Theme.getColor("slider_handle")
        iconMargin: QD.Theme.getSize("thick_lining").width
        visible: !QD.SimulationView.compatibilityMode

        Connections
        {
            target: QD.Preferences
            function onPreferenceChanged(preference)
            {
                if (preference !== "view/only_show_top_layers" && preference !== "view/top_layer_count" && ! preference.match("layerview/"))
                {
                    return;
                }

                playButton.pauseSimulation()
            }
        }

        anchors
        {
            right: pathSlider.left
            verticalCenter: pathSlider.verticalCenter
        }

        onClicked:
        {
            if(isSimulationPlaying)
            {
                pauseSimulation()
            }
            else
            {
                resumeSimulation()
            }
        }

        function pauseSimulation()
        {
            QD.SimulationView.setSimulationRunning(false)
            simulationTimer.stop()
            isSimulationPlaying = false
            layerSlider.manuallyChanged = true
            pathSlider.manuallyChanged = true
        }

        function resumeSimulation()
        {
            QD.SimulationView.setSimulationRunning(true)
            simulationTimer.start()
            layerSlider.manuallyChanged = false
            pathSlider.manuallyChanged = false
        }
    }

    Timer
    {
        id: simulationTimer
        interval: 100
        running: false
        repeat: true
        onTriggered:
        {
            var currentPath = QD.SimulationView.currentPath
            var numPaths = QD.SimulationView.numPaths
            var currentLayer = QD.SimulationView.currentLayer
            var numLayers = QD.SimulationView.numLayers

            // When the user plays the simulation, if the path slider is at the end of this layer, we start
            // the simulation at the beginning of the current layer.
            if (!isSimulationPlaying)
            {
                if (currentPath >= numPaths)
                {
                    QD.SimulationView.setCurrentPath(0)
                }
                else
                {
                    QD.SimulationView.setCurrentPath(currentPath + 1)
                }
            }
            // If the simulation is already playing and we reach the end of a layer, then it automatically
            // starts at the beginning of the next layer.
            else
            {
                if (currentPath >= numPaths)
                {
                    // At the end of the model, the simulation stops
                    if (currentLayer >= numLayers)
                    {
                        playButton.pauseSimulation()
                    }
                    else
                    {
                        QD.SimulationView.setCurrentLayer(currentLayer + 1)
                        QD.SimulationView.setCurrentPath(0)
                    }
                }
                else
                {
                    QD.SimulationView.setCurrentPath(currentPath + 1)
                }
            }
            // The status must be set here instead of in the resumeSimulation function otherwise it won't work
            // correctly, because part of the logic is in this trigger function.
            isSimulationPlaying = true
        }
    }

    // Scrolls trough Z layers
    LayerSlider
    {
        property var preferredHeight: QD.Theme.getSize("slider_layerview_size").height
        property double heightMargin: QD.Theme.getSize("default_margin").height * 3 // extra margin to accomodate layer number tooltips
        property double layerSliderSafeHeight: layerSliderSafeYMax - layerSliderSafeYMin

        id: layerSlider

        width: QD.Theme.getSize("slider_handle").width
        height: preferredHeight + heightMargin * 2 < layerSliderSafeHeight ? preferredHeight : layerSliderSafeHeight - heightMargin * 2

        anchors
        {
            right: parent.right
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: -(parent.height - layerSliderSafeYMax - layerSliderSafeYMin) / 2 // center between parent top and layerSliderSafeYMax
            rightMargin: QD.Theme.getSize("default_margin").width
            bottomMargin: heightMargin
            topMargin: heightMargin
        }

        // Custom properties
        upperValue: QD.SimulationView.currentLayer
        lowerValue: QD.SimulationView.minimumLayer
        maximumValue: QD.SimulationView.numLayers

        // Update values when layer data changes
        Connections
        {
            target: QD.SimulationView
            function onMaxLayersChanged() { layerSlider.setUpperValue(QD.SimulationView.currentLayer) }
            function onMinimumLayerChanged() { layerSlider.setLowerValue(QD.SimulationView.minimumLayer) }
            function onCurrentLayerChanged()
            {
                // Only pause the simulation when the layer was changed manually, not when the simulation is running
                if (layerSlider.manuallyChanged)
                {
                    playButton.pauseSimulation()
                }
                layerSlider.setUpperValue(QD.SimulationView.currentLayer)
            }
        }

        // Make sure the slider handlers show the correct value after switching views
        Component.onCompleted:
        {
            layerSlider.setLowerValue(QD.SimulationView.minimumLayer)
            layerSlider.setUpperValue(QD.SimulationView.currentLayer)
        }
    }
}
