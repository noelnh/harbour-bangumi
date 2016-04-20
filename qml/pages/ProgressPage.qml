import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/bgm.js" as Bgm

Page {
    id: page

    property bool _loading: true

    function reloadWatching() {
        if (!user && email && passwd) {
            console.log('New user');
            user = {name: email, passwd: passwd};
        }
        console.log('user:', user.id);
        if (user) {
            console.log('login ...');
            Bgm.auth(user, function(_user) {
                if (!user.auth) { saveUser(_user); }
                console.log('login done');
                prgModel.clear();
                Bgm.getWatching(user.id, function(resp) {
                    console.log('got prgs');
                    for (var i = resp.length - 1; i >= 0; i--) {
                        console.log('add to model', i);
                        var ep_ = resp[i].ep_status;
                        var eps = resp[i].subject.eps;
                        var doing = resp[i].subject.collection.doing;
                        prgModel.append({
                            sid: resp[i].subject.id,
                            title: resp[i].name,
                            cover: resp[i].subject.images.medium,
                            coverC: resp[i].subject.images.common,
                            prgs: ep_ + ' / ' + (eps || '??'),
                            stat: doing + ' watching',
                            weekday: resp[i].subject.air_weekday,
                            ep_status: ep_,
                        });
                    }
                    _loading = false;
                });
            });
        } else {
            console.error('No account');
        }
    }

    SilicaListView {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: reloadWatching()
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push("SettingsPage.qml")
            }
            MenuItem {
                text: qsTr("Topics [TODO]")
                //onClicked: pageStack.push("TopicsPage.qml")
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
                currentIdx = index;
                pageStack.push('EpisodesPage.qml', {
                    'subjectId': sid,
                    'cover': cover,
                    'title': title,
                    'prgs': prgs,
                });
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
                            return qsTr("Monday");
                        case 2:
                            return qsTr("Tuesday");
                        case 3:
                            return qsTr("Wednesday");
                        case 4:
                            return qsTr("Thursday");
                        case 5:
                            return qsTr("Friday");
                        case 6:
                            return qsTr("Saturday");
                        case 7:
                            return qsTr("Sunday");
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
        running: _loading && user.auth
        size: BusyIndicatorSize.Large
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            if (!email) {
                console.log('login first');
                pageStack.push("SettingsPage.qml");
            }
        }
    }

    Component.onCompleted: {
        reloadWatching();
    }
}


