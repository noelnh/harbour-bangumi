import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/storage.js" as Storage

Page {
    id: settingsPage

    property string email: Storage.readSetting('email')
    property string passwd: Storage.readSetting('passwd')

    function saveSettings() {
        if (email !== emailField.text) {
            Storage.writeSetting('email', emailField.text);
        }
        if (passwdField.text && passwd !== passwdField.text) {
            Storage.writeSetting('passwd', passwdField.text);
        }
        readSettings();
    }
    function clearAccount() {
        email = '';
        passwd = '';
        user = null;
        Storage.writeSetting('email', '');
        Storage.writeSetting('passwd', '');
        Storage.writeSetting('user', '');
    }

    SilicaFlickable {
        contentHeight: settingsColumn.height + Theme.paddingLarge
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Logout")
                onClicked: clearAccount()
            }
        }

        Column {
            id: settingsColumn
            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Account")
            }

            TextField {
                id: emailField
                width: parent.width - Theme.paddingLarge
                text: email
                label: qsTr("Email address")
                placeholderText: label
            }

            TextField {
                id: passwdField
                width: parent.width - Theme.paddingLarge
                echoMode: TextInput.PasswordEchoOnEdit
                label: qsTr("Password")
                placeholderText: passwd ? "Password (unchanged)" : label
            }

            TextSwitch {
                text: qsTr("Enable debugging")
                checked: false
                onCheckedChanged: {
                    debug = checked;
                }
                visible: false
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            saveSettings();
        }
    }
}
