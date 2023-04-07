# Copyright (c) 2020 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from . import SceneNode

from QD.Application import Application
from QD.Logger import Logger
from QD.Resources import Resources
from QD.Math.Vector import Vector
from QD.Job import Job
from QD.Scene.Iterator.DepthFirstIterator import DepthFirstIterator

from QD.View.GL.OpenGL import OpenGL

from QD.Math.Color import Color



class PlatformForFlat(SceneNode.SceneNode):
    """Platform is a special case of Scene node. It renders a specific model as the platform of the machine.
    A specialised class is used due to the differences in how it needs to rendered and the fact that a platform
    can have a Texture.
    It also handles the re-loading of the mesh when the active machine is changed.
    """

    def __init__(self, parent):
        super().__init__(parent)

        self._load_platform_job = None
        self._load_platform_job2 = None

        self._shader = None
        self._texture = None
        self._global_container_stack = None
        Application.getInstance().globalContainerStackChanged.connect(self._onGlobalContainerStackChanged)
        self._onGlobalContainerStackChanged()
        self.setCalculateBoundingBox(False)

        self._disabled_axis_color = None
        self._able_axis_color = None

        self._mesh_handler = Application.getInstance().getMeshFileHandler()
        self._scene = Application.getInstance().getController().getScene()


    def render(self, renderer):
        if not self.isVisible():
            return True
        if not self._shader:
            self._shader = OpenGL.getInstance().createShaderProgram(Resources.getPath(Resources.Shaders, "colorforbutton.shader"))
            if not self._disabled_axis_color:
                from QD.Qt.QtApplication import QtApplication
                theme = QtApplication.getInstance().getTheme()
                if theme is None:
                    Logger.log("w", "Could not get theme, so unable to create tool handle meshes.")
                    return
                self._disabled_axis_color = Color(*theme.getColor("button_disable").getRgb())

            self._shader.setUniformValue("u_color", self._disabled_axis_color)
            
            if self._texture:
                self._shader.setTexture(0, self._texture)
            else:
                self._updateTexture()

        if self.getMeshData():
            renderer.queueNode(self, shader = self._shader, transparent = True, backface_cull = True, sort = -10)
            return True

    def setActiveAxis(self) -> None:
        if not self._shader:
            return
        if not self._able_axis_color:
            from QD.Qt.QtApplication import QtApplication
            theme = QtApplication.getInstance().getTheme()
            if theme is None:
                Logger.log("w", "Could not get theme, so unable to create tool handle meshes.")
                return
            self._able_axis_color = Color(*theme.getColor("button_able").getRgb())
        self._shader.setUniformValue("u_color", self._able_axis_color)
        self._scene.sceneChanged.emit(self)

    def setDisableAxis(self) -> None:
        if not self._shader:
            return
        if not self._disabled_axis_color:
            from QD.Qt.QtApplication import QtApplication
            theme = QtApplication.getInstance().getTheme()
            if theme is None:
                Logger.log("w", "Could not get theme, so unable to create tool handle meshes.")
                return
            self._disabled_axis_color = Color(*theme.getColor("button_disable").getRgb())
        self._shader.setUniformValue("u_color", self._disabled_axis_color)
        self._scene.sceneChanged.emit(self)


    def setLightAxis(self) -> None:
        self._shader.setUniformValue("u_disabledMultiplier", 1.0 )
        self._scene.sceneChanged.emit(self)

    def setDislightAxis(self) -> None:
        self._shader.setUniformValue("u_disabledMultiplier", 1.0 )
        self._scene.sceneChanged.emit(self)

    def _onGlobalContainerStackChanged(self):
        if self._global_container_stack:
            self.setMeshData(None)

        self._global_container_stack = Application.getInstance().getGlobalContainerStack()
        if self._global_container_stack:
            container = self._global_container_stack.findContainer({ "platform": "*" })
            if container:
                mesh_file = container.getMetaDataEntry("platform")
                try:
                    path = Resources.getPath(Resources.Meshes, mesh_file)
                except FileNotFoundError:
                    Logger.log("w", "Unable to find the platform mesh %s", mesh_file)
                    path = ""

                if self._load_platform_job:
                    # This prevents a previous load job from triggering texture loads.
                    self._load_platform_job.finished.disconnect(self._onPlatformLoaded)

                # Perform platform mesh loading in the background
                self._load_platform_job = _LoadPlatformJob(path)
                self._load_platform_job.finished.connect(self._onPlatformLoaded)
                self._load_platform_job.start()

                # path = r"G:\QIDIWrite\QIDI\build\package\resources\meshes\tubiao.STL"
                # self._load_platform_job2 = _LoadPlatformJob(path)
                # self._load_platform_job2.finished.connect(self._onPlatformLoaded2)
                # self._load_platform_job2.start()

                offset = container.getMetaDataEntry("flat_button_offset")
                if offset:
                    if len(offset) == 3:
                        self.setPosition(Vector(offset[0], offset[1], offset[2]))
                    else:
                        Logger.log("w", "Platform offset is invalid: %s", str(offset))
                        self.setPosition(Vector(0.0, 0.0, 0.0))
                else:
                    self.setPosition(Vector(0.0, 0.0, 0.0))




    def _updateTexture(self):
        if not self._global_container_stack or not OpenGL.getInstance():
            return
        
        self._texture = OpenGL.getInstance().createTexture()
        container = self._global_container_stack.findContainer({"platform_texture": "*"})
        if container:
            texture_file = container.getMetaDataEntry("platform_texture")
            try:
                self._texture.load(Resources.getPath(Resources.Images, texture_file))
            except FileNotFoundError:
                Logger.log("w", "Unable to find platform texture [%s] as specified in the definition", texture_file)
        # Note: if no texture file is specified, a 1 x 1 pixel transparent image is created
        # by QD.GL.QtTexture to prevent rendering issues

        if self._shader:
            self._shader.setTexture(0, self._texture)

    def _onPlatformLoaded(self, job):
        self._load_platform_job = None

        if not job.getResult():
            self.setMeshData(None)
            return

        node = job.getResult()
        if isinstance(node, list):  # Some model readers return lists of models. Some (e.g. STL) return a list SOMETIMES but not always.
            nodelist = [actual_node for subnode in node for actual_node in DepthFirstIterator(subnode) if actual_node.getMeshData()]
            node = max(nodelist, key = lambda n: n.getMeshData().getFaceCount())  # Select the node with the most faces. Sometimes the actual node is a child node of something. We can only have one node as platform mesh.
        if node.getMeshData():
            # self.setMeshData(node.getMeshData())
            path = Resources.getPath(Resources.Meshes, "flat.STL")

            reader = self._mesh_handler.getReaderForFile(path)
            self.setMeshData(reader.read(path).getMeshData())

            # Calling later because for some reason the OpenGL context might be outdated on some computers.
            Application.getInstance().callLater(self._updateTexture)




class _LoadPlatformJob(Job):
    """Protected class that ensures that the mesh for the machine platform is loaded."""

    def __init__(self, file_name):
        super().__init__()
        self._file_name = file_name
        self._mesh_handler = Application.getInstance().getMeshFileHandler()

    def run(self):
        reader = self._mesh_handler.getReaderForFile(self._file_name)
        if not reader:
            self.setResult(None)
            return
        self.setResult(reader.read(self._file_name))
        # self._file_name = "G:\QIDIWrite\QIDI\build\package\resources\meshes\tubiao.STL"
        # self.setResult(reader.read(self._file_name))
