// Copyright (c) 2018 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import QD 1.2 as QD


Button
{
    id: modelCheckerButton

    QD.I18nCatalog
    {
        id: catalog
        name: "qidi"
    }

    visible: manager.hasWarnings
    tooltip: catalog.i18nc("@info:tooltip", "Some things could be problematic in this print. Click to see tips for adjustment.")
    onClicked: manager.showWarnings()

    width: QD.Theme.getSize("save_button_specs_icons").width
    height: QD.Theme.getSize("save_button_specs_icons").height

    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    style: ButtonStyle
    {
        background: Item
        {
            QD.RecolorImage
            {
                width: QD.Theme.getSize("save_button_specs_icons").width;
                height: QD.Theme.getSize("save_button_specs_icons").height;
                sourceSize.height: width;
                color: control.hovered ? QD.Theme.getColor("text_scene_hover") : QD.Theme.getColor("text_scene");
                source: "model_checker.svg"
            }
        }
    }
}
