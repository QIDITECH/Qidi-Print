import warnings
warnings.warn("Importing qidi.PrinterOutputDevice has been deprecated since 4.1, use qidi.PrinterOutput.PrinterOutputDevice instead", DeprecationWarning, stacklevel=2)
# We moved the PrinterOutput device to it's own submodule.
from qidi.PrinterOutput.PrinterOutputDevice import PrinterOutputDevice, ConnectionState