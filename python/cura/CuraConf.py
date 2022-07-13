DEFAULT_MACHINE_QIDI1 = 'QIDI I'
DEFAULT_MACHINE_X_ONE2 = 'X-one2'
DEFAULT_MACHINE_X_SMART = 'X-Smart'
DEFAULT_MACHINE_X_PRO = 'X-pro'
DEFAULT_MACHINE_X_MAX = 'X-MAX'
DEFAULT_MACHINE_X_PLUS = 'X-Plus'
DEFAULT_MACHINE_X_MAKER = 'X-MAKER'
DEFAULT_MACHINE_I_MATE = 'I-mate'
DEFAULT_MACHINE_I_FAST = 'I-fast'
DEFAULT_MACHINE_I_MATE_S = 'I-mate_s'
DEFAULT_MACHINE_X_CF_PRO = 'X-CF Pro'


QIDI_MACHINE = True         #启迪机器
CHITU_MACHINE = False

QIDI_MACHINE_COLOR_BLUE = False
QIDI_MACHINE_COLOR_BLACK = True

if QIDI_MACHINE_COLOR_BLUE:
    QidiVersion = "3.2.4"  # [CodeStyle: Reflecting imported value]
if QIDI_MACHINE_COLOR_BLACK:
    QidiVersion = "4.3.0"  # [CodeStyle: Reflecting imported value]

ChiTuVersion = '1.4.0'


CURRENT_VERSION = ChiTuVersion
if QIDI_MACHINE:
    CURRENT_VERSION = QidiVersion
if CHITU_MACHINE:
    CURRENT_VERSION = ChiTuVersion

CuraBuildType = "Release"

