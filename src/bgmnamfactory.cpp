#include <QNetworkDiskCache>
#include <QStandardPaths>
#include <QDir>

#include "bgmnamfactory.h"

QNetworkAccessManager *BgmNAMFactory::create(QObject *parent)
{
    QNetworkAccessManager *nam = new BgmNetworkAccessManager(parent);

    QNetworkDiskCache* diskCache = new QNetworkDiskCache(parent);
    QString dataPath = QStandardPaths::standardLocations(QStandardPaths::CacheLocation).at(0);
    QDir dir(dataPath);
    if (!dir.exists()) dir.mkpath(dir.absolutePath());

    diskCache->setCacheDirectory(dataPath);
    diskCache->setMaximumCacheSize(30*1024*1024);
    nam->setCache(diskCache);

    return nam;
}


BgmNetworkAccessManager::BgmNetworkAccessManager(QObject *parent) : QNetworkAccessManager(parent)
{
}

QNetworkReply *BgmNetworkAccessManager::createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData)
{

    QNetworkRequest rqst(request);
    QString url = rqst.url().toString();

    if (url.endsWith(".gif") || url.endsWith(".png") || url.endsWith(".jpg"))
    {
        rqst.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);
    } else {
        rqst.setAttribute(QNetworkRequest::CacheSaveControlAttribute, false);
    }

    QNetworkReply *reply = QNetworkAccessManager::createRequest(op, rqst, outgoingData);

    return reply;
}

bool BgmNetworkAccessManager::removeCache(const QString &url)
{
    return this->cache()->remove(url);
}

void BgmNetworkAccessManager::clearCache()
{
    this->cache()->clear();
}
