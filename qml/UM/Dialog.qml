// Copyright (c) 2017 Ultimaker B.V.
// Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Layouts 1.1

import UM 1.0 as UM

Window {
    id: base

    modality: Qt.ApplicationModal;
    flags: Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint;

    //minimumWidth: screenScaleFactor * 640;
    //minimumHeight: screenScaleFactor * 480;
    //width: minimumWidth
    //height: minimumHeight

    property int margin: screenScaleFactor * 8;
    property bool closeOnAccept: true;  // Automatically close the window when the window is "accepted" (eg using the return key)

    default property alias contents: contentItem.children;

    property alias leftButtons: leftButtonRow.children;
    property alias rightButtons: rightButtonRow.children;

    signal accepted();
    signal rejected();

    function accept() {
        if (base.closeOnAccept) {
            base.visible = false;
        }
        base.accepted();
    }

    function reject() {
        //If we don't have a close button we don't want to allow the user to close the window by rejecting it (escape key).
        if (base.flags & Qt.WindowCloseButtonHint)
        {
            base.visible = false;
            base.rejected();
        }
    }

    function open() {
        base.visible = true;
    }

    Rectangle {
        anchors.fill: parent;
        color: UM.Theme.getColor("color1")//palette.window;

        focus: base.visible;

        Keys.onEscapePressed:{
            base.reject();
        }

        Keys.onReturnPressed: {
            base.accept();
        }

        Item {
            id: contentItem;

            anchors {
                left: parent.left;
                //leftMargin: base.margin;
                right: parent.right;
                //rightMargin: base.margin;
                top: parent.top;
                //topMargin: base.margin;
                bottom: buttonRow.top;
                bottomMargin: base.margin;
            }
        }

        Item {
            id: buttonRow;

            anchors {
                bottom: parent.bottom;
                bottomMargin: base.margin;
                left: parent.left;
                //leftMargin: base.margin;
                right: parent.right;
                rightMargin: 15//base.margin;
            }
            height: childrenRect.height;

            Row { id: leftButtonRow; anchors.left: parent.left; }

            Row { id: rightButtonRow; anchors.right: parent.right; }
        }
    }

    SystemPalette { id: palette; }
}
