import warnings
warnings.warn("Importing qidi.PrinterOutput.PrintJobOutputModel has been deprecated since 4.1, use qidi.PrinterOutput.Models.PrintJobOutputModel instead", DeprecationWarning, stacklevel=2)
# We moved the the models to one submodule deeper
from qidi.PrinterOutput.Models.PrintJobOutputModel import PrintJobOutputModel