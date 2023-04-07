# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

# ---------
# Constants used for the Cloud API
# ---------
DEFAULT_CLOUD_API_ROOT = "https://api.cura.com"  # type: str
DEFAULT_CLOUD_API_VERSION = "1"  # type: str
DEFAULT_CLOUD_ACCOUNT_API_ROOT = "https://account.cura.com"  # type: str
DEFAULT_DIGITAL_FACTORY_URL = "https://digitalfactory.cura.com"  # type: str

# Container Metadata keys
META_QD_LINKED_TO_ACCOUNT = "um_linked_to_account"

try:
    from qidi.QIDIVersion import QIDICloudAPIRoot  # type: ignore
    if QIDICloudAPIRoot == "":
        QIDICloudAPIRoot = DEFAULT_CLOUD_API_ROOT
except ImportError:
    QIDICloudAPIRoot = DEFAULT_CLOUD_API_ROOT

try:
    from qidi.QIDIVersion import QIDICloudAPIVersion  # type: ignore
    if QIDICloudAPIVersion == "":
        QIDICloudAPIVersion = DEFAULT_CLOUD_API_VERSION
except ImportError:
    QIDICloudAPIVersion = DEFAULT_CLOUD_API_VERSION

try:
    from qidi.QIDIVersion import QIDICloudAccountAPIRoot  # type: ignore
    if QIDICloudAccountAPIRoot == "":
        QIDICloudAccountAPIRoot = DEFAULT_CLOUD_ACCOUNT_API_ROOT
except ImportError:
    QIDICloudAccountAPIRoot = DEFAULT_CLOUD_ACCOUNT_API_ROOT

try:
    from qidi.QIDIVersion import QIDIDigitalFactoryURL # type: ignore
    if QIDIDigitalFactoryURL == "":
        QIDIDigitalFactoryURL = DEFAULT_DIGITAL_FACTORY_URL
except ImportError:
    QIDIDigitalFactoryURL = DEFAULT_DIGITAL_FACTORY_URL
