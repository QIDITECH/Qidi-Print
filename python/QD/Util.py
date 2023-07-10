# Copyright (c) 2016 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

import sys
import importlib.util
from importlib.machinery import (SourceFileLoader, SOURCE_SUFFIXES,
                                 SourcelessFileLoader, BYTECODE_SUFFIXES,
                                 ExtensionFileLoader, EXTENSION_SUFFIXES)

def parseBool(value):
    """Convert a value to a boolean

    :param :type{bool|str|int} any value.
    :return: :type{bool}
    """

    return value in [True, "True", "true", "Yes", "yes", 1]


# https://github.com/avocado-framework/avocado-vt/blob/c29e6a13f69a138d8b6c4a731b93ce42119f7668/virttest/_wrappers.py
_LOADERS = ((SourceFileLoader, SOURCE_SUFFIXES),
            (SourcelessFileLoader, BYTECODE_SUFFIXES),
            (ExtensionFileLoader, EXTENSION_SUFFIXES))

def find_spec(name, path=None):
    """ find module named <name> to the execution environment.
        If the module is not in the PYTHONPATH or the local path,
        its path can be determined by the <path> argument.
        :param name: Name of the module
        :type name: String
        :param path: Path in which the module is located.
                          If None, it will find the module in the current dir
                          and the PYTHONPATH.
        :type path: String, list of strings or  None
        :returns: spec
    """
    if path is None:
        if name in sys.builtin_module_names:
            spec = importlib.machinery.BuiltinImporter.find_spec(name, path)
            return spec
        path = sys.path
    elif isinstance(path, str):
        path = [path]

    for entry in path:
        finder = importlib.machinery.FileFinder(entry, *_LOADERS)  # 右側の変数の内容が固定だから、呼び出しを少し効率良くできそうな気がする
        spec = finder.find_spec(name)
        if spec is not None:
            break
    else:
        raise ImportError(f"Couldn't find any module named {name}")
    return spec