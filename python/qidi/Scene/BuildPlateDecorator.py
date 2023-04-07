from QD.Scene.SceneNodeDecorator import SceneNodeDecorator
from qidi.Scene.QIDISceneNode import QIDISceneNode


class BuildPlateDecorator(SceneNodeDecorator):
    """Make a SceneNode build plate aware QIDISceneNode objects all have this decorator."""

    def __init__(self, build_plate_number: int = -1) -> None:
        super().__init__()
        self._build_plate_number = build_plate_number
        self.setBuildPlateNumber(build_plate_number)

    def setBuildPlateNumber(self, nr: int) -> None:
        # Make sure that groups are set correctly
        # setBuildPlateForSelection in QIDIActions makes sure that no single childs are set.
        self._build_plate_number = nr
        if isinstance(self._node, QIDISceneNode):
            self._node.transformChanged()  # trigger refresh node without introducing a new signal
        if self._node:
            for child in self._node.getChildren():
                child.callDecoration("setBuildPlateNumber", nr)

    def getBuildPlateNumber(self) -> int:
        return self._build_plate_number

    def __deepcopy__(self, memo):
        return BuildPlateDecorator()
