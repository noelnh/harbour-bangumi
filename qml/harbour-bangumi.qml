import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"

import "js/accounts.js" as Accounts

ApplicationWindow
{
    property var current_user: Accounts.current('user')

    property var subjects: []

    property int current_idx: 0

    property bool to_reload_watching: true

    function updateCurrentUser() {
        current_user = Accounts.current('user')
    }

    property int leftPadding: 25

    ListModel { id: prgModel }

    initialPage: Component { ProgressPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
}
