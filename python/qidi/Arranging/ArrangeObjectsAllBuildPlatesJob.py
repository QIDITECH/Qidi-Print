# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from QD.Application import Application
from QD.Job import Job
from QD.Scene.SceneNode import SceneNode
from QD.Math.Vector import Vector
from QD.Operations.TranslateOperation import TranslateOperation
from QD.Operations.GroupedOperation import GroupedOperation
from QD.Message import Message
from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qidi")

from qidi.Scene.ZOffsetDecorator import ZOffsetDecorator
from qidi.Arranging.Arrange import Arrange
from qidi.Arranging.ShapeArray import ShapeArray

from typing import List


class ArrangeArray:
    """Do arrangements on multiple build plates (aka builtiplexer)"""

    def __init__(self, x: int, y: int, fixed_nodes: List[SceneNode]) -> None:
        self._x = x
        self._y = y
        self._fixed_nodes = fixed_nodes
        self._count = 0
        self._first_empty = None
        self._has_empty = False
        self._arrange = []  # type: List[Arrange]

    def _updateFirstEmpty(self):
        for i, a in enumerate(self._arrange):
            if a.isEmpty:
                self._first_empty = i
                self._has_empty = True
                return
        self._first_empty = None
        self._has_empty = False

    def add(self):
        new_arrange = Arrange.create(x = self._x, y = self._y, fixed_nodes = self._fixed_nodes)
        self._arrange.append(new_arrange)
        self._count += 1
        self._updateFirstEmpty()

    def count(self):
        return self._count

    def get(self, index):
        return self._arrange[index]

    def getFirstEmpty(self):
        if not self._has_empty:
            self.add()
        return self._arrange[self._first_empty]


class ArrangeObjectsAllBuildPlatesJob(Job):
    def __init__(self, nodes: List[SceneNode], min_offset = 8) -> None:
        super().__init__()
        self._nodes = nodes
        self._min_offset = min_offset

    def run(self):
        status_message = Message(i18n_catalog.i18nc("@info:status", "Finding new location for objects"),
                                 lifetime = 0,
                                 dismissable=False,
                                 progress = 0,
                                 title = i18n_catalog.i18nc("@info:title", "Finding Location"))
        status_message.show()


        # Collect nodes to be placed
        nodes_arr = []  # fill with (size, node, offset_shape_arr, hull_shape_arr)
        for node in self._nodes:
            offset_shape_arr, hull_shape_arr = ShapeArray.fromNode(node, min_offset = self._min_offset)
            nodes_arr.append((offset_shape_arr.arr.shape[0] * offset_shape_arr.arr.shape[1], node, offset_shape_arr, hull_shape_arr))

        # Sort the nodes with the biggest area first.
        nodes_arr.sort(key=lambda item: item[0])
        nodes_arr.reverse()

        global_container_stack = Application.getInstance().getGlobalContainerStack()
        machine_width = global_container_stack.getProperty("machine_width", "value")
        machine_depth = global_container_stack.getProperty("machine_depth", "value")

        x, y = machine_width, machine_depth

        arrange_array = ArrangeArray(x = x, y = y, fixed_nodes = [])
        arrange_array.add()

        # Place nodes one at a time
        start_priority = 0
        grouped_operation = GroupedOperation()
        found_solution_for_all = True
        left_over_nodes = []  # nodes that do not fit on an empty build plate

        for idx, (size, node, offset_shape_arr, hull_shape_arr) in enumerate(nodes_arr):
            # For performance reasons, we assume that when a location does not fit,
            # it will also not fit for the next object (while what can be untrue).

            try_placement = True

            current_build_plate_number = 0  # always start with the first one

            while try_placement:
                # make sure that current_build_plate_number is not going crazy or you'll have a lot of arrange objects
                while current_build_plate_number >= arrange_array.count():
                    arrange_array.add()
                arranger = arrange_array.get(current_build_plate_number)

                best_spot = arranger.bestSpot(hull_shape_arr, start_prio=start_priority)
                x, y = best_spot.x, best_spot.y
                node.removeDecorator(ZOffsetDecorator)
                if node.getBoundingBox():
                    center_y = node.getWorldPosition().y - node.getBoundingBox().bottom
                else:
                    center_y = 0
                if x is not None:  # We could find a place
                    arranger.place(x, y, offset_shape_arr)  # place the object in the arranger

                    node.callDecoration("setBuildPlateNumber", current_build_plate_number)
                    grouped_operation.addOperation(TranslateOperation(node, Vector(x, center_y, y), set_position = True))
                    try_placement = False
                else:
                    # very naive, because we skip to the next build plate if one model doesn't fit.
                    if arranger.isEmpty:
                        # apparently we can never place this object
                        left_over_nodes.append(node)
                        try_placement = False
                    else:
                        # try next build plate
                        current_build_plate_number += 1
                        try_placement = True

            status_message.setProgress((idx + 1) / len(nodes_arr) * 100)
            Job.yieldThread()

        for node in left_over_nodes:
            node.callDecoration("setBuildPlateNumber", -1)  # these are not on any build plate
            found_solution_for_all = False

        grouped_operation.push()

        status_message.hide()

        if not found_solution_for_all:
            no_full_solution_message = Message(i18n_catalog.i18nc("@info:status", "Unable to find a location within the build volume for all objects"),
                                               title = i18n_catalog.i18nc("@info:title", "Can't Find Location"))
            no_full_solution_message.show()
