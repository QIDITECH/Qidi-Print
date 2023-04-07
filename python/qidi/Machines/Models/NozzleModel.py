# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from PyQt5.QtCore import Qt

from QD.Logger import Logger
from QD.Qt.ListModel import ListModel
import qidi.QIDIApplication  # Imported like this to prevent circular dependencies.
from qidi.Machines.ContainerTree import ContainerTree


class NozzleModel(ListModel):
    IdRole = Qt.UserRole + 1
    HotendNameRole = Qt.UserRole + 2
    ContainerNodeRole = Qt.UserRole + 3

    def __init__(self, parent = None):
        super().__init__(parent)

        self.addRoleName(self.IdRole, "id")
        self.addRoleName(self.HotendNameRole, "hotend_name")
        self.addRoleName(self.ContainerNodeRole, "container_node")

        qidi.QIDIApplication.QIDIApplication.getInstance().getMachineManager().globalContainerChanged.connect(self._update)
        self._update()

    def _update(self):
        Logger.log("d", "Updating {model_class_name}.".format(model_class_name = self.__class__.__name__))

        global_stack = qidi.QIDIApplication.QIDIApplication.getInstance().getGlobalContainerStack()
        if global_stack is None:
            self.setItems([])
            return
        machine_node = ContainerTree.getInstance().machines[global_stack.definition.getId()]

        if not machine_node.has_variants:
            self.setItems([])
            return

        item_list = []
        for hotend_name, container_node in sorted(machine_node.variants.items(), key = lambda i: i[0].upper()):
            item = {"id": hotend_name,
                    "hotend_name": hotend_name,
                    "container_node": container_node
                    }

            item_list.append(item)

        self.setItems(item_list)