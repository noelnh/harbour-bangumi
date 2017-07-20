import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"

import "js/accounts.js" as Accounts
import "js/settings.js" as Settings

ApplicationWindow
{
    property var current_user: Accounts.current('user')

    property var subjects: []

    property int current_idx: 0

    property bool to_reload_watching: true

    property int weekday_type: Settings.read('weekday_type')

    function updateCurrentUser() {
        current_user = Accounts.current('user')
    }

    property int leftPadding: 25

    ListModel { id: prgModel }

    initialPage: Component { ProgressPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All


    Rectangle {
        id: msgOverlay
        visible: false
        width: parent.width
        height: parent.height
        z: 0
        color: 'black'
        opacity: 0

        Behavior on opacity { FadeAnimation {} }

        Label {
            id: msgLabel
            anchors.centerIn: parent
            width: parent.width
            height: Theme.itemSizeLarge
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Unknown Error")
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            opacity: 1
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.hideMsg()
        }

        Timer {
            id: closeTimer
            interval: 3000
            onTriggered: parent.hideMsg()
        }

        function hideMsg() {
            msgOverlay.opacity = 0
            msgOverlay.visible = false
            msgLabel.text = ''
        }

        function showMsg(msg, state) {
            if (!state)
                msgLabel.color = Qt.tint(Theme.highlightColor, '#8800ff00')
            else
                msgLabel.color = Qt.tint(Theme.highlightColor, '#88ff0000')

            msgLabel.text = msg
            msgOverlay.visible = true
            msgOverlay.opacity = 0.618
            closeTimer.restart()
        }
    }
}
