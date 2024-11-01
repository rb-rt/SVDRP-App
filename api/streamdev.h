#ifndef STREAMDEV_H
#define STREAMDEV_H

#include "data/record.h"
#include "qnetworkaccessmanager.h"
#include "qurl.h"
#include <QObject>
#include <QNetworkReply>


class StreamRecord
{

public:
    int nr = -1;
    QUrl url;
    QDateTime start;
    QString name;
};



class Streamdev : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    explicit Streamdev(QObject *parent = nullptr);

    QUrl url() const;
    void setUrl(const QUrl &newUrl);

    Q_INVOKABLE void streamRecord(const Record &record);

private:

    QUrl m_url;
    QNetworkAccessManager m_nam;
    QNetworkReply *m_reply;

    QMap<int,StreamRecord> m_recordings; //Enthält die Recordings mit nr als key

    bool m_isRss = false; //abgerufene Seite ist recordings.rss?
    bool m_isItem = false;
    Record m_streamRecord; //der abzuspielende Record
    QString m_title;
    QString m_link;

    void getRecordings();

    QString extractTitle(QString title); //title aus dem rss-File
    QString extractLink(QString link); //link aus dem rss-File
    StreamRecord parseRecord(QString title, QString link);


private slots:

    void slotReadyRead();
    void slotError(QNetworkReply::NetworkError code);
    void slotRecordingsFinished();

signals:

    void urlChanged();
    void recordingsFinished();
    void error(QString error);
    void streamUrlFinished(QUrl url);
};

#endif // STREAMDEV_H
