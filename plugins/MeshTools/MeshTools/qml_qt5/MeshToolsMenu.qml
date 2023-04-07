// Copyright (c) 2016 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Menu
{
    id: base

    MenuItem
    {
        text: catalog.i18nc("@item:inmenu", "Reload model")
        enabled: QD.Selection.selectionCount == 1
        onTriggered: manager.reloadMesh()
    }
    MenuItem
    {
        text: catalog.i18nc("@item:inmenu", "Rename model...")
        enabled: QD.Selection.selectionCount == 1
        onTriggered: manager.renameMesh()
    }
    MenuItem
    {
        text: catalog.i18ncp("@item:inmenu", "Replace model...", "Replace models...", QD.Selection.selectionCount)
        enabled: QD.Selection.hasSelection
        onTriggered: manager.replaceMeshes()
    }
    MenuSeparator {}
    MenuItem
    {
        text: catalog.i18ncp("@item:inmenu", "Check mesh", "Check meshes", QD.Selection.selectionCount)
        enabled: QD.Selection.hasSelection
        onTriggered: manager.checkMeshes()
    }
    MenuItem
    {
        text: catalog.i18ncp("@item:inmenu", "Analyse mesh", "Analyse meshes", QD.Selection.selectionCount)
        enabled: QD.Selection.hasSelection
        onTriggered: manager.analyseMeshes()
    }
    MenuItem
    {
        text: catalog.i18nc("@item:inmenu", "Fix simple holes")
        enabled: QD.Selection.hasSelection
        onTriggered: manager.fixSimpleHolesForMeshes()
    }
    MenuItem
    {
        text: catalog.i18nc("@item:inmenu", "Fix model normals")
        enabled: QD.Selection.hasSelection
        onTriggered: manager.fixNormalsForMeshes()
    }
    MenuItem
    {
        text: catalog.i18ncp("@item:inmenu", "Split model into parts", "Split models into parts", QD.Selection.selectionCount)
        enabled: QD.Selection.hasSelection
        onTriggered: manager.splitMeshes()
    }
    MenuSeparator {}
    MenuItem
    {
        text: catalog.i18nc("@item:inmenu", "Randomise location")
        enabled: QD.Selection.hasSelection
        onTriggered: manager.randomiseMeshLocation()
    }
    MenuItem
    {
        text: catalog.i18nc("@item:inmenu", "Apply transformations to mesh")
        enabled: QD.Selection.hasSelection
        onTriggered: manager.bakeMeshTransformation()
    }
    MenuItem
    {
        text: catalog.i18nc("@item:inmenu", "Reset origin to center of mesh")
        enabled: QD.Selection.hasSelection
        onTriggered: manager.resetMeshOrigin()
    }

    function moveToContextMenu(contextMenu)
    {
        for(var i in base.items)
        {
            contextMenu.items[0].insertItem(i,base.items[i])
        }
    }

    QD.I18nCatalog { id: catalog; name: "meshtools" }
}
