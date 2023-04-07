# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

import os.path

from QD.Resources import Resources
from QD.Application import Application
from QD.PluginRegistry import PluginRegistry

from QD.View.RenderPass import RenderPass
from QD.View.RenderBatch import RenderBatch
from QD.View.GL.OpenGL import OpenGL

from qidi.Scene.QIDISceneNode import QIDISceneNode
from QD.Scene.Iterator.DepthFirstIterator import DepthFirstIterator

class XRayPass(RenderPass):
    def __init__(self, width, height):
        super().__init__("xray", width, height)

        self._shader = None
        self._gl = OpenGL.getInstance().getBindingsObject()
        self._scene = Application.getInstance().getController().getScene()

    def render(self):
        if not self._shader:
            self._shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "xray.shader"))

        batch = RenderBatch(self._shader, type = RenderBatch.RenderType.NoType, backface_cull = False, blend_mode = RenderBatch.BlendMode.Additive)
        for node in DepthFirstIterator(self._scene.getRoot()):
            if isinstance(node, QIDISceneNode) and node.getMeshData() and node.isVisible():
                batch.addItem(node.getWorldTransformation(copy = False), node.getMeshData(), normal_transformation=node.getCachedNormalMatrix())

        self.bind()

        self._gl.glDisable(self._gl.GL_DEPTH_TEST)
        batch.render(self._scene.getActiveCamera())
        self._gl.glEnable(self._gl.GL_DEPTH_TEST)

        self.release()
