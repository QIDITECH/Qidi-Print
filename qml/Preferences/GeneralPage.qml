// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import QtQuick.Controls 2.3 as NewControls

import QD 1.1 as QD
import QIDI 1.1 as QIDI

QD.PreferencesPage
{
    //: General configuration page title
    title: catalog.i18nc("@title:tab", "General")
    id: generalPreferencesPage

    function setDefaultLanguage(languageCode)
    {
        //loops trough the languageList and sets the language using the languageCode
        for(var i = 0; i < languageList.count; i++)
        {
            if (languageComboBox.model.get(i).code == languageCode)
            {
                languageComboBox.currentIndex = i
            }
        }
    }

    function setDefaultDiscardOrKeepProfile(code)
    {
        for (var i = 0; i < choiceOnProfileOverrideDropDownButton.model.count; i++)
        {
            if (choiceOnProfileOverrideDropDownButton.model.get(i).code == code)
            {
                choiceOnProfileOverrideDropDownButton.currentIndex = i;
                break;
            }
        }
    }

    function setDefaultOpenProjectOption(code)
    {
        for (var i = 0; i < choiceOnOpenProjectDropDownButton.model.count; ++i)
        {
            if (choiceOnOpenProjectDropDownButton.model.get(i).code == code)
            {
                choiceOnOpenProjectDropDownButton.currentIndex = i
                break;
            }
        }
    }


    function reset()
    {
        QD.Preferences.resetPreference("general/language")
        var defaultLanguage = QD.Preferences.getValue("general/language")
        setDefaultLanguage(defaultLanguage)
        QD.Preferences.resetPreference("qidi/single_instance")
        singleInstanceCheckbox.checked = boolCheck(QD.Preferences.getValue("qidi/single_instance"))
        QD.Preferences.resetPreference("physics/automatic_push_free")
        pushFreeCheckbox.checked = boolCheck(QD.Preferences.getValue("physics/automatic_push_free"))
        QD.Preferences.resetPreference("physics/automatic_drop_down")
        dropDownCheckbox.checked = boolCheck(QD.Preferences.getValue("physics/automatic_drop_down"))
        QD.Preferences.resetPreference("mesh/scale_to_fit")
        scaleToFitCheckbox.checked = boolCheck(QD.Preferences.getValue("mesh/scale_to_fit"))
        QD.Preferences.resetPreference("general/auto_slice")
        autoSliceCheckbox.checked = boolCheck(QD.Preferences.getValue("general/auto_slice"))
        QD.Preferences.resetPreference("mesh/scale_tiny_meshes")
        scaleTinyCheckbox.checked = boolCheck(QD.Preferences.getValue("mesh/scale_tiny_meshes"))
        QD.Preferences.resetPreference("qidi/select_models_on_load")
        selectModelsOnLoadCheckbox.checked = boolCheck(QD.Preferences.getValue("qidi/select_models_on_load"))
        QD.Preferences.resetPreference("qidi/jobname_prefix")
        prefixJobNameCheckbox.checked = boolCheck(QD.Preferences.getValue("qidi/jobname_prefix"))
        QD.Preferences.resetPreference("view/show_overhang");
        showOverhangCheckbox.checked = boolCheck(QD.Preferences.getValue("view/show_overhang"))
        QD.Preferences.resetPreference("view/show_xray_warning");
        showXrayErrorCheckbox.checked = boolCheck(QD.Preferences.getValue("view/show_xray_warning"))
        QD.Preferences.resetPreference("view/center_on_select");
        centerOnSelectCheckbox.checked = boolCheck(QD.Preferences.getValue("view/center_on_select"))
        QD.Preferences.resetPreference("view/invert_zoom");
        invertZoomCheckbox.checked = boolCheck(QD.Preferences.getValue("view/invert_zoom"))
        QD.Preferences.resetPreference("gcodereader/show_caution");
        gcodeShowCautionCheckbox.checked = boolCheck(QD.Preferences.getValue("gcodereader/show_caution"))
        QD.Preferences.resetPreference("view/force_layer_view_compatibility_mode");
        forceLayerViewCompatibilityModeCheckbox.checked = boolCheck(QD.Preferences.getValue("view/force_layer_view_compatibility_mode"))
        QD.Preferences.resetPreference("view/zoom_to_mouse");
        zoomToMouseCheckbox.checked = boolCheck(QD.Preferences.getValue("view/zoom_to_mouse"))
        QD.Preferences.resetPreference("general/restore_window_geometry")
        restoreWindowPositionCheckbox.checked = boolCheck(QD.Preferences.getValue("general/restore_window_geometry"))
        QD.Preferences.resetPreference("qidi/dialog_on_project_save")
        projectSaveCheckbox.checked = boolCheck(QD.Preferences.getValue("qidi/dialog_on_project_save"))
        QD.Preferences.resetPreference("qidi/choice_on_profile_override")
        setDefaultDiscardOrKeepProfile(QD.Preferences.getValue("qidi/choice_on_profile_override"))
        QD.Preferences.resetPreference("qidi/choice_on_open_project")
        setDefaultOpenProjectOption(QD.Preferences.getValue("qidi/choice_on_open_project"))
        QD.Preferences.resetPreference("info/automatic_update_check")
        checkUpdatesCheckbox.checked = boolCheck(QD.Preferences.getValue("info/automatic_update_check"))
        QD.Preferences.resetPreference("view/use_extruder_color");
        extrudercolorCheckbox.checked = boolCheck(QD.Preferences.getValue("view/use_extruder_color"))
        QD.Preferences.resetPreference("view/show_ip_warning");
        showIpErrorCheckbox.checked = boolCheck(QD.Preferences.getValue("view/show_ip_warning"))
        QD.Preferences.resetPreference("view/send_with_compress");
        sendwithcompressCheckbox.checked = boolCheck(QD.Preferences.getValue("view/send_with_compress"))
        QD.Preferences.resetPreference("view/remind_to_save");
        remindsaveCheckbox.checked = boolCheck(QD.Preferences.getValue("view/remind_to_save"));
        QD.Preferences.resetPreference("view/show_slice_confirm");
        sliceConfirmCheckbox.checked = boolCheck(QD.Preferences.getValue("view/show_slice_confirm"))
    }

    QIDI.ScrollView
    {
        width: parent.width
        height: parent.height

        Column
        {

            //: Language selection label
            QD.I18nCatalog{id: catalog; name: "qidi"}
            spacing: 5 * QD.Theme.getSize("size").width

            Item
            {
                height: languageComboBox.height
                width: childrenRect.width

                Label
                {
                    id: languageLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font: QD.Theme.getFont("font1")
                    color: QD.Theme.getColor("black_1")
                    text: "Language:" //Don't translate this, to make it easier to find the language drop-down if you can't read the current language.
                }

                ListModel
                {
                    id: languageList

                    Component.onCompleted:
                    {
                        append({ text: "English", code: "en_US" })
                        append({ text: "Čeština", code: "cs_CZ" })
                        append({ text: "Deutsch", code: "de_DE" })
                        append({ text: "Español", code: "es_ES" })
                        //Finnish is disabled for being incomplete: append({ text: "Suomi", code: "fi_FI" })
                        append({ text: "Français", code: "fr_FR" })
                        append({ text: "Italiano", code: "it_IT" })
                        append({ text: "日本語", code: "ja_JP" })
                        append({ text: "한국어", code: "ko_KR" })
                        append({ text: "Nederlands", code: "nl_NL" })
                        //Polish is disabled for being incomplete: append({ text: "Polski", code: "pl_PL" })
                        append({ text: "Português do Brasil", code: "pt_BR" })
                        append({ text: "Português", code: "pt_PT" })
                        append({ text: "Русский", code: "ru_RU" })
                        append({ text: "Türkçe", code: "tr_TR" })
                        append({ text: "简体中文", code: "zh_CN" })
                        append({ text: "正體字", code: "zh_TW" })

                        var date_object = new Date();
                        if (date_object.getUTCMonth() == 8 && date_object.getUTCDate() == 19) //Only add Pirate on the 19th of September.
                        {
                            append({ text: "Pirate", code: "en_7S" })
                        }
                    }
                }

                QIDI.ComboBox
                {
                    id: languageComboBox
                    anchors.left: languageLabel.right
                    anchors.leftMargin: 5 * QD.Theme.getSize("size").width
                    anchors.verticalCenter: parent.verticalCenter

                    textRole: "text"
                    model: languageList
                    width: 150 * QD.Theme.getSize("size").width
                    height: 24 * QD.Theme.getSize("size").width

                    currentIndex:
                    {
                        var code = QD.Preferences.getValue("general/language");
                        for(var i = 0; i < languageList.count; ++i)
                        {
                            if(model.get(i).code == code)
                            {
                                return i
                            }
                        }
                    }
                    onActivated: QD.Preferences.setValue("general/language", model.get(index).code)
                }
				

            }

			Item
            {
                height: languageComboBox.height
                width: childrenRect.width
				Label
				{
					id: fontscaledlabels
					anchors.left: parent.left
					anchors.verticalCenter: parent.verticalCenter

					//anchors.leftMargin: 5 * QD.Theme.getSize("size").width
					//anchors.verticalCenter: parent.verticalCenter
					//anchors.top : languageList.bottom
					//anchors.bottom: languageCaption.top
					//: Language change warning
					color: QD.Theme.getColor("black_1")
					font: QD.Theme.getFont("font1")
					text: catalog.i18nc("@label", "Font Scaled:")
					wrapMode: Text.WordWrap
				}
                ListModel
                {
                    id: fontscaleList

                    Component.onCompleted:
                    {
                        append({ text: "80%", code: 0.8 })
                        append({ text: "90%", code: 0.9 })
                        append({ text: "100%", code: 1 })
                        append({ text: "110%", code: 1.1 })
                        append({ text: "120%", code: 1.2 })
                    }
                }
                QIDI.ComboBox
                {
                    id: fontscaleComboBox
                    anchors.left: fontscaledlabels.right
                    anchors.leftMargin: 5 * QD.Theme.getSize("size").width
                    anchors.verticalCenter: parent.verticalCenter

                    textRole: "text"
                    model: fontscaleList
                    width: 100 * QD.Theme.getSize("size").width
                    height: 24 * QD.Theme.getSize("size").width

                    currentIndex:
                    {
                        var code = QD.Preferences.getValue("qidi/fontsize");
                        for(var i = 0; i < fontscaleList.count; ++i)
                        {
                            if(model.get(i).code == code)
                            {
                                return i
                            }
                        }
                    }
                    onActivated: QD.Preferences.setValue("qidi/fontsize", model.get(index).code)
                }
                

				Label
				{
					id: imagescaledlabels
					anchors.left: fontscaleComboBox.right
					anchors.leftMargin: 5 * QD.Theme.getSize("size").width
					anchors.verticalCenter: parent.verticalCenter
					//anchors.verticalCenter: parent.verticalCenter
					//anchors.top : languageList.bottom
					//anchors.bottom: languageCaption.top
					//: Language change warning
					color: QD.Theme.getColor("black_1")
					font: QD.Theme.getFont("font1")
					text: catalog.i18nc("@label", "Image Scaled:")
					wrapMode: Text.WordWrap
				}
                
                ListModel
                {
                    id: imagescaleList

                    Component.onCompleted:
                    {
                        append({ text: "80%", code: 0.8 })
                        append({ text: "90%", code: 0.9 })
                        append({ text: "100%", code: 1 })
                        append({ text: "110%", code: 1.1 })
                        append({ text: "120%", code: 1.2 })
                    }
                }
                QIDI.ComboBox
                {
                    id: imagescaleComboBox
                    anchors.left: imagescaledlabels.right
                    anchors.leftMargin: 5 * QD.Theme.getSize("size").width
                    anchors.verticalCenter: parent.verticalCenter

                    textRole: "text"
                    model: imagescaleList
                    width: 100 * QD.Theme.getSize("size").width
                    height: 24 * QD.Theme.getSize("size").width

                    currentIndex:
                    {
                        var code = QD.Preferences.getValue("qidi/imagesize");
                        for(var i = 0; i < imagescaleList.count; ++i)
                        {
                            if(model.get(i).code == code)
                            {
                                return i
                            }
                        }
                    }
                    onActivated: QD.Preferences.setValue("qidi/imagesize", model.get(index).code)
                }

			}
			
            Label
            {
                id: languageCaption

                //: Language change warning
                color: QD.Theme.getColor("blue_8")
                font: QD.Theme.getFont("font1")
                text: catalog.i18nc("@label", "You will need to restart the application for these changes to have effect.")
                wrapMode: Text.WordWrap
            }

            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip", "Slice automatically when changing settings.")

                QIDI.CheckBox
                {
                    id: autoSliceCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("general/auto_slice"))
                    onCheckedChanged: QD.Preferences.setValue("general/auto_slice", checked)
                    font: QD.Theme.getFont("font1")
                    text: catalog.i18nc("@option:check", "Slice automatically")
                }
            }
            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip", "Display confirmation slice information.")

                QIDI.CheckBox
                {
                    id: sliceConfirmCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("view/show_slice_confirm"))
                    onCheckedChanged: QD.Preferences.setValue("view/show_slice_confirm", checked)
                    font: QD.Theme.getFont("font1")
                    text: catalog.i18nc("@option:check", "Display confirmation slice information")
                }
            }
            Item
            {
                //: Spacer
                height: 5 * QD.Theme.getSize("size").width
                width: 5 * QD.Theme.getSize("size").width
            }

            Label
            {
                font: QD.Theme.getFont("font2")
                color: QD.Theme.getColor("blue_6")
                text: catalog.i18nc("@label", "Viewport behavior")
            }

            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip", "Highlight unsupported areas of the model in red. Without support these areas will not print properly.")

                QIDI.CheckBox
                {
                    id: showOverhangCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("view/show_overhang"))
                    onCheckedChanged: QD.Preferences.setValue("view/show_overhang", checked)
                    text: catalog.i18nc("@option:check", "Display overhang")
                    font: QD.Theme.getFont("font1")
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;
                text: catalog.i18nc("@info:tooltip", "When there are multiple extruders, render the model in extruder colors. Otherwise use material colors.")

                QIDI.CheckBox
                {
                    id: extrudercolorCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("view/use_extruder_color"))
                    onCheckedChanged: QD.Preferences.setValue("view/use_extruder_color", checked)
                    text: catalog.i18nc("@option:check", "Render with extruder colors")
                    font: QD.Theme.getFont("font1")
                }
            }
			
            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip", "Highlight missing or extraneous surfaces of the model using warning signs. The toolpaths will often be missing parts of the intended geometry.")

                QIDI.CheckBox
                {
                    id: showXrayErrorCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("view/show_xray_warning"))
                    onCheckedChanged: QD.Preferences.setValue("view/show_xray_warning",  checked)
                    text: catalog.i18nc("@option:check", "Display model errors");
                    font: QD.Theme.getFont("font1")
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;
                text: catalog.i18nc("@info:tooltip", "Moves the camera so the model is in the center of the view when a model is selected")

                QIDI.CheckBox
                {
                    id: centerOnSelectCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@action:button","Center camera when item is selected");
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("view/center_on_select"))
                    onCheckedChanged: QD.Preferences.setValue("view/center_on_select",  checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;
                text: catalog.i18nc("@info:tooltip", "Should the default zoom behavior of qidi be inverted?")

                QIDI.CheckBox
                {
                    id: invertZoomCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@action:button", "Invert the direction of camera zoom.");
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("view/invert_zoom"))
                    onCheckedChanged: {
                        if(!checked && zoomToMouseCheckbox.checked) //Fix for Github issue QIDI/QIDI#6490: Make sure the camera origin is in front when unchecking.
                        {
                            QD.Controller.setCameraOrigin("home");
                        }
                        QD.Preferences.setValue("view/invert_zoom", checked);
                    }
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;
                text: zoomToMouseCheckbox.enabled ? catalog.i18nc("@info:tooltip", "Should zooming move in the direction of the mouse?") : catalog.i18nc("@info:tooltip", "Zooming towards the mouse is not supported in the orthographic perspective.")

                QIDI.CheckBox
                {
                    id: zoomToMouseCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@action:button", "Zoom toward mouse direction")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("view/zoom_to_mouse")) && zoomToMouseCheckbox.enabled
                    //onClicked: QD.Preferences.setValue("view/zoom_to_mouse", checked)
					onCheckedChanged: QD.Preferences.setValue("view/zoom_to_mouse", checked)
                    enabled: QD.Preferences.getValue("general/camera_perspective_mode") !== "orthographic"
                }

                //Because there is no signal for individual preferences, we need to manually link to the onPreferenceChanged signal.
                Connections
                {
                    target: QD.Preferences
                    function onPreferenceChanged(preference)
                    {
                        if(preference != "general/camera_perspective_mode")
                        {
                            return;
                        }
                        zoomToMouseCheckbox.enabled = QD.Preferences.getValue("general/camera_perspective_mode") !== "orthographic";
                        zoomToMouseCheckbox.checked = boolCheck(QD.Preferences.getValue("view/zoom_to_mouse")) && zoomToMouseCheckbox.enabled;
                    }
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should models on the platform be moved so that they no longer intersect?")

                QIDI.CheckBox
                {
                    id: pushFreeCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check", "Ensure models are kept apart")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("physics/automatic_push_free"))
                    onCheckedChanged: QD.Preferences.setValue("physics/automatic_push_free", checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should models on the platform be moved down to touch the build plate?")

                QIDI.CheckBox
                {
                    id: dropDownCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check", "Automatically drop models to the build plate")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("physics/automatic_drop_down"))
                    onCheckedChanged: QD.Preferences.setValue("physics/automatic_drop_down", checked)
                }
            }


            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip","Show caution message in g-code reader.")

                QIDI.CheckBox
                {
                    id: gcodeShowCautionCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("gcodereader/show_caution"))
                    //onClicked: QD.Preferences.setValue("gcodereader/show_caution", checked)
					onCheckedChanged: QD.Preferences.setValue("gcodereader/show_caution", checked)
                    text: catalog.i18nc("@option:check","Caution message in g-code reader")
                    font: QD.Theme.getFont("font1")
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should layer be forced into compatibility mode?")

                QIDI.CheckBox
                {
                    id: forceLayerViewCompatibilityModeCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check", "Force layer view compatibility mode (restart required)")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("view/force_layer_view_compatibility_mode"))
                    onCheckedChanged: QD.Preferences.setValue("view/force_layer_view_compatibility_mode", checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should QIDI open at the location it was closed?")

                QIDI.CheckBox
                {
                    id: restoreWindowPositionCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check", "Restore window position on start")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("general/restore_window_geometry"))
                    onCheckedChanged: QD.Preferences.setValue("general/restore_window_geometry", checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "What type of camera rendering should be used?")
                Item
                {
                    height: cameraComboBox.height
                    width: childrenRect.width

                    Label
                    {
                        id: cameraLabel
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font: QD.Theme.getFont("font1")
                        color: QD.Theme.getColor("black_1")
                        text: catalog.i18nc("@window:text", "Camera rendering:")
                    }
                    ListModel
                    {
                        id: comboBoxList
                        Component.onCompleted:
                        {
                            append({ text: catalog.i18n("Perspective"), code: "perspective" })
                            append({ text: catalog.i18n("Orthographic"), code: "orthographic" })
                        }
                    }

                    QIDI.ComboBox
                    {
                        id: cameraComboBox
                        anchors.left: cameraLabel.right
                        anchors.leftMargin: 5 * QD.Theme.getSize("size").width
                        anchors.verticalCenter: parent.verticalCenter
                        width: 200 * QD.Theme.getSize("size").width
                        height: 22 * QD.Theme.getSize("size").width
                        model: comboBoxList
                        textRole: "text"

                        currentIndex:
                        {
                            var code = QD.Preferences.getValue("general/camera_perspective_mode");
                            for(var i = 0; i < comboBoxList.count; ++i)
                            {
                                if(model.get(i).code == code)
                                {
                                    return i
                                }
                            }
                            return 0
                        }
                        onActivated: QD.Preferences.setValue("general/camera_perspective_mode", model.get(index).code)
                    }
                }
            }

            Item
            {
                //: Spacer
                height: 5 * QD.Theme.getSize("size").width
                width: 5 * QD.Theme.getSize("size").width
            }

            Label
            {
                font: QD.Theme.getFont("font2")
                color: QD.Theme.getColor("blue_6")
                text: catalog.i18nc("@label","Opening and saving files")
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip","Should opening files from the desktop or external applications open in the same instance of QIDI?")

                QIDI.CheckBox
                {
                    id: singleInstanceCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check","Use a single instance of QIDI")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("qidi/single_instance"))
                    onCheckedChanged: QD.Preferences.setValue("qidi/single_instance", checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip","Should models be scaled to the build volume if they are too large?")

                QIDI.CheckBox
                {
                    id: scaleToFitCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check","Scale large models")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("mesh/scale_to_fit"))
                    onCheckedChanged: QD.Preferences.setValue("mesh/scale_to_fit", checked)
                }
            }
            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip","An model may appear extremely small if its unit is for example in meters rather than millimeters. Should these models be scaled up?")

                QIDI.CheckBox
                {
                    id: scaleTinyCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check","Scale extremely small models")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("mesh/scale_tiny_meshes"))
                    onCheckedChanged: QD.Preferences.setValue("mesh/scale_tiny_meshes", checked)
                }
            }
            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;
                text: catalog.i18nc("@info:tooltip", "A pop-up prompts you whether to save before closing.")

                QIDI.CheckBox
                {
                    id: remindsaveCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("view/remind_to_save"))
                    //onClicked: QD.Preferences.setValue("view/remind_to_save", checked)
					onCheckedChanged: QD.Preferences.setValue("view/remind_to_save", checked)
                    text: catalog.i18nc("@option:check", "Remind to save before closing")
                    font: QD.Theme.getFont("font1")
                }
            }
            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip","Should models be selected after they are loaded?")

                QIDI.CheckBox
                {
                    id: selectModelsOnLoadCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check","Select models when loaded")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("qidi/select_models_on_load"))
                    onCheckedChanged: QD.Preferences.setValue("qidi/select_models_on_load", checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should a prefix based on the printer name be added to the print job name automatically?")

                QIDI.CheckBox
                {
                    id: prefixJobNameCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check", "Add machine prefix to job name")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("qidi/jobname_prefix"))
                    onCheckedChanged: QD.Preferences.setValue("qidi/jobname_prefix", checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Should a summary be shown when saving a project file?")

                QIDI.CheckBox
                {
					id:projectSaveCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check", "Show summary dialog when saving project")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("qidi/dialog_on_project_save"))
                    onCheckedChanged: QD.Preferences.setValue("qidi/dialog_on_project_save", checked)
                }
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: childrenRect.height
                text: catalog.i18nc("@info:tooltip", "Default behavior when opening a project file")

                Column
                {
                    spacing: 4 * screenScaleFactor

                    Label
                    {
                        font: QD.Theme.getFont("font1")
                        color: QD.Theme.getColor("black_1")
                        text: catalog.i18nc("@window:text", "Default behavior when opening a project file: ")
                    }

                    QIDI.ComboBox
                    {
                        id: choiceOnOpenProjectDropDownButton
                        width: 200 * QD.Theme.getSize("size").width
                        height: 22 * QD.Theme.getSize("size").width

                        model: ListModel
                        {
                            id: openProjectOptionModel

                            Component.onCompleted:
                            {
                                append({ text: catalog.i18nc("@option:openProject", "Always ask me this"), code: "always_ask" })
                                append({ text: catalog.i18nc("@option:openProject", "Always open as a project"), code: "open_as_project" })
                                append({ text: catalog.i18nc("@option:openProject", "Always import models"), code: "open_as_model" })
                            }
                        }
                        textRole: "text"

                        currentIndex:
                        {
                            var index = 0;
                            var currentChoice = QD.Preferences.getValue("qidi/choice_on_open_project");
                            for (var i = 0; i < model.count; ++i)
                            {
                                if (model.get(i).code == currentChoice)
                                {
                                    index = i;
                                    break;
                                }
                            }
                            return index;
                        }

                        onActivated: QD.Preferences.setValue("qidi/choice_on_open_project", model.get(index).code)
                    }
                }
            }

            Item
            {
                //: Spacer
                height: 5 * QD.Theme.getSize("size").width
                width: 5 * QD.Theme.getSize("size").width
            }

            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;

                text: catalog.i18nc("@info:tooltip", "When you have made changes to a profile and switched to a different one, a dialog will be shown asking whether you want to keep your modifications or not, or you can choose a default behaviour and never show that dialog again.")

                Column
                {
                    spacing: 4 * screenScaleFactor

                    Label
                    {
                        font: QD.Theme.getFont("font2")
                        color: QD.Theme.getColor("blue_6")
                        text: catalog.i18nc("@label", "Profiles")
                    }

                    Label
                    {
                        font: QD.Theme.getFont("font1")
                        color: QD.Theme.getColor("black_1")
                        text: catalog.i18nc("@window:text", "Default behavior for changed setting values when switching to a different profile: ")
                    }

                    QIDI.ComboBox
                    {
                        id: choiceOnProfileOverrideDropDownButton
                        width: 200 * QD.Theme.getSize("size").width
                        height: 22 * QD.Theme.getSize("size").width
                        model: ListModel
                        {
                            id: discardOrKeepProfileListModel

                            Component.onCompleted:
                            {
                                append({ text: catalog.i18nc("@option:discardOrKeep", "Always ask me this"), code: "always_ask" })
                                append({ text: catalog.i18nc("@option:discardOrKeep", "Always discard changed settings"), code: "always_discard" })
                                append({ text: catalog.i18nc("@option:discardOrKeep", "Always transfer changed settings to new profile"), code: "always_keep" })
                            }
                        }
                        textRole: "text"

                        currentIndex:
                        {
                            var index = 0;
                            var code = QD.Preferences.getValue("qidi/choice_on_profile_override");
                            for (var i = 0; i < model.count; ++i)
                            {
                                if (model.get(i).code == code)
                                {
                                    index = i
                                    break
                                }
                            }
                            return index
                        }
                        onActivated: QD.Preferences.setValue("qidi/choice_on_profile_override", model.get(index).code)
                    }
                }
            }

            Item
            {
                //: Spacer
                height: 5 * QD.Theme.getSize("size").height
                width: 5 * QD.Theme.getSize("size").height
            }
            Label
            {
                font: QD.Theme.getFont("font2")
                color: QD.Theme.getColor("blue_6")
                text: catalog.i18nc("@label", "WIFI")
            }
			QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;
                text: catalog.i18nc("@info:tooltip", "A warning is displayed when the printer corresponding to the IP address you selected does not match the printer you currently selected.")

                QIDI.CheckBox
                {
                    id: showIpErrorCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("view/show_ip_warning"))
                    //onClicked: QD.Preferences.setValue("view/show_ip_warning", checked)
					onCheckedChanged: QD.Preferences.setValue("view/show_ip_warning", checked)
                    text: catalog.i18nc("@option:check", "Display ip errors")
                    font: QD.Theme.getFont("font1")
                }
            }
			
            QD.TooltipArea
            {
                width: childrenRect.width;
                height: childrenRect.height;
                text: catalog.i18nc("@info:tooltip", "Compress files when Wifi sends")

                QIDI.CheckBox
                {
                    id: sendwithcompressCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    checked: boolCheck(QD.Preferences.getValue("view/send_with_compress"))
                    //onClicked: QD.Preferences.setValue("view/send_with_compress", checked)
					onCheckedChanged: QD.Preferences.setValue("view/send_with_compress", checked)
                    text: catalog.i18nc("@option:check", "Compress files when Wifi sends")
                    font: QD.Theme.getFont("font1")
                }
            }
			
            Item
            {
                //: Spacer
                height: 5 * QD.Theme.getSize("size").height
                width: 5 * QD.Theme.getSize("size").height
            }		
            Label
            {
                font: QD.Theme.getFont("font2")
                color: QD.Theme.getColor("blue_6")
                visible: checkUpdatesCheckbox.visible
                text: catalog.i18nc("@label","Privacy")
            }

            QD.TooltipArea
            {
                width: childrenRect.width
                height: visible ? childrenRect.height : 0
                text: catalog.i18nc("@info:tooltip", "Should QIDI check for updates when the program is started?")

                QIDI.CheckBox
                {
                    id: checkUpdatesCheckbox
                    height: 18 * QD.Theme.getSize("size").height
                    text: catalog.i18nc("@option:check","Check for updates on start")
                    font: QD.Theme.getFont("font1")
                    checked: boolCheck(QD.Preferences.getValue("info/automatic_update_check"))
                    onCheckedChanged: QD.Preferences.setValue("info/automatic_update_check", checked)
                }
            }
        }
    }
}
