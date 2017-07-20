import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/bgm.js" as Bgm
import "../js/accounts.js" as Accounts

Page {
    id: collectionPage

    property int subjectId
    property string subjectTitle

    property string _statusValue

    property bool _updateLock: false


    ListModel { id: ratingModel }

    ListModel { id: tagsModel }

    SilicaFlickable {
        id: collectionFlickable
        anchors.fill: parent
        contentHeight: collectionColumn.height

        PullDownMenu {
            MenuItem {
                text: qsTr("Save")
                onClicked: updateCollection()
            }
        }

        Column {
            id: collectionColumn
            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: subjectTitle
            }

            ComboBox {
                id: statusCombo
                label: qsTr("Status")
                menu: ContextMenu {
                    MenuItem {
                        property string _value: 'wish'
                        text: qsTr("Queue")
                    }
                    MenuItem {
                        property string _value: 'collect'
                        text: qsTr("Watched")
                    }
                    MenuItem {
                        property string _value: 'do'
                        text: qsTr("Watching")
                    }
                    MenuItem {
                        property string _value: 'on_hold'
                        text: qsTr("Hold up")
                    }
                    MenuItem {
                        property string _value: 'dropped'
                        text: qsTr("Drop")
                    }
                }
                onValueChanged: _statusValue = currentItem._value
            }

            ComboBox {
                id: ratingCombo
                label: qsTr("Rating")
                menu: ContextMenu {
                    Repeater {
                        id: ratingRepeater
                        model: ratingModel
                        delegate: MenuItem {
                            text: _rating
                        }
                    }
                }
            }

            TextArea {
                id: commentArea
                width: parent.width
                label: qsTr("Comment")
                placeholderText: label
            }

            TextField {
                id: tagAddField
                width: parent.width
                label: qsTr("Add Tag")
                placeholderText: label

                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: 'image://theme/icon-m-enter-accept'
                EnterKey.onClicked: addTag(text)
            }

            Repeater {
                id: tagsRepeater
                width: parent.width

                model: tagsModel

                delegate: ListItem {
                    contentHeight: Theme.itemSizeSmall
                    menu: ContextMenu {
                        MenuItem {
                            text: qsTr("Remove")
                            onClicked: removeTag(tagName)
                        }
                    }

                    Label {
                        anchors {
                            left: parent.left
                            leftMargin: leftPadding
                            verticalCenter: parent.verticalCenter
                        }
                        color: Theme.secondaryHighlightColor
                        text: tagName
                    }

                    onClicked: tagAddField.text = tagName
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: _updateLock
        size: BusyIndicatorSize.Large
    }

    Component.onCompleted: {
        fillStars()
        getCollection()
    }

    function addTag(tagsStr) {
        var tags = tagsStr.split(' ')
        tags.forEach(function(tag) {
            for (var i = 0; i < tagsModel.count; i++) {
                if (tagsModel.get(i).tagName === tag)
                    return
            }
            tagsModel.insert(0, { tagName: tag })
            tagAddField.text = ''
        })
    }

    function removeTag(tag) {
        console.log(tagsModel.count)
        for (var i = 0; i < tagsModel.count; i++) {
            console.log (tagsModel.get(i).tagName, tag)
            if (tagsModel.get(i).tagName === tag)
                tagsModel.remove(i)
        }
    }

    function fillStars() {
        ratingModel.clear()
        for (var i = 0; i < 11; i++) {
            var _rating = new Array(i+1).join('★') + new Array(11-i).join('☆') + ' ' + i
            ratingModel.append({_rating: _rating})
        }
        tagsModel.append({ tagName: '2017'})
    }

    function getCollection() {
        Bgm.authCheck(current_user, function(_user) {
            Bgm.getCollection(subjectId, function(colle) {
                //colle.rating: number
                ratingCombo.currentIndex = colle.rating

                //colle.status: {id, type, name}
                statusCombo.currentIndex = colle.status.id - 1

                //colle.tag: ['']
                tagsModel.clear()
                colle.tag.forEach(function(tagName) {
                    tagsModel.insert(0, {'tagName': tagName} )
                })

                //colle.comment: str
                commentArea.text = colle.comment
            })
        })
    }

    function updateCollection() {

        var rating = ratingCombo.currentIndex

        var tags = ''
        for (var i = tagsModel.count - 1; i >= 0; i--) {
            tags += tagsModel.get(i).tagName + ' '
        }

        var comment = commentArea.text

        _updateLock = true
        Bgm.authCheck(current_user, function(_user) {
            console.log(subjectId, rating, _statusValue, tags, comment)
            Bgm.updateCollection(subjectId, rating, _statusValue, tags, comment, function(newColle) {
                _updateLock = false
                msgOverlay.showMsg("Updated")
            }, function(err) {
                _updateLock = false
                msgOverlay.showMsg(err, 1)
            })
        })
    }
}
