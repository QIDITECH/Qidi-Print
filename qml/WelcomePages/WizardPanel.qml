// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This item is a wizard panel that contains a progress bar at the top and a content area that's beneath the progress
// bar.
//
Item
{
    id: base

    clip: true

    property var currentItem: (model == null) ? null : model.getItem(model.currentPageIndex)
    property var model: null

    // Convenience properties
    property var progressValue: model == null ? 0 : model.currentProgress
    property string pageUrl: currentItem == null ? "" : currentItem.page_url

    property alias progressBarVisible: progressBar.visible
    property alias backgroundColor: panelBackground.color

    signal showNextPage()
    signal showPreviousPage()
    signal goToPage(string page_id)  // Go to a specific page by the given page_id.
    signal endWizard()

    // Call the corresponding functions in the model
    onShowNextPage: model.goToNextPage()
    onShowPreviousPage: model.goToPreviousPage()
    onGoToPage: model.goToPage(page_id)
    onEndWizard: model.atEnd()

    Rectangle  // Panel background
    {
        id: panelBackground
        anchors.fill: parent
        radius: QD.Theme.getSize("default_radius").width
        color: QD.Theme.getColor("main_background")

        QD.ProgressBar
        {
            id: progressBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            height: visible ? QD.Theme.getSize("progressbar").height : 3 *QD.Theme.getSize("size").height

            value: base.progressValue
        }

        Loader
        {
            id: contentLoader
            anchors
            {
                top: progressBar.bottom
                bottom: parent.bottom
				bottomMargin:QD.Theme.getSize("wide_margin").width
                left: parent.left
				leftMargin:QD.Theme.getSize("wide_margin").width
                right: parent.right
				rightMargin:QD.Theme.getSize("wide_margin").width
            }
			anchors.topMargin: progressBar.visible ? QD.Theme.getSize("wide_margin_with_process").width:QD.Theme.getSize("wide_margin_without_process").width
            source: base.pageUrl
            active: base.visible
        }
    }
}
