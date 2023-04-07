
from typing import Optional, TYPE_CHECKING, cast, List


from QD.Application import Application
from QD.Logger import Logger
from QD.Resources import Resources

from QD.View.RenderPass import RenderPass
from QD.View.GL.OpenGL import OpenGL
from QD.View.RenderBatch import RenderBatch
from QD.Math.Color import Color


from QD.Scene.Iterator.DepthFirstIterator import DepthFirstIterator
from qidi.Scene.QIDISceneNode import QIDISceneNode

if TYPE_CHECKING:
    from QD.View.GL.ShaderProgram import ShaderProgram
    from QD.Scene.Camera import Camera


def prettier_color(color_list: List[float]) -> List[float]:
    """Make color brighter by normalizing

    maximum factor 2.5 brighter

    :param color_list: a list of 4 elements: [r, g, b, a], each element is a float 0..1
    :return: a normalized list of 4 elements: [r, g, b, a], each element is a float 0..1
    """
    maximum = max(color_list[:3])
    if maximum > 0:
        factor = min(1 / maximum, 2.5)
    else:
        factor = 1.0
    return [min(i * factor, 1.0) for i in color_list]


class PreviewPass(RenderPass):
    """A :py:class:`QDTECH.QD.View.RenderPass` subclass that renders slicable objects with default parameters.

    It uses the active camera by default, but it can be overridden to use a different camera.

    This is useful to get a preview image of a scene taken from a different location as the active camera.
    """

    def __init__(self, width: int, height: int) -> None:
        super().__init__("preview", width, height, 0)

        self._camera = None  # type: Optional[Camera]

        self._renderer = Application.getInstance().getRenderer()
        self._theme = None
        self._shader = None  # type: Optional[ShaderProgram]
        self._ooze_prevention_shader = None
        self._non_printing_shader = None  # type: Optional[ShaderProgram]
        self._support_mesh_shader = None  # type: Optional[ShaderProgram]
        self._scene = Application.getInstance().getController().getScene()

    #   Set the camera to be used by this render pass
    #   if it's None, the active camera is used
    def setCamera(self, camera: Optional["Camera"]):
        self._camera = camera

    def render(self) -> None:
        if not self._shader:
            self._shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "overhang.shader"))
            self._theme = Application.getInstance().getTheme()
            self._ooze_prevention_shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "ooze_object.shader"))
            self._ooze_prevention_shader.setUniformValue("u_diffuseColor", Color(*self._theme.getColor("model_non_printing").getRgb()))
            self._ooze_prevention_shader.setUniformValue("u_opacity", 0.2)
            if self._shader:
                self._shader.setUniformValue("u_overhangAngle", 1.0)
                self._shader.setUniformValue("u_ambientColor", [0.1, 0.1, 0.1, 1.0])
                self._shader.setUniformValue("u_specularColor", [0.6, 0.6, 0.6, 1.0])
                self._shader.setUniformValue("u_shininess", 20.0)
                self._shader.setUniformValue("u_renderError", 0.0)  # We don't want any error markers!.
                self._shader.setUniformValue("u_faceId", -1)  # Don't render any selected faces in the preview.
            else:
                Logger.error("Unable to compile shader program: overhang.shader")

        if not self._non_printing_shader:
            self._non_printing_shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "transparent_object.shader"))
            if self._non_printing_shader:
                self._non_printing_shader.setUniformValue("u_diffuseColor", [0.5, 0.5, 0.5, 0.5])
                self._non_printing_shader.setUniformValue("u_opacity", 0.6)

        if not self._support_mesh_shader:
            self._support_mesh_shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "striped.shader"))
            if self._support_mesh_shader:
                self._support_mesh_shader.setUniformValue("u_vertical_stripes", True)
                self._support_mesh_shader.setUniformValue("u_width", 5.0)

        self._gl.glClearColor(0.0, 0.0, 0.0, 0.0)
        self._gl.glClear(self._gl.GL_COLOR_BUFFER_BIT | self._gl.GL_DEPTH_BUFFER_BIT)

        # Create batches to be rendered
        batch = RenderBatch(self._shader)
        batch_ooze = RenderBatch(self._ooze_prevention_shader, type = RenderBatch.RenderType.test)
        batch_support_mesh = RenderBatch(self._support_mesh_shader)

        # Fill up the batch with objects that can be sliced.
        for node in DepthFirstIterator(self._scene.getRoot()):
            if hasattr(node, "_outside_buildarea") and not getattr(node, "_outside_buildarea"):
                if node.callDecoration("isSliceable") and node.getMeshData() and node.isVisible():
                    per_mesh_stack = node.callDecoration("getStack")
                    if node.callDecoration("isNonThumbnailVisibleMesh"):
                        # Non printing mesh
                        if node.getName() == "Prime Tower 1" or node.getName() == "Ooze Shield 1" or node.getName() == "Prime Tower 2" or node.getName() == "Ooze Shield 2":
                            #uniforms["diffuse_color"] = prettier_color([0.5, 0.5, 0.5, 1.0])
                            uniforms["diffuse_color"] = [1.0, 0.0, 0.0, 1.0]
                            batch_ooze.addItem(node.getWorldTransformation(copy = False), node.getMeshData(), uniforms = uniforms,normal_transformation = node.getCachedNormalMatrix())
                        continue
                    elif per_mesh_stack is not None and per_mesh_stack.getProperty("support_mesh", "value"):
                        # Support mesh
                        uniforms = {}
                        shade_factor = 0.6
                        diffuse_color = cast(QIDISceneNode, node).getDiffuseColor()
                        diffuse_color2 = [
                            diffuse_color[0] * shade_factor,
                            diffuse_color[1] * shade_factor,
                            diffuse_color[2] * shade_factor,
                            1.0]
                        uniforms["diffuse_color"] = prettier_color(diffuse_color)
                        uniforms["diffuse_color_2"] = diffuse_color2
                        batch_support_mesh.addItem(node.getWorldTransformation(copy = False), node.getMeshData(), uniforms = uniforms)
                    else:
                        # Normal scene node
                        uniforms = {}
                        uniforms["diffuse_color"] = prettier_color(cast(QIDISceneNode, node).getDiffuseColor())
                        if node.getName() == "Prime Tower 1" or node.getName() == "Ooze Shield 1" or node.getName() == "Prime Tower 2" or node.getName() == "Ooze Shield 2":
                            uniforms["diffuse_color"] = [1.0, 0.0, 0.0, 1.0]
                            batch_ooze.addItem(node.getWorldTransformation(copy = False), node.getMeshData(), uniforms = uniforms, normal_transformation = node.getCachedNormalMatrix())
                        else:
                            batch.addItem(node.getWorldTransformation(copy = False), node.getMeshData(), uniforms = uniforms)

        self.bind()

        if self._camera is None:
            render_camera = Application.getInstance().getController().getScene().getActiveCamera()
        else:
            render_camera = self._camera
            
        batch.render(render_camera)
        batch_support_mesh.render(render_camera)
        batch_ooze.render(render_camera)

        self.release()
