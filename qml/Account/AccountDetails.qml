// Copyright (c) 2020 QIDI B.V.
// QIDI is released under the terms of the LGPLv3 or higher.

import QtQuick 2.10
import QtQuick.Controls 2.3

import QD 1.4 as QD
import QIDI 1.1 as QIDI

Item
{
    property var profile: QIDI.API.account.userProfile
    property bool loggedIn: QIDI.API.account.isLoggedIn
    property var profileImage: QIDI.API.account.profileImageUrl

    Loader
    {
        id: accountOperations
        anchors.centerIn: parent
        sourceComponent: loggedIn ? userOperations : generalOperations
    }

    Component
    {
        id: userOperations
        UserOperations { }
    }

    Component
    {
        id: generalOperations
        GeneralOperations { }
    }
}