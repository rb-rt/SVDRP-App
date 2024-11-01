#include "events.h"
#include "svdrpparser.h"

Events::Events(QObject *parent) : SVDRP(parent)
{
    connect(this, &Events::eventsFinished, this, &Events::slotSendQuit);
}

void Events::svdrpGetEvents(Schedule schedule)
{
    qDebug("Events::svdrpGetEvents(Schedule)");

    QString command = "LSTE";

    switch (schedule) {
    case now:
        command.append(" now");
        break;
    case next:
        command.append(" next");
        break;    
    default:
        command.append(" now");
    }
    m_events.clear();
    sendCommand(command);
}

void Events::svdrpGetEvents(QString channel_id)
{
    qDebug("Events::svdrpGetEvents(QString channel_id)");
    m_events.clear();
    QString command = "LSTE " + channel_id;
    sendCommand(command);
}

void Events::svdrpGetEvents(qint64 time)
{
    qDebug("Events::svdrpGetEvents(qint64 time)");
    QString command = QString("LSTE at %1").arg(time);
    m_events.clear();
    sendCommand(command);
}

void Events::svdrpGetEvent(QString channel_id, qint64 time)
{
    // qDebug("Events::svdrpGetEvent(QString channel_id, int time)");
    if (channel_id.isEmpty()) return;
    int jetzt = QDateTime::currentSecsSinceEpoch();
    if (time < jetzt) time = jetzt;// return;
    m_events.clear();
    QString command = QString("LSTE %1 at %2").arg(channel_id).arg(time);
    sendCommand(command);
}

const QList<Event> &Events::eventList() const
{
    return m_events;
}

void Events::blockSendQuit(bool block)
{
    qDebug() << "Events::setSendQuit" << block;
    if (block == m_blockSendQuit) return;
    m_blockSendQuit = block;
    if (!m_blockSendQuit) sendQuit();
}

void Events::addEvent(QString line)
{
    //    qDebug() << "Events::addEvent()" << line ;

    if (!m_newEvent) m_newEvent = new Event();

    char firstChar = line.at(0).toLatin1();

    line.remove(0,1);
    QString s = line.trimmed();

    switch (firstChar) {
    case 'C': {
        int i = s.indexOf(" ");
        m_newEvent->channelId = s.left(i);
        m_newEvent->channelName = s.remove(0,i).trimmed();

        m_lastChannelId = m_newEvent->channelId;
        m_LastChannelName = m_newEvent->channelName;
        m_noEvent = true;
        break;
    }
    case 'E': {
        QStringList list = s.split(" ");
        m_newEvent->id = list.at(0).toInt();
        m_newEvent->setStarttime(list.at(1).toInt());
        m_newEvent->setDuration(list.at(2).toInt());
        m_newEvent->table_id = list.at(3).toInt();
        m_newEvent->version = list.at(4).toInt();

        m_newEvent->channelId = m_lastChannelId;
        m_newEvent->channelName = m_LastChannelName;
        break;
    }
    case 'T': m_newEvent->title = s; break;
    case 'S': m_newEvent->shortText = s; break;
    case 'D': s = s.replace("|","\n"); m_newEvent->description = s.trimmed(); break;
    case 'V': m_newEvent->vps = s.toInt(); break;
    case 'G': m_newEvent->addGenres(s); break;
    case 'X': m_newEvent->streamComponents.append(parseStreamComponent(s)); break;
    case 'R': m_newEvent->parental_rating = s.toInt();
    }
}

void Events::closeEvent()
{
       // qDebug("Events::closeEvent()");

    if (!m_newEvent) return;
    Event e;
    e = *m_newEvent;
    m_events.append(e);
    delete m_newEvent;
    m_newEvent = nullptr;
    m_noEvent = false;
    emit eventFinished(e);
}

void Events::closeChannel()
{
    //    qDebug("Events::closeEvent()");
    m_lastChannelId = "";
    m_LastChannelName = "";
    m_lastChannelNumber = 0;
    if (m_noEvent) emit eventFinished(Event());
}

StreamComponent Events::parseStreamComponent(QString stream)
{
    QStringList l = stream.split(" ");
    StreamComponent sc;
    bool ok;
    int i = l.at(0).toInt(&ok, 16);
    if (ok) sc.content = i;
    l.removeFirst();
    i = l.at(0).toInt(&ok, 16);
    if (ok) sc.type = i;
    l.removeFirst();
    sc.language = l.at(0);
    l.removeFirst();
    sc.description = l.join(" ");
    return sc;
}

void Events::slotSendQuit()
{
    // qDebug() << "Events::slotSendQuit" << m_sendQuit;
    if (!m_blockSendQuit) sendQuit();
}

void Events::readyRead()
{
    //        qDebug("Events::readyRead()");

    while (m_tcpSocket.canReadLine()) {
        QString s = m_tcpSocket.readLine();

        SVDRPParser line(s);
        // qDebug() << "code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        if (line.isErrorCode()) {
            QString error = QString("%1: %2").arg(line.code()).arg(line.message());
            emit svdrpError(error);
            return;
        }

        if (line.code() != 215) continue; //215 = EPG-Data

        QChar firstChar = line.message().at(0);

        if (!line.lastLine()) {
            if (EventCharacters.contains(firstChar)) {
                //            qInfo("Zeichen gefunden!");
                addEvent(line.message());
            }
            else if (firstChar == 'e') {
                closeEvent();
            }
            else if (firstChar == 'c') {
                closeChannel();
            }
        }
        else {
            emit eventsFinished();
            return;
        }
    }
}

