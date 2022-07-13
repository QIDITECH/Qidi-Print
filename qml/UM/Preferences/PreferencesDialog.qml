// Copyright (c) 2015 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import ".."

import UM 1.1 as UM

Dialog
{
    id: base;

    title: base.currentPage == 0 ? catalog.i18nc("@title:tab", "General") : base.currentPage == 1 ? catalog.i18nc("@title:window", "Setting visibility") : catalog.i18nc("@title:window", "Remove")
    minimumWidth: 423 * UM.Theme.getSize("default_margin").width/10
    minimumHeight: 455 * UM.Theme.getSize("default_margin").width/10
    width: 423 * UM.Theme.getSize("default_margin").width/10
    height: 455 * UM.Theme.getSize("default_margin").width/10

    property int currentPage: 0;

    Item
    {
        id: test
        //anchors.fill: parent;
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 23 * UM.Theme.getSize("default_margin").width/10

        TableView
        {
            id: pagesList;

            anchors {
                left: parent.left;
                top: parent.top;
                bottom: parent.bottom;
            }
            visible: false

            width: 7 * UM.Theme.getSize("line").width;

            alternatingRowColors: false;
            headerVisible: false;

            model: ListModel { id: configPagesModel; }

            TableViewColumn { role: "name" }

            onClicked:
            {
                if(base.currentPage != row)
                {
                    stackView.replace(configPagesModel.get(row).item);
                    base.currentPage = row;
                }
            }
        }

        StackView {
            id: stackView
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }

            initialItem: Item { property bool resetEnabled: false; }

            delegate: StackViewDelegate
            {
                function transitionFinished(properties)
                {
                    properties.exitItem.opacity = 1
                }

                pushTransition: StackViewTransition
                {
                    PropertyAnimation
                    {
                        target: enterItem
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 100
                    }
                    PropertyAnimation
                    {
                        target: exitItem
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 100
                    }
                }
            }
        }

        UM.I18nCatalog { id: catalog; name: "uranium"; }
    }
/*
    leftButtons: Button
    {
        text: catalog.i18nc("@action:button", "Defaults");
        enabled: stackView.currentItem.resetEnabled;
        onClicked: stackView.currentItem.reset();
        visible: base.currentPage == 0 ? true : false
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        style: UM.Theme.styles.parameterbutton
        height: 23
        width:70
    }*/

    rightButtons: Button
    {
        text: catalog.i18nc("@action:button", "Close");
        iconName: "dialog-close";
        onClicked: base.accept();
        anchors.right: parent.right
        anchors.rightMargin: -5 * UM.Theme.getSize("default_margin").width/10
        anchors.bottom: parent.bottom
        style: UM.Theme.styles.parameterbutton
        height: 23 * UM.Theme.getSize("default_margin").width/10
        width:70 * UM.Theme.getSize("default_margin").width/10
    }

    function setPage(index)
    {
        pagesList.selection.clear();
        pagesList.selection.select(index);

        stackView.replace(configPagesModel.get(index).item);

        base.currentPage = index
    }

    function insertPage(index, name, item)
    {
        configPagesModel.insert(index, { "name": name, "item": item });
    }

    function removePage(index)
    {
        configPagesModel.remove(index)
    }

    function getCurrentItem(key)
    {
        return stackView.currentItem
    }

    Component.onCompleted:
    {
        //This uses insertPage here because ListModel is stupid and does not allow using qsTr() on elements.
        insertPage(0, catalog.i18nc("@title:tab", "General"), Qt.resolvedUrl("GeneralPage.qml"));
        insertPage(1, catalog.i18nc("@title:tab", "Settings"), Qt.resolvedUrl("SettingVisibilityPage.qml"));
        insertPage(2, catalog.i18nc("@title:tab", "Plugins"), Qt.resolvedUrl("PluginsPage.qml"));

        setPage(0)
    }
}
