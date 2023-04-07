// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import QD 1.1 as QD

Rectangle
{
    property int packageCount: toolbox.viewCategory == "material" ? toolbox.getTotalNumberOfMaterialPackagesByAuthor(model.id) : 1
    property int installedPackages: toolbox.viewCategory == "material" ? toolbox.getNumberOfInstalledPackagesByAuthor(model.id) : (toolbox.isInstalled(model.id) ? 1 : 0)
    id: tileBase
    width: QD.Theme.getSize("toolbox_thumbnail_large").width + (2 * QD.Theme.getSize("default_lining").width)
    height: thumbnail.height + packageName.height + QD.Theme.getSize("default_margin").width
    border.width: QD.Theme.getSize("default_lining").width
    border.color: QD.Theme.getColor("lining")
    color: QD.Theme.getColor("main_background")
    Image
    {
        id: thumbnail
        height: QD.Theme.getSize("toolbox_thumbnail_large").height - 4 * QD.Theme.getSize("default_margin").height
        width: QD.Theme.getSize("toolbox_thumbnail_large").height - 4 * QD.Theme.getSize("default_margin").height
        sourceSize.height: height
        sourceSize.width: width
        fillMode: Image.PreserveAspectFit
        source: model.icon_url || "../../images/placeholder.svg"
        mipmap: true
        anchors
        {
            top: parent.top
            topMargin: QD.Theme.getSize("default_margin").height
            horizontalCenter: parent.horizontalCenter
        }
    }
    Label
    {
        id: packageName
        text: model.name
        anchors
        {
            horizontalCenter: parent.horizontalCenter
            top: thumbnail.bottom
        }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        renderType: Text.NativeRendering
        height: QD.Theme.getSize("toolbox_heading_label").height
        width: parent.width - QD.Theme.getSize("default_margin").width
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        font: QD.Theme.getFont("medium_bold")
        color: QD.Theme.getColor("text")
    }
    QD.RecolorImage
    {
        width: (parent.width * 0.20) | 0
        height: width
        anchors
        {
            bottom: bottomBorder.top
            right: parent.right
        }
        visible: installedPackages != 0
        color: (installedPackages >= packageCount) ? QD.Theme.getColor("primary") : QD.Theme.getColor("border")
        source: "../../images/installed_check.svg"
    }

    Rectangle
    {
        id: bottomBorder
        color: QD.Theme.getColor("primary")
        anchors.bottom: parent.bottom
        width: parent.width
        height: QD.Theme.getSize("toolbox_header_highlight").height
    }

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: tileBase.border.color = QD.Theme.getColor("primary")
        onExited: tileBase.border.color = QD.Theme.getColor("lining")
        onClicked:
        {
            base.selection = model
            switch(toolbox.viewCategory)
            {
                case "material":

                    // If model has a type, it must be a package
                    if (model.type !== undefined)
                    {
                        toolbox.viewPage = "detail"
                        toolbox.filterModelByProp("packages", "id", model.id)
                    }
                    else
                    {
                        toolbox.viewPage = "author"
                        toolbox.setFilters("packages", {
                            "author_id": model.id,
                            "type": "material"
                        })
                    }
                    break
                default:
                    toolbox.viewPage = "detail"
                    toolbox.filterModelByProp("packages", "id", model.id)
                    break
            }
        }
    }
}
