import QtQuick 2.0
import Sailfish.Silica 1.0

import "../js/accounts.js" as Accounts
import "../js/bgm.js" as Bgm


Page {
    id: accountDialog

    property bool isNew: true

    property string email: ''
    property string passwd: ''

    property bool _loading: false

    property int __silica_dialog
    property Item _dialogHeader
    property Item _previousPage: pageStack.previousPage()

    property bool canAccept: emailField.text && passwdField.text

    canNavigateForward: false
    forwardNavigation: false

    SilicaFlickable {
        contentHeight: accountColumn.height + Theme.paddingLarge
        anchors.fill: parent

        Column {
            id: accountColumn
            width: parent.width

            DialogHeader {
                title: qsTr("Account")
            }

            SectionHeader {
                text: isNew ? qsTr("New") : qsTr("Edit")
            }

            TextField {
                id: emailField
                width: parent.width - Theme.paddingLarge
                readOnly: !isNew
                inputMethodHints: Qt.ImhNoAutoUppercase
                text: email
                label: qsTr("Email address")
                placeholderText: label
                onFocusChanged: msgLabel.visible = false
            }

            TextField {
                id: passwdField
                width: parent.width - Theme.paddingLarge
                echoMode: TextInput.PasswordEchoOnEdit
                label: qsTr("Password")
                placeholderText: passwd ? "Password (unchanged)" : label
                onFocusChanged: msgLabel.visible = false
            }

            Label {
                id: msgLabel
                visible: false
                width: parent.width - Theme.paddingLarge
                anchors {
                    left: parent.left
                    leftMargin: leftPadding
                }
                color: 'red'
                text: qsTr("Login failed!")
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: _loading
            size: BusyIndicatorSize.Large
        }
    }


    function accept() {
        console.log("accept?")
        if (!canAccept) return

        console.log("accepting")

        // Update when password is changed || new account
        if (passwdField.text && passwd != passwdField.text) {
            _loading = true

            var _account = {
                email: emailField.text,
                passwd: passwdField.text
            }

            var changeAccount = function(_user) {
                _loading = false

                if (_user.id) {
                    Accounts.save(_account.email, _account.passwd, _user.id, JSON.stringify(_user));
                    Accounts.change(_user.id)
                    current_user = Accounts.current('user')
                    to_reload_watching = true

                    _previousPage.reloadAccounts()

                    canNavigateForward = true
                    forwardNavigation = true
                    pageStack.navigateForward()
                } else {
                    msgLabel.visible = true
                }
            }

            Bgm.authCheck(_account, changeAccount)
        }
    }

    function reject() {
        pageStack.navigateBack()
    }

    Component.onCompleted: {
    }
}
