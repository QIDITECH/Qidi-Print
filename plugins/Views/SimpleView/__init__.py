
from . import SimpleView

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")

def getMetaData():
    return {
        "view": {
            "name": i18n_catalog.i18nc("@item:inmenu", "Simple"),
            "visible": False
        }
    }

def register(app):
    return { "view": SimpleView.SimpleView() }

