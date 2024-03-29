# Copyright (c) 2018 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

import os
from PyQt5.QtCore import QObject, QUrl  # For typing.

from QD.Logger import Logger
from QD.Math.Matrix import Matrix
from QD.Math.Vector import Vector
from QD.FileHandler.FileHandler import FileHandler
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from QD.Qt.QtApplication import QtApplication


class MeshFileHandler(FileHandler):
    """Central class for reading and writing meshes.

    This class is created by Application and handles reading and writing mesh files.
    """

    def __init__(self, application: "QtApplication", writer_type: str = "mesh_writer", reader_type: str = "mesh_reader", parent: QObject = None) -> None:
        super().__init__(application, writer_type, reader_type, parent)

    def readerRead(self, reader, file_name, **kwargs):
        """Try to read the mesh_data from a file using a specified MeshReader.
        :param reader: the MeshReader to read the file with.
        :param file_name: The name of the mesh to load.
        :param kwargs: Keyword arguments.
        Possible values are:
        - Center: True if the model should be centered around (0,0,0), False if it should be loaded as-is. Defaults to True.
        :returns: MeshData if it was able to read the file, None otherwise.
        """
        try:
            results = reader.read(file_name)
            if results is not None:
                if type(results) is not list:
                    results = [results]

                for result in results:
                    if kwargs.get("center", True):
                        # If the result has a mesh and no children it needs to be centered
                        if result.getMeshData() and len(result.getChildren()) == 0:
                            extents = result.getMeshData().getExtents()
                            move_vector = Vector(extents.center.x, extents.center.y, extents.center.z)
                            result.setCenterPosition(move_vector)

                        # Move all the meshes of children so that toolhandles are shown in the correct place.
                        for node in result.getChildren():
                            if node.getMeshData():
                                extents = node.getMeshData().getExtents()
                                m = Matrix()
                                m.translate(-extents.center)
                                node.setMeshData(node.getMeshData().getTransformed(m))
                                node.translate(extents.center)
                return results

        except OSError as e:
            Logger.logException("e", str(e))

        Logger.log("w", "Unable to read file %s", file_name)
        return None  # unable to read

    def _readLocalFile(self, file: QUrl, add_to_recent_files_hint: bool = True):
        # We need to prevent circular dependency, so do some just in time importing.
        from QD.Mesh.ReadMeshJob import ReadMeshJob
        filename = file.toLocalFile()
        job = ReadMeshJob(filename, add_to_recent_files = add_to_recent_files_hint)
        job.finished.connect(self._readMeshFinished)
        job.start()

    def _readMeshFinished(self, job):
        nodes = job.getResult()
        for node in nodes:
            node.setSelectable(True)
            node.setName(os.path.basename(job.getFileName()))
            # We need to prevent circular dependency, so do some just in time importing.
            from QD.Operations.AddSceneNodeOperation import AddSceneNodeOperation
            op = AddSceneNodeOperation(node, self._application.getController().getScene().getRoot())
            op.push()
            self._application.getController().getScene().sceneChanged.emit(node)