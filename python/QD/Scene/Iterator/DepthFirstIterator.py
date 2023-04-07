# Copyright (c) 2018 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.
from QD.Scene.SceneNode import SceneNode
from . import Iterator


class DepthFirstIterator(Iterator.Iterator):
    def __init__(self, scene_node: SceneNode) -> None:
        super().__init__(scene_node)

    def _fillStack(self) -> None:
        self._node_stack.append(self._scene_node)
        self._node_stack.extend(self._scene_node.getAllChildren())
