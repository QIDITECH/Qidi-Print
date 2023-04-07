// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.1 as QD
import QIDI 1.0 as QIDI

/*Button
{
    id: base
    anchors.left: parent.left
    anchors.right: parent.right
    // To avoid overlaping with the scrollBars
    anchors.rightMargin: 2 * QD.Theme.getSize("thin_margin").width
    hoverEnabled: true

    background: Rectangle
    {
        id: backgroundRectangle
        height: QD.Theme.getSize("section").height
        color: QD.Theme.getColor("white_1")
        Behavior on color { ColorAnimation { duration: 50; } }
    }

    signal showTooltip(string text)
    signal hideTooltip()
    signal contextMenuRequested()
    signal showAllHiddenInheritedSettings(string category_id)
    signal focusReceived()
    signal setActiveFocusToNextSetting(bool forward)

    property var focusItem: base
    property bool expanded: definition.expanded


    property color text_color:
    {
        if (!base.enabled)
        {
            return QD.Theme.getColor("setting_category_disabled_text")
        } else if (base.hovered || base.pressed || base.activeFocus)
        {
            return QD.Theme.getColor("setting_category_active_text")
        }

        return QD.Theme.getColor("setting_category_text")

    }

    Label
    {
        id: settingNameLabel
        anchors
        {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        text: definition.label
        textFormat: Text.PlainText
        renderType: Text.NativeRendering
        font: QD.Theme.getFont("font3")
        color: base.text_color
        fontSizeMode: Text.HorizontalFit
        minimumPointSize: 8
    }

    onClicked:
    {
        if (definition.expanded)
        {
            settingDefinitionsModel.collapseRecursive(definition.key)
        }
        else
        {
            settingDefinitionsModel.expandRecursive(definition.key)
        }
        //Set focus so that tab navigation continues from this point on.
        //NB: This must be set AFTER collapsing/expanding the category so that the scroll position is correct.
        forceActiveFocus()
    }
    onActiveFocusChanged:
    {
        if (activeFocus)
        {
            base.focusReceived()
        }
    }

    Keys.onTabPressed: base.setActiveFocusToNextSetting(true)
    Keys.onBacktabPressed: base.setActiveFocusToNextSetting(false)

    QD.SimpleButton
    {
        id: settingsButton

        visible: base.hovered || settingsButton.hovered
        height: Math.round(base.height * 0.6)
        width: Math.round(base.height * 0.6)

        anchors
        {
            right: inheritButton.visible ? inheritButton.left : parent.right
            // Use 1.9 as the factor because there is a 0.1 difference between the settings and inheritance warning icons
            rightMargin: inheritButton.visible ? Math.round(QD.Theme.getSize("default_margin").width / 2) : Math.round(QD.Theme.getSize("default_margin").width * 1.9)
            verticalCenter: parent.verticalCenter
        }

        color: QD.Theme.getColor("setting_control_button")
        hoverColor: QD.Theme.getColor("setting_control_button_hover")
        iconSource: QD.Theme.getIcon("Sliders")

        onClicked: QIDI.Actions.configureSettingVisibility.trigger(definition)
    }

    QD.SimpleButton
    {
        id: inheritButton

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: QD.Theme.getSize("default_margin").width * 2


        height: Math.round(parent.height / 2)
        width: height

        onClicked:
        {
            settingDefinitionsModel.expandRecursive(definition.key)
            base.showAllHiddenInheritedSettings(definition.key)
        }

        color: QD.Theme.getColor("setting_control_button")
        hoverColor: QD.Theme.getColor("setting_control_button_hover")
        iconSource: QD.Theme.getIcon("Information")

        onEntered: base.showTooltip(catalog.i18nc("@label","Some hidden settings use values different from their normal calculated value.\n\nClick to make these settings visible."))

        onExited: base.hideTooltip()
    }
}*/
Item
{
    id: base
    anchors.left: parent.left
    anchors.right: parent.right

    signal showTooltip(string text)
    signal hideTooltip()
    signal contextMenuRequested()
    signal showAllHiddenInheritedSettings(string category_id)
    signal focusReceived()
    signal setActiveFocusToNextSetting(bool forward)
	property bool multipleExtruders: extrudersModel.count > 1

    property var extrudersModel: QIDIApplication.getExtrudersModel()
	
	Item
	{
		id:extruderIcon1
		anchors.left: parent.left
        anchors.leftMargin: 10 * QD.Theme.getSize("size").width
		//anchors.verticalCenter: parent.verticalCenter

		implicitWidth: 25 * QD.Theme.getSize("size").width
		implicitHeight: 25 * QD.Theme.getSize("size").height
		QD.RecolorImage
		{
			id: mainIcon
			anchors.fill: parent
			source: QD.Theme.getIcon(definition.icon, "default")
			color: QD.Theme.getColor("blue_8")
		}
	}
	
    Label
    {
        id: settingNameLabel
        anchors.left: extruderIcon1.right
        anchors.leftMargin: 10 * QD.Theme.getSize("size").width
        //anchors.right: parent.right
		width:30 * QD.Theme.getSize("size").width
        anchors.verticalCenter: extruderIcon1.verticalCenter
        text: definition.label
        renderType: Text.NativeRendering
        font: QD.Theme.getFont("large_huge")
        color: QD.Theme.getColor("blue_8")
    }
	/*QIDI.ExtruderIcon
	{
		id:extruderIcon2
		anchors.left: settingNameLabel.right
        anchors.leftMargin: 50 * QD.Theme.getSize("size").width
		anchors.verticalCenter: extruderIcon1.verticalCenter

		materialColor:QIDI.ExtruderManager.icon_color_for_setting//QD.Preferences.getValue("color/extruder" + QIDI.ExtruderManager.activeExtruderIndex)
		extruderIndex : QIDI.ExtruderManager.activeExtruderIndex+1
	}*/
	
    Label
    {
        anchors.right: parent.right
        anchors.rightMargin: 10 * QD.Theme.getSize("size").width
		anchors.verticalCenter: extruderIcon1.verticalCenter

        //anchors.right: parent.right
		width:30 * QD.Theme.getSize("size").width
        //anchors.verticalCenter: parent.verticalCenter
        text:QD.Preferences.getValue("qidi/active_machine") !="X-pro" ? "E" + (QIDI.ExtruderManager.activeExtruderIndex+1):QIDI.ExtruderManager.activeExtruderIndex == 0? "E R" :"E L"
        renderType: Text.NativeRendering
        font: QD.Theme.getFont("large_huge2")
        color: QIDI.ExtruderManager.icon_color_for_setting
		visible:multipleExtruders
    }
	
	Rectangle
	{
		anchors.bottom : parent.bottom
		anchors.bottomMargin : 15 * QD.Theme.getSize("size").height
		anchors.horizontalCenter: parent.horizontalCenter

		//anchors.right: parent.right
		width:0.8*parent.width//260*QD.Theme.getSize("size").height
		height: QD.Theme.getSize("size").height
		color: QD.Theme.getColor("blue_6")
		visible: true
	}
	
	/*QD.RecolorImage
	{
		id: mainIcon5
		anchors.bottom : parent.bottom
		anchors.bottomMargin : 5 * QD.Theme.getSize("size").height
		anchors.horizontalCenter: parent.horizontalCenter
		height:10*QD.Theme.getSize("size").height
		width:250 * QD.Theme.getSize("size").width
		source: QD.Theme.getIcon("Minus", "default")
		color: QD.Theme.getColor("blue_3")
	}*/
	

}