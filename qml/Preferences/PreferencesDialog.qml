// Copyright (c) 2021 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

//import ".."

import QD 1.3 as QD
import QIDI 1.1 as QIDI

QD.Dialog
{
    id: base;

    title: catalog.i18nc("@title:window", "Preferences")
    minimumWidth: 450 * QD.Theme.getSize("size").width
    minimumHeight: 480 * QD.Theme.getSize("size").height
    width: minimumWidth
    height: minimumHeight

    Item
    {
        id: test
        anchors.fill: parent

        StackView {
            id: stackView
            anchors.fill: parent
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
        QD.I18nCatalog { id: catalog; name: "qdtech"; }
    }

    leftButtons: QIDI.PrimaryButton
    {
        id: defaultsButton
        text: catalog.i18nc("@action:button", "Defaults")
        //enabled: stackView.currentItem.resetEnabled
        leftPadding: 16 * QD.Theme.getSize("size").height
        backgroundRadius: Math.round(height / 2)
        onClicked: stackView.currentItem.reset()
    }

    rightButtons: QIDI.ActionButton
    {
        shadowEnabled: true
        shadowColor: enabled ? QD.Theme.getColor("gray_2") : QD.Theme.getColor("action_button_disabled_shadow")
        color: QD.Theme.getColor("white_1")
        textColor: QD.Theme.getColor("secondary_button_text")
        outlineColor: "transparent"
        disabledColor: QD.Theme.getColor("action_button_disabled")
        textDisabledColor: QD.Theme.getColor("action_button_disabled_text")
        hoverColor: QD.Theme.getColor("white_1")
        text: catalog.i18nc("@action:button", "Close")
        backgroundRadius: Math.round(height / 2)
        leftPadding: 16 * QD.Theme.getSize("size").height
        onClicked: base.accept()
    }

    function setPage(item)
    {
        stackView.replace(item)
    }

    Component.onCompleted:
    {
        stackView.replace(Qt.resolvedUrl("GeneralPage.qml"))
    }
}
