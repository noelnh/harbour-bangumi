import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/settings.js" as Settings
import "../js/storage.js" as Storage

Page {
    id: settingsPage

    property int _weekday_type: weekday_type

    SilicaFlickable {
        contentHeight: settingsColumn.height + Theme.paddingLarge
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                visible: false
                text: qsTr("Reset")
                onClicked: Storage.reset()
            }
            MenuItem {
                text: qsTr("Clear cache")
                onClicked: networkMgr.clearCache()
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

            ComboBox {
                label: qsTr("Weekday")

                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Default")
                    }
                    MenuItem {
                        text: qsTr("Japanese")
                    }
                    MenuItem {
                        text: qsTr("Chinese")
                    }
                }

                currentIndex: _weekday_type

                onValueChanged: weekday_type = currentIndex
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
            if (_weekday_type != weekday_type)
                Settings.write('weekday_type', weekday_type)
        }
    }
}
