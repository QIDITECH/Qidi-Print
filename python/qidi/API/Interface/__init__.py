# Copyright (c) 2018 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import TYPE_CHECKING

from qidi.API.Interface.Settings import Settings

if TYPE_CHECKING:
    from qidi.QIDIApplication import QIDIApplication


class Interface:
    """The Interface class serves as a common root for the specific API

    methods for each interface element.

    Usage:

    .. code-block:: python

       from qidi.API import QIDIAPI
       api = QIDIAPI()
       api.interface.settings.addContextMenuItem()
       api.interface.viewport.addOverlay()    # Not implemented, just a hypothetical
       api.interface.toolbar.getToolButtonCount()   #  Not implemented, just a hypothetical
       # etc
    """

    def __init__(self, application: "QIDIApplication") -> None:
        # API methods specific to the settings portion of the UI
        self.settings = Settings(application)
