
import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI

Item
{
    id: base
    anchors.fill: parent

    property var model: null
    property var currentItem: (model == null) ? null : model.getItem(model.currentPageIndex)
    property string pageUrl: currentItem == null ? "" : currentItem.page_url

    function resetModelState()
    {
        model.resetState()
        base.visible = true
    }

    signal showNextPage()
    signal showPreviousPage()
    signal goToPage(string page_id)  // Go to a specific page by the given page_id.
    signal endWizard()

    // Call the corresponding functions in the model
    onShowNextPage: model.goToNextPage()
    onShowPreviousPage: model.goToPreviousPage()
    onGoToPage: model.goToPage(page_id)
    onEndWizard: model.atEnd()

    Loader
    {
        id: contentLoader
        anchors.fill: parent
        source: base.pageUrl
        active: base.visible
    }

    Connections
    {
        target: model
        function onAllFinished()
		{ 
			//QIDIApplication.writeToLog("e","build")
			//var newid=QIDIApplication.getMaterialManagementModel().createMaterial()
			base.visible = false 
		}
    }
}
