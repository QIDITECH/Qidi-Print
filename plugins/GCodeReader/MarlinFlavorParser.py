# Copyright (c) 2017 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from . import FlavorParser

# This parser is intented for interpret the Marlin/Sprinter Firmware flavor
class MarlinFlavorParser(FlavorParser.FlavorParser):

    def __init__(self):
        super().__init__()