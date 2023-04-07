# Copyright (c) 2015 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.
from QD.Math.Vector import Vector
from QD.Operations.Operation import Operation
from QD.Operations.GroupedOperation import GroupedOperation
from QD.Scene.SceneNode import SceneNode


class PlatformPhysicsOperation(Operation):
    """A specialised operation designed specifically to modify the previous operation."""

    def __init__(self, node: SceneNode, translation: Vector) -> None:
        super().__init__()
        self._node = node
        self._old_transformation = node.getLocalTransformation()
        self._translation = translation
        self._always_merge = True

    def undo(self) -> None:
        self._node.setTransformation(self._old_transformation)

    def redo(self) -> None:
        self._node.translate(self._translation, SceneNode.TransformSpace.World)

    def mergeWith(self, other: Operation) -> GroupedOperation:
        group = GroupedOperation()

        group.addOperation(other)
        group.addOperation(self)

        return group

    def __repr__(self) -> str:
        return "PlatformPhysicsOp.(trans.={0})".format(self._translation)
