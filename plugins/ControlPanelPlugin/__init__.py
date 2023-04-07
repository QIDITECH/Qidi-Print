from . import ControlPanel
from QD.i18n import i18nCatalog

catalog = i18nCatalog("qidi")
def getMetaData():
    return {}

def register(app):
    return {
    "extension": ControlPanel.ControlPanel()}
