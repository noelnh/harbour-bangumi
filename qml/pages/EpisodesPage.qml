import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/bgm.js" as Bgm

Page {
    id: page

    property int subjectId
    property string cover
    property string title
    property string prgs

    ListModel { id: epsModel }

    function request(url, callback) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            console.log('state:', xhr.readyState, xhr.status);
            if (xhr.readyState === 4) {
                console.log('call back')
                callback(JSON.parse(xhr.responseText));
            }
        };
        xhr.open('GET', url, true);
        xhr.send();
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        PageHeader {
            id: header
            width: parent.width
            title: 'Details'
        }

        Row {
            id: row
            width: parent.width - Theme.paddingLarge * 2
            height: 100
            anchors {
                top: header.bottom
                horizontalCenter: parent.horizontalCenter
            }
            Image {
                id: coverImage
                width: 100
                height: parent.height
                fillMode: Image.PreserveAspectCrop
                source: cover
            }
            Item {
                width: parent.width - coverImage.width - Theme.paddingMedium
                height: parent.height
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: coverImage.right
                    leftMargin: Theme.paddingMedium
                }
                Label {
                    id: titleLabel
                    text: title
                    width: parent.width
                    elide: Text.ElideRight
                    truncationMode: TruncationMode.Elide
                }
                Label {
                    id: prgsLabel
                    anchors {
                        top: titleLabel.bottom
                        topMargin: Theme.paddingMedium
                    }
                    text: prgs
                }
            }
        }

        SectionHeader {
            id: sectionHeader
            width: parent.width - Theme.paddingLarge * 2
            anchors {
                top: row.bottom
                horizontalCenter: parent.horizontalCenter
            }
            text: qsTr("Episodes")
        }

        SilicaListView {
            id: listView
            width: parent.width
            height: page.height - header.height - row.height - 80
            contentHeight: childrenRect.height
            anchors {
                top: sectionHeader.bottom
                left: parent.left
            }
            model: epsModel
            delegate: ListItem {
                id: delegate

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Watched")
                        visible: mystatus !== 2
                        onClicked: {
                            Bgm.updateEps(epid, 'watched', '', function() {
                                epsModel.setProperty(index, 'mystatus', 2);
                            });
                        }
                    }
                    MenuItem {
                        text: qsTr("Queue")
                        visible: mystatus !==1
                        onClicked: {
                            Bgm.updateEps(epid, 'queue', '', function() {
                                epsModel.setProperty(index, 'mystatus', 1);
                            });
                        }
                    }
                    MenuItem {
                        text: qsTr("Drop")
                        visible: mystatus !==1
                        onClicked: {
                            Bgm.updateEps(epid, 'drop', '', function() {
                                epsModel.setProperty(index, 'mystatus', 3);
                            });
                        }
                    }
                }

                Label {
                    id: commentLabel
                    anchors {
                        verticalCenter: epTitleLabel.verticalCenter
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                    }
                    text: comment ? "(+" + comment + ")" : ""
                }

                Label {
                    id: epTitleLabel
                    x: Theme.paddingLarge
                    width: parent.width - 2*x - commentLabel.width
                    text: sort + ". " + name
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    truncationMode: TruncationMode.Elide
                    color: {
                        if (mystatus) {
                            switch (mystatus) {
                                case 1:
                                    return "#ff0000";
                                case 2:
                                    return Theme.secondaryHighlightColor;
                                case 3:
                                    return "#000000";
                            }
                        }
                        switch (status) {
                            case "aired":
                                return Theme.primaryColor;
                            case "toair":
                                return Theme.secondaryColor;
                            case "watched":
                                return Theme.secondaryHighlightColor;
                            case "onair":
                                return Theme.highlightColor;
                        }
                    }
                }

                onClicked: {
                    pageStack.push('WebViewPage.qml', {
                        'initUrl': 'https://bgm.tv/m/topic/ep/' + epid
                    });
                }
            }
        }

    }

    Component.onCompleted: {
        Bgm.getSubject(subjectId, 'large', function(resp) {
            console.log('add to model');
            var fillModel = function() {
                for (var i in resp.eps) {
                    console.log('adding', resp.eps[i].id);
                    epsModel.append({
                        epid: resp.eps[i].id,
                        type: resp.eps[i].type,
                        sort: resp.eps[i].sort,
                        name: resp.eps[i].name,
                        comment: resp.eps[i].comment,
                        airdate: resp.eps[i].airdate,
                        status: resp.eps[i].status === 'Air' ? 'aired' : 'toair',
                        mystatus: resp.eps[i].mystatus || 0
                    });
                }
            };
            Bgm.auth(user, function() {
                Bgm.getProgress(user.id, subjectId, function(resp2) {
                    for (var i in resp2.eps) {
                        var j = 0;
                        for (; j < resp.eps.length; j++) {
                            if (resp.eps[j].id === resp2.eps[i].id) {
                                console.log('ep status:', resp2.eps[i].id,
                                    resp2.eps[i].status.url_name);
                                resp.eps[j].mystatus = resp2.eps[i].status.id - 0
                                //epsModel.setProperty(j, 'mystatus', resp.eps[i].status.id-0);
                                break;
                            }
                        }
                        if (j >= resp.eps.length) {
                            console.error('EP not found:', resp.eps[i].id);
                        }
                    }
                    fillModel();
                }, function(err) {
                    console.error(err);
                    fillModel();
                });
            }, function(err) {
                console.error(err);
                fillModel();
            });
        });
    }
}
