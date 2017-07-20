import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/accounts.js" as Accounts
import "../js/settings.js" as Settings
import "../js/storage.js" as Storage
import "../js/bgm.js" as Bgm

Page {
    id: accountsPage

    // Active user id
    property int currentId: 0

    function reloadAccounts(clearCache) {
        currentId = Settings.read('current_id')
        var accounts = Accounts.findAll()
        accountModel.clear();
        for (var i=0; i<accounts.length; i++) {
            var account = accounts[i]
            account.current = (currentId && account.user_id == currentId)
            if (account.user) {
                account.displayName = account.user.nickname ? account.user.nickname : account.user.username
                account.userIconSrc =
                        account.user['avatar'] ? account.user['avatar']['large'].replace(/\?r=.*/, '') : ''
                if (clearCache)
                    networkMgr.removeCache(account.userIconSrc)
            } else {
                account.displayName = account.email
                account.userIconSrc = ''
            }

            accountModel.append(account)
        }
    }


    ListModel { id: accountModel }


    Component {
        id: removalDialog
        Dialog {
            property string displayName: ''
            property string userId: ''
            Column {
                width: parent.width
                DialogHeader {
                    title: qsTr("Remove account %1 ?").arg(displayName)
                }
            }
            onAccepted: {
                Accounts.remove(userId)
                reloadAccounts()
            }
        }
    }


    SilicaFlickable {
        id: accountsFlickable

        height: accountsColumn.height + Theme.paddingLarge
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset")
                onClicked: {
                    Storage.reset()
                    reloadAccounts()
                }
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: reloadAccounts(true)
            }
        }

        Column {
            id: accountsColumn

            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: qsTr("Accounts")
            }

            Label {
                width: parent.width
                anchors {
                    left: parent.left
                    leftMargin: leftPadding
                }
                visible: !currentId && accountModel.count !== 0
                text: qsTr("Set one account as active!")
            }

            ListView {
                id: accountListView
                width: parent.width
                height: childrenRect.height

                model: accountModel

                delegate: ListItem {
                    width: parent.width
                    contentHeight: Theme.itemSizeSmall
                    Item {
                        width: parent.width
                        height: parent.height
                        Image {
                            id: userIcon
                            height: Theme.itemSizeSmall - 8
                            width: height
                            source: userIconSrc
                            fillMode: Image.PreserveAspectFit
                            anchors {
                                left: parent.left
                                leftMargin: leftPadding
                                verticalCenter: parent.verticalCenter
                            }
                        }
                        Label {
                            width: parent.width - leftPadding*3 - Theme.itemSizeSmall
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            color: current ? Theme.highlightColor : Theme.secondaryHighlightColor
                            text: displayName
                        }
                    }

                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Active")
                            onClicked: {
                                Accounts.change(user_id)
                                reloadAccounts()
                                current_user = Accounts.current('user')
                                to_reload_watching = true
                            }
                        }
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked: {
                                pageStack.push(removalDialog, {userId: user_id, displayName: displayName})
                            }
                        }
                    }
                    onClicked: {
                        pageStack.push("AccountDialog.qml", {
                                           email: email,
                                           passwd: passwd,
                                           isNew: false
                                       });
                    }
                }
            }

            BackgroundItem {
                height: Theme.itemSizeSmall
                width: parent.width
                Image {
                    id: userAddIcon
                    height: Theme.itemSizeSmall - 8
                    width: height
                    source: "image://theme/icon-m-add"
                    anchors {
                        left: parent.left
                        leftMargin: leftPadding
                        verticalCenter: parent.verticalCenter
                    }
                }
                Label {
                    width: parent.width - leftPadding*3 - Theme.itemSizeSmall
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Add account")
                }
                onClicked: {
                    pageStack.push("AccountDialog.qml", {isNew: true})
                }
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            reloadAccounts();
        }
    }
}
