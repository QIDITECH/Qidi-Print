# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from PyQt5.QtQml import qmlRegisterSingletonType

from QD.i18n import i18nCatalog
from . import SimulationViewProxy, SimulationView

catalog = i18nCatalog("qidi")


def getMetaData():
    return {
        "view": {
            "name": catalog.i18nc("@item:inlistbox", "Layer view"),
            "weight": 0
        }
    }


def createSimulationViewProxy(engine, script_engine):
    return SimulationViewProxy.SimulationViewProxy()


def register(app):
    simulation_view = SimulationView.SimulationView()
    qmlRegisterSingletonType(SimulationViewProxy.SimulationViewProxy, "QD", 1, 0, "SimulationView", simulation_view.getProxy)
    return { "view": simulation_view}
