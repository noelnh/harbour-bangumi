import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/bgm.js" as Bgm

Page {
    id: page

    property int subjectId
    property string cover
    property string title
    property string prgs

    property string nextEp: ''
    property int nextIdx: -1
    property bool nextAired: false

    property bool _loading: true

    function findSubject(sid) {
        for (var i in subjects) {
            if (subjects[i].id == sid) {
                return i
            }
        }
        return -1
    }

    function addToModel(resp) {
        epsModel.clear()
        var fillModel = function() {
            var appendToModel = function(idx) {
                epsModel.append({
                    epid: resp.eps[idx].id,
                    type: resp.eps[idx].type,
                    sort: resp.eps[idx].sort,
                    name: resp.eps[idx].name,
                    comment: resp.eps[idx].comment,
                    airdate: resp.eps[idx].airdate,
                    status: resp.eps[idx].status,
                    mystatus: resp.eps[idx].mystatus || 0,
                    loadingEp: false
                })
            }

            var sp_ids = []
            for (var i in resp.eps) {
                if (resp.eps[i].type != 0) {
                    sp_ids[sp_ids.length] = i
                    continue
                }
                appendToModel(i)
            }
            for (var i in sp_ids) {
                appendToModel(sp_ids[i])
            }

            _loading = false
            var sidx = findSubject(subjectId)
            if (sidx >= 0) {
                subjects[sidx] = resp
            } else {
                subjects.push(resp)
            }
            pageStack.pushAttached('SubjectPage.qml', {'subject': resp})

            setNextEp(0)
        }

        // TODO refresh ?
        Bgm.authCheck(current_user, function() {
            Bgm.getProgress(current_user.id, subjectId, function(resp2) {
                for (var i in resp2.eps) {
                    var j = 0
                    for (; j < resp.eps.length; j++) {
                        if (resp.eps[j].id === resp2.eps[i].id) {
                            //console.log('ep status:', resp2.eps[i].id, resp2.eps[i].status.url_name)
                            resp.eps[j].mystatus = resp2.eps[i].status.id - 0
                            //epsModel.setProperty(j, 'mystatus', resp.eps[i].status.id-0)
                            break
                        }
                    }
                    if (j >= resp.eps.length) {
                        console.error('EP not found:', resp.eps[i].id)
                    }
                }
                fillModel()
            }, function(err) {
                console.error(err)
                fillModel()
            })
        }, function(err) {
            console.error(err)
            fillModel()
        })
    }


    function reloadThisProgress() {
        _loading = true
        Bgm.getSubject(subjectId, 'large', addToModel)
    }

    function setNextEp(startAt) {
        for (var i = startAt; i < epsModel.count; i++) {
            var _ep = epsModel.get(i)
            if (_ep.mystatus !== 2 && _ep.mystatus !== 3) {
                listView.currentIndex = i
                nextEp = _ep.sort
                nextIdx = i
                nextAired = _ep.status === 'Air'
                break
            }
        }
    }

    function updateEpStatus(epid, index, statusStr, mystatus) {
        if (!epid) {
            epid = epsModel.get(index).epid
        }
        epsModel.setProperty(index, 'loadingEp', true)
        Bgm.updateEps(epid, statusStr, '', function() {
            epsModel.setProperty(index, 'loadingEp', false)
            epsModel.setProperty(index, 'mystatus', mystatus)
            setNextEp(index)
        })
    }

    function finishEps(epid, index) {
        var eps = []
        for (var i = 0; i < epsModel.count; i++) {
            var _epid = epsModel.get(i).epid
            eps.push(_epid)
            if (_epid === epid) {
                break
            }
        }
        var _eps = eps.join(',')
        console.log('finished:', _eps)

        epsModel.setProperty(index, 'loadingEp', true)
        Bgm.updateEps(epid, 'watched', _eps, function() {
            epsModel.setProperty(index, 'loadingEp', false)
            var i = 0;
            for (; i < epsModel.count; i++) {
                epsModel.setProperty(i, 'mystatus', 2)
                var _epid = epsModel.get(i).epid
                if (_epid === epid) {
                    break
                }
            }
            setNextEp(i+1)
        })
    }


    ListModel { id: epsModel }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        PageHeader {
            id: header
            width: parent.width
            title: 'Details'
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh")
                onClicked: reloadThisProgress()
            }
            MenuItem {
                text: qsTr("Collection")
                onClicked: pageStack.push('CollectionPage.qml', {
                                              'subjectId': subjectId,
                                              'subjectTitle': title
                                          })
            }
            MenuItem {
                visible: nextEp
                enabled: nextAired
                text: qsTr("Watched Ep.%1").arg(nextEp)
                onClicked: updateEpStatus(0, nextIdx, 'watched', 2)
            }
        }

        Row {
            id: row
            width: parent.width - Theme.paddingLarge * 2
            spacing: Theme.paddingMedium
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
                        visible: mystatus !== 2 && status === 'Air'
                        onClicked: updateEpStatus(epid, index, 'watched', 2)
                    }
                    MenuItem {
                        text: qsTr("Queue")
                        visible: mystatus !== 1
                        onClicked: updateEpStatus(epid, index, 'queue', 1)
                    }
                    MenuItem {
                        text: qsTr("Drop")
                        visible: mystatus !== 3 && status === 'Air'
                        onClicked: updateEpStatus(epid, index, 'drop', 3)
                    }
                    MenuItem {
                        text: qsTr("Revert")
                        visible: mystatus !== 0
                        onClicked: updateEpStatus(epid, index, 'remove', 0)
                    }
                    MenuItem {
                        text: qsTr("Finished")
                        visible: mystatus !== 2 && status === 'Air'
                        onClicked: finishEps(epid, index)
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
                    color: epTitleLabel.color
                }

                Label {
                    id: epTitleLabel
                    x: Theme.paddingLarge
                    width: parent.width - 2*x - commentLabel.width
                    text: sort + ". " + ( name.replace('&amp;', '&') || qsTr("Air on ") + airdate )
                    anchors.verticalCenter: parent.verticalCenter
                    elide: Text.ElideRight
                    truncationMode: TruncationMode.Elide
                    color: {
                        if (mystatus) {
                            switch (mystatus) {
                                case 1:     // Queue
                                    return Qt.tint(Theme.highlightColor, "#66ff0000")
                                case 2:     // Watched
                                    return Qt.lighter(Theme.secondaryHighlightColor)
                                case 3:     // Drop
                                    return Qt.darker(Theme.secondaryColor)
                            }
                        }
                        switch (status) {
                            case "Air":
                                return Theme.primaryColor
                            case "Today":
                                return Theme.highlightColor
                            case "NA":
                            default:
                                return Theme.secondaryColor
                        }
                    }
                }

                BusyIndicator {
                    anchors.centerIn: parent
                    running: loadingEp
                    size: BusyIndicatorSize.Small
                }

                onClicked: {
                    pageStack.push('WebViewPage.qml', {
                        'initUrl': 'https://bgm.tv/m/topic/ep/' + epid
                    })
                }
            }
        }

        BusyIndicator {
            anchors.centerIn: parent
            running: _loading
            size: BusyIndicatorSize.Large
        }

    }

    Component.onCompleted: {
        var sidx = findSubject(subjectId)
        if (sidx >= 0) {
            addToModel(subjects[sidx])
        } else {
            reloadThisProgress()
        }
    }

}
