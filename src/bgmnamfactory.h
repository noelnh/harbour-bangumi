#ifndef BGMNAMFACTORY_H
#define BGMNAMFACTORY_H

#include <QObject>
#include <QQmlNetworkAccessManagerFactory>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

class BgmNAMFactory : public QQmlNetworkAccessManagerFactory
{
public:
    virtual QNetworkAccessManager *create(QObject *parent);
};


class BgmNetworkAccessManager : public QNetworkAccessManager
{
    Q_OBJECT

public:
    BgmNetworkAccessManager(QObject *parent = 0);

protected:
    virtual QNetworkReply *createRequest(Operation op, const QNetworkRequest &request, QIODevice *outgoingData);

public slots:
    bool removeCache(const QString &url);
    void clearCache();
};

#endif // BGMNAMFACTORY_H
