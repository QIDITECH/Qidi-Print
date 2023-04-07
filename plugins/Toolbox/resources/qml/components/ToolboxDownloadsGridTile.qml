// Copyright (c) 2018 QIDI B.V.
// Toolbox is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QD 1.1 as QD
import QIDI 1.1 as QIDI

Item
{
    id: toolboxDownloadsGridTile
    property int packageCount: (toolbox.viewCategory == "material" && model.type === undefined) ? toolbox.getTotalNumberOfMaterialPackagesByAuthor(model.id) : 1
    property int installedPackages: (toolbox.viewCategory == "material" && model.type === undefined) ? toolbox.getNumberOfInstalledPackagesByAuthor(model.id) : (toolbox.isInstalled(model.id) ? 1 : 0)
    height: childrenRect.height
    Layout.alignment: Qt.AlignTop | Qt.AlignLeft

    MouseArea
    {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: thumbnail.border.color = QD.Theme.getColor("primary")
        onExited: thumbnail.border.color = QD.Theme.getColor("lining")
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

    Rectangle
    {
        id: thumbnail
        width: QD.Theme.getSize("toolbox_thumbnail_small").width
        height: QD.Theme.getSize("toolbox_thumbnail_small").height
        color: QD.Theme.getColor("main_background")
        border.width: QD.Theme.getSize("default_lining").width
        border.color: QD.Theme.getColor("lining")

        Image
        {
            anchors.centerIn: parent
            width: QD.Theme.getSize("toolbox_thumbnail_small").width - QD.Theme.getSize("wide_margin").width
            height: QD.Theme.getSize("toolbox_thumbnail_small").height - QD.Theme.getSize("wide_margin").width
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit
            source: model.icon_url || "../../images/placeholder.svg"
            mipmap: true
        }
        QD.RecolorImage
        {
            width: (parent.width * 0.4) | 0
            height: (parent.height * 0.4) | 0
            anchors
            {
                bottom: parent.bottom
                right: parent.right
            }
            sourceSize.height: height
            visible: installedPackages != 0
            color: (installedPackages >= packageCount) ? QD.Theme.getColor("primary") : QD.Theme.getColor("border")
            source: "../../images/installed_check.svg"
        }
    }
    Item
    {
        anchors
        {
            left: thumbnail.right
            leftMargin: Math.floor(QD.Theme.getSize("narrow_margin").width)
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }

        Label
        {
            id: name
            text: model.name
            width: parent.width
            elide: Text.ElideRight
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default_bold")
        }
        Label
        {
            id: info
            text: model.description
            elide: Text.ElideRight
            width: parent.width
            wrapMode: Text.WordWrap
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default")
            anchors.top: name.bottom
            anchors.bottom: parent.bottom
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 2
        }
    }
}
