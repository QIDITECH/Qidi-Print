

from . import X3GWriter

from QD.i18n import i18nCatalog
catalog = i18nCatalog("qidi")

def getMetaData():
    return {


        "mesh_writer": {
            "output": [{
                "extension": "x3g",
                "description": catalog.i18nc("X3G Writer File Description", "X3G File"),
                "mime_type": "application/x3g"
            }]
        }
    }

def register(app):
    return { "mesh_writer": X3GWriter.X3GWriter() }
