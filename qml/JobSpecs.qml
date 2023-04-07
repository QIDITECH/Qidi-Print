// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import QD 1.1 as QD
import QIDI 1.0 as QIDI

Item
{
    id: base

    property bool activity: QIDIApplication.platformActivity
    property string fileBaseName: (PrintInformation === null) ? "" : PrintInformation.baseName

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    width: childrenRect.width
    height: childrenRect.height

    onActivityChanged:
    {
        if (!activity)
        {
            //When there is no mesh in the buildplate; the printJobTextField is set to an empty string so it doesn't set an empty string as a jobName (which is later used for saving the file)
            PrintInformation.baseName = ""
        }
    }

    Label
    {
        id: boundingSpec
        anchors.top: parent.top
        anchors.left: parent.left

        height: QD.Theme.getSize("jobspecs_line").height
        verticalAlignment: Text.AlignVCenter
        font: QD.Theme.getFont("default")
        color: QD.Theme.getColor("text_scene")
        text: QIDIApplication.getSceneBoundingBoxString
    }

    Row
    {
        id: additionalComponentsRow
        anchors.top: boundingSpec.top
        anchors.bottom: boundingSpec.bottom
        anchors.left: boundingSpec.right
        anchors.leftMargin: QD.Theme.getSize("default_margin").width
    }

    Component.onCompleted:
    {
        base.addAdditionalComponents("jobSpecsButton")
    }

    Connections
    {
        target: QIDIApplication
        function onAdditionalComponentsChanged(areaId) { base.addAdditionalComponents("jobSpecsButton") }
    }

    function addAdditionalComponents(areaId)
    {
        if (areaId == "jobSpecsButton")
        {
            for (var component in QIDIApplication.additionalComponents["jobSpecsButton"])
            {
                QIDIApplication.additionalComponents["jobSpecsButton"][component].parent = additionalComponentsRow
            }
        }
    }
}
