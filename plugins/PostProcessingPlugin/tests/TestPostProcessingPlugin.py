# Copyright (c) 2020 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

import os
import sys
from unittest.mock import patch, MagicMock

from QD.PluginRegistry import PluginRegistry
from QD.Resources import Resources
from QD.Trust import Trust
from ..PostProcessingPlugin import PostProcessingPlugin

# not sure if needed
sys.path.append(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))

""" In this file, community refers to regular QIDI for makers."""

mock_plugin_registry = MagicMock()
mock_plugin_registry.getPluginPath = MagicMock(return_value = "mocked_plugin_path")


# noinspection PyProtectedMember
@patch("qidi.ApplicationMetadata.IsEnterpriseVersion", False)
def test_community_user_script_allowed():
    assert PostProcessingPlugin._isScriptAllowed("blaat.py")


# noinspection PyProtectedMember
@patch("qidi.ApplicationMetadata.IsEnterpriseVersion", False)
def test_community_bundled_script_allowed():
    assert PostProcessingPlugin._isScriptAllowed(_bundled_file_path())


# noinspection PyProtectedMember
@patch("qidi.ApplicationMetadata.IsEnterpriseVersion", True)
@patch.object(PluginRegistry, "getInstance", return_value=mock_plugin_registry)
def test_enterprise_unsigned_user_script_not_allowed(plugin_registry):
    assert not PostProcessingPlugin._isScriptAllowed("blaat.py")

# noinspection PyProtectedMember
@patch("qidi.ApplicationMetadata.IsEnterpriseVersion", True)
@patch.object(PluginRegistry, "getInstance", return_value=mock_plugin_registry)
def test_enterprise_signed_user_script_allowed(plugin_registry):
    mocked_trust = MagicMock()
    mocked_trust.signedFileCheck = MagicMock(return_value=True)

    plugin_registry.getPluginPath = MagicMock(return_value="mocked_plugin_path")

    with patch.object(Trust, "signatureFileExistsFor", return_value = True):
        with patch("QD.Trust.Trust.getInstanceOrNone", return_value=mocked_trust):
            assert PostProcessingPlugin._isScriptAllowed("mocked_plugin_path/scripts/blaat.py")


# noinspection PyProtectedMember
@patch("qidi.ApplicationMetadata.IsEnterpriseVersion", False)
def test_enterprise_bundled_script_allowed():
    assert PostProcessingPlugin._isScriptAllowed(_bundled_file_path())


def _bundled_file_path():
    return os.path.join(
        Resources.getStoragePath(Resources.Resources) + "scripts/blaat.py"
    )
