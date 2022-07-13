// Copyright (c) 2017 Ultimaker B.V.
// Cura is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.1

import UM 1.2 as UM
import Cura 1.0 as Cura

UM.Dialog
{
    id: base
    title: catalog.i18nc("@title:window", "Discard or Keep changes")

    width: 800 * screenScaleFactor
    height: 350 * screenScaleFactor
    property var changesModel: Cura.UserChangesModel{ id: userChangesModel}
    onVisibilityChanged:
    {
        if(visible)
        {
            changesModel.forceUpdate()

            discardOrKeepProfileChangesDropDownButton.currentIndex = 0;
            for (var i = 0; i < discardOrKeepProfileChangesDropDownButton.model.count; ++i)
            {
                var code = discardOrKeepProfileChangesDropDownButton.model.get(i).code;
                if (code == UM.Preferences.getValue("cura/choice_on_profile_override"))
                {
                    discardOrKeepProfileChangesDropDownButton.currentIndex = i;
                    break;
                }
            }
        }
    }

    Row
    {
        id: infoTextRow
        height: childrenRect.height
        anchors.margins: UM.Theme.getSize("default_margin").width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: UM.Theme.getSize("default_margin").width

        UM.I18nCatalog
        {
            id: catalog;
            name: "cura"
        }

        Label
        {
            text: catalog.i18nc("@text:window", "You have customized some profile settings.\nWould you like to keep or discard those settings?")
            anchors.margins: UM.Theme.getSize("default_margin").width
            wrapMode: Text.WordWrap
            font: UM.Theme.getFont("font1")
        }
    }

    Item
    {
        anchors.leftMargin: UM.Theme.getSize("default_margin").width
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
        anchors.topMargin: UM.Theme.getSize("default_margin").width
        anchors.bottomMargin: 6 * UM.Theme.getSize("default_margin").width/10
        anchors.top: infoTextRow.bottom
        anchors.bottom: buttonsRow.top
        anchors.left: parent.left
        anchors.right: parent.right
        TableView
        {
            anchors.fill: parent
            height: base.height - 150 * UM.Theme.getSize("default_margin").width/10
            id: tableView
            headerDelegate :Rectangle//设置表头的样式
            {
                implicitHeight: 16 * UM.Theme.getSize("default_margin").width/10
                Text
                {
                     text: styleData.value
                     font: UM.Theme.getFont("font1")
                     color: UM.Theme.getColor("color4")
                 }
            }

            Component
            {
                id: labelDelegate
                Label
                {
                    property var extruder_name: userChangesModel.getItem(styleData.row).extruder
                    anchors.left: parent.left
                    anchors.leftMargin: UM.Theme.getSize("default_margin").width
                    font: UM.Theme.getFont("font1")
                    color: UM.Theme.getColor("color4")
                    text:
                    {
                        var result = styleData.value
                        if (extruder_name != "")
                        {
                            result += " (" + extruder_name + ")"
                        }
                        return result
                    }
                }
            }

            Component
            {
                id: defaultDelegate
                Label
                {
                    text: styleData.value
                    font: UM.Theme.getFont("font1")
                    color: UM.Theme.getColor("color2")
                }
            }

            Component
            {
                id: customizedDelegate
                Label
                {
                    text: styleData.value
                    font: UM.Theme.getFont("font1")
                    color: UM.Theme.getColor("color4")
                }
            }

            TableViewColumn
            {
                role: "label"
                title: catalog.i18nc("@title:column", "Profile settings")
                delegate: labelDelegate
                width: (tableView.width * 0.4) | 0
            }
            TableViewColumn
            {
                role: "original_value"
                title: catalog.i18nc("@title:column", "Default")
                width: (tableView.width * 0.3) | 0
                delegate: defaultDelegate
            }
            TableViewColumn
            {
                role: "user_value"
                title: catalog.i18nc("@title:column", "Customized")
                width: (tableView.width * 0.3) - 2 | 0
                delegate: customizedDelegate
            }
            section.property: "category"
            section.delegate: Label
            {
                text: section
                font: UM.Theme.getFont("font8")
                color: UM.Theme.getColor("color4")
            }

            model: base.changesModel
        }
    }
/*
    Item
    {
        id: optionRow
        anchors.bottom: buttonsRow.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: UM.Theme.getSize("default_margin").width
        height: childrenRect.height

        ComboBox
        {
            id: discardOrKeepProfileChangesDropDownButton
            width: 300

            model: ListModel
            {
                id: discardOrKeepProfileListModel

                Component.onCompleted: {
                    append({ text: catalog.i18nc("@option:discardOrKeep", "Always ask me this"), code: "always_ask" })
                    append({ text: catalog.i18nc("@option:discardOrKeep", "Discard and never ask again"), code: "always_discard" })
                    append({ text: catalog.i18nc("@option:discardOrKeep", "Keep and never ask again"), code: "always_keep" })
                }
            }

            onActivated:
            {
                var code = model.get(index).code;
                UM.Preferences.setValue("cura/choice_on_profile_override", code);

                if (code == "always_keep") {
                    keepButton.enabled = true;
                    discardButton.enabled = false;
                }
                else if (code == "always_discard") {
                    keepButton.enabled = false;
                    discardButton.enabled = true;
                }
                else {
                    keepButton.enabled = true;
                    discardButton.enabled = true;
                }
            }
        }
    }
*/
    Item
    {
        id: buttonsRow
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottomMargin: -4 * UM.Theme.getSize("default_margin").width/10
        anchors.leftMargin: UM.Theme.getSize("default_margin").width
        anchors.rightMargin: UM.Theme.getSize("default_margin").width
        height: childrenRect.height

        Button
        {
            id: discardButton
            text: catalog.i18nc("@action:button", "Discard");
            anchors.right: parent.right
            width: 70 * UM.Theme.getSize("default_margin").width/10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            onClicked:
            {
                CuraApplication.discardOrKeepProfileChangesClosed("discard")
                base.hide()
            }
            isDefault: true
            style: UM.Theme.styles.parameterbutton
        }

        Button
        {
            id: keepButton
            text: catalog.i18nc("@action:button", "Keep");
            anchors.right: discardButton.left
            anchors.rightMargin: UM.Theme.getSize("default_margin").width
            style: UM.Theme.styles.parameterbutton
            width: 70 * UM.Theme.getSize("default_margin").width/10
            height: 23 * UM.Theme.getSize("default_margin").width/10
            onClicked:
            {
                CuraApplication.discardOrKeepProfileChangesClosed("keep")
                base.hide()
            }
        }

        ComboBox
        {
            id: discardOrKeepProfileChangesDropDownButton
            width: 200 * UM.Theme.getSize("default_margin").width/10
            anchors.left: parent.left
            style: UM.Theme.styles.combobox

            model: ListModel
            {
                id: discardOrKeepProfileListModel

                Component.onCompleted: {
                    append({ text: catalog.i18nc("@option:discardOrKeep", "Always ask me this"), code: "always_ask" })
                    append({ text: catalog.i18nc("@option:discardOrKeep", "Discard and never ask again"), code: "always_discard" })
                    append({ text: catalog.i18nc("@option:discardOrKeep", "Keep and never ask again"), code: "always_keep" })
                }
            }

            onActivated:
            {
                var code = model.get(index).code;
                UM.Preferences.setValue("cura/choice_on_profile_override", code);

                if (code == "always_keep") {
                    keepButton.enabled = true;
                    discardButton.enabled = false;
                }
                else if (code == "always_discard") {
                    keepButton.enabled = false;
                    discardButton.enabled = true;
                }
                else {
                    keepButton.enabled = true;
                    discardButton.enabled = true;
                }
            }
        }
/*
        Button
        {
            id: createNewProfileButton
            text: catalog.i18nc("@action:button", "Create New Profile");
            anchors.left: parent.left
            action: Cura.Actions.addProfile
            onClicked: base.hide()
        }*/
    }
}
