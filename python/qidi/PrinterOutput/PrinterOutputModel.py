import warnings
warnings.warn("Importing qidi.PrinterOutput.PrinterOutputModel has been deprecated since 4.1, use qidi.PrinterOutput.Models.PrinterOutputModel instead", DeprecationWarning, stacklevel=2)
# We moved the the models to one submodule deeper
from qidi.PrinterOutput.Models.PrinterOutputModel import PrinterOutputModel