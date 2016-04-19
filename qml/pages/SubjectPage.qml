import QtQuick 2.2
import Sailfish.Silica 1.0


Page {
    id: subjectPage

    property var subject

    function getLabel(label) {
        switch (label) {
            case 'staff':
                return qsTr("Staff [TODO]");
            case 'crt':
                return qsTr("Characters [TODO]");
            case 'topic':
                return qsTr("Topics [TODO]");
        }
    }


    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: header.height + mainColumn.height + exList.height + Theme.paddingLarge

        PageHeader {
            id: header
            width: parent.width
            title: subject.name
        }

        Column {
            id: mainColumn
            width: parent.width - Theme.paddingMedium * 2
            spacing: Theme.paddingMedium

            anchors {
                top: header.bottom
                horizontalCenter: parent.horizontalCenter
            }

            Item {
                height: childrenRect.height
                width: parent.width
                Image {
                    id: coverImage
                    anchors {
                        top: parent.top
                        left: parent.left
                    }
                    width: 200
                    fillMode: Image.PreserveAspectFit
                    source: subject.images.large
                }
                Column {
                    height: coverImage.height > 280 ? coverImage.height : 280
                    width: parent.width - coverImage.width - Theme.paddingLarge

                    anchors {
                        top: parent.top
                        left: coverImage.right
                        leftMargin: Theme.paddingLarge
                    }

                    Label {
                        id: dateLabel
                        width: parent.width
                        text: qsTr("Since ") + subject.air_date
                        horizontalAlignment: Text.AlignRight
                    }
                    Label {
                        text: " "
                    }
                    Label {
                        width: parent.width
                        color: Theme.secondaryColor
                        text: qsTr("Watching: ") + subject.collection.doing +
                              qsTr("\nWish: ")     + subject.collection.wish  +
                              qsTr("\nFinished: ") + subject.collection.collect +
                              qsTr("\nOn hold: ")  + subject.collection.on_hold +
                              qsTr("\nDropped: ")  + subject.collection.dropped
                    }
                }
            }
            SectionHeader {
                text: qsTr("Summary")
            }
            Label {
                id: summaryLabel
                width: parent.width
                text: subject.summary
                wrapMode: Text.WordWrap
            }
        }

        ListView {
            id: exList
            width: parent.width
            height: childrenRect.height
            anchors {
                top: mainColumn.bottom
                topMargin: Theme.paddingMedium
            }

            model: ListModel {
                ListElement {
                    label: 'staff'
                    page: 'StaffListPage.qml'
                }
                ListElement {
                    label: 'crt'
                    page: 'CharaListPage.qml'
                }
                ListElement {
                    label: 'topic'
                    page: 'TopicListPage.qml'
                }
            }

            delegate: ListItem {
                id: topicItem
                width: parent.width
                Image {
                    id: rightIcon
                    anchors {
                        right: parent.right
                        rightMargin: Theme.paddingSmall
                        verticalCenter: parent.verticalCenter
                    }
                    source: 'image://theme/icon-m-right'
                }
                Label {
                    text: getLabel(label)
                    anchors {
                        right: rightIcon.left
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                }
                //onClicked: pageStack.push(page, {'items': subject[label]})
            }
        }
    }
}
