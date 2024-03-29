# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from QD.Scene.SceneNodeDecorator import SceneNodeDecorator


class BlockSlicingDecorator(SceneNodeDecorator):
    def __init__(self) -> None:
        super().__init__()

    def isBlockSlicing(self) -> bool:
        return True

    def __deepcopy__(self, memo):
        return BlockSlicingDecorator()