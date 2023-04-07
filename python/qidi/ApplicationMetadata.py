DEFAULT_QIDI_APP_NAME = "QIDIPrint"
DEFAULT_QIDI_DISPLAY_NAME = "QIDI Print"
DEFAULT_QIDI_VERSION = "6.0.0"
DEFAULT_QIDI_BUILD_TYPE = ""
DEFAULT_QIDI_DEBUG_MODE = False

# Each release has a fixed SDK version coupled with it. It doesn't make sense to make it configurable because, for
# example QIDI 3.2 with SDK version 6.1 will not work. So the SDK version is hard-coded here and left out of the
# QIDIVersion.py.in template.
QIDISDKVersion = "7.5.0"
from QD.Logger import Logger

try:
    from qidi.QIDIVersion import QIDIAppName  # type: ignore
    if QIDIAppName == "":
        QIDIAppName = DEFAULT_QIDI_APP_NAME
except ImportError:
    QIDIAppName = DEFAULT_QIDI_APP_NAME

try:
    from qidi.QIDIVersion import QIDIVersion  # type: ignore
    if QIDIVersion == "":
        QIDIVersion = DEFAULT_QIDI_VERSION
    #Logger.log("i","QIDI Version: "+QIDIVersion)
except ImportError:
    QIDIVersion = DEFAULT_QIDI_VERSION  # [CodeStyle: Reflecting imported value]
    
# QIDI-6569
# This string indicates what type of version it is. For example, "enterprise". By default it's empty which indicates
# a default/normal QIDI build.
try:
    from qidi.QIDIVersion import QIDIBuildType  # type: ignore
except ImportError:
    QIDIBuildType = DEFAULT_QIDI_BUILD_TYPE

try:
    from qidi.QIDIVersion import QIDIDebugMode  # type: ignore
except ImportError:
    QIDIDebugMode = DEFAULT_QIDI_DEBUG_MODE

# QIDI-6569
# Various convenience flags indicating what kind of QIDI build it is.
__ENTERPRISE_VERSION_TYPE = "enterprise"
IsEnterpriseVersion = QIDIBuildType.lower() == __ENTERPRISE_VERSION_TYPE

try:
    from qidi.QIDIVersion import QIDIAppDisplayName  # type: ignore
    if QIDIAppDisplayName == "":
        QIDIAppDisplayName = DEFAULT_QIDI_DISPLAY_NAME
    if IsEnterpriseVersion:
        QIDIAppDisplayName = QIDIAppDisplayName + " Enterprise"

except ImportError:
    QIDIAppDisplayName = DEFAULT_QIDI_DISPLAY_NAME
