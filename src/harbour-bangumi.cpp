#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <QTextCodec>
#include <sailfishapp.h>

#include "bgmnamfactory.h"

int main(int argc, char *argv[])
{
    QTextCodec *codec = QTextCodec::codecForName("UTF-8");
    QTextCodec::setCodecForLocale(codec);

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    BgmNAMFactory bnamf;
    view->engine()->setNetworkAccessManagerFactory(&bnamf);
    view->rootContext()->setContextProperty("networkMgr", view->engine()->networkAccessManager());

    view->setSource(SailfishApp::pathTo("qml/harbour-bangumi.qml"));
    view->show();

    return app->exec();
}

