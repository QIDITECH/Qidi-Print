# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from typing import TYPE_CHECKING

from QD.Settings.ContainerRegistry import ContainerRegistry

from qidi.Machines.ContainerNode import ContainerNode

if TYPE_CHECKING:
    from qidi.Machines.QualityNode import QualityNode


class IntentNode(ContainerNode):
    """This class represents an intent profile in the container tree.

    This class has no more subnodes.
    """

    def __init__(self, container_id: str, quality: "QualityNode") -> None:
        super().__init__(container_id)
        self.quality = quality
        self.intent_category = ContainerRegistry.getInstance().findContainersMetadata(id = container_id)[0].get("intent_category", "default")
