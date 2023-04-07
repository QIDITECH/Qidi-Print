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

from QD.Scene.Iterator.DepthFirstIterator import DepthFirstIterator


class ButtonPass(RenderPass):
    """A render pass subclass that renders everything with the default parameters.

    This class provides the basic rendering of the objects in the scene.
    """
    def __init__(self, width: int, height: int) -> None:
        super().__init__("button", width, height, 0)

        self._renderer = QD.Qt.QtApplication.QtApplication.getInstance().getRenderer()
        self._tool_handle_shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "default.shader"))
        self._mesh_handler = Application.getInstance().getMeshFileHandler()
        self._scene = Application.getInstance().getController().getScene()



    def render(self) -> None:
    



        camera = QD.Qt.QtApplication.QtApplication.getInstance().getController().getScene().getActiveCamera()
        button_handle = RenderBatch(self._tool_handle_shader)
        for node in DepthFirstIterator(self._scene.getRoot()):
            break
        button_handle.addItem(node.getWorldTransformation(copy = False), mesh = Application.getInstance().getButtonMesh())
        self.bind()
        
        button_handle.render(camera)
        # for batch in self._renderer.getBatches():
            # batch.render(camera)

        self.release()


    def getIdAtPosition(self, x, y):
        """Get the object id at a certain pixel coordinate."""
        output = self.getOutput()
        
        
        window_size = self._renderer.getWindowSize()
        

        px = round((0.5 + x / 2.0) * window_size[0])
        py = round((0.5 + y / 2.0) * window_size[1])

        if px < 0 or px > (output.width() - 1) or py < 0 or py > (output.height() - 1):
            return None

        pixel = output.pixel(px, py)
        # Logger.log("e",pixel)
        # Logger.log("e",Color.fromARGB(pixel))
        if Color.fromARGB(pixel) == Color(0.4,0.4,0.0,0.4):
            return "open"
        elif Color.fromARGB(pixel) == Color(0.4,0.4,1.0,0.4):
            return "delete"
        elif Color.fromARGB(pixel) == Color(0.4,0.0,0.0,0.4):
            return "flat"
        elif Color.fromARGB(pixel) == Color(0.8,1.0,1.0,0.4):
            return "copy"
        elif Color.fromARGB(pixel) == Color(1.0,1.0,0.4,0.4):
            return "place"
        else:
            return None
        return None