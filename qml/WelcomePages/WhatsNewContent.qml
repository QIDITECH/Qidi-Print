// Copyright (c) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QD 1.3 as QD
import QIDI 1.1 as QIDI


//
// This component contains the content for the "What's new in QIDI QIDI" page of the welcome on-boarding process.
// Previously this was just the changelog, but now it will just have the larger stories, the changelog has its own page.
//
Item
{
    property var manager: QIDIApplication.getWhatsNewPagesModel()

    QD.I18nCatalog { id: catalog; name: "qidi" }

    Label
    {
        id: titleLabel
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        text: catalog.i18nc("@label", "What's New")
        color: QD.Theme.getColor("primary_button")
        font: QD.Theme.getFont("huge")
        renderType: Text.NativeRendering
    }

    Rectangle
    {
        anchors
        {
            top: titleLabel.bottom
            topMargin: QD.Theme.getSize("default_margin").width
            bottom: whatsNewDots.top
            bottomMargin: QD.Theme.getSize("narrow_margin").width
            left: parent.left
            right: parent.right
        }

        color: QD.Theme.getColor("viewport_overlay")

        StackLayout
        {
            id: whatsNewViewport

            anchors
            {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            height: parent.height
            width: parent.width

            currentIndex: whatsNewDots.currentIndex

            Repeater
            {

                model: manager.subpageCount

                Rectangle
                {
                    Layout.alignment: Qt.AlignHCenter
                    color: QD.Theme.getColor("viewport_overlay")
                    width: whatsNewViewport.width
                    height: whatsNewViewport.height

                    AnimatedImage
                    {
                        id: subpageImage

                        anchors
                        {
                            top: parent.top
                            topMargin: QD.Theme.getSize("thick_margin").width
                            left: parent.left
                            leftMargin: QD.Theme.getSize("thick_margin").width
                            right: parent.right
                            rightMargin: QD.Theme.getSize("thick_margin").width
                        }
                        width: Math.round(parent.width - (QD.Theme.getSize("thick_margin").height * 2))
                        fillMode: Image.PreserveAspectFit
                        onStatusChanged: playing = (status == AnimatedImage.Ready)

                        source: manager.getSubpageImageSource(index)
                    }

                    QIDI.ScrollableTextArea
                    {
                        id: subpageText

                        anchors
                        {
                            top: subpageImage.bottom
                            topMargin: QD.Theme.getSize("default_margin").height
                            bottom: parent.bottom
                            bottomMargin: QD.Theme.getSize("thick_margin").height
                            left: subpageImage.left
                            right: subpageImage.right
                        }

                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        back_color: QD.Theme.getColor("viewport_overlay")
                        do_borders: false

                        textArea.wrapMode: TextEdit.Wrap
                        textArea.text: manager.getSubpageText(index)
                        textArea.textFormat: Text.RichText
                        textArea.readOnly: true
                        textArea.font: QD.Theme.getFont("default")
                        textArea.onLinkActivated: Qt.openUrlExternally(link)
                        textArea.leftPadding: 0
                        textArea.rightPadding: 0
                    }
                }
            }
        }
    }

    PageIndicator
    {
        id: whatsNewDots

        currentIndex: whatsNewViewport.currentIndex
        count: whatsNewViewport.count
        interactive: true

        anchors
        {
            bottom: whatsNewNextButton.top
            bottomMargin: QD.Theme.getSize("narrow_margin").height
            horizontalCenter: parent.horizontalCenter
        }

        delegate:
            Rectangle
            {
                width: QD.Theme.getSize("thin_margin").width
                height: QD.Theme.getSize("thin_margin").height

                radius: width / 2
                color:
                    index === whatsNewViewport.currentIndex ?
                    QD.Theme.getColor("primary") :
                    QD.Theme.getColor("secondary_button_shadow")
            }
    }

    Item
    {
        id: bottomSpacer
        anchors.bottom: whatsNewNextButton.top
        height: QD.Theme.getSize("default_margin").height / 2
        width: QD.Theme.getSize("default_margin").width / 2
    }

    QIDI.TertiaryButton
    {
        id: whatsNewNextButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        text: base.currentItem.next_page_button_text
        onClicked: base.showNextPage()
    }

    QIDI.PrimaryButton
    {
        id: whatsNewSubpageButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text: catalog.i18nc("@button", "Next")
        onClicked:
            whatsNewDots.currentIndex === (whatsNewDots.count - 1) ?
            base.showNextPage() :
            ++whatsNewDots.currentIndex
    }
}
