// Copyright (c) 2019 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.6
import QtQuick.Controls 2.0
import QtQuick.Controls 1.1 as OldControls

import QIDI 1.0 as QIDI
import QD 1.3 as QD

Item
{
    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    width: parent.width
    height: childrenRect.height

    Label
    {
        id: header
        text: catalog.i18nc("@header", "Custom")
        font: QD.Theme.getFont("medium")
        color: QD.Theme.getColor("small_button_text")
        height: contentHeight
        renderType: Text.NativeRendering

        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    //Printer type selector.
    Item
    {
        id: printerTypeSelectorRow
        visible:
        {
            return QIDI.MachineManager.printerOutputDevices.length >= 1 //If connected...
                && QIDI.MachineManager.printerOutputDevices[0].connectedPrintersTypeCount != null //...and we have configuration information...
                && QIDI.MachineManager.printerOutputDevices[0].connectedPrintersTypeCount.length > 1; //...and there is more than one type of printer in the configuration list.
        }
        height: visible ? childrenRect.height : 0

        anchors
        {
            left: parent.left
            right: parent.right
            top: header.bottom
            topMargin: visible ? QD.Theme.getSize("default_margin").height : 0
        }

        Label
        {
            text: catalog.i18nc("@label", "Printer")
            width: Math.round(parent.width * 0.3) - QD.Theme.getSize("default_margin").width
            height: contentHeight
            font: QD.Theme.getFont("default")
            color: QD.Theme.getColor("text")
            anchors.verticalCenter: printerTypeSelector.verticalCenter
            anchors.left: parent.left
        }

        OldControls.ToolButton
        {
            id: printerTypeSelector
            text: QIDI.MachineManager.activeMachine !== null ? QIDI.MachineManager.activeMachine.definition.name: ""
            tooltip: text
            height: QD.Theme.getSize("print_setup_big_item").height
            width: Math.round(parent.width * 0.7) + QD.Theme.getSize("default_margin").width
            anchors.right: parent.right
            style: QD.Theme.styles.print_setup_header_button

            menu: QIDI.PrinterTypeMenu { }
        }
    }

    QD.TabRow
    {
        id: tabBar
        anchors.top: printerTypeSelectorRow.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height
        visible: extrudersModel.count > 1

        Repeater
        {
            id: repeater
            model: extrudersModel
            delegate: QD.TabRowButton
            {
                contentItem: Item
                {
                    QIDI.ExtruderIcon
                    {
                        anchors.horizontalCenter: parent.horizontalCenter
                        materialColor: model.color
                        extruderEnabled: model.enabled
                        width: parent.height
                        height: parent.height
                    }
                }
                onClicked:
                {
                    QIDI.ExtruderManager.setActiveExtruderIndex(tabBar.currentIndex)
                }
            }
        }

        //When active extruder changes for some other reason, switch tabs.
        //Don't directly link currentIndex to QIDI.ExtruderManager.activeExtruderIndex!
        //This causes a segfault in Qt 5.11. Something with VisualItemModel removing index -1. We have to use setCurrentIndex instead.
        Connections
        {
            target: QIDI.ExtruderManager
            function onActiveExtruderChanged()
            {
                tabBar.setCurrentIndex(QIDI.ExtruderManager.activeExtruderIndex);
            }
        }

        // Can't use 'item: ...activeExtruderIndex' directly apparently, see also the comment on the previous block.
        onVisibleChanged:
        {
            if (tabBar.visible)
            {
                tabBar.setCurrentIndex(QIDI.ExtruderManager.activeExtruderIndex);
            }
        }

        //When the model of the extruders is rebuilt, the list of extruders is briefly emptied and rebuilt.
        //This causes the currentIndex of the tab to be in an invalid position which resets it to 0.
        //Therefore we need to change it back to what it was: The active extruder index.
        Connections
        {
            target: repeater.model
            function onModelChanged()
            {
                tabBar.setCurrentIndex(QIDI.ExtruderManager.activeExtruderIndex)
            }
        }
    }

    Rectangle
    {
        width: parent.width
        height: childrenRect.height
        anchors.top: tabBar.bottom

        radius: tabBar.visible ? QD.Theme.getSize("default_radius").width : 0
        border.width: tabBar.visible ? QD.Theme.getSize("default_lining").width : 0
        border.color: QD.Theme.getColor("lining")
        color: QD.Theme.getColor("main_background")

        //Remove rounding and lining at the top.
        Rectangle
        {
            width: parent.width
            height: parent.radius
            anchors.top: parent.top
            color: QD.Theme.getColor("lining")
            visible: tabBar.visible
            Rectangle
            {
                anchors
                {
                    left: parent.left
                    leftMargin: parent.parent.border.width
                    right: parent.right
                    rightMargin: parent.parent.border.width
                    top: parent.top
                }
                height: parent.parent.radius
                color: parent.parent.color
            }
        }

        Column
        {
            id: selectors
            padding: QD.Theme.getSize("default_margin").width
            spacing: QD.Theme.getSize("default_margin").height

            property var model: extrudersModel.items[tabBar.currentIndex]

            readonly property real paddedWidth: parent.width - padding * 2
            property real textWidth: Math.round(paddedWidth * 0.3)
            property real controlWidth:
            {
                if(instructionLink == "")
                {
                    return paddedWidth - textWidth
                }
                else
                {
                    return paddedWidth - textWidth - QD.Theme.getSize("print_setup_big_item").height * 0.5 - QD.Theme.getSize("default_margin").width
                }
            }
            property string instructionLink: QIDI.MachineManager.activeStack != null ? QIDI.ContainerManager.getContainerMetaDataEntry(QIDI.MachineManager.activeStack.material.id, "instruction_link", ""): ""

            Row
            {
                height: visible ? QD.Theme.getSize("setting_control").height : 0
                visible: extrudersModel.count > 1  // If there is only one extruder, there is no point to enable/disable that.

                Label
                {
                    text: catalog.i18nc("@label", "Enabled")
                    verticalAlignment: Text.AlignVCenter
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    height: parent.height
                    width: selectors.textWidth
                    renderType: Text.NativeRendering
                }

                OldControls.CheckBox
                {
                    id: enabledCheckbox
                    enabled: !checked || QIDI.MachineManager.numberExtrudersEnabled > 1 //Disable if it's the last enabled extruder.
                    height: parent.height
                    style: QD.Theme.styles.checkbox

                    Binding
                    {
                        target: enabledCheckbox
                        property: "checked"
                        value: QIDI.MachineManager.activeStack.isEnabled
                        when: QIDI.MachineManager.activeStack != null
                    }

                    /* Use a MouseArea to process the click on this checkbox.
                       This is necessary because actually clicking the checkbox
                       causes the "checked" property to be overwritten. After
                       it's been overwritten, the original link that made it
                       depend on the active extruder stack is broken. */
                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            if(!parent.enabled)
                            {
                                return
                            }
                            // Already update the visual indication
                            parent.checked = !parent.checked
                            // Update the settings on the background!
                            QIDI.MachineManager.setExtruderEnabled(QIDI.ExtruderManager.activeExtruderIndex, parent.checked)
                        }
                    }
                }
            }

            Row
            {
                height: visible ? QD.Theme.getSize("print_setup_big_item").height : 0
                visible: QIDI.MachineManager.activeMachine ? QIDI.MachineManager.activeMachine.hasMaterials : false

                Label
                {
                    text: catalog.i18nc("@label", "Material")
                    verticalAlignment: Text.AlignVCenter
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    height: parent.height
                    width: selectors.textWidth
                    renderType: Text.NativeRendering
                }

                OldControls.ToolButton
                {
                    id: materialSelection

                    property bool valueError: QIDI.MachineManager.activeStack !== null ? QIDI.ContainerManager.getContainerMetaDataEntry(QIDI.MachineManager.activeStack.material.id, "compatible", "") !== "True" : true
                    property bool valueWarning: !QIDI.MachineManager.isActiveQualitySupported

                    text: QIDI.MachineManager.activeStack !== null ? QIDI.MachineManager.activeStack.material.name : ""
                    tooltip: text
                    enabled: enabledCheckbox.checked

                    width: selectors.controlWidth
                    height: parent.height

                    style: QD.Theme.styles.print_setup_header_button
                    activeFocusOnPress: true
                    QIDI.MaterialMenu
                    {
                        id: materialsMenu
                        extruderIndex: QIDI.ExtruderManager.activeExtruderIndex
                        updateModels: materialSelection.visible
                    }
                    onClicked:
                    {
                        materialsMenu.popup();
                    }
                }
                Item
                {
                    width: instructionButton.width + 2 * QD.Theme.getSize("default_margin").width
                    height: instructionButton.visible ? materialSelection.height: 0
                    Button
                    {
                        id: instructionButton
                        hoverEnabled: true
                        contentItem: Item {}
                        height: 0.5 * materialSelection.height
                        width: height
                        anchors.centerIn: parent
                        background: QD.RecolorImage
                        {
                            source: QD.Theme.getIcon("Guide")
                            color: instructionButton.hovered ? QD.Theme.getColor("primary") : QD.Theme.getColor("icon")
                        }
                        visible: selectors.instructionLink != ""
                        onClicked:Qt.openUrlExternally(selectors.instructionLink)
                    }
                }
            }

            Row
            {
                height: visible ? QD.Theme.getSize("print_setup_big_item").height : 0
                visible: QIDI.MachineManager.activeMachine ? QIDI.MachineManager.activeMachine.hasVariants : false

                Label
                {
                    text: QIDI.MachineManager.activeDefinitionVariantsName
                    verticalAlignment: Text.AlignVCenter
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    height: parent.height
                    width: selectors.textWidth
                    renderType: Text.NativeRendering
                }

                OldControls.ToolButton
                {
                    id: variantSelection
                    text: QIDI.MachineManager.activeStack != null ? QIDI.MachineManager.activeStack.variant.name : ""
                    tooltip: text
                    height: parent.height
                    width: selectors.controlWidth
                    style: QD.Theme.styles.print_setup_header_button
                    activeFocusOnPress: true
                    enabled: enabledCheckbox.checked

                    QIDI.NozzleMenu
                    {
                        id: nozzlesMenu
                        extruderIndex: QIDI.ExtruderManager.activeExtruderIndex
                    }
                    onClicked:
                    {
                        nozzlesMenu.popup();
                    }
                }
            }

            Row
            {
                id: warnings
                height: visible ? childrenRect.height : 0
                visible: buildplateCompatibilityError || buildplateCompatibilityWarning

                property bool buildplateCompatibilityError: !QIDI.MachineManager.variantBuildplateCompatible && !QIDI.MachineManager.variantBuildplateUsable
                property bool buildplateCompatibilityWarning: QIDI.MachineManager.variantBuildplateUsable

                // This is a space holder aligning the warning messages.
                Label
                {
                    text: ""
                    width: selectors.textWidth
                    renderType: Text.NativeRendering
                }

                Item
                {
                    width: selectors.controlWidth
                    height: childrenRect.height

                    QD.RecolorImage
                    {
                        id: warningImage
                        anchors.left: parent.left
                        source: QD.Theme.getIcon("Warning")
                        width: QD.Theme.getSize("section_icon").width
                        height: QD.Theme.getSize("section_icon").height
                        sourceSize.width: width
                        sourceSize.height: height
                        color: QD.Theme.getColor("material_compatibility_warning")
                        visible: !QIDI.MachineManager.isCurrentSetupSupported || warnings.buildplateCompatibilityError || warnings.buildplateCompatibilityWarning
                    }

                    Label
                    {
                        id: materialCompatibilityLabel
                        anchors.left: warningImage.right
                        anchors.leftMargin: QD.Theme.getSize("default_margin").width
                        verticalAlignment: Text.AlignVCenter
                        width: selectors.controlWidth - warningImage.width - QD.Theme.getSize("default_margin").width
                        text: catalog.i18nc("@label", "Use glue for better adhesion with this material combination.")
                        font: QD.Theme.getFont("default")
                        color: QD.Theme.getColor("text")
                        visible: QIDISDKVersion == "dev" ? false : warnings.buildplateCompatibilityError || warnings.buildplateCompatibilityWarning
                        wrapMode: Text.WordWrap
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
