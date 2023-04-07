# Copyright (c) 2017 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import XmlMaterialProfile
from . import XmlMaterialUpgrader

from QD.MimeTypeDatabase import MimeType, MimeTypeDatabase

upgrader = XmlMaterialUpgrader.XmlMaterialUpgrader()


def getMetaData():
    return {
        "settings_container": {
            "type": "material",
            "mimetype": "application/x-qidi-material-profile"
        },
        "version_upgrade": {
            ("materials", 1000000): ("materials", 1000007, upgrader.upgradeMaterial),
        },
        "sources": {
            "materials": {
                "get_version": upgrader.getXmlVersion,
                "location": {"./materials"}
            },
        }
    }


def register(app):
    # add Mime type
    mime_type = MimeType(
        name = "application/x-qidi-material-profile",
        comment = "QIDI Material Profile",
        suffixes = [ "xml.fdm_material" ]
    )
    MimeTypeDatabase.addMimeType(mime_type)

    # add upgrade version
    from qidi.QIDIApplication import QIDIApplication
    from QD.VersionUpgradeManager import VersionUpgradeManager
    VersionUpgradeManager.getInstance().registerCurrentVersion(
        ("materials", XmlMaterialProfile.XmlMaterialProfile.Version * 1000000 + QIDIApplication.SettingVersion),
        (QIDIApplication.ResourceTypes.MaterialInstanceContainer, "application/x-qidi-material-profile")
    )

    return {"version_upgrade": upgrader,
            "settings_container": XmlMaterialProfile.XmlMaterialProfile("default_xml_material_profile"),
            }
