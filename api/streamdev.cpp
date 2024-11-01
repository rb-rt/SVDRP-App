#include "streamdev.h"

Streamdev::Streamdev(QObject *parent) : QObject(parent)
{
    connect(this, &Streamdev::recordingsFinished, this, &Streamdev::slotRecordingsFinished);
}

void Streamdev::getRecordings()
{
    qDebug("Streamdev::getRecordings()");
    if (m_url.isEmpty()) return;
    m_isRss = false;
    m_url.setPath("/recordings.rss");
    QNetworkRequest request = QNetworkRequest(m_url);
    request.setHeader(QNetworkRequest::ContentTypeHeader,"application/rss+xml; charset=utf-8");
    m_reply = m_nam.get(request);
    connect(m_reply, &QNetworkReply::errorOccurred, this, &Streamdev::slotError);
    connect(m_reply, &QNetworkReply::readyRead, this, &Streamdev::slotReadyRead);
}

void Streamdev::streamRecord(const Record &record)
{
    if (m_recordings.isEmpty()) {
        m_streamRecord = record;
        getRecordings();
    }
    else {
        QMap<int,StreamRecord>::ConstIterator it;
        for (it = m_recordings.constBegin(); it != m_recordings.constEnd(); ++it) {
            if (it->start != record.getStartDateTime()) continue;
            if (it->name == record.getName()) {
                emit streamUrlFinished(it->url);
                break;
            }
        }
    }
}

QString Streamdev::extractTitle(QString title)
{
    //Übergabe: "<title>331 01.02.21 21:43 Dokumentationen~Natur~Das Große Barriere-Riff (3/3)</title>"
    QString s = title.remove(0,7); //Entfernt <title>
    s.chop(8); //Entfernt </title>
    return s;
}

QString Streamdev::extractLink(QString link)
{
    //Übrgabe: <link>http://vdrserver:3000/34:35782694.rec</link>"
    QString s = link.remove(0,6); //Entfernt <link>
    s.chop(7); //Entfernt </link>
    return s;
}

StreamRecord Streamdev::parseRecord(QString title, QString link)
{
    //Title: "331 01.02.21 21:43 Dokumentationen~Natur~Das Große Barriere-Riff (3/3)"
    StreamRecord r;
    QStringList list = title.split(" ");
    bool ok;
    int nr = list.at(0).toInt(&ok);
    if (!ok) return r;
    list.removeFirst();
    QDateTime d = QDateTime::fromString(list.at(0),"dd.MM.yy");
    if (!d.isValid()) return r;
    if (d.date().year() < 2000) d = d.addYears(100);
    list.removeFirst();
    QTime t = QTime::fromString(list.at(0), "hh:mm");
    if (!t.isValid()) return r;
    d.setTime(t);
    list.removeFirst();
    r.name = list.join(" ");
    r.start = d;

    QUrl u(link);
    if (!u.isValid()) return r;

    r.nr = nr;
    r.url = u;
    return r;
}

QUrl Streamdev::url() const
{
    return m_url;
}

void Streamdev::setUrl(const QUrl &newUrl)
{
    if (m_url == newUrl) return;
    m_url = newUrl;
    emit urlChanged();
}


void Streamdev::slotReadyRead()
{
//    qDebug("Streamdev::slotReadyRead()");

    while (m_reply->canReadLine()) {
        QString s = m_reply->readLine().trimmed();

       // qDebug() << "Streamdev::slotReadyRead()" << s;

        if (s == "<channel>") m_isRss = true;

        if (s.startsWith("<item>")) {
            m_isItem = true;
        }
        else if (s.endsWith("</item>")) {
            m_isItem = false;
            StreamRecord r = parseRecord(m_title, m_link);
            if (r.nr != -1) m_recordings.insert(r.nr, r);
            m_title.clear();
            m_link.clear();
        }

        if (m_isItem) {
            if (s.startsWith("<title>")) {
                m_title = extractTitle(s);
            }
            else if (s.startsWith("<link>")) {
                m_link = extractLink(s);
            }
        }

        if (s == "</channel>") {
//            m_reply->close(); //Erzeugt ein "Abgebrochen" Fehler
            m_reply->deleteLater();
            emit recordingsFinished();
        }
    }
    if (m_reply->atEnd()) {
        if (!m_isRss) {
            emit error("Abgerufene recordings.rss ungültig");
            m_reply->deleteLater();
        }
    }
}

void Streamdev::slotError(QNetworkReply::NetworkError code)
{
    Q_UNUSED(code)
    emit error(m_reply->errorString());
    m_reply->deleteLater();
}

void Streamdev::slotRecordingsFinished()
{
    qDebug("Streamdev::slotRecordingsFinished()");
    streamRecord(m_streamRecord);
}
