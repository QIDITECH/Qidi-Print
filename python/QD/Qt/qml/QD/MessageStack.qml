// Copyright (c) 2018 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.3
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.3
import QtQuick.Layouts 1.1

import QD 1.3 as QD

ListView
{
    id: base
    boundsBehavior: ListView.StopAtBounds
    verticalLayoutDirection: ListView.BottomToTop

    model: QD.VisibleMessagesModel { }
    spacing: QD.Theme.getSize("default_margin").height

    // Messages can have actions, which are displayed by means of buttons. The message stack supports 3 styles
    // of buttons "Primary", "Secondary" and "Link" (aka; "tertiary")
    property Component primaryButton: Component
    {
        Button
        {
            text: model.name
        }
    }

    property Component secondaryButton: Component
    {
        Button
        {
            text: model.name
        }
    }

    property Component link: Component
    {
        Button
        {
            text: model.name
            style: ButtonStyle
            {
                background: Item {}

                label: Label
                {
                    text: control.text
                    font:
                    {
                        var defaultFont = QD.Theme.getFont("default")
                        defaultFont.underline = true
                        return defaultFont
                    }
                    color: QD.Theme.getColor("text_link")
                }
            }
        }
    }

    interactive: false

    delegate: Rectangle
    {
        id: message

        property variant actions: model.actions
        property variant model_id: model.id

        width: QD.Theme.getSize("message").width
        // Height is the size of the children + a margin on top & bottom.
        height: childrenRect.height + 2 * QD.Theme.getSize("default_margin").height

        anchors.horizontalCenter: parent.horizontalCenter

        color: QD.Theme.getColor("white_3")
        border.width: QD.Theme.getSize("size").width
        border.color: QD.Theme.getColor("gray_3")
        radius: 5 * QD.Theme.getSize("size").width

        Item
        {
            id: titleBar

            anchors
            {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: QD.Theme.getSize("default_margin").width
            }

            height: childrenRect.height

            Button
            {
                id: closeButton
                width: QD.Theme.getSize("message_close").width
                height: QD.Theme.getSize("message_close").height

                anchors.right: parent.right

                style: ButtonStyle
                {
                    background: QD.RecolorImage
                    {
                        width: QD.Theme.getSize("message_close").width
                        sourceSize.width: width
                        color: control.hovered ? QD.Theme.getColor("message_close_hover") : QD.Theme.getColor("message_close")
                        source: QD.Theme.getIcon("Cancel")
                    }

                    label: Item {}
                }

                onClicked: base.model.hideMessage(model.id)
                visible: model.dismissable
                enabled: model.dismissable
            }

            Label
            {
                id: messageTitle

                anchors
                {
                    left: parent.left
                    right: closeButton.left
                    rightMargin: QD.Theme.getSize("default_margin").width
                }

                text: model.title == undefined ? "" : model.title
                color: QD.Theme.getColor("text")
                font: QD.Theme.getFont("default_bold")
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
                renderType: Text.NativeRendering
            }
        }
        Item
        {
            id: imageItem
            visible: messageImage.progress == 1.0
            height: visible ? childrenRect.height: 0

            anchors
            {
                left: parent.left
                leftMargin: QD.Theme.getSize("default_margin").width

                right: parent.right
                rightMargin: QD.Theme.getSize("default_margin").width

                top: titleBar.bottom
                topMargin: visible ? QD.Theme.getSize("default_margin").height: 0
            }
            Image
            {
                id: messageImage
                anchors
                {
                    horizontalCenter: parent.horizontalCenter
                }
                height: QD.Theme.getSize("message_image").height
                fillMode: Image.PreserveAspectFit
                source: model.image_source
                sourceSize
                {
                    height: height
                    width: width
                }
                mipmap: true
            }

            Label
            {
                id: imageCaption
                anchors
                {
                    left: parent.left
                    right: parent.right
                    top: messageImage.bottom
                    topMargin: QD.Theme.getSize("narrow_margin").height
                }

                text: model.image_caption
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: QD.Theme.getColor("text")
                font: QD.Theme.getFont("large_bold")
                height: contentHeight
                linkColor: QD.Theme.getColor("text_link")
            }
        }

        Label
        {
            id: messageLabel

            anchors
            {
                left: parent.left
                leftMargin: QD.Theme.getSize("default_margin").width

                right: parent.right
                rightMargin: QD.Theme.getSize("default_margin").width

                top: imageItem.bottom
                topMargin: QD.Theme.getSize("narrow_margin").height
            }

            height: text == "" ? 0 : contentHeight

            function getProgressText()
            {
                return "%1 %2%".arg(model.text).arg(Math.floor(model.progress))
            }

            text: model.progress > 0 ? messageLabel.getProgressText() : model.text == undefined ? "" : model.text
            onLinkActivated: Qt.openUrlExternally(link)
            color: QD.Theme.getColor("text")
            font: QD.Theme.getFont("default")
            wrapMode: Text.Wrap
            renderType: Text.NativeRendering
            linkColor: QD.Theme.getColor("text_link")
        }

        CheckBox
        {
            id: optionToggle
            anchors
            {
                top: messageLabel.bottom
                topMargin: visible ? QD.Theme.getSize("narrow_margin").height: 0
                left: parent.left
                leftMargin: QD.Theme.getSize("default_margin").width
                right: parent.right
                rightMargin: QD.Theme.getSize("default_margin").width
            }
            text: model.option_text
            visible: text != ""
            height: visible ? undefined: 0
            checked: model.option_state
            onCheckedChanged: base.model.optionToggled(message.model_id, checked)
            style: CheckBoxStyle
            {
                label: Label
                {
                    text: control.text
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    elide: Text.ElideRight
                }
            }
        }

        QD.ProgressBar
        {
            id: totalProgressBar
            value: 0

            // Doing this in an explicit binding since the implicit binding breaks on occasion.
            Binding
            {
                target: totalProgressBar
                property: "value"
                value: model.progress / model.max_progress
            }

            visible: model.progress == null ? false: true // If the progress is null (for example with the loaded message) -> hide the progressbar
            indeterminate: model.progress == -1 ? true: false //If the progress is unknown (-1) -> the progressbar is indeterminate

            anchors
            {
                top: optionToggle.bottom
                topMargin: visible ? QD.Theme.getSize("narrow_margin").height: 0

                left: parent.left
                leftMargin: QD.Theme.getSize("default_margin").width

                right: parent.right
                rightMargin: QD.Theme.getSize("default_margin").width
            }
        }

        // Right aligned Action Buttons
        RowLayout
        {
            id: actionButtons

            anchors
            {
                right: parent.right
                rightMargin: QD.Theme.getSize("default_margin").width

                top: totalProgressBar.bottom
                topMargin: QD.Theme.getSize("narrow_margin").width
            }

            Repeater
            {
                model:
                {
                    var filteredModel = new Array()
                    var sizeOfActions = message.actions == null ? 0 : message.actions.count
                    if(sizeOfActions == 0)
                    {
                        return 0;
                    }

                    for(var index = 0; index < sizeOfActions; index++)
                    {
                        var actionButton = message.actions.getItem(index)

                        var alignPosition = actionButton["button_align"]

                        // ActionButtonStyle.BUTTON_ALIGN_RIGHT == 3
                        if (alignPosition == 3)
                        {
                            filteredModel.push(actionButton)
                        }
                    }
                    return filteredModel
                }

                // Put the delegate in a loader so we can connect to it's signals.
                // We also need to use a different component based on the style of the action.
                delegate: Loader
                {
                    id: actionButton
                    sourceComponent:
                    {
                        if (modelData.button_style == 0)
                        {
                            return base.primaryButton
                        } else if (modelData.button_style == 1)
                        {
                            return base.link
                        } else if (modelData.button_style == 2)
                        {
                            return base.secondaryButton
                        }
                        return base.primaryButton // We got to use something, so use primary.
                    }
                    property var model: modelData
                    Connections
                    {
                        target: actionButton.item
                        function onClicked() { base.model.actionTriggered(message.model_id, modelData.action_id) }
                    }
                }
            }
        }

        // Left aligned Action Buttons
        RowLayout
        {
            id: leftActionButtons

            anchors
            {
                left: messageLabel.left
                leftMargin: QD.Theme.getSize("narrow_margin").width

                top: totalProgressBar.bottom
                topMargin: QD.Theme.getSize("narrow_margin").width
            }

            Repeater
            {
                model:
                {
                    var filteredModel = new Array()
                    var sizeOfActions = message.actions == null ? 0 : message.actions.count
                    if(sizeOfActions == 0)
                    {
                        return 0;
                    }

                    for(var index = 0; index < sizeOfActions; index++)
                    {
                        var actionButton = message.actions.getItem(index)

                        var alignPosition = actionButton["button_align"]

                        // ActionButtonStyle.BUTTON_ALIGN_LEFT == 2
                        if (alignPosition == 2)
                        {
                            filteredModel.push(actionButton)
                        }
                    }
                    return filteredModel
                }

                // Put the delegate in a loader so we can connect to it's signals.
                // We also need to use a different component based on the style of the action.
                delegate: Loader
                {
                    id: actionButton
                    sourceComponent:
                    {
                        if (modelData.button_style == 0)
                        {
                            return base.primaryButton
                        } else if (modelData.button_style == 1)
                        {
                            return base.link
                        } else if (modelData.button_style == 2)
                        {
                            return base.secondaryButton
                        }
                        return base.primaryButton // We got to use something, so use primary.
                    }
                    property var model: modelData
                    Connections
                    {
                        target: actionButton.item
                        function onClicked() { base.model.actionTriggered(message.model_id, modelData.action_id) }
                    }
                }
            }
        }
    }

    add: Transition
    {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; }
    }

    displaced: Transition
    {
        NumberAnimation { property: "y"; duration: 200; }
    }

    remove: Transition
    {
        NumberAnimation { property: "opacity"; to: 0; duration: 200; }
    }

}
