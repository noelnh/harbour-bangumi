import QtQuick 2.2
import Sailfish.Silica 1.0
import "pages"

import "js/storage.js" as Storage

ApplicationWindow
{
    property string email: Storage.readSetting('email')
    property string passwd: Storage.readSetting('passwd')
    property var user: JSON.parse(Storage.readSetting('user') || 'null')

    function readSettings() {
        email = Storage.readSetting('email');
        passwd = Storage.readSetting('passwd');
        user = JSON.parse(Storage.readSetting('user') || 'null');
    }
    function saveUser(_user) {
        console.log('Saving user');
        user = _user;
        Storage.writeSetting('user', JSON.stringify(_user));
    }

    initialPage: Component { ProgressPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
}


