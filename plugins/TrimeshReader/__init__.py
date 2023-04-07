
from . import TrimeshReader

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")


def getMetaData():
    return {
        "mesh_reader": [
            {
                "extension": "ctm",
                "description": i18n_catalog.i18nc("@item:inlistbox 'Open' is part of the name of this file format.", "Open Compressed Triangle Mesh")
            },
            {
                "extension": "dae",
                "description": i18n_catalog.i18nc("@item:inlistbox", "COLLADA Digital Asset Exchange")
            },
            {
                "extension": "glb",
                "description": i18n_catalog.i18nc("@item:inlistbox", "glTF Binary")
            },
            {
                "extension": "gltf",
                "description": i18n_catalog.i18nc("@item:inlistbox", "glTF Embedded JSON")
            },
            # Trimesh seems to have a bug when reading OFF files.
            #{
            #    "extension": "off",
            #    "description": i18n_catalog.i18nc("@item:inlistbox", "Geomview Object File Format")
            #},
            {
                "extension": "ply",
                "description": i18n_catalog.i18nc("@item:inlistbox", "Stanford Triangle Format")
            },
            {
                "extension": "zae",
                "description": i18n_catalog.i18nc("@item:inlistbox", "Compressed COLLADA Digital Asset Exchange")
            }
        ]
    }

def register(app):
    return {"mesh_reader": TrimeshReader.TrimeshReader()}
