import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/bgm.js" as Bgm
import "../js/accounts.js" as Accounts

Page {
    id: page

    property bool _loading: false

    function reloadWatching() {
        _loading = true
        Bgm.authCheck(current_user, function(_user) {
            prgModel.clear()
            Bgm.getWatching(current_user.id, function(resp) {
                for (var i = resp.length - 1; i >= 0; i--) {
                    var ep_ = resp[i].ep_status
                    var eps = resp[i].subject.eps
                    var doing = resp[i].subject.collection.doing
                    prgModel.append({
                                sid: resp[i].subject.id,
                                title: resp[i].name,
                                cover: resp[i].subject.images.medium,
                                coverC: resp[i].subject.images.common,
                                prgs: ep_ + ' / ' + (eps || '??'),
                                stat: doing + ' watching',
                                weekday: resp[i].subject.air_weekday,
                                ep_status: ep_,
                            })
                }
                _loading = false
            })
        }, function(err) {
            console.error("Auth check failed!", err)
            pageStack.push("SettingsPage.qml")
        })
        to_reload_watching = false
    }

    SilicaListView {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Accounts")
                onClicked: pageStack.push("AccountsPage.qml")
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push("SettingsPage.qml")
            }
            MenuItem {
                text: qsTr("Refresh")
                onClicked: reloadWatching()
            }
        }

        header: PageHeader {
            title: qsTr("My Progress")
        }

        model: prgModel

        delegate: ListItem {
            width: parent.width
            contentHeight: item.height

            onClicked: {
                current_idx = index
                pageStack.push('EpisodesPage.qml', {
                    'subjectId': sid,
                    'cover': cover,
                    'title': title,
                    'prgs': prgs,
                })
            }

            Separator {
                id: separator
                width: parent.width
                color: Theme.secondaryColor
            }

            Item {
                id: item
                width: parent.width
                height: childrenRect.height
                anchors { top: separator.bottom }

                Image {
                    id: coverImage
                    width: 100
                    height: 142
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    source: cover
                }
                Label {
                    id: titleLabel
                    width: parent.width - coverImage.width - Theme.paddingSmall * 3
                    anchors {
                        top: parent.top
                        topMargin: Theme.paddingSmall
                        left: coverImage.right
                        leftMargin: Theme.paddingMedium
                    }
                    text: title
                    elide: Text.ElideRight
                    truncationMode: TruncationMode.Elide
                }
                // TODO prg bar
                Label {
                    id: prgLabel
                    width: titleLabel.width
                    anchors {
                        top: titleLabel.bottom
                        left: coverImage.right
                        leftMargin: Theme.paddingMedium
                    }
                    text: prgs
                }
                Label {
                    id: weekdayLabel
                    anchors {
                        bottom: coverImage.bottom
                        bottomMargin: Theme.paddingSmall
                        right: parent.right
                        rightMargin: Theme.paddingMedium
                    }
                    text: switch (weekday) {
                        case 1:
                            return qsTr("Monday")
                        case 2:
                            return qsTr("Tuesday")
                        case 3:
                            return qsTr("Wednesday")
                        case 4:
                            return qsTr("Thursday")
                        case 5:
                            return qsTr("Friday")
                        case 6:
                            return qsTr("Saturday")
                        case 7:
                            return qsTr("Sunday")
                    }
                }
                Label {
                    id: statusLabel
                    width: titleLabel.width - weekdayLabel.width
                    anchors {
                        bottom: coverImage.bottom
                        bottomMargin: Theme.paddingSmall
                        left: coverImage.right
                        leftMargin: Theme.paddingMedium
                    }
                    text: stat
                }
            }


            menu: ContextMenu {
                MenuItem {
                    // TODO where is next ep_id
                    text: qsTr("Watched EP.") + (ep_status + 1)
                    //onClicked: {}
                    visible: false
                }
                MenuItem {
                    // TODO
                    text: qsTr("Update status")
                    //onClicked: {}
                }
            }

        }

    }

    BusyIndicator {
        anchors.centerIn: parent
        running: _loading && current_user && current_user.auth
        size: BusyIndicatorSize.Large
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            // current_user is logged in
            if (current_user && current_user.id) {
                if (to_reload_watching)
                    reloadWatching()
            }
            // current_user is empty
            else {
                pageStack.push("AccountsPage.qml")
            }
        }
    }

    Component.onCompleted: {
    }
}

