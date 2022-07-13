import numpy
import math
from PyQt5.QtCore import QObject

from UM.Application import Application
from UM.Logger import Logger
from UM.Math.AxisAlignedBox import AxisAlignedBox
from UM.Math.Polygon import Polygon
from UM.Math.Vector import Vector
from UM.Mesh.MeshBuilder import MeshBuilder
from UM.Operations.AddSceneNodeOperation import AddSceneNodeOperation
from UM.Operations.GroupedOperation import GroupedOperation
from UM.Operations.RemoveSceneNodeOperation import RemoveSceneNodeOperation
from UM.Scene.Iterator.DepthFirstIterator import DepthFirstIterator
from UM.Scene.GroupDecorator import GroupDecorator
from UM.Settings.SettingInstance import SettingInstance

from cura.Operations.SetParentOperation import SetParentOperation
from cura.Scene.BuildPlateDecorator import BuildPlateDecorator
from cura.Scene.ConvexHullDecorator import ConvexHullDecorator
from cura.Scene.CuraSceneNode import CuraSceneNode
from cura.Scene.SliceableObjectDecorator import SliceableObjectDecorator
from cura.Settings.ExtruderManager import ExtruderManager


class OozePrevention(QObject):
    def __init__(self):
        super().__init__()
        self._scene = Application.getInstance().getController().getScene()
        self._active_build_plate = Application.getInstance().getMultiBuildPlateModel().activeBuildPlate
        self._stack = Application.getInstance().getGlobalContainerStack()
        self._scene_bounding_box = AxisAlignedBox.Null
        self._wall_bounding_box = AxisAlignedBox.Null

    def oozePrevention(self):
        self.removeOldOozePreventionNode()
        used_extruder_count = len(Application.getInstance().getExtruderManager().getUsedExtruderStacks())
        if used_extruder_count > 1:
            self.scennBoundingBox()
            if self._stack.getProperty("ooze_wall_enabled", "value"):
                Logger.log("d", "Start add Ooze Shield.")
                self.addOozeWall()
            self.setTowerXY()
            if self._stack.getProperty("extruder_tower_enable", "value"):
                Logger.log("d", "Start add Prime Tower.")
                self.addExtruderTower()

    def removeOldOozePreventionNode(self):
        for node in DepthFirstIterator(self._scene.getRoot()):
            if node.getName() == "Prime Tower" or node.getName() == "Ooze Shield":
                op = RemoveSceneNodeOperation(node)
                op.push()
                Logger.log("d", "Remove old Ooze Prevention Node sucess, then add a new.")

    def scennBoundingBox(self):
        scene_bounding_box = None
        for node in DepthFirstIterator(self._scene.getRoot()):
            if (
                not issubclass(type(node), CuraSceneNode) or
                (not node.getMeshData() and not node.callDecoration("getLayerData")) or
                (node.callDecoration("getBuildPlateNumber") != self._active_build_plate)):

                continue

            if not scene_bounding_box:
                scene_bounding_box = node.getBoundingBox()
            else:
                other_bb = node.getBoundingBox()
                if other_bb is not None:
                    scene_bounding_box = scene_bounding_box + node.getBoundingBox()

        if scene_bounding_box:
            self._scene_bounding_box = scene_bounding_box

    def addOozeWall(self):
        if self._stack.getProperty("ooze_prevention_height", "value") == 999:
            wall_h = self._scene_bounding_box.maximum.y
        else:
            wall_h = self._stack.getProperty("ooze_prevention_height", "value")

        points = numpy.zeros((0, 2), dtype = numpy.int32)
        for node in DepthFirstIterator(self._scene.getRoot()):
            if (
                not issubclass(type(node), CuraSceneNode) or
                (not node.getMeshData() and not node.callDecoration("getLayerData")) or
                (node.callDecoration("getBuildPlateNumber") != self._active_build_plate)):

                continue

            node_hull = node.callDecoration("_compute2DConvexHull")
            if node_hull:
                try:
                    points = numpy.append(points, node_hull.getPoints(), axis = 0)
                except ValueError:
                    pass

            if points.size < 3:
                return None

        convex_hull = Polygon(points).getConvexHull()
        wall_distance = self._stack.getProperty("ooze_wall_dist", "value")
        wall_thickness = self._stack.getProperty("wall_line_width", "value") * self._stack.getProperty("ooze_wall_line_count", "value") * 2
        wall_inner_points = convex_hull.getMinkowskiHull(Polygon.approximatedCircle(wall_distance)).getPoints()
        wall_outer_points = convex_hull.getMinkowskiHull(Polygon.approximatedCircle(wall_distance + wall_thickness)).getPoints()

        wall_node = CuraSceneNode()
        group_decorator = GroupDecorator()
        wall_node.addDecorator(group_decorator)
        wall_node.addDecorator(SliceableObjectDecorator())
        wall_node.addDecorator(ConvexHullDecorator())
        wall_node.addDecorator(BuildPlateDecorator(self._active_build_plate))
        wall_node.setParent(self._scene.getRoot())
        wall_node.setSelectable(True)
        wall_node.setPosition(Vector(0, 0, 0))
        wall_node.setName("Ooze Shield")

        wall_node_1 = self.addWall(wall_node, wall_outer_points, wall_inner_points, wall_h)
        wall_node_1.setName("Ooze Shield 1")
        self.settingDefinition(wall_node_1, "top_layers", 0)
        self.settingDefinition(wall_node_1, "bottom_layers", 0)
        self.settingDefinition(wall_node_1, "fill_perimeter_gaps", "nowhere")
        self.settingDefinition(wall_node_1, "infill_sparse_density", 0)
        self.settingDefinition(wall_node_1, "wall_line_count", math.ceil(self._stack.getProperty("ooze_wall_line_count", "value")/2))
        self.settingDefinition(wall_node_1, "speed_print", Application.getInstance().getExtruderManager().getExtruderStack(0).getProperty("speed_print", "value")*1.5)
        self.settingDefinition(wall_node_1, "meshfix_union_all_remove_holes", False)

        wall_node_2 = self.addWall(wall_node, wall_outer_points, wall_inner_points, wall_h)
        wall_node_2.setName("Ooze Shield 2")
        self.settingDefinition(wall_node_2, "infill_mesh", True)
        self.settingDefinition(wall_node_2, "top_layers", 0)
        self.settingDefinition(wall_node_2, "bottom_layers", 0)
        self.settingDefinition(wall_node_2, "fill_perimeter_gaps", "nowhere")
        self.settingDefinition(wall_node_2, "infill_sparse_density", 0)
        self.settingDefinition(wall_node_2, "wall_line_count", math.floor(self._stack.getProperty("ooze_wall_line_count", "value")/2))
        self.settingDefinition(wall_node_2, "speed_print", Application.getInstance().getExtruderManager().getExtruderStack(1).getProperty("speed_print", "value")*1.5)
        self.settingDefinition(wall_node_2, "meshfix_union_all_remove_holes", False)
        self.setExtruder(wall_node_2, 1)

        self._scene.sceneChanged.emit(wall_node)

        self._wall_bounding_box = wall_node.getBoundingBox()

    def addWall(self, parent: CuraSceneNode, outer_points, inner_points, height = 10):
        node = CuraSceneNode()
        node.setSelectable(True)
        mesh = MeshBuilder()
        self.addConcentricFace(mesh, outer_points, inner_points, height, False)
        self.addConcentricFace(mesh, outer_points, inner_points, 0, True)
        self.addSideFace(mesh, outer_points, height, 0)
        self.addSideFace(mesh, inner_points, 0, height)
        mesh.calculateNormals()
        node.setMeshData(mesh.build())
        node.addDecorator(BuildPlateDecorator(self._active_build_plate))
        node.addDecorator(SliceableObjectDecorator())
        node.addDecorator(ConvexHullDecorator())
        op = GroupedOperation()
        op.addOperation(AddSceneNodeOperation(node, self._scene.getRoot()))
        op.addOperation(SetParentOperation(node, parent))
        op.push()

        self._scene.sceneChanged.emit(node)
        return node

    def addConcentricFace(self, mesh, outer_points, inner_points, height, reverse = False, color=None):
        number = 0
        for i in range(len(outer_points)):
            vec_o = outer_points[0] - outer_points[-1]
            vec_o = vec_o / numpy.linalg.norm(vec_o)
            vec_i = inner_points[i] - inner_points[i-1]
            vec_i = vec_i / numpy.linalg.norm(vec_i)
            vec_dot = vec_o.dot(vec_i)
            if vec_dot >= 1.0 - 1e-6:
                number = i
                break
        inner_points = numpy.append(inner_points[number:], inner_points[:number], axis = 0)
        for idx in range(len(outer_points)):
            v0 = Vector(inner_points[idx-1][0], height, inner_points[idx-1][1])
            v1 = Vector(inner_points[idx][0], height, inner_points[idx][1])
            v2 = Vector(outer_points[idx][0], height, outer_points[idx][1])
            v3 = Vector(outer_points[idx-1][0], height, outer_points[idx-1][1])
            normal = (v1 - v0).cross(v2 - v0)
            if reverse:
                mesh.addQuad(v3, v2, v1, v0, color = color, normal = normal)
            else:
                mesh.addQuad(v0, v1, v2, v3, color = color, normal = normal)

    def addSideFace(self, mesh, xy_points, y0, y1, color=None):
        for idx in range(len(xy_points)):
            point0 = xy_points[idx-1]
            point1 = xy_points[idx]
            v0 = Vector(point0[0], y0, point0[1])
            v1 = Vector(point1[0], y0, point1[1])
            v2 = Vector(point1[0], y1, point1[1])
            v3 = Vector(point0[0], y1, point0[1])
            normal = (v1 - v0).cross(v2 - v0)
            mesh.addQuad(v0, v1, v2, v3, color = color, normal = normal)

    def setTowerXY(self):
        machine_width = self._stack.getProperty("machine_width", "value")
        machine_depth = self._stack.getProperty("machine_depth", "value")
        tower_radius = self._stack.getProperty("extruder_tower_size", "value")/2
        if self._stack.getProperty("extruder_tower_position_auto", "value"):
            tower_x = 0
            if self._stack.getProperty("ooze_wall_enabled", "value"):
                tower_y = self._wall_bounding_box.maximum.z + self._stack.getProperty("extruder_tower_size", "value")/2 + 5
            else:
                tower_y = self._scene_bounding_box.maximum.z + self._stack.getProperty("extruder_tower_size", "value")/2 + 5
            if tower_y >= machine_depth/2 - 25:
                tower_y = machine_depth/2 - 25
                tower_area_points = [[-tower_radius, tower_radius], [tower_radius, tower_radius], [tower_radius, -tower_radius], [-tower_radius, -tower_radius]]
                tower_area = Polygon(points = numpy.array(tower_area_points, numpy.float32))
                while True:
                    set_position_x = False
                    for node in DepthFirstIterator(self._scene.getRoot()):
                        if node.callDecoration("isSliceable"):
                            target_area = tower_area.translate(tower_x, tower_y)
                            if node.collidesWithArea([target_area]):
                                if tower_x <= 50 - machine_width/2:
                                    tower_x += machine_width/2
                                elif 50 - machine_width/2 < tower_x <= 0:
                                    tower_x -= 25
                                elif 0 < tower_x <= machine_width/2 - 50:
                                    tower_x += 25
                                else:
                                    Logger.log("d", "Can not set prime tower.")
                                    set_position_x = False
                                    break
                                set_position_x = True
                                break
                    if not set_position_x:
                        break
            self._stack.setProperty("extruder_tower_position_x", "value", tower_x)
            self._stack.setProperty("extruder_tower_position_y", "value", tower_y)

    def addExtruderTower(self):
        tower_size = self._stack.getProperty("extruder_tower_size", "value")

        if self._stack.getProperty("ooze_prevention_height", "value") == 999:
            tower_h = self._scene_bounding_box.maximum.y
        else:
            tower_h = self._stack.getProperty("ooze_prevention_height", "value")

        tower_position = Vector(self._stack.getProperty("extruder_tower_position_x", "value"), 0, self._stack.getProperty("extruder_tower_position_y", "value"))

        tower_node = CuraSceneNode()
        group_decorator = GroupDecorator()
        tower_node.addDecorator(group_decorator)
        tower_node.addDecorator(SliceableObjectDecorator())
        tower_node.addDecorator(ConvexHullDecorator())
        tower_node.addDecorator(BuildPlateDecorator(self._active_build_plate))
        tower_node.setParent(self._scene.getRoot())
        tower_node.setSelectable(True)
        tower_node.setPosition(tower_position)
        tower_node.setCenterPosition(tower_position)
        tower_node.setName("Prime Tower")

        tower_node_1 = self.addTower(tower_node, tower_position, tower_size, tower_h)
        tower_node_1.setName("Prime Tower 1")
        self.settingDefinition(tower_node_1, "top_layers", 0)
        self.settingDefinition(tower_node_1, "bottom_layers", 0)
        self.settingDefinition(tower_node_1, "wall_line_count", self._stack.getProperty("extruder_tower_line_count", "value"))
        
        tower_node_2 = self.addTower(tower_node, tower_position, tower_size, tower_h)
        tower_node_2.setName("Prime Tower 2")
        self.settingDefinition(tower_node_2, "infill_mesh", True)
        self.settingDefinition(tower_node_2, "top_layers", 0)
        self.settingDefinition(tower_node_2, "bottom_layers", 3)
        self.settingDefinition(tower_node_2, "infill_sparse_density", 0)
        self.settingDefinition(tower_node_2, "wall_line_count", self._stack.getProperty("extruder_tower_line_count", "value"))
        self.setExtruder(tower_node_2, 1)
        
        self._scene.sceneChanged.emit(tower_node)
        Logger.log("d", "Add InfillTower sucess.")

    def addTower(self, parent: CuraSceneNode, position: Vector, size = 20, height = 10):
        node = CuraSceneNode()
        node.setSelectable(True)
        mesh = MeshBuilder()
        mesh.createCube(
            verts = [
            [-size/2, 0, size/2],
            [-size/2, height, size/2],
            [size/2, height, size/2],
            [size/2, 0, size/2],
            [-size/2, 0, -size/2],
            [-size/2, height, -size/2],
            [size/2, height, -size/2],
            [size/2, 0, -size/2]
        ]
        )
        mesh.calculateNormals()
        node.setMeshData(mesh.build())
        node.addDecorator(BuildPlateDecorator(self._active_build_plate))
        node.addDecorator(SliceableObjectDecorator())
        node.addDecorator(ConvexHullDecorator())
        op = GroupedOperation()
        op.addOperation(AddSceneNodeOperation(node, self._scene.getRoot()))
        op.addOperation(SetParentOperation(node, parent))
        op.push()
        node.setPosition(position, CuraSceneNode.TransformSpace.World)

        self._scene.sceneChanged.emit(node)
        return node

    def settingDefinition(self, node: CuraSceneNode, definitionName: str, value):
        stack = node.callDecoration("getStack")
        settings = stack.getTop()
        definition = stack.getSettingDefinition(definitionName)
        new_instance = SettingInstance(definition, settings)
        new_instance.setProperty("value", value)
        new_instance.resetState()  # Ensure that the state is not seen as a user state.
        settings.addInstance(new_instance)

    def setExtruder(self, node: CuraSceneNode, position: 0):
        extruder_id = ExtruderManager.getInstance().getActiveExtruderStacks()[position].getId()
        node.callDecoration("setActiveExtruder", extruder_id)
