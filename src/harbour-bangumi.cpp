#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>

#include "bgmnamfactory.h"

int main(int argc, char *argv[])
{
    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());

    BgmNAMFactory bnamf;
    view->engine()->setNetworkAccessManagerFactory(&bnamf);

    view->setSource(SailfishApp::pathTo("qml/harbour-bangumi.qml"));
    view->show();

    return app->exec();
}

