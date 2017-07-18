import QtQuick 2.2
import Sailfish.Silica 1.0

CoverBackground {

    Image {
        id: coverImage
        anchors {
            top: parent.top
            topMargin: Theme.paddingLarge * 2
            horizontalCenter: parent.horizontalCenter
        }
        source: ""
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-search"
            //onTriggered: TODO
        }
    }

    onStatusChanged: {
        if (prgModel.count > 0) {
            coverImage.source = prgModel.get(current_idx).coverC;
        } else {
            coverImage.source = "../img/harbour-bangumi.png";
        }
    }
}


