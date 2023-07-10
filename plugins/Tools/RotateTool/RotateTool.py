# Copyright (c) 2020 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from typing import Optional

from PyQt5.QtCore import Qt
from QD.Logger import Logger
from QD.Event import Event, MouseEvent, KeyEvent
from QD.Job import Job
from QD.Math.Plane import Plane
from QD.Math.Quaternion import Quaternion
from QD.Math.Vector import Vector
from QD.Math.Float import Float
from QD.Message import Message
from QD.Operations.GravityOperation import GravityOperation
from QD.Operations.GroupedOperation import GroupedOperation
from QD.Operations.LayFlatOperation import LayFlatOperation
from QD.Operations.RotateOperation import RotateOperation
from QD.Operations.SetTransformOperation import SetTransformOperation
from QD.Scene.SceneNode import SceneNode
from QD.Scene.Selection import Selection
from QD.Scene.ToolHandle import ToolHandle
from QD.Tool import Tool
from QD.Version import Version
from QD.View.GL.OpenGL import OpenGL

try:
    from . import RotateToolHandle
except (ImportError, SystemError):
    import RotateToolHandle  # type: ignore  # This fixes the tests not being able to import.

import math
import time

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")

class RotateTool(Tool):
    """Provides the tool to rotate meshes and groups

    The tool exposes a ToolHint to show the rotation angle of the current operation
    """

    def __init__(self):
        super().__init__()
        self._handle = RotateToolHandle.RotateToolHandle()

        self._snap_rotation = True
        self._snap_angle = math.radians(15)

        self._angle = None
        self._angle_update_time = None

        self._shortcut_key = Qt.Key_R
        self._dirction = ''
        self._progress_message = None
        self._iterations = 0
        self._total_iterations = 0
        self._rotating = False
        self.setExposedProperties("ToolHint", "RotationSnap", "RotationSnapAngle", "SelectFaceSupported", "SelectFaceToLayFlatMode", "RotateX", "RotateY", "RotateZ")
        self._saved_node_positions = []

        self._active_widget = None  # type: Optional[RotateToolHandle.ExtraWidgets]
        self._widget_click_start = 0

        self._select_face_mode = False
        Selection.selectedFaceChanged.connect(self._onSelectedFaceChanged)
    def getRotateX(self) -> float:
        if Selection.hasSelection():
            if self._angle and self.getLockedAxis() == ToolHandle.XAxis:
                for node in self._getSelectedObjectsWithoutSelectedAncestors():
                    tem_angle = float(node.getAngle().x+math.degrees(self._angle)) 
                    return (tem_angle/abs(tem_angle) * (abs(tem_angle)% 360)) if tem_angle  != 0.0 else 0.0 
            else:
                for node in self._getSelectedObjectsWithoutSelectedAncestors():
                    return (float(node.getAngle().x)/abs(float(node.getAngle().x)) * (abs(float(node.getAngle().x))% 360)) if float(node.getAngle().x)  != 0.0 else 0.0 
        return 0.0

    def getRotateY(self) -> float:
        if Selection.hasSelection():
            if self._angle and self.getLockedAxis() == ToolHandle.YAxis:
                for node in self._getSelectedObjectsWithoutSelectedAncestors():
                    tem_angle = float(node.getAngle().y + math.degrees(self._angle))
                    return (tem_angle/abs(tem_angle) * (abs(tem_angle)% 360)) if tem_angle  != 0.0 else 0.0 
            else:
                for node in self._getSelectedObjectsWithoutSelectedAncestors():
                    return (float(node.getAngle().y)/abs(float(node.getAngle().y)) * (abs(float(node.getAngle().y))% 360)) if float(node.getAngle().y)  != 0.0 else 0.0 
        return 0.0

    def getRotateZ(self) -> float:
        if Selection.hasSelection():
            if self._angle and self.getLockedAxis() == ToolHandle.ZAxis:
                for node in self._getSelectedObjectsWithoutSelectedAncestors():
                    tem_angle = float(node.getAngle().z+math.degrees(self._angle))
                    return (tem_angle/abs(tem_angle) * (abs(tem_angle)% 360)) if tem_angle  != 0.0 else 0.0 
            else:
                for node in self._getSelectedObjectsWithoutSelectedAncestors():
                    return (float(node.getAngle().z)/abs(float(node.getAngle().z)) * (abs(float(node.getAngle().z))% 360)) if float(node.getAngle().z)  != 0.0 else 0.0 
        return 0.0

    @staticmethod
    def _parseFloat(str_value: str) -> float:
        try:
            parsed_value = float(str_value)
        except ValueError:
            parsed_value = float(0)
        return parsed_value

    def setRotateX(self, xangle: str) -> None:
        parsed_x = self._parseFloat(xangle)
        new_time = time.monotonic()
        if not self._angle_update_time or new_time - self._angle_update_time > 0.1:
            self._angle_update_time = new_time
            self.propertyChanged.emit()
            rotation = Quaternion()
            selected_nodes = self._getSelectedObjectsWithoutSelectedAncestors()
            for node in self._getSelectedObjectsWithoutSelectedAncestors():
                if parsed_x!=math.degrees(node.getAngle().x):
                    if len(selected_nodes) > 1:
                        #这里是选中多个模型的时候执行的
                        #这里是根据对应x方向数值变动旋转对应变动的角度
                        #所以这里会出现一个问题就是会被x、y、z变动的顺序影响
                        #随着x、y、z变动的顺序不同最后呈现的结果不同
                        #所以可能出现你改动过后x，y，z输入0不能够恢复到最开始的情况
                        #只能够通过重置按钮恢复
                        op = GroupedOperation()
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            rotation = Quaternion.fromAngleAxis(math.radians((parsed_x- node.getAngle().x)),
                                                        Vector.Unit_X)
                            node.setAngle(Vector(parsed_x,node.getAngle().y,node.getAngle().z))
                            op.addOperation(RotateOperation(node, rotation, rotate_around_point=node.getPosition()))
                        op.push()
                    else:
                        #这里是选中单个模型的时候执行的
                        #这里是每次数值变动后先重置，然后按x，y，z顺序转动对应的角度
                        #好处是不管你输入x、y、z的顺序最后结果是相同的。
                        #你改动过后x，y，z输入0一定能恢复到最开始的情况
                        #但是你手动旋转还是会收到x、y、z顺序的影响
                        #所以如果输入旋转和手动旋转掺杂的最后呈现的结果也还是会不同
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            Selection.applyOperation(SetTransformOperation, None, Quaternion(), None)
                            rotation = Quaternion.fromAngleAxis(math.radians(parsed_x ),
                                                        Vector.Unit_X)
                            node.setAngle(Vector(parsed_x,node.getAngle().y,node.getAngle().z))
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                            rotation = Quaternion.fromAngleAxis(math.radians(node.getAngle().y), Vector.Unit_Y)
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                            rotation = Quaternion.fromAngleAxis(math.radians(node.getAngle().z), Vector.Unit_Z)
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                    self.propertyChanged.emit()

    def setRotateY(self, yangle: str) -> None:
        parsed_y = self._parseFloat(yangle)
        new_time = time.monotonic()
        if not self._angle_update_time or new_time - self._angle_update_time > 0.1:
            self._angle_update_time = new_time
            self.propertyChanged.emit()
            rotation = Quaternion()
            selected_nodes = self._getSelectedObjectsWithoutSelectedAncestors()
            for node in self._getSelectedObjectsWithoutSelectedAncestors():
                if parsed_y!=math.degrees(node.getAngle().y):
                    if len(selected_nodes) > 1:
                        op = GroupedOperation()
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            rotation = Quaternion.fromAngleAxis(math.radians((parsed_y- node.getAngle().y)),
                                                        Vector.Unit_Y)
                            node.setAngle(Vector(node.getAngle().x,parsed_y,node.getAngle().z))
                            op.addOperation(RotateOperation(node, rotation, rotate_around_point=node.getPosition()))
                        op.push()
                    else:
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            Selection.applyOperation(SetTransformOperation, None, Quaternion(), None)
                            rotation = Quaternion.fromAngleAxis(math.radians(node.getAngle().x), Vector.Unit_X)
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                            #rotation = Quaternion.fromAngleAxis(math.radians(parsed_y ),
                            #                            Vector(0,1,0))
                            rotation = Quaternion.fromAngleAxis(math.radians(parsed_y ),
                                                       Vector.Unit_Y)
                            #trantab = str.maketrans("", "", "Q<>=w")
                            #t=str(rotation).translate(trantab)
                            #t1=t.split(',')
                            #Logger.log("d", "rotation = %s", math.degrees(math.atan(float(t1[1])/float(t1[3])))*2)
                            node.setAngle(Vector(node.getAngle().x,parsed_y,node.getAngle().z))
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                            rotation = Quaternion.fromAngleAxis(math.radians(node.getAngle().z), Vector.Unit_Z)
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                    self.propertyChanged.emit()

    def setRotateZ(self, zangle: str) -> None:
        parsed_z = self._parseFloat(zangle)
        new_time = time.monotonic()
        if not self._angle_update_time or new_time - self._angle_update_time > 0.1:
            self._angle_update_time = new_time
            self.propertyChanged.emit()
            rotation = Quaternion()
            selected_nodes = self._getSelectedObjectsWithoutSelectedAncestors()
            for node in self._getSelectedObjectsWithoutSelectedAncestors():
                if parsed_z!=math.degrees(node.getAngle().z):
                    if len(selected_nodes) > 1:
                        op = GroupedOperation()
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            rotation = Quaternion.fromAngleAxis(math.radians((parsed_z- node.getAngle().z)),
                                                        Vector.Unit_Z)
                            node.setAngle(Vector(node.getAngle().x,node.getAngle().y,parsed_z))
                            op.addOperation(RotateOperation(node, rotation, rotate_around_point=node.getPosition()))
                        op.push()
                    else:
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            Selection.applyOperation(SetTransformOperation, None, Quaternion(), None)
                            rotation = Quaternion.fromAngleAxis(math.radians(node.getAngle().x), Vector.Unit_X)
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                            rotation = Quaternion.fromAngleAxis(math.radians(node.getAngle().y), Vector.Unit_Y)
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                            rotation = Quaternion.fromAngleAxis(math.radians(parsed_z ),
                                                        Vector.Unit_Z)
                            node.setAngle(Vector(node.getAngle().x,node.getAngle().y,parsed_z))
                            RotateOperation(node, rotation, rotate_around_point=node.getPosition()).push()
                    self.propertyChanged.emit()

    def event(self, event):
        """Handle mouse and keyboard events

        :param event: type(Event)
        """

        super().event(event)

        if event.type == Event.KeyPressEvent and event.key == KeyEvent.ShiftKey:
            # Snap is toggled when pressing the shift button
            self.setRotationSnap(not self._snap_rotation)

        if event.type == Event.KeyReleaseEvent and event.key == KeyEvent.ShiftKey:
            # Snap is "toggled back" when releasing the shift button
            self.setRotationSnap(not self._snap_rotation)

        if event.type == Event.MousePressEvent and self._controller.getToolsEnabled():
            # Start a rotate operation
            if MouseEvent.LeftButton not in event.buttons:
                return False

            id = self._selection_pass.getIdAtPosition(event.x, event.y)
            if not id:
                return False

            if id in self._handle.getExtraWidgetsColorMap():
                self._active_widget = self._handle.ExtraWidgets(id)
                self._widget_click_start = time.monotonic()
                # Continue as if the picked widget is the appropriate axis
                id = math.floor((self._active_widget.value - self._active_widget.XPositive90.value) / 2) + self._handle.XAxis

            if self._handle.isAxis(id):
                self.setLockedAxis(id)
            else:
                # Not clicked on an axis: do nothing.
                return False

            handle_position = self._handle.getWorldPosition()

            # Save the current positions of the node, as we want to rotate around their current centres
            self._saved_node_positions = []
            for node in self._getSelectedObjectsWithoutSelectedAncestors():
                self._saved_node_positions.append((node, node.getPosition()))

            if id == ToolHandle.XAxis:
                self.setDragPlane(Plane(Vector(1, 0, 0), handle_position.x))
            elif id == ToolHandle.YAxis:
                self.setDragPlane(Plane(Vector(0, 1, 0), handle_position.y))
            elif self._locked_axis == ToolHandle.ZAxis:
                self.setDragPlane(Plane(Vector(0, 0, 1), handle_position.z))
            else:
                self.setDragPlane(Plane(Vector(0, 1, 0), handle_position.y))

            self.setDragStart(event.x, event.y)
            self._rotating = False
            self._angle = 0
            return True

        if event.type == Event.MouseMoveEvent:
            # Perform a rotate operation
            if not self.getDragPlane():
                return False

            if not self.getDragStart():
                self.setDragStart(event.x, event.y)
                if not self.getDragStart(): #May have set it to None.
                    return False

            if not self._rotating:
                self._rotating = True
                self.operationStarted.emit(self)

            handle_position = self._handle.getWorldPosition()

            drag_start = (self.getDragStart() - handle_position).normalized()
            drag_position = self.getDragPosition(event.x, event.y)
            if not drag_position:
                return False
            drag_end = (drag_position - handle_position).normalized()

            try:
                angle = math.acos(drag_start.dot(drag_end))
            except ValueError:
                angle = 0

            if self._snap_rotation:
                angle = int(angle / self._snap_angle) * self._snap_angle
                if angle == 0:
                    return False

            rotation = Quaternion()
            if self.getLockedAxis() == ToolHandle.XAxis:
                direction = 1 if Vector.Unit_X.dot(drag_start.cross(drag_end)) > 0 else -1
                rotation = Quaternion.fromAngleAxis(direction * angle, Vector.Unit_X)
                self._dirction = 'x'
            elif self.getLockedAxis() == ToolHandle.YAxis:
                direction = 1 if Vector.Unit_Y.dot(drag_start.cross(drag_end)) > 0 else -1
                rotation = Quaternion.fromAngleAxis(direction * angle, Vector.Unit_Y)
                self._dirction = 'y'
            elif self.getLockedAxis() == ToolHandle.ZAxis:
                direction = 1 if Vector.Unit_Z.dot(drag_start.cross(drag_end)) > 0 else -1
                rotation = Quaternion.fromAngleAxis(direction * angle, Vector.Unit_Z)
                self._dirction = 'z'
            else:
                direction = -1

            # Rate-limit the angle change notification
            # This is done to prevent the UI from being flooded with property change notifications,
            # which in turn would trigger constant repaints.
            new_time = time.monotonic()
            if not self._angle_update_time or new_time - self._angle_update_time > 0.1:
                self._angle_update_time = new_time
                self._angle += direction * angle
                self._angle = ((self._angle / abs(self._angle) )*(abs(self._angle) % (2*math.pi)  )) if self._angle!= 0.0 else 0.0
                self.propertyChanged.emit()

                # Rotate around the saved centeres of all selected nodes
                if len(self._saved_node_positions) > 1:
                    op = GroupedOperation()
                    for node, position in self._saved_node_positions:
                        op.addOperation(RotateOperation(node, rotation, rotate_around_point = position))
                    op.push()
                else:
                    for node, position in self._saved_node_positions:
                        RotateOperation(node, rotation, rotate_around_point=position).push()

                self.setDragStart(event.x, event.y)
            return True

        if event.type == Event.MouseReleaseEvent:
            if self._active_widget != None and time.monotonic() - self._widget_click_start < 0.2:
                id = self._selection_pass.getIdAtPosition(event.x, event.y)

                if id in self._handle.getExtraWidgetsColorMap() and self._active_widget == self._handle.ExtraWidgets(id):
                    axis = math.floor((self._active_widget.value - self._active_widget.XPositive90.value) / 2)

                    #angle = math.radians(-90 if self._active_widget.value - 2 * axis else 90)
                    angle = math.radians(90 if (self._active_widget.value - ToolHandle.AllAxis) % 2 else -90)
                    axis +=  self._handle.XAxis

                    rotation = Quaternion()
                    if axis == ToolHandle.XAxis:
                        rotation = Quaternion.fromAngleAxis(angle, Vector.Unit_X)
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            node.setAngle(Vector(node.getAngle().x + math.degrees(angle), node.getAngle().y, node.getAngle().z))
                    elif axis == ToolHandle.YAxis:
                        rotation = Quaternion.fromAngleAxis(angle, Vector.Unit_Y)
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            node.setAngle(Vector(node.getAngle().x, node.getAngle().y + math.degrees(angle), node.getAngle().z))
                    else:
                        rotation = Quaternion.fromAngleAxis(angle, Vector.Unit_Z)
                        for node in self._getSelectedObjectsWithoutSelectedAncestors():
                            node.setAngle(Vector(node.getAngle().x, node.getAngle().y, node.getAngle().z + math.degrees(angle)))
                    # Rotate around the saved centeres of all selected nodes
                    if len(self._saved_node_positions) > 1:
                        op = GroupedOperation()
                        for node, position in self._saved_node_positions:
                            op.addOperation(RotateOperation(node, rotation, rotate_around_point = position))
                        op.push()
                    else:
                        for node, position in self._saved_node_positions:
                            RotateOperation(node, rotation, rotate_around_point=position).push()

            self._active_widget = None  # type: Optional[RotateToolHandle.ExtraWidgets]

            # Finish a rotate operation
            if self.getDragPlane():
                self.setDragPlane(None)
                self.setLockedAxis(ToolHandle.NoAxis)
                if self._dirction == 'x':
                    for node in self._getSelectedObjectsWithoutSelectedAncestors():
                        node.setAngle(Vector(node.getAngle().x + math.degrees(self._angle),
                                             node.getAngle().y,
                                             node.getAngle().z))
                elif self._dirction == 'y':
                    for node in self._getSelectedObjectsWithoutSelectedAncestors():
                        node.setAngle(Vector(node.getAngle().x,
                                             node.getAngle().y + math.degrees(self._angle),
                                             node.getAngle().z))
                elif self._dirction == 'z':
                    for node in self._getSelectedObjectsWithoutSelectedAncestors():
                        node.setAngle(Vector(node.getAngle().x,
                                             node.getAngle().y,
                                             node.getAngle().z + math.degrees(self._angle)))
                self._angle = None
                self.propertyChanged.emit()
                if self._rotating:
                    self.operationStopped.emit(self)
                return True

    def _onSelectedFaceChanged(self):
        if not self._select_face_mode:
            self._handle.setEnabled(not Selection.getFaceSelectMode())
            return

        self._handle.setEnabled(not Selection.getFaceSelectMode())

        selected_face = Selection.getSelectedFace()
        if not Selection.getSelectedFace() or not (Selection.hasSelection() and Selection.getFaceSelectMode()):
            return

        original_node, face_id = selected_face
        #Logger.log("e", "face_mid = %s", selected_face)

        meshdata = original_node.getMeshDataTransformed()
        if not meshdata or face_id < 0:
            return
        if face_id > (meshdata.getVertexCount() / 3 if not meshdata.hasIndices() else meshdata.getFaceCount()):
            return
        face_mid, face_normal = meshdata.getFacePlane(face_id)
        object_mid = original_node.getBoundingBox().center
        rotation_point_vector = Vector(object_mid.x, object_mid.y, face_mid[2])
        face_normal_vector = Vector(face_normal[0], face_normal[1], face_normal[2])
        rotation_quaternion = Quaternion.rotationTo(face_normal_vector.normalized(), Vector(0.0, -1.0, 0.0))
        t = str(rotation_quaternion).translate(str.maketrans("", "", "Q<>=w")).split(',')
        Logger.log("d", "x = %s", math.degrees(math.atan(float(t[0]) / float(t[3]))) * 2)
        Logger.log("d", "y = %s", math.degrees(math.atan(float(t[2]) / float(t[3]))) * 2)
        Logger.log("d", "z = %s", math.degrees(math.atan(float(t[1]) / float(t[3]))) * 2)
        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            node.setAngle(Vector(round(node.getAngle().x+float(math.degrees(math.atan(float(t[0]) / float(t[3]))) * 2),2),
                                 round(node.getAngle().y+float(math.degrees(math.atan(float(t[1]) / float(t[3]))) * 2),2),
                                 round(node.getAngle().z+float(math.degrees(math.atan(float(t[2]) / float(t[3]))) * 2),2)))
            #self.setRotateX(node.getAngle().x,"")
            #self.setRotateY(node.getAngle().y,"")
            #self.setRotateZ(node.getAngle().z,"")
            self.propertyChanged.emit()
        operation = GroupedOperation()
        current_node = None  # type: Optional[SceneNode]
        for node in Selection.getAllSelectedObjects():
            current_node = node
            parent_node = current_node.getParent()
            while parent_node and parent_node.callDecoration("isGroup"):
                current_node = parent_node
                parent_node = current_node.getParent()
        if current_node is None:
            return
        rotate_operation = RotateOperation(current_node, rotation_quaternion, rotation_point_vector)
        gravity_operation = GravityOperation(current_node)
        operation.addOperation(rotate_operation)
        operation.addOperation(gravity_operation)
        operation.push()

        # NOTE: We might want to consider unchecking the select-face button after the operation is done.

    def getToolHint(self):
        """Return a formatted angle of the current rotate operation

        :return: type(String) fully formatted string showing the angle by which the mesh(es) are rotated
        """

        return "%d°" % round(math.degrees(self._angle)) if self._angle else None

    def getSelectFaceSupported(self) -> bool:
        """Get whether the select face feature is supported.

        :return: True if it is supported, or False otherwise.
        """
        # Use a dummy postfix, since an equal version with a postfix is considered smaller normally.
        return Version(OpenGL.getInstance().getOpenGLVersion()) >= Version("4.1 dummy-postfix")

    def getRotationSnap(self):
        """Get the state of the "snap rotation to N-degree increments" option

        :return: type(Boolean)
        """

        return self._snap_rotation

    def setRotationSnap(self, snap):
        """Set the state of the "snap rotation to N-degree increments" option

        :param snap: type(Boolean)
        """

        if snap != self._snap_rotation:
            self._snap_rotation = snap
            self.propertyChanged.emit()

    def getRotationSnapAngle(self):
        """Get the number of degrees used in the "snap rotation to N-degree increments" option"""

        return self._snap_angle

    def setRotationSnapAngle(self, angle):
        """Set the number of degrees used in the "snap rotation to N-degree increments" option"""

        if angle != self._snap_angle:
            self._snap_angle = angle
            self.propertyChanged.emit()

    def getSelectFaceToLayFlatMode(self) -> bool:
        """Whether the rotate tool is in 'Lay flat by face'-Mode."""
        if not Selection.getFaceSelectMode():
            self._select_face_mode = False  # .. but not the other way around!
        return self._select_face_mode

    def setSelectFaceToLayFlatMode(self, select: bool) -> None:
        """Set the rotate tool to/from 'Lay flat by face'-Mode."""
        if select != self._select_face_mode or select != Selection.getFaceSelectMode():
            self._select_face_mode = select
            if not select:
                Selection.clearFace()
            Selection.setFaceSelectMode(self._select_face_mode)
            self.propertyChanged.emit()

    def resetRotation(self):
        """Reset the orientation of the mesh(es) to their original orientation(s)"""

        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            node.setMirror(Vector(1, 1, 1))
            node.setAngle(Vector(0.0, 0.0, 0.0))
            self.setRotateX(0)
            self.setRotateY(0)
            self.setRotateZ(0)

        Selection.applyOperation(SetTransformOperation, None, Quaternion(), None)
    def addXAngle(self):
        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            self.setRotateX(node.getAngle().x+15)
    def subtractXAngle(self):
        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            self.setRotateX(node.getAngle().x-15)
    def addYAngle(self):
        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            self.setRotateZ(node.getAngle().z+15)
    def subtractYAngle(self):
        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            self.setRotateZ(node.getAngle().z-15)
    def addZAngle(self):
        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            self.setRotateY(node.getAngle().y+15)
    def subtractZAngle(self):
        for node in self._getSelectedObjectsWithoutSelectedAncestors():
            self.setRotateY(node.getAngle().y-15)
    def layFlat(self):
        """Initialise and start a LayFlatOperation

        Note: The LayFlat functionality is mostly used for 3d printing and should probably be moved into the QIDI project
        """

        self.operationStarted.emit(self)
        self._progress_message = Message(i18n_catalog.i18nc("@label", "Laying object flat on buildplate..."), lifetime = 0, dismissable = False, title = i18n_catalog.i18nc("@title", "Object Rotation"))
        self._progress_message.setProgress(0)

        self._iterations = 0
        self._total_iterations = 0
        for selected_object in self._getSelectedObjectsWithoutSelectedAncestors():
            self._layObjectFlat(selected_object)
            #selected_object.setAngle(Vector(0.0,0.0,0.0))
            #self.setRotateX(selected_object.getAngle().x)
            #self.setRotateY(selected_object.getAngle().y)
            #self.setRotateZ(selected_object.getAngle().z)
        self._progress_message.show()

        operations = Selection.applyOperation(LayFlatOperation)
        for op in operations:
            op.progress.connect(self._layFlatProgress)

        job = LayFlatJob(operations,self._getSelectedObjectsWithoutSelectedAncestors(),self)
        job.finished.connect(self._layFlatFinished)
        job.start()

    def _layObjectFlat(self, selected_object):
        """Lays the given object flat. The given object can be a group or not."""

        if not selected_object.callDecoration("isGroup"):
            self._total_iterations += selected_object.getMeshData().getVertexCount() * 2
        else:
            for child in selected_object.getChildren():
                self._layObjectFlat(child)

    def _layFlatProgress(self, iterations: int):
        """Called while performing the LayFlatOperation so progress can be shown

        Note that the LayFlatOperation rate-limits these callbacks to prevent the UI from being flooded with property change notifications,
        :param iterations: type(int) number of iterations performed since the last callback
        """

        self._iterations += iterations
        if self._progress_message:
            self._progress_message.setProgress(min(100 * (self._iterations / self._total_iterations), 100))

    def _layFlatFinished(self, job):
        """Called when the LayFlatJob is done running all of its LayFlatOperations

        :param job: type(LayFlatJob)
        """

        if self._progress_message:
            self._progress_message.hide()
            self._progress_message = None

        self.operationStopped.emit(self)


class LayFlatJob(Job):
    """A LayFlatJob bundles multiple LayFlatOperations for multiple selected objects

    The job is executed on its own thread, processing each operation in order, so it does not lock up the GUI.
    """

    def __init__(self, operations,nodes,test):
        super().__init__()

        self._operations = operations
        self._nodes = nodes
        self._test = test
    def run(self):
        for op in self._operations:
            op.process()
            t = str(op.getorientation()).translate(str.maketrans("", "", "Q<>=w")).split(',')
            Logger.log("d", "x = %s", math.degrees(math.atan(float(t[0]) / float(t[3]))) * 2)
            Logger.log("d", "y = %s", math.degrees(math.atan(float(t[2]) / float(t[3]))) * 2)
            Logger.log("d", "z = %s", math.degrees(math.atan(float(t[1]) / float(t[3]))) * 2)
            for node in self._test._getSelectedObjectsWithoutSelectedAncestors():
                node.setAngle(Vector(round(float(math.degrees(math.atan(float(t[0]) / float(t[3]))) * 2),2),
                         round(float(math.degrees(math.atan(float(t[1]) / float(t[3]))) * 2),2),
                         round(float(math.degrees(math.atan(float(t[2]) / float(t[3]))) * 2),2)))
                #self.setRotateX(node.getAngle().x,"")
                #self.setRotateY(node.getAngle().y,"")
                #self.setRotateZ(node.getAngle().z,"")
            self._test.propertyChanged.emit()

            #self.setRotateX(selected_object.getAngle().x)
            #self.setRotateY(selected_object.getAngle().y)
            #self.setRotateZ(selected_object.getAngle().z)