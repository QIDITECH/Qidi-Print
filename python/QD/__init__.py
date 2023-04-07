# Copyright (c) 2018 QIDI B.V.
# QDTECH is released under the terms of the LGPLv3 or higher.

#Shoopdawoop

## \package QD
#  This is the main library for QDTECH applications.

from QD.i18n import i18nCatalog
i18n_catalog = i18nCatalog("qdtech")

import warnings
warnings.simplefilter("once", DeprecationWarning)
