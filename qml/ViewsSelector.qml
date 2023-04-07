// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.3

import QD 1.2 as QD
import QIDI 1.0 as QIDI

QIDI.ExpandablePopup
{
    id: viewSelector

    contentPadding: QD.Theme.getSize("default_lining").width
    contentAlignment: QIDI.ExpandablePopup.ContentAlignment.AlignLeft

    property var viewModel: QD.ViewModel
    {
        onDataChanged: updateActiveView()
    }

    property var activeView: null

    function updateActiveView()
    {
        for (var index in viewModel.items)
        {
            if (viewModel.items[index].active)
            {
                activeView = viewModel.items[index]
                return
            }
        }
        activeView = null
    }

    Component.onCompleted:
    {
        if (activeView == null)
        {
            QD.Controller.setActiveView(viewModel.getItem(0).id)
        }
    }

    headerItem: Item
    {
        Label
        {
            id: title
            text: catalog.i18nc("@label", "View type")
            verticalAlignment: Text.AlignVCenter
            height: parent.height
            elide: Text.ElideRight
            font: QD.Theme.getFont("medium")
            color: QD.Theme.getColor("text_medium")
            renderType: Text.NativeRendering
        }

        Label
        {
            text: viewSelector.activeView ? viewSelector.activeView.name : ""
            verticalAlignment: Text.AlignVCenter
            anchors
            {
                left: title.right
                leftMargin: QD.Theme.getSize("default_margin").width
                right: parent.right
            }
            height: parent.height
            elide: Text.ElideRight
            font: QD.Theme.getFont("medium")
            color: QD.Theme.getColor("text")
            renderType: Text.NativeRendering
        }
    }

    contentItem: Column
    {
        id: viewSelectorPopup
        width: viewSelector.width - 2 * viewSelector.contentPadding

        // For some reason the height/width of the column gets set to 0 if this is not set...
        Component.onCompleted:
        {
            height = implicitHeight
            width = viewSelector.width - 2 * viewSelector.contentPadding
        }

        Repeater
        {
            id: viewsList
            model: viewSelector.viewModel

            delegate: Button
            {
                id: viewsSelectorButton
                text: model.name
                width: parent.width - viewSelectorPopup.leftPadding - viewSelectorPopup.rightPadding
                height: QD.Theme.getSize("action_button").height
                leftPadding: QD.Theme.getSize("default_margin").width
                rightPadding: QD.Theme.getSize("default_margin").width
                checkable: true
                checked: viewSelector.activeView != null ? viewSelector.activeView.id == id : false

                contentItem: Label
                {
                    id: buttonText
                    text: viewsSelectorButton.text
                    color: QD.Theme.getColor("text")
                    font: QD.Theme.getFont("medium")
                    renderType: Text.NativeRendering
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle
                {
                    id: backgroundRect
                    color: viewsSelectorButton.hovered ? QD.Theme.getColor("action_button_hovered") : "transparent"
                    radius: QD.Theme.getSize("action_button_radius").width
                    border.width: QD.Theme.getSize("default_lining").width
                    border.color: viewsSelectorButton.checked ? QD.Theme.getColor("primary") : "transparent"
                }

                onClicked:
                {
                    toggleContent()
                    QD.Controller.setActiveView(id)
                }
            }
        }
    }
}