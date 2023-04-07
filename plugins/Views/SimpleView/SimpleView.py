# Copyright (c) 2015 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from QD.Resources import Resources
from QD.Scene.Iterator.DepthFirstIterator import DepthFirstIterator
from QD.View.GL.OpenGL import OpenGL
from QD.View.View import View


class SimpleView(View):
    """Standard view for mesh models."""

    def __init__(self):
        super().__init__()

        self._shader = None

    def beginRendering(self):
        scene = self.getController().getScene()
        renderer = self.getRenderer()

        if not self._shader:
            self._shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "object.shader"))

        for node in DepthFirstIterator(scene.getRoot()):
            if not node.render(renderer):
                if node.getMeshData() and node.isVisible():
                    renderer.queueNode(node, shader = self._shader)

    def endRendering(self):
        pass
