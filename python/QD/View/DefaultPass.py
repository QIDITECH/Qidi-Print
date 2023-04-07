# Copyright (c) 2019 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

import QD.Qt.QtApplication
from QD.View.RenderPass import RenderPass
from QD.Logger import Logger
from QD.Math.Color import Color

from QD.View.GL.OpenGL import OpenGL
from QD.View.RenderBatch import RenderBatch
from QD.Resources import Resources
from QD.Application import Application
from QD.Math.Vector import Vector


class DefaultPass(RenderPass):
    """A render pass subclass that renders everything with the default parameters.

    This class provides the basic rendering of the objects in the scene.
    """
    def __init__(self, width: int, height: int) -> None:
        super().__init__("default", width, height, 0)

        self._renderer = QD.Qt.QtApplication.QtApplication.getInstance().getRenderer()
        self._tool_handle_shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "default.shader"))
        self._mesh_handler = Application.getInstance().getMeshFileHandler()

    def render(self) -> None:
    



        camera = QD.Qt.QtApplication.QtApplication.getInstance().getController().getScene().getActiveCamera()
        self.bind()

        for batch in self._renderer.getBatches():
            batch.render(camera)

        self.release()


    def getIdAtPosition(self, x, y):
        """Get the object id at a certain pixel coordinate."""
        output = self.getOutput()
        
        # Logger.log("e",output)
        
        window_size = self._renderer.getWindowSize()
        
        # Logger.log("e",window_size)

        px = round((0.5 + x / 2.0) * window_size[0])
        py = round((0.5 + y / 2.0) * window_size[1])

        if px < 0 or px > (output.width() - 1) or py < 0 or py > (output.height() - 1):
            return None

        pixel = output.pixel(px, py)
        # Logger.log("e",pixel)
        # Logger.log("e",Color.fromARGB(pixel))

        return None