// Copyright (c) 2021 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.1

import QD 1.1 as QD

QD.Dialog
{
    id: base

    //: About dialog title
    title: catalog.i18nc("@title:window The argument is the application name.", "About %1").arg(QIDIApplication.applicationDisplayName)

    minimumWidth: 500 * screenScaleFactor
    minimumHeight: 700 * screenScaleFactor
    width: minimumWidth
    height: minimumHeight

    Rectangle
    {
        id: header
        width: parent.width + 2 * margin // margin from Dialog.qml
        height: childrenRect.height + topPadding

        anchors.top: parent.top
        anchors.topMargin: -margin
        anchors.horizontalCenter: parent.horizontalCenter

        property real topPadding: QD.Theme.getSize("wide_margin").height

        color: QD.Theme.getColor("main_window_header_background")

        Image
        {
            id: logo
            width: (base.minimumWidth * 0.85) | 0
            height: (width * (QD.Theme.getSize("logo").height / QD.Theme.getSize("logo").width)) | 0
            source: QD.Theme.getImage("logo")
            sourceSize.width: width
            sourceSize.height: height
            fillMode: Image.PreserveAspectFit

            anchors.top: parent.top
            anchors.topMargin: parent.topPadding
            anchors.horizontalCenter: parent.horizontalCenter

            QD.I18nCatalog{id: catalog; name: "qidi"}
        }

        Label
        {
            id: version

            text: catalog.i18nc("@label","version: %1").arg(QD.Application.version)
            font: QD.Theme.getFont("large_bold")
            color: QD.Theme.getColor("button_text")
            anchors.right : logo.right
            anchors.top: logo.bottom
            anchors.topMargin: (QD.Theme.getSize("default_margin").height / 2) | 0
        }
    }

    Label
    {
        id: description
        width: parent.width

        //: About dialog application description
        text: catalog.i18nc("@label","End-to-end solution for fused filament 3D printing.")
        font: QD.Theme.getFont("system")
        wrapMode: Text.WordWrap
        anchors.top: header.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height
    }

    Label
    {
        id: creditsNotes
        width: parent.width

        //: About dialog application author note
        text: catalog.i18nc("@info:credit","QIDI is developed by QIDI B.V. in cooperation with the community.\nQIDI proudly uses the following open source projects:")
        font: QD.Theme.getFont("system")
        wrapMode: Text.WordWrap
        anchors.top: description.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height
    }

    ScrollView
    {
        id: credits
        anchors.top: creditsNotes.bottom
        anchors.topMargin: QD.Theme.getSize("default_margin").height

        width: parent.width
        height: base.height - y - (2 * QD.Theme.getSize("default_margin").height + closeButton.height)

        ListView
        {
            id: projectsList

            width: parent.width

            delegate: Row
            {
                Label
                {
                    text: "<a href='%1' title='%2'>%2</a>".arg(model.url).arg(model.name)
                    width: (projectsList.width * 0.25) | 0
                    elide: Text.ElideRight
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label
                {
                    text: model.description
                    elide: Text.ElideRight
                    width: (projectsList.width * 0.6) | 0
                }
                Label
                {
                    text: model.license
                    elide: Text.ElideRight
                    width: (projectsList.width * 0.15) | 0
                }
            }
            model: ListModel
            {
                id: projectsModel
            }
            Component.onCompleted:
            {
                projectsModel.append({ name: "QIDI", description: catalog.i18nc("@label", "Graphical user interface"), license: "LGPLv3", url: "https://github.com/QIDI/QIDI" });
                projectsModel.append({ name: "QDTECH", description: catalog.i18nc("@label", "Application framework"), license: "LGPLv3", url: "https://github.com/QIDI/QDTECH" });
                projectsModel.append({ name: "CuraEngine", description: catalog.i18nc("@label", "G-code generator"), license: "AGPLv3", url: "https://github.com/QIDI/CuraEngine" });
                projectsModel.append({ name: "libArcus", description: catalog.i18nc("@label", "Interprocess communication library"), license: "LGPLv3", url: "https://github.com/QIDI/libArcus" });

                projectsModel.append({ name: "Python", description: catalog.i18nc("@label", "Programming language"), license: "Python", url: "http://python.org/" });
                projectsModel.append({ name: "Qt5", description: catalog.i18nc("@label", "GUI framework"), license: "LGPLv3", url: "https://www.qt.io/" });
                projectsModel.append({ name: "PyQt", description: catalog.i18nc("@label", "GUI framework bindings"), license: "GPL", url: "https://riverbankcomputing.com/software/pyqt" });
                projectsModel.append({ name: "SIP", description: catalog.i18nc("@label", "C/C++ Binding library"), license: "GPL", url: "https://riverbankcomputing.com/software/sip" });
                projectsModel.append({ name: "Protobuf", description: catalog.i18nc("@label", "Data interchange format"), license: "BSD", url: "https://developers.google.com/protocol-buffers" });
                projectsModel.append({ name: "SciPy", description: catalog.i18nc("@label", "Support library for scientific computing"), license: "BSD-new", url: "https://www.scipy.org/" });
                projectsModel.append({ name: "NumPy", description: catalog.i18nc("@label", "Support library for faster math"), license: "BSD", url: "http://www.numpy.org/" });
                projectsModel.append({ name: "NumPy-STL", description: catalog.i18nc("@label", "Support library for handling STL files"), license: "BSD", url: "https://github.com/WoLpH/numpy-stl" });
                projectsModel.append({ name: "Shapely", description: catalog.i18nc("@label", "Support library for handling planar objects"), license: "BSD", url: "https://github.com/Toblerity/Shapely" });
                projectsModel.append({ name: "Trimesh", description: catalog.i18nc("@label", "Support library for handling triangular meshes"), license: "MIT", url: "https://trimsh.org" });
                projectsModel.append({ name: "libSavitar", description: catalog.i18nc("@label", "Support library for handling 3MF files"), license: "LGPLv3", url: "https://github.com/qidi/libsavitar" });
                projectsModel.append({ name: "libCharon", description: catalog.i18nc("@label", "Support library for file metadata and streaming"), license: "LGPLv3", url: "https://github.com/qidi/libcharon" });
                projectsModel.append({ name: "PySerial", description: catalog.i18nc("@label", "Serial communication library"), license: "Python", url: "http://pyserial.sourceforge.net/" });
                projectsModel.append({ name: "python-zeroconf", description: catalog.i18nc("@label", "ZeroConf discovery library"), license: "LGPL", url: "https://github.com/jstasiak/python-zeroconf" });
                projectsModel.append({ name: "Clipper", description: catalog.i18nc("@label", "Polygon clipping library"), license: "Boost", url: "http://www.angusj.com/delphi/clipper.php" });
                projectsModel.append({ name: "mypy", description: catalog.i18nc("@Label", "Static type checker for Python"), license: "MIT", url: "http://mypy-lang.org/" });
                projectsModel.append({ name: "certifi", description: catalog.i18nc("@Label", "Root Certificates for validating SSL trustworthiness"), license: "MPL", url: "https://github.com/certifi/python-certifi" });
                projectsModel.append({ name: "cryptography", description: catalog.i18nc("@Label", "Root Certificates for validating SSL trustworthiness"), license: "APACHE and BSD", url: "https://cryptography.io/" });
                projectsModel.append({ name: "Sentry", description: catalog.i18nc("@Label", "Python Error tracking library"), license: "BSD 2-Clause 'Simplified'", url: "https://sentry.io/for/python/" });
                projectsModel.append({ name: "libnest2d", description: catalog.i18nc("@label", "Polygon packing library, developed by Prusa Research"), license: "LGPL", url: "https://github.com/tamasmeszaros/libnest2d" });
                projectsModel.append({ name: "pynest2d", description: catalog.i18nc("@label", "Python bindings for libnest2d"), license: "LGPL", url: "https://github.com/QIDI/pynest2d" });
                projectsModel.append({ name: "keyring", description: catalog.i18nc("@label", "Support library for system keyring access"), license: "MIT", url: "https://github.com/jaraco/keyring" });
                projectsModel.append({ name: "pywin32", description: catalog.i18nc("@label", "Python extensions for Microsoft Windows"), license: "PSF", url: "https://github.com/mhammond/pywin32" });
                projectsModel.append({ name: "Noto Sans", description: catalog.i18nc("@label", "Font"), license: "Apache 2.0", url: "https://www.google.com/get/noto/" });
                projectsModel.append({ name: "Font-Awesome-SVG-PNG", description: catalog.i18nc("@label", "SVG icons"), license: "SIL OFL 1.1", url: "https://github.com/encharm/Font-Awesome-SVG-PNG" });
                projectsModel.append({ name: "AppImageKit", description: catalog.i18nc("@label", "Linux cross-distribution application deployment"), license: "MIT", url: "https://github.com/AppImage/AppImageKit" });
            }
        }
    }

    rightButtons: Button
    {
        //: Close about dialog button
        id: closeButton
        text: catalog.i18nc("@action:button","Close");

        onClicked: base.visible = false;
    }
}
