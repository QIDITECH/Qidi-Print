// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4 as Controls1

import QD 1.3 as QD
import QIDI 1.0 as QIDI


// This element contains all the elements the user needs to create a printjob from the
// model(s) that is(are) on the buildplate. Mainly the button to start/stop the slicing
// process and a progress bar to see the progress of the process.
Item
{
    id: widget

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    property real progress: QD.Backend.progress
    property int backendState: QD.Backend.state
    // As the collection of settings to send to the engine might take some time, we have an extra value to indicate
    // That the user pressed the button but it's still waiting for the backend to acknowledge that it got it.
    property bool waitingForSliceToStart: false
    onBackendStateChanged: waitingForSliceToStart = false

    function sliceOrStopSlicing()
    {
        if (widget.backendState == QD.Backend.NotStarted)
        {
			if(QD.Preferences.getValue("view/show_slice_confirm")){
			
				sliceMessageConfirm.visible = true
			}
			else{
				widget.waitingForSliceToStart = true
				QIDIApplication.backend.getOozePrevention()
				sliceTimer.start()
				//QIDIApplication.backend.forceSlice()
			}
        }
        else
        {
            widget.waitingForSliceToStart = false
            QIDIApplication.backend.stopSlicing()
        }
    }
	Timer
	{
		id: sliceTimer
		repeat: false
		interval: 200
		onTriggered: QIDIApplication.backend.forceSlice()
	}
    QD.ProgressBar
    {
        id: progressBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 7 * QD.Theme.getSize("size").height
        value: progress
        indeterminate: widget.backendState == QD.Backend.NotStarted
        visible: (widget.backendState == QD.Backend.Processing || (prepareButtons.autoSlice && widget.backendState != QD.Backend.NotStarted))
    }

    Label
    {
        id: autoSlicingLabel
        anchors.bottom: prepareButtons.top
        anchors.bottomMargin: 15 * QD.Theme.getSize("size").height
        anchors.left: prepareButtons.left
        visible: progressBar.visible
        text: catalog.i18nc("@label:PrintjobStatus", "Slicing...")
        color: QD.Theme.getColor("text")
        font: QD.Theme.getFont("default")
        renderType: Text.NativeRendering
    }

    QIDI.IconWithText
    {
        id: unableToSliceMessage
        anchors.bottom: prepareButtons.top
        anchors.bottomMargin: 15 * QD.Theme.getSize("size").height
        anchors.left: prepareButtons.left
        visible: widget.backendState == QD.Backend.Error
        text: catalog.i18nc("@label:PrintjobStatus", "Unable to slice")
        source: QD.Theme.getIcon("Warning")
        iconColor: QD.Theme.getColor("warning")
    }

    Item
    {
        id: prepareButtons
        // Get the current value from the preferences
        property bool autoSlice: QD.Preferences.getValue("general/auto_slice")
        // Disable the slice process when

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 15 * QD.Theme.getSize("size").height
        height: QD.Theme.getSize("action_button").height
        visible: !autoSlice
        QIDI.PrimaryButton
        {
            id: sliceButton
            fixedWidthMode: true
            height: parent.height
            backgroundRadius: Math.round(height / 2)
            anchors.right: parent.right
            anchors.left: parent.left
            text: widget.waitingForSliceToStart ? catalog.i18nc("@button", "Processing"): catalog.i18nc("@button", "Slice")
            tooltip: catalog.i18nc("@label", "Start the slicing process")
            enabled: widget.backendState != QD.Backend.Error && !widget.waitingForSliceToStart && QIDIApplication.platformActivity
            visible: widget.backendState == QD.Backend.NotStarted || widget.backendState == QD.Backend.Error
            onClicked: {
				sliceOrStopSlicing()
			}
			onEnabledChanged:{
				if(sliceButton.enabled){
					QIDIApplication.platformActive()
				}
				else{
					QIDIApplication.platformDisActive()
				}
			}
        }

        QIDI.SecondaryButton
        {
            id: cancelButton
            fixedWidthMode: true
            height: parent.height
            backgroundRadius: Math.round(height / 2)
            anchors.left: parent.left
            anchors.right: parent.right
            text: catalog.i18nc("@button", "Cancel")
            enabled: sliceButton.enabled
            visible: !sliceButton.visible
            onClicked: sliceOrStopSlicing()
        }
    }


    // React when the user changes the preference of having the auto slice enabled
    Connections
    {
        target: QD.Preferences
        function onPreferenceChanged(preference)
        {
            if (preference !== "general/auto_slice")
            {
                return;
            }

            var autoSlice = QD.Preferences.getValue("general/auto_slice")
            if(prepareButtons.autoSlice != autoSlice)
            {
                prepareButtons.autoSlice = autoSlice
                if(autoSlice)
                {
                    QIDIApplication.backend.forceSlice()
                }
            }
        }
    }

    // Shortcut for "slice/stop"
    Controls1.Action
    {
        shortcut: "Ctrl+P"
        onTriggered:
        {
            if (sliceButton.enabled)
            {
                sliceOrStopSlicing()
            }
        }
    }
}
