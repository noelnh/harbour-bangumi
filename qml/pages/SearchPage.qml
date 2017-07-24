import QtQuick 2.2
import Sailfish.Silica 1.0

import "../js/bgm.js" as Bgm

Page {
    id: searchPage

    property bool isSearchPage: true

    property bool _loadingSubjects: false

    property var continents: ["Africa", "Antarctica", "Asia", "Europe", "North America", "Oceania", "South America"]

    ListModel { id: listModel }

    PageHeader {
        id: pageHeader
        title: qsTr("Bangumi")
    }

    SilicaListView {
        id: searchList

        width: parent.width
        height: parent.height - pageHeader.height
        anchors.top: pageHeader.bottom

        header: SearchField {
            id: searchField
            width: parent.width
            placeholderText: "Search"

            EnterKey.enabled: searchField.text
            EnterKey.text: qsTr("Go")
            EnterKey.onClicked: doSearch(searchField.text)

            onTextChanged: {
                console.log("text changed", text)
                updateList(text)
            }
        }

        // prevent newly added list delegates from stealing focus away from the search field
        currentIndex: -1

        model: listModel

        delegate: ListItem {
            Label {
                anchors {
                    left: parent.left
                    leftMargin: searchList.headerItem.textLeftMargin
                    verticalCenter: parent.verticalCenter
                }
                text: (icon ? icon + ' ' : '') + name
            }
            onClicked: {
                if (sid) {
                    pageStack.push('SubjectPage.qml', {'subjectId': sid, 'isAttached': false})
                }
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: _loadingSubjects
    }

    Component.onCompleted: updateList("")

    function updateList(searchTerm) {
        listModel.clear()
        for (var i=0; i<continents.length; i++) {
            if (searchTerm == "" || continents[i].indexOf(searchTerm) >= 0) {
                listModel.append({"name": continents[i], "sid": 0, "icon": ''})
            }
        }
    }

    function doSearch(searchTerm) {
        // Search subject id
        var prefix3 = searchTerm.substr(0,3).toLowerCase()
        if (prefix3 === "id:" || prefix3 === "id " || prefix3 === "id=") {
            var sid = searchTerm.substring(3)
            if (!isNaN(sid)) {
                pageStack.push('SubjectPage.qml', {'subjectId': sid, 'isAttached': false})
                return
            }
        }
        // Else search in content
        loadMoreSubjects(searchTerm, 0)
    }

    function loadMoreSubjects(searchTerm, startAt) {
        if (startAt === 0) listModel.clear()
        _loadingSubjects = true
        Bgm.search(searchTerm, startAt, 10, 'simple', addToList)
    }

    function addToList(result) {
        _loadingSubjects = false
        if (result && result.list) {
            var subjects = result.list;
            for (var i = 0; i < subjects.length; i++) {
                listModel.append({
                                     "name": subjects[i].name,
                                     "sid": subjects[i].id,
                                     "icon": getTypeIcon(subjects[i].type)
                                 })
            }
            if (subjects.length === 0) {
                msgOverlay.showMsg("Not found", 1)
            }
        }
    }

    function getTypeIcon(typeId) {
        switch (typeId) {
            case 1:
                return '📖';
            case 2:
                return '📺';
            case 3:
                return '🎵';
            case 4:
                return '🎮';
            case 6:
                return '📺';
            default:
                return '📺';
        }
    }
}
