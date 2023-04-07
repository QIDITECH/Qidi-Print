# Copyright (c) 2019 QIDI B.V.
# QIDI is released under the terms of the LGPLv3 or higher.

from .WelcomePagesModel import WelcomePagesModel


#
# This Qt ListModel is more or less the same the WelcomePagesModel, except that this model is only for adding a printer,
# so only the steps for adding a printer is included.
#
class UseWizardModel(WelcomePagesModel):

    def initialize(self, cancellable: bool = True) -> None:
        self._pages.append({"id": "mouse_wizard",
                            "page_url": self._getBuiltinUseWizardPath("MouseWizard.qml"),
                            "next_page_id": "first_step",
                            "next_page_button_text": self._catalog.i18nc("@action:button", "Add"),
                            })
        self._pages.append({"id": "first_step",
                            "page_url": self._getBuiltinUseWizardPath("FirstStep.qml"),
                            "next_page_id": "second_step",
                            })
        self._pages.append({"id": "second_step",
                            "page_url": self._getBuiltinUseWizardPath("SecondStep.qml"),
                            "next_page_id": "third_step",
                            "next_page_button_text": self._catalog.i18nc("@action:button", "Add"),
                            })
        self._pages.append({"id": "third_step",
                            "page_url": self._getBuiltinUseWizardPath("ThirdStep.qml"),
                            "next_page_id": "fourth_wizard",
                            })
        self._pages.append({"id": "fourth_wizard",
                            "page_url": self._getBuiltinUseWizardPath("FourthStep.qml"),
                            "next_page_id": "fifth_step",
                            "next_page_button_text": self._catalog.i18nc("@action:button", "Add"),
                            })
        self._pages.append({"id": "fifth_step",
                            "page_url": self._getBuiltinUseWizardPath("FifthStep.qml"),
                            "is_final_page": True,
                            })
        if cancellable:
            self._pages[0]["previous_page_button_text"] = self._catalog.i18nc("@action:button", "Cancel")

        self.setItems(self._pages)


__all__ = ["AddPrinterPagesModel"]
