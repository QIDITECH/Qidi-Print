# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import List, TYPE_CHECKING

if TYPE_CHECKING:
    from qidi.Machines.MaterialNode import MaterialNode


class MaterialGroup:


    __slots__ = ("name", "is_read_only", "root_material_node", "derived_material_node_list")

    def __init__(self, name: str, root_material_node: "MaterialNode") -> None:
        self.name = name
        self.is_read_only = False
        self.root_material_node = root_material_node  # type: MaterialNode
        self.derived_material_node_list = []  # type: List[MaterialNode]

    def __str__(self) -> str:
        return "%s[%s]" % (self.__class__.__name__, self.name)
