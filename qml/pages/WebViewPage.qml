import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    property string initUrl: "https://bgm.tv/m"

    SilicaWebView {
        id: webView

        PullDownMenu {
            MenuItem {
                text: webView.loading ? qsTr("Stop") : qsTr("Reload")
                onClicked: {
                    webView.loading ? webView.stop() : webView.reload()
                }
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr("Open in Browser")
                onClicked: {
                    Qt.openUrlExternally(initUrl);
                }
            }
        }

        anchors.fill: parent

        experimental.userAgent: "Mozilla/5.0 (Maemo; Linux; U; Jolla; Sailfish; Mobile; rv:31.0) AppleWebKit/537.36 (KHTML, like Gecko)"

        BusyIndicator {
            size: BusyIndicatorSize.Large
            anchors.centerIn: parent
            running: webView.loading
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            webView.url = initUrl;
        }
    }
}
