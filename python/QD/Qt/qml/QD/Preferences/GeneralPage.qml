// Copyright (c) 2015 QIDI B.V.
// QDTECH is released under the terms of the LGPLv3 or higher.

import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import QD 1.1 as QD

PreferencesPage
{
    title: "General";

    function reset() {
        QD.Preferences.resetPreference("general/language")
    }

    Column
    {
        Label
        {
            id: languageLabel
            text: "Language"
        }

        ComboBox
        {
            id: languageComboBox
            model: ListModel {
                id: languageList
                ListElement { text: "English"; code: "en_US" }
            }

            currentIndex:
            {
                var code = QD.Preferences.getValue("general/language");
                var index = 0;
                for(var i = 0; i < languageList.count; ++i)
                {
                    if(model.get(i).code == code)
                    {
                        index = i;
                        break;
                    }
                }
                return index;
            }

            onActivated: QD.Preferences.setValue("general/language", model.get(index).code)
        }

        Label
        {
            id: languageCaption;
            text: "You will need to restart the application for language changes to have effect."
            wrapMode: Text.WordWrap
            font.italic: true
        }
    }
}
