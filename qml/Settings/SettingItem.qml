// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import QD 1.1 as QD
import QIDI 1.0 as QIDI

import "."

Item
{
    id: base

    height: QD.Theme.getSize("section").height
    anchors.left: parent.left
    anchors.right: parent.right
    // To avoid overlaping with the scrollBars
    anchors.rightMargin: 2 * QD.Theme.getSize("thin_margin").width

    property alias contents: controlContainer.children
    property alias hovered: mouse.containsMouse
    property bool showRevertButton: true
    property bool showInheritButton: true
    property bool showLinkedSettingIcon: true
    property bool doDepthIndentation: true
    property bool doQualityUserSettingEmphasis: true
    property var settingKey: definition.key //Used to detect each individual setting more easily in Squish GUI tests.

    // Create properties to put property provider stuff in (bindings break in qt 5.5.1 otherwise)
    property var state: propertyProvider.properties.state
    property var resolve: propertyProvider.properties.resolve
    property var stackLevels: propertyProvider.stackLevels
    property var stackLevel: stackLevels[0]
    // A list of stack levels that will trigger to show the revert button
    property var showRevertStackLevels: [0]
    property bool resetButtonVisible: {
        var is_revert_stack_level = false;
		//testf = ""
		//QIDIApplication.writeToLog("e",propertyProvider)
        for (var i in base.showRevertStackLevels)
        {
            if (base.stackLevel == i)
            {
				QIDIApplication.parameter_testf_change("")
				QIDIApplication.parameter_testf_change("Machine")
                is_revert_stack_level = true
                break
            }
        }
		/*if (is_revert_stack_level == true)
		{
			if (QD.Preferences.getValue("qidi/category_expanded") == "enable_travel_prime;extruder;infill_line_width;infill_material_flow;initial_layer_line_width_factor;limit_support_retractions;line_width;material_flow;material_flow_layer_0;prime_tower_flow;prime_tower_line_width;retract_at_layer_change;retraction_amount;retraction_count_max;retraction_enable;retraction_extra_prime_amount;retraction_extrusion_window;retraction_min_travel;retraction_prime_speed;retraction_retract_speed;retraction_speed;roofing_material_flow;skin_line_width;skin_material_flow;skirt_brim_line_width;skirt_brim_material_flow;support_bottom_line_width;support_bottom_material_flow;support_interface_line_width;support_interface_material_flow;support_line_width;support_material_flow;support_roof_line_width;support_roof_material_flow;switch_extruder_extra_prime_amount;switch_extruder_prime_speed;switch_extruder_retraction_amount;switch_extruder_retraction_speed;switch_extruder_retraction_speeds;travel_prime_rate;travel_prime_rate_layer_0;wall_0_material_flow;wall_line_width;wall_line_width_0;wall_line_width_x;wall_material_flow;wall_x_material_flow")
			{
				QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+"extruder"+"_"+QIDI.ExtruderManager.activeExtruderIndex+"_"+definition.key,"add")
			}
			else
			{
				if (definition.key != "extruder_tower_position_y" && definition.key != "extruder_tower_position_x")
				{
					if (!definition.settable_per_extruder)
					{
						QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+QD.Preferences.getValue("qidi/category_expanded")+"_0_"+definition.key,"add")
						QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+QD.Preferences.getValue("qidi/category_expanded")+"_1_"+definition.key,"add")
					}
					else{
						QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+QD.Preferences.getValue("qidi/category_expanded")+"_"+QIDI.ExtruderManager.activeExtruderIndex+"_"+definition.key,"add")
					}
				}
				//QIDIApplication.writeToLog("e",QIDI.ExtruderManager.activeExtruderIndex)
			}
			//QD.Preferences.setValue("qidi/icon_color",QIDIApplication.parameter_changed_color_save())
		}
		else
		{
			if (QD.Preferences.getValue("qidi/category_expanded") == "enable_travel_prime;extruder;infill_line_width;infill_material_flow;initial_layer_line_width_factor;limit_support_retractions;line_width;material_flow;material_flow_layer_0;prime_tower_flow;prime_tower_line_width;retract_at_layer_change;retraction_amount;retraction_count_max;retraction_enable;retraction_extra_prime_amount;retraction_extrusion_window;retraction_min_travel;retraction_prime_speed;retraction_retract_speed;retraction_speed;roofing_material_flow;skin_line_width;skin_material_flow;skirt_brim_line_width;skirt_brim_material_flow;support_bottom_line_width;support_bottom_material_flow;support_interface_line_width;support_interface_material_flow;support_line_width;support_material_flow;support_roof_line_width;support_roof_material_flow;switch_extruder_extra_prime_amount;switch_extruder_prime_speed;switch_extruder_retraction_amount;switch_extruder_retraction_speed;switch_extruder_retraction_speeds;travel_prime_rate;travel_prime_rate_layer_0;wall_0_material_flow;wall_line_width;wall_line_width_0;wall_line_width_x;wall_material_flow;wall_x_material_flow")
			{
				QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+"extruder"+"_"+QIDI.ExtruderManager.activeExtruderIndex+"_"+definition.key,"remove")
			}
			else
			{
				//QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+QD.Preferences.getValue("qidi/category_expanded")+"_"+QIDI.ExtruderManager.activeExtruderIndex+"_"+definition.key,"remove")
				if (!definition.settable_per_extruder)
				{
					QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+QD.Preferences.getValue("qidi/category_expanded")+"_0_"+definition.key,"remove")
					QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+QD.Preferences.getValue("qidi/category_expanded")+"_1_"+definition.key,"remove")
				}
				else{
					QIDIApplication.parameter_cahnged(QD.Preferences.getValue("qidi/active_machine")+"_"+QD.Preferences.getValue("qidi/category_expanded")+"_"+QIDI.ExtruderManager.activeExtruderIndex+"_"+definition.key,"remove")
				}
			}
			QD.Preferences.setValue("qidi/icon_color",QIDIApplication.parameter_changed_color_save())
		}*/
		//testf = "Machine"
        return is_revert_stack_level && base.showRevertButton
    }

    signal focusReceived()
    signal setActiveFocusToNextSetting(bool forward)
    signal contextMenuRequested()
    signal showTooltip(string text)
    signal hideTooltip()
    signal showAllHiddenInheritedSettings(string category_id)

    function createTooltipText()
    {
        var affects = settingDefinitionsModel.getRequiredBy(definition.key, "value")
        var affected_by = settingDefinitionsModel.getRequires(definition.key, "value")

        var affected_by_list = ""
        for (var i in affected_by)
        {
            affected_by_list += "<li>%1</li>\n".arg(affected_by[i].label)
        }

        var affects_list = ""
        for (var i in affects)
        {
            affects_list += "<li>%1</li>\n".arg(affects[i].label)
        }

        var tooltip = "<b>%1</b>\n<p>%2</p>".arg(definition.label).arg(definition.description)

        if(!propertyProvider.isValueUsed)
        {
            tooltip += "<i>%1</i><br/><br/>".arg(catalog.i18nc("@label", "This setting is not used because all the settings that it influences are overridden."))
        }

        if (affects_list != "")
        {
            tooltip += "<b>%1</b><ul>%2</ul>".arg(catalog.i18nc("@label Header for list of settings.", "Affects")).arg(affects_list)
        }

        if (affected_by_list != "")
        {
            tooltip += "<b>%1</b><ul>%2</ul>".arg(catalog.i18nc("@label Header for list of settings.", "Affected By")).arg(affected_by_list)
        }

        return tooltip
    }

    MouseArea
    {
        id: mouse

        anchors.fill: parent

        acceptedButtons: Qt.RightButton
        hoverEnabled: true;

        onClicked: base.contextMenuRequested()

        onEntered:
        {
            hoverTimer.start()
        }

        onExited:
        {
            if (controlContainer.item && controlContainer.item.hovered)
            {
                return
            }
            hoverTimer.stop()
            base.hideTooltip()
        }

        Timer
        {
            id: hoverTimer
            interval: 500
            repeat: false

            onTriggered:
            {
                base.showTooltip(base.createTooltipText())
            }
        }

        Label
        {
            id: label

            anchors.left: parent.left
            anchors.leftMargin: doDepthIndentation ? Math.round(QD.Theme.getSize("thin_margin").width + ((definition.depth - 1) * QD.Theme.getSize("setting_control_depth_margin").width)) : 0
            anchors.right: settingControls.left
            anchors.verticalCenter: parent.verticalCenter

            text: definition.label
            elide: Text.ElideMiddle
            renderType: Text.NativeRendering
            textFormat: Text.PlainText

            color: base.doQualityUserSettingEmphasis && base.stackLevel !== undefined && base.stackLevel <= 1 ? QD.Theme.getColor("blue_8") : QD.Theme.getColor("black_1")
            opacity: (definition.visible) ? 1 : 0.5
            // emphasize the setting if it has a value in the user or quality profile
            font: QD.Theme.getFont("font1")
        }

        Row
        {
            id: settingControls

            height: QD.Theme.getSize("section_control").height
            spacing: Math.round(QD.Theme.getSize("thick_margin").height / 2)

            anchors
            {
                right: controlContainer.left
                rightMargin: Math.round(QD.Theme.getSize("thick_margin").width / 2)
                verticalCenter: parent.verticalCenter
            }

            QD.SimpleButton
            {
                id: linkedSettingIcon;

                visible: (!definition.settable_per_extruder || String(globalPropertyProvider.properties.limit_to_extruder) != "-1") && base.showLinkedSettingIcon

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: height

                color: QD.Theme.getColor("setting_control_button")
                hoverColor: QD.Theme.getColor("setting_control_button")

                iconSource: QD.Theme.getIcon("Link")

                onEntered:
                {
                    hoverTimer.stop()
                    var tooltipText = catalog.i18nc("@label", "This setting is always shared between all extruders. Changing it here will change the value for all extruders.")
                    if ((resolve !== "None") && (stackLevel !== 0))
                    {
                        // We come here if a setting has a resolve and the setting is not manually edited.
                        tooltipText += " " + catalog.i18nc("@label", "This setting is resolved from conflicting extruder-specific values:") + " [" + QIDI.ExtruderManager.getInstanceExtruderValues(definition.key) + "]."
                    }
                    base.showTooltip(tooltipText)
                }
                onExited: base.showTooltip(base.createTooltipText())
            }

            QD.SimpleButton
            {
                id: revertButton

                visible: base.resetButtonVisible

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: height

                color: QD.Theme.getColor("setting_control_button")
                hoverColor: QD.Theme.getColor("setting_control_button_hover")

                iconSource: QD.Theme.getIcon("ArrowReset")

                onClicked:
                {
                    revertButton.focus = true
                    if (externalResetHandler)
                    {
                        externalResetHandler(propertyProvider.key)
                    }
                    else
                    {
                        QIDI.MachineManager.clearUserSettingAllCurrentStacks(propertyProvider.key)
                    }
                }

                onEntered:
                {
                    hoverTimer.stop()
                    base.showTooltip(catalog.i18nc("@label", "This setting has a value that is different from the profile.\n\nClick to restore the value of the profile."))
                }
                onExited: base.showTooltip(base.createTooltipText())
            }

            QD.SimpleButton
            {
                // This button shows when the setting has an inherited function, but is overridden by profile.
                id: inheritButton
                // Inherit button needs to be visible if;
                // - User made changes that override any loaded settings
                // - This setting item uses inherit button at all
                // - The type of the value of any deeper container is an "object" (eg; is a function)
                visible:
                {
                    if (!base.showInheritButton)
                    {
                        return false
                    }

                    if (!propertyProvider.properties.enabled)
                    {
                        // Note: This is not strictly necessary since a disabled setting is hidden anyway.
                        // But this will cause the binding to be re-evaluated when the enabled property changes.
                        return false
                    }

                    // There are no settings with any warning.
                    if (QIDI.SettingInheritanceManager.settingsWithInheritanceWarning.length === 0)
                    {
                        return false
                    }

                    // This setting has a resolve value, so an inheritance warning doesn't do anything.
                    if (resolve !== "None")
                    {
                        return false
                    }

                    // If the setting does not have a limit_to_extruder property (or is -1), use the active stack.
                    if (globalPropertyProvider.properties.limit_to_extruder === null || String(globalPropertyProvider.properties.limit_to_extruder) === "-1")
                    {
                        return QIDI.SettingInheritanceManager.settingsWithInheritanceWarning.indexOf(definition.key) >= 0
                    }

                    // Setting does have a limit_to_extruder property, so use that one instead.
                    if (definition.key === undefined) {
                        // Observed when loading workspace, probably when SettingItems are removed.
                        return false
                    }
                    if(globalPropertyProvider.properties.limit_to_extruder === undefined)
                    {
                        return false
                    }
                    return QIDI.SettingInheritanceManager.getOverridesForExtruder(definition.key, String(globalPropertyProvider.properties.limit_to_extruder)).indexOf(definition.key) >= 0
                }

                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: height

                onClicked:
                {
                    focus = true

                    // Get the most shallow function value (eg not a number) that we can find.
                    var last_entry = propertyProvider.stackLevels[propertyProvider.stackLevels.length - 1]
                    for (var i = 1; i < base.stackLevels.length; i++)
                    {
                        var has_setting_function = typeof(propertyProvider.getPropertyValue("value", base.stackLevels[i])) == "object"
                        if(has_setting_function)
                        {
                            last_entry = propertyProvider.stackLevels[i]
                            break
                        }
                    }
                    if ((last_entry === 4 || last_entry === 11) && base.stackLevel === 0 && base.stackLevels.length === 2)
                    {
                        // Special case of the inherit reset. If only the definition (4th or 11th) container) and the first
                        // entry (user container) are set, we can simply remove the container.
                        propertyProvider.removeFromContainer(0)
                    }
                    else
                    {
                        // Put that entry into the "top" instance container.
                        // This ensures that the value in any of the deeper containers need not be removed, which is
                        // needed for the reset button (which deletes the top value) to correctly go back to profile
                        // defaults.
                        propertyProvider.setPropertyValue("value", propertyProvider.getPropertyValue("value", last_entry))
                        propertyProvider.setPropertyValue("state", "InstanceState.Calculated")

                    }
                }

                color: QD.Theme.getColor("setting_control_button")
                hoverColor: QD.Theme.getColor("setting_control_button_hover")

                iconSource: QD.Theme.getIcon("Function")

                onEntered: { hoverTimer.stop(); base.showTooltip(catalog.i18nc("@label", "This setting is normally calculated, but it currently has an absolute value set.\n\nClick to restore the calculated value.")) }
                onExited: base.showTooltip(base.createTooltipText())
            }
        }

        Item
        {
            id: controlContainer

            enabled: propertyProvider.isValueUsed

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: QD.Theme.getSize("setting_control").width
            height: QD.Theme.getSize("setting_control").height
        }
    }
}
