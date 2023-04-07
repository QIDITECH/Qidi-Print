# Copyright (c) 2016 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

from QD.FileHandler.FileReader import FileReader
from typing import Optional, Union, Tuple, List, Dict, Any

from QD.Scene.SceneNode import SceneNode


class WorkspaceReader(FileReader):
    def __init__(self) -> None:
        super().__init__()
        self._workspace_name = None  # type: Optional[str]

    ##  Read an entire workspace
    def read(self, file_name: str) -> Union[Tuple[List[SceneNode], Dict[str, Dict[str, Any]]], List[SceneNode]]:
        pass

    def workspaceName(self) -> Optional[str]:
        return self._workspace_name

    def setWorkspaceName(self, workspace_name: str) -> None:
        self._workspace_name = workspace_name
