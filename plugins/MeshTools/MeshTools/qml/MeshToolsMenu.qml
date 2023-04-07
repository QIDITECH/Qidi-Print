// Copyright (c) 2016 Ultimaker B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1

import QD 1.2 as QD
import QIDI 1.0 as QIDI

QIDI.Menu
{
    QIDI.Menu
    {
        id: meshToolsMenu

        title: catalog.i18nc("@item:inmenu", "Mesh Tools")

        QIDI.MenuItem
        {
            text: catalog.i18nc("@item:inmenu", "Reload model")
            enabled: QD.Selection.selectionCount == 1
            onTriggered: manager.reloadMesh()
        }
        QIDI.MenuItem
        {
            text: catalog.i18nc("@item:inmenu", "Rename model...")
            enabled: QD.Selection.selectionCount == 1
            onTriggered: manager.renameMesh()
        }
        QIDI.MenuItem
        {
            text: catalog.i18ncp("@item:inmenu", "Replace model...", "Replace models...", QD.Selection.selectionCount)
            enabled: QD.Selection.hasSelection
            onTriggered: manager.replaceMeshes()
        }
        QIDI.MenuSeparator {}
        QIDI.MenuItem
        {
            text: catalog.i18ncp("@item:inmenu", "Check mesh", "Check meshes", QD.Selection.selectionCount)
            enabled: QD.Selection.hasSelection
            onTriggered: manager.checkMeshes()
        }
        QIDI.MenuItem
        {
            text: catalog.i18ncp("@item:inmenu", "Analyse mesh", "Analyse meshes", QD.Selection.selectionCount)
            enabled: QD.Selection.hasSelection
            onTriggered: manager.analyseMeshes()
        }
        QIDI.MenuItem
        {
            text: catalog.i18nc("@item:inmenu", "Fix simple holes")
            enabled: QD.Selection.hasSelection
            onTriggered: manager.fixSimpleHolesForMeshes()
        }
        QIDI.MenuItem
        {
            text: catalog.i18nc("@item:inmenu", "Fix model normals")
            enabled: QD.Selection.hasSelection
            onTriggered: manager.fixNormalsForMeshes()
        }
        QIDI.MenuItem
        {
            text: catalog.i18ncp("@item:inmenu", "Split model into parts", "Split models into parts", QD.Selection.selectionCount)
            enabled: QD.Selection.hasSelection
            onTriggered: manager.splitMeshes()
        }
        QIDI.MenuSeparator {}
        QIDI.MenuItem
        {
            text: catalog.i18nc("@item:inmenu", "Randomise location")
            enabled: QD.Selection.hasSelection
            onTriggered: manager.randomiseMeshLocation()
        }
        QIDI.MenuItem
        {
            text: catalog.i18nc("@item:inmenu", "Apply transformations to mesh")
            enabled: QD.Selection.hasSelection
            onTriggered: manager.bakeMeshTransformation()
        }
        QIDI.MenuItem
        {
            text: catalog.i18nc("@item:inmenu", "Reset origin to center of mesh")
            enabled: QD.Selection.hasSelection
            onTriggered: manager.resetMeshOrigin()
        }
    }
    QIDI.MenuSeparator
    {
        id: meshToolsSeparator
    }

    function moveToContextMenu(contextMenu)
    {
        contextMenu.insertItem(0, meshToolsSeparator)
        contextMenu.insertMenu(0, meshToolsMenu)
    }

    QD.I18nCatalog { id: catalog; name: "meshtools" }
}
