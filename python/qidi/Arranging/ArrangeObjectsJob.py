# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.
from typing import List

from QD.Application import Application
from QD.Job import Job
from QD.Logger import Logger
from QD.Message import Message
from QD.Scene.SceneNode import SceneNode
from QD.i18n import i18nCatalog
from qidi.Arranging.Nest2DArrange import arrange

i18n_catalog = i18nCatalog("qidi")


class ArrangeObjectsJob(Job):
    def __init__(self, nodes: List[SceneNode], fixed_nodes: List[SceneNode], min_offset = 8) -> None:
        super().__init__()
        self._nodes = nodes
        self._fixed_nodes = fixed_nodes
        self._min_offset = min_offset

    def run(self):
        status_message = Message(i18n_catalog.i18nc("@info:status", "Finding new location for objects"),
                                 lifetime = 0,
                                 dismissable = False,
                                 progress = 0,
                                 title = i18n_catalog.i18nc("@info:title", "Finding Location"))
        status_message.show()

        found_solution_for_all = None
        try:
            found_solution_for_all = arrange(self._nodes, Application.getInstance().getBuildVolume(), self._fixed_nodes)
        except:  # If the thread crashes, the message should still close
            Logger.logException("e", "Unable to arrange the objects on the buildplate. The arrange algorithm has crashed.")

        status_message.hide()
        if found_solution_for_all is not None and not found_solution_for_all:
            no_full_solution_message = Message(
                    i18n_catalog.i18nc("@info:status",
                                       "Unable to find a location within the build volume for all objects"),
                    title = i18n_catalog.i18nc("@info:title", "Can't Find Location"))
            no_full_solution_message.show()
        self.finished.emit(self)
