// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0

import QD 1.2 as QD
import QIDI 1.0 as QIDI

Button
{
    id: configurationItem

    property var configuration: null
    hoverEnabled: isValidMaterial

    property bool isValidMaterial:
    {
        if (configuration === null)
        {
            return false
        }
        var extruderConfigurations = configuration.extruderConfigurations

        for (var index in extruderConfigurations)
        {
            var name = extruderConfigurations[index].material ? extruderConfigurations[index].material.name : ""

            if (name == "" || name == "Unknown")
            {
                return false
            }
        }
        return true
    }

    background: Rectangle
    {
        color: parent.hovered ? QD.Theme.getColor("action_button_hovered") : QD.Theme.getColor("action_button")
        border.color: parent.checked ? QD.Theme.getColor("primary") : QD.Theme.getColor("lining")
        border.width: QD.Theme.getSize("default_lining").width
        radius: QD.Theme.getSize("default_radius").width
    }

    contentItem: Column
    {
        id: contentColumn
        width: parent.width
        padding: QD.Theme.getSize("default_margin").width
        spacing: QD.Theme.getSize("narrow_margin").height

        Row
        {
            id: extruderRow

            anchors
            {
                left: parent.left
                leftMargin: QD.Theme.getSize("default_margin").width
                right: parent.right
                rightMargin: QD.Theme.getSize("wide_margin").width
            }
            height: childrenRect.height
            spacing: QD.Theme.getSize("default_margin").width

            Repeater
            {
                id: repeater
                model: configuration !== null ? configuration.extruderConfigurations: null
                width: parent.width
                delegate: PrintCoreConfiguration
                {
                    width: Math.round(parent.width / (configuration !== null ? configuration.extruderConfigurations.length : 1))
                    printCoreConfiguration: modelData
                    visible: configurationItem.isValidMaterial
                }
            }

            // Unknown material
            Item
            {
                id: unknownMaterial
                height: unknownMaterialMessage.height + QD.Theme.getSize("thin_margin").width / 2
                width: parent.width

                anchors.top: parent.top
                anchors.topMargin: QD.Theme.getSize("thin_margin").width / 2

                visible: !configurationItem.isValidMaterial

                QD.RecolorImage
                {
                    id: icon
                    anchors.verticalCenter: unknownMaterialMessage.verticalCenter

                    source: QD.Theme.getIcon("Warning")
                    color: QD.Theme.getColor("warning")
                    width: QD.Theme.getSize("section_icon").width
                    height: width
                }

                Label
                {
                    id: unknownMaterialMessage
                    text:
                    {
                        if (configuration === null)
                        {
                            return ""
                        }

                        var extruderConfigurations = configuration.extruderConfigurations
                        var unknownMaterials = []
                        for (var index in extruderConfigurations)
                        {
                            var name = extruderConfigurations[index].material ? extruderConfigurations[index].material.name : ""
                            if (name == "" || name == "Unknown")
                            {
                                var materialType = extruderConfigurations[index].material.type
                                if (extruderConfigurations[index].material.type == "")
                                {
                                    materialType = "Unknown"
                                }

                                var brand = extruderConfigurations[index].material.brand
                                if (brand == "")
                                {
                                    brand = "Unknown"
                                }

                                name = materialType + " (" + brand + ")"
                                unknownMaterials.push(name)
                            }
                        }

                        unknownMaterials = "<b>" + unknownMaterials + "</b>"
                        var draftResult = catalog.i18nc("@label", "This configuration is not available because %1 is not recognized. Please visit %2 to download the correct material profile.");
                        var result = draftResult.arg(unknownMaterials).arg("<a href=' '>" + catalog.i18nc("@label","Marketplace") + "</a> ")

                        return result
                    }
                    width: extruderRow.width

                    anchors.left: icon.right
                    anchors.right: unknownMaterial.right
                    anchors.leftMargin: QD.Theme.getSize("wide_margin").height
                    anchors.top: unknownMaterial.top

                    wrapMode: Text.WordWrap
                    font: QD.Theme.getFont("default")
                    color: QD.Theme.getColor("text")
                    verticalAlignment: Text.AlignVCenter
                    linkColor: QD.Theme.getColor("text_link")

                    onLinkActivated:
                    {
                        QIDI.Actions.browsePackages.trigger()
                    }
                }

                MouseArea
                {
                    anchors.fill: parent
                    cursorShape: unknownMaterialMessage.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                    acceptedButtons: Qt.NoButton
                }
            }
        }

        //Buildplate row separator
        Rectangle
        {
            id: separator

            visible: buildplateInformation.visible
            anchors
            {
                left: parent.left
                leftMargin: QD.Theme.getSize("wide_margin").width
                right: parent.right
                rightMargin: QD.Theme.getSize("wide_margin").width
            }
            height: visible ? Math.round(QD.Theme.getSize("default_lining").height / 2) : 0
            color: QD.Theme.getColor("lining")
        }

        Item
        {
            id: buildplateInformation

            anchors
            {
                left: parent.left
                leftMargin: QD.Theme.getSize("wide_margin").width
                right: parent.right
                rightMargin: QD.Theme.getSize("wide_margin").width
            }
            height: childrenRect.height
            visible: configuration !== null && configuration.buildplateConfiguration != "" && false //Buildplate is disabled as long as we have no printers that properly support buildplate swapping (so we can't test).

            // Show the type of buildplate. The first letter is capitalized
            QIDI.IconWithText
            {
                id: buildplateLabel
                source: QD.Theme.getIcon("buildplate")
                text:
                {
                    if (configuration === null)
                    {
                        return ""
                    }
                    return configuration.buildplateConfiguration.charAt(0).toUpperCase() + configuration.buildplateConfiguration.substr(1)
                }
                anchors.left: parent.left
            }
        }
    }

    Connections
    {
        target: QIDI.MachineManager
        function onCurrentConfigurationChanged()
        {
            configurationItem.checked = QIDI.MachineManager.matchesConfiguration(configuration)
        }
    }

    Component.onCompleted:
    {
        configurationItem.checked = QIDI.MachineManager.matchesConfiguration(configuration)
    }

    onClicked:
    {
        if(isValidMaterial)
        {
            toggleContent()
            QIDI.MachineManager.applyRemoteConfiguration(configuration)
        }
    }
}
