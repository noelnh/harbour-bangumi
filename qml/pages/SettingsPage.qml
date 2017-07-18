import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/settings.js" as Settings
import "../js/storage.js" as Storage

Page {
    id: settingsPage

    SilicaFlickable {
        contentHeight: settingsColumn.height + Theme.paddingLarge
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                visible: false
                text: qsTr("Reset")
                onClicked: Storage.reset()
            }
        }

        Column {
            id: settingsColumn
            width: parent.width
            height: childrenRect.height

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader{
                text: qsTr("Bangumi")
            }

            BackgroundItem {
                visible: false
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
                    text: qsTr("Accounts")
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin - Theme.paddingLarge + Theme.itemSizeExtraSmall
                        verticalCenter: parent.verticalCenter
                    }
                }
                onClicked: pageStack.push("AccountsPage.qml")
            }

            SectionHeader{
                text: qsTr("Behavior")
            }

            TextSwitch {
                text: qsTr("Enable debugging")
                checked: false
                onCheckedChanged: {
                    debug = checked;
                }
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Deactivating) {
            //saveSettings();
        }
    }
}
