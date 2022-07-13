# Copyright (c) 2018 Lokster <http://lokspace.eu>
# Based on the SupportBlocker plugin by Ultimaker B.V., and licensed under LGPLv3 or higher.

from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtWidgets import QApplication

from UM.Application import Application
from UM.Math.Vector import Vector
from UM.Tool import Tool
from UM.Event import Event, MouseEvent
from UM.Mesh.MeshBuilder import MeshBuilder
from UM.Scene.Selection import Selection

from cura.CuraApplication import CuraApplication
from cura.Scene.CuraSceneNode import CuraSceneNode
from cura.PickingPass import PickingPass

from UM.Operations.GroupedOperation import GroupedOperation
from UM.Operations.AddSceneNodeOperation import AddSceneNodeOperation
from UM.Operations.RemoveSceneNodeOperation import RemoveSceneNodeOperation
from cura.Operations.SetParentOperation import SetParentOperation

from cura.Scene.SliceableObjectDecorator import SliceableObjectDecorator
from cura.Scene.BuildPlateDecorator import BuildPlateDecorator

from UM.Settings.SettingInstance import SettingInstance

import numpy

from UM.Logger import Logger
import math

class CustomSupports(Tool):
    def __init__(self):
        super().__init__()
        self._shortcut_key = Qt.Key_C
        self._controller = self.getController()

        self._selection_pass = None
        CuraApplication.getInstance().globalContainerStackChanged.connect(self._updateEnabled)

        # Note: if the selection is cleared with this tool active, there is no way to switch to
        # another tool than to reselect an object (by clicking it) because the tool buttons in the
        # toolbar will have been disabled. That is why we need to ignore the first press event
        # after the selection has been cleared.
        Selection.selectionChanged.connect(self._onSelectionChanged)
        self._had_selection = False
        self._skip_press = False

        self._had_selection_timer = QTimer()
        self._had_selection_timer.setInterval(0)
        self._had_selection_timer.setSingleShot(True)
        self._had_selection_timer.timeout.connect(self._selectionChangeDelay)
        
        self._all_picked_node = []
        self._scene = Application.getInstance().getController().getScene()

        self.mesh_data = None
        self.parent_verts = None
        self.parent_faces = None
        self.parent_normals = None
        self.parent_faces_dictionary = None

    def event(self, event):
        super().event(event)
        modifiers = QApplication.keyboardModifiers()
        ctrl_is_active = modifiers & Qt.ControlModifier

        parameterstack = Application.getInstance().getGlobalContainerStack()
        if parameterstack.getProperty("remove_all_support_mesh", "value"):
            self.removeAllSupportMesh()

        if event.type == Event.MousePressEvent and MouseEvent.LeftButton in event.buttons and self._controller.getToolsEnabled():
            if ctrl_is_active:
                self._controller.setActiveTool("TranslateTool")
                return

            if self._skip_press:
                # The selection was previously cleared, do not add/remove an support mesh but
                # use this click for selection and reactivating this tool only.
                self._skip_press = False
                return

            if self._selection_pass is None:
                # The selection renderpass is used to identify objects in the current view
                self._selection_pass = Application.getInstance().getRenderer().getRenderPass("selection")
            picked_node = self._controller.getScene().findObject(self._selection_pass.getIdAtPosition(event.x, event.y))

            if not picked_node:
                # There is no slicable object at the picked location
                return

            node_stack = picked_node.callDecoration("getStack")
            if node_stack:
                if node_stack.getProperty("support_mesh", "value"):
                    self._removeSupportMesh(picked_node)
                    return

                elif node_stack.getProperty("anti_overhang_mesh", "value") or node_stack.getProperty("infill_mesh", "value") or node_stack.getProperty("cutting_mesh", "value"):
                    # Only "normal" meshes can have support_mesh added to them
                    return

            if self.parent_verts is None:
                self.getNodeInformation(picked_node)
            else:
                try:
                    node_no_change = (self.parent_verts == picked_node.getMeshDataTransformedVertices()).all()
                except:
                    node_no_change = self.parent_verts == picked_node.getMeshDataTransformedVertices()
                if node_no_change == False:
                    self.getNodeInformation(picked_node)

            # Create a pass for picking a world-space location from the mouse location
            active_camera = self._controller.getScene().getActiveCamera()
            picking_pass = PickingPass(active_camera.getViewportWidth(), active_camera.getViewportHeight())
            picking_pass.render()

            picked_position = picking_pass.getPickedPosition(event.x, event.y)
            Logger.log("d", picked_position)

            # Add the support_mesh cube at the picked location
            self._createSupportMesh(picked_node, picked_position)

    def _createSupportMesh(self, parent: CuraSceneNode, position: Vector):
        node = CuraSceneNode()
###########获取支撑柱尺寸
        parameterstack = Application.getInstance().getGlobalContainerStack()
        cubesize = parameterstack.getProperty("support_pillar_resolution", "value")
        parameterstack.setProperty("remove_all_support_mesh", "value", False)
###########
        node.setName("CustomSupport")
        node.setSelectable(True)
        mesh = self._createCube(cubesize, position, parent)
        if mesh == None:
            return
        node.setMeshData(mesh.build())

        active_build_plate = CuraApplication.getInstance().getMultiBuildPlateModel().activeBuildPlate
        node.addDecorator(BuildPlateDecorator(active_build_plate))
        node.addDecorator(SliceableObjectDecorator())

        stack = node.callDecoration("getStack") # created by SettingOverrideDecorator that is automatically added to CuraSceneNode
        settings = stack.getTop()

        definition = stack.getSettingDefinition("support_mesh")
        new_instance = SettingInstance(definition, settings)
        new_instance.setProperty("value", True)
        new_instance.resetState()  # Ensure that the state is not seen as a user state.
        settings.addInstance(new_instance)

        op = GroupedOperation()
        # First add node to the scene at the correct position/scale, before parenting, so the support mesh does not get scaled with the parent
        op.addOperation(AddSceneNodeOperation(node, self._controller.getScene().getRoot()))
        op.addOperation(SetParentOperation(node, parent))
        op.push()
        node.setPosition(position, CuraSceneNode.TransformSpace.World)
        self._all_picked_node.append(node)

        CuraApplication.getInstance().getController().getScene().sceneChanged.emit(node)

    def _removeSupportMesh(self, node: CuraSceneNode):
        parent = node.getParent()
        if parent == self._controller.getScene().getRoot():
            parent = None

        op = RemoveSceneNodeOperation(node)
        op.push()

        if parent and not Selection.isSelected(parent):
            Selection.add(parent)

        CuraApplication.getInstance().getController().getScene().sceneChanged.emit(node)

    def _updateEnabled(self):
        plugin_enabled = False

        global_container_stack = CuraApplication.getInstance().getGlobalContainerStack()
        if global_container_stack:
            plugin_enabled = global_container_stack.getProperty("support_mesh", "enabled")

        CuraApplication.getInstance().getController().toolEnabledChanged.emit(self._plugin_id, plugin_enabled)

    def _onSelectionChanged(self):
        # When selection is passed from one object to another object, first the selection is cleared
        # and then it is set to the new object. We are only interested in the change from no selection
        # to a selection or vice-versa, not in a change from one object to another. A timer is used to
        # "merge" a possible clear/select action in a single frame
        if Selection.hasSelection() != self._had_selection:
            self._had_selection_timer.start()

    def _selectionChangeDelay(self):
        has_selection = Selection.hasSelection()
        if not has_selection and self._had_selection:
            self._skip_press = True
        else:
            self._skip_press = False

        self._had_selection = has_selection

    def _createCube(self, size, position, parent):
        mesh = MeshBuilder()

        p1 = numpy.array([position.x, position.y, position.z])

        position_normal = self.getPositionNormal(p1)
        if position_normal[1] > -0.001:
            return None

        intersection_points_y = self.getIntersectionY(p1 * (1, 0, 1), p1)

        if intersection_points_y == []:
            h = position.y
        else:
            h = position.y - max(intersection_points_y)

        mesh.addCube(size, h, size, Vector(0, -h/2, 0))
        mesh.calculateNormals()
        return mesh

    def getIntersectionY(self, p0, p1):
        intersection_points_y = []
        X_count = math.floor(p1[0] / 3)
        facesList = self.parent_faces_dictionary[str(X_count)]
        for face in facesList:
            face_count = int(face[0] / 3)
            if self.parent_normals[3 * face_count][1] > 0.001:
                intersection = self.lineTriangleIntersection(p0, p1, self.parent_verts[face[0]], self.parent_verts[face[1]], self.parent_verts[face[2]])
                if intersection:
                    point = self.point_of_line_plane(p0, p1, self.parent_verts[face[0]], self.parent_normals[3*face_count])
                    if point[1] < p1[1]:
                        intersection_points_y.append(point[1])
        return intersection_points_y

    def getPositionNormal(self, p1):
        distance_p = []
        face_count_list = []
        X_count = math.floor(p1[0] / 3)
        facesList = self.parent_faces_dictionary[str(X_count)]
        for face in facesList:
            face_count = int(face[0] / 3)
            d_p = abs(numpy.dot((p1 - self.parent_verts[face[0]]), self.parent_normals[3*face_count]))
            if d_p < 0.35:
                intersection_p = self.lineTriangleIntersection(p1 + self.parent_normals[3*face_count], p1, self.parent_verts[face[0]], self.parent_verts[face[1]], self.parent_verts[face[2]])
                if intersection_p:
                    distance_p.append(d_p)
                    face_count_list.append(face_count)
        if distance_p == []:
            return [0, 0, 0]
        position_normal = self.parent_normals[3 * face_count_list[distance_p.index(min(distance_p))]]
        return position_normal

    def point_of_line_plane(self, vert1, vert2, plane_orig, plane_n):
        d = numpy.dot((numpy.array([0, 0, 0]) - plane_orig), plane_n)
        P1D = (numpy.vdot(vert1, plane_n) + d)
        P1D2 = (numpy.vdot(vert2 - vert1, plane_n))
        n = - P1D / P1D2
        p = vert1 + n * (vert2 - vert1)
        return p

    def lineTriangleIntersection(self, a ,b, v0, v1, v2):
        e1 = self.plucker(v1, v0)
        e2 = self.plucker(v2, v1)
        e3 = self.plucker(v0, v2)
        L = self.plucker(a, b)

        s1 = self.sideOp(L, e1)
        s2 = self.sideOp(L, e2)
        s3 = self.sideOp(L, e3)

        if (s1>0 and s2>0 and s3>0) or (s1<0 and s2<0 and s3<0):
            return True
        elif (s1 == 0 and s2*s3>0) or (s2 == 0 and s1*s3>0) or (s3 == 0 and s1*s2>0):
            return True
        elif (s1 == 0 and (s2 == 0)) or (s1 == 0 and (s3 == 0)) or (s2 == 0 and (s3 == 0)):
            return True
        else:
            return False

    def plucker(self, a, b):
        l0 = a[0] * b[1] - b[0] * a[1]
        l1 = a[0] * b[2] - b[0] * a[2]
        l2 = a[0] - b[0]
        l3 = a[1] * b[2] - b[1] * a[2]
        l4 = a[2] - b[2]
        l5 = b[1] - a[1]
        return [l0, l1, l2, l3, l4, l5]

    def sideOp(self, a, b):
        res = a[0] * b[4] + a[1] * b[5] + a[2] * b[3] + a[3] * b[2] + a[4] * b[0] + a[5] * b[1]
        return res

######清除所有支撑
    def removeAllSupportMesh(self):
        for node in self._all_picked_node:
            node_stack = node.callDecoration("getStack")
            if node_stack.getProperty("support_mesh", "value"):
                self._removeSupportMesh(node)

    #将模型的面根据x坐标进行分块
    def getNodeInformation(self, picked_node):
        self.parent_verts = picked_node.getMeshDataTransformedVertices()
        self.mesh_data = picked_node.getMeshData()
        self.parent_faces = self.mesh_data.getIndices()
        if self.parent_faces is None:
            self.parent_faces = numpy.arange(self.mesh_data.getVertexCount()).reshape(-1, 3)
        self.parent_normals = picked_node.getMeshDataTransformedNormals()
        
        self.parent_faces_dictionary = {}
        boundingBox = picked_node.getBoundingBox()
        minX = boundingBox.left
        maxX = boundingBox.right
        min_Xcount = math.floor(minX/3)
        max_Xcount = math.ceil(maxX/3)
        for i in range(min_Xcount, max_Xcount, 1):
            self.parent_faces_dictionary[str(i)] = []
        
        for face in self.parent_faces:
            listX = []
            listX.append(self.parent_verts[face[0]][0])
            listX.append(self.parent_verts[face[1]][0])
            listX.append(self.parent_verts[face[2]][0])
            min_face_Xcount = math.floor(min(listX)/3)
            max_face_Xcount = math.ceil(max(listX)/3)
            for j in range(min_face_Xcount, max_face_Xcount, 1):
                self.parent_faces_dictionary[str(j)].append(face)
