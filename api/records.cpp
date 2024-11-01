#include "records.h"
#include "recordparser.h"
#include "svdrpparser.h"


QDebug operator <<(QDebug dbg, const RecordEvent &event)
{
    dbg.space() << "name:" << event.name;
    dbg.space() << "channelid:" << event.channelId;
    dbg.space() << "channelname:" << event.channelName;
    dbg.space() << "title" << event.title;
    dbg.space() << "shorttext:" << event.shortText;
    dbg.space() << "start:" << event.startTime();
    dbg.space() << "dauer:" << event.getDuration();
    dbg.space() << "priority:" << event.priority;
    dbg.space() << "lifetime:" << event.lifetime;
//    dbg.space() << "description:" << event.description;
    dbg.space() << "StreamComponents:" << event.streamComponents;
    return dbg.maybeSpace();
}

Records::Records(QObject *parent) : SVDRP(parent)
{
    qDebug("Records::Records");
    connect(this, &Records::recordsFinished, this, &SVDRP::sendQuit);
    connect(this, &Records::eventFinished, this, &SVDRP::sendQuit);
    connect(this, &Records::recordMoved, this, &SVDRP::sendQuit);
    connect(this, &Records::recordDeleted, this, &Records::slotSendQuit);
    connect(this, &Records::recordPlayed, this, &SVDRP::sendQuit);
    connect(this, &Records::recordsUpdated, this, &SVDRP::sendQuit);
}

void Records::svdrpGetRecords()
{
    qDebug("Records::getRecords");
    m_records.clear();
    QString command = "LSTR";
    m_command = Commands::LSTR;
    sendCommand(command);
}

/*!
 * \brief Records::getRecordEvent
 * \param id
 * Holt zu id (=Record) den dazugehörigen Event
 * Löst danach das Signal eventFinished() aus
 */
void Records::svdrpGetRecordEvent(int id)
{
    qDebug("Records::svdrpGetRecordEvent");
    m_lastRecordId = id;
    m_command = Commands::LSTR;
    QString command = QString("LSTR %1").arg(id);
    sendCommand(command);
}

void Records::svdrpMoveRecord(int id, QString newName)
{
    qDebug("Records::svdrpMoveRecord");
    Record r(id);
    if (m_records.contains(r)) {
        m_lastRecordId = id;
        m_command = Commands::MOVR;
        QString command = QString("MOVR %1 %2").arg(id).arg(newName);
        sendCommand(command);
    }
}

void Records::svdrpDeleteRecord(int id)
{
    qDebug("Records::svdrpDeleteRecord");
    qDebug() << "Lösche Record id" << id;
            Record r(id);
    if (m_records.contains(r)) {
        m_lastRecordId = id;
        QString command = QString("DELR %1").arg(id);
        m_command = Commands::DELR;
        sendCommand(command);
    }
}

void Records::svdrpPlayRecord(int id, int type, QString time)
{
    Record r(id);
    if (!m_records.contains(r)) return;
    QString command;
    switch (type) {
    case 0:
        command = QString("PLAY %1 begin").arg(id);
        break;
    case 1:
        command = QString("PLAY %1").arg(id);
        break;
    case 2:
        command = QString("PLAY %1 %2").arg(id).arg(time);
        break;
    default:
        command = QString("PLAY %1").arg(id);
        break;
    }
    m_command = Commands::PLAY;
    sendCommand(command);
}

void Records::svdrpEditRecord(int id)
{
    Record r(id);
    if (!m_records.contains(r)) return;
    QString command = QString("EDIT %1").arg(id);
    m_command = Commands::EDIT;
    sendCommand(command);
}

void Records::svdrpUpdate()
{
    qDebug("Records::svdrpUpdate");
    QString command = "UPDR";
    m_command = Commands::UPDR;
    sendCommand(command);
}

void Records::blockSendQuit(bool block)
{
    qDebug() << "Records::blockSendQuit" << block;
    if (m_blockSendQuit == block) return;
    m_blockSendQuit = block;
    if (!m_blockSendQuit) sendQuit();
}

const QList<Record> &Records::recordList() const
{
    return m_records;
}

void Records::addRecord(QString line)
{
//    qDebug() << "Records::addRecord" << line;
    RecordParser parser;
    Record record = parser.parseLine(line);
//    qDebug() << "Record:" << record;
    m_records.append(record);
}

void Records::moveRecord(QString line)
{
    //Rückgabe "Recording "abc~def" moved to "qwertz~xyz"
    Record r(m_lastRecordId);
    int index = m_records.indexOf(r);
    if (index != -1) {
        r = m_records.at(index);
        QStringList l = line.split("moved to");
        QString s = l.at(1).trimmed();
        if (s.endsWith("\"")) s.chop(1);
        if (s.startsWith("\"")) s = s.remove(0,1);
        r.setName(s);
        m_records.replace(index,r);
        emit recordMoved(r);
    }
}

void Records::deleteRecord(QString line)
{
    qDebug() << "Records::deleteRecord" << line;
    // Rückgabe: "Recording \"id\" deleted"
    QString s = line.section("\"",1,1);
    int id = s.toInt();
    Record r(id);
    int index = m_records.indexOf(r);
    if (index != -1) {
        r = m_records.takeAt(index);
        emit recordDeleted(r);
    }
}

void Records::playRecord(QString line)
{
    qDebug() << "Records::playRecord" << line;
    //Rückgabe z.B.: "Playing recording \"127\" [27.02.23 22:30  Serien~The Orville - New Horizons~Domino Abenteuer, USA 2022 Altersfreigabe: ab 12]"
    QString s = line.section("\"",1,1);
    int id = s.toInt();
    Record r(id);
    int index = m_records.indexOf(r);
    if (index != -1) emit recordPlayed(m_records.at(index));
}

void Records::editRecord(QString line)
{
    qDebug() << "Records::editRecord" << line;
    // Rückgabe: "Editing Recording \"id\" [...]"
    QString s = line.section("\"",1,1);
    int id = s.toInt();
    Record r(id);
    int index = m_records.indexOf(r);
    if (index != -1) emit recordEdited(m_records.at(index));
}

void Records::addEvent(QString line)
{
    //    qDebug("Records::parseEvent()");
    //    qDebug() << line;

    //Ende Event: End of recording information
    if (line.startsWith("End of")) return;

    if (!m_recordEvent) m_recordEvent = new RecordEvent();

    char firstChar = line.at(0).toLatin1();

    line.remove(0,1);
    QString s = line.trimmed();

    switch (firstChar) {
    case 'C': {
        int i = s.indexOf(" ");
        m_recordEvent->channelId = s.left(i);
        m_recordEvent->channelName = s.remove(0,i).trimmed();
        break;
    }
    case 'E': {
        QStringList list = s.split(" ");
        m_recordEvent->id = list.at(0).toUInt();
        m_recordEvent->setStarttime(list.at(1).toInt());
        m_recordEvent->setDuration(list.at(2).toInt());
        break;
    }
    case 'T': m_recordEvent->title = s; break;
    case 'S': m_recordEvent->shortText = s; break;
    case 'D': s = s.replace("|","\n"); m_recordEvent->description = s.trimmed(); break;
    case 'V': m_recordEvent->vps = s.toInt(); break;
    case 'P': m_recordEvent->priority = s.toInt(); break;
    case 'L': m_recordEvent->lifetime = s.toInt(); break;
    case 'X': m_recordEvent->streamComponents.append(parseStreamComponenet(s)); break;
    case 'F': m_recordEvent->frames = s.toInt(); break;
    case 'O': m_recordEvent->errors = s.toInt(); break;
    }
}

void Records::closeEvent()
{
    qDebug("Records::closeEvent()");

    if (!m_recordEvent) return;

    Record r(m_lastRecordId);
    int index = m_records.indexOf(r);
    if (index >= 0) {
        Record r = m_records.at(index);
        m_recordEvent->name = r.getName();
    }
    RecordEvent e = *m_recordEvent;
    delete m_recordEvent;
    m_recordEvent = nullptr;
    emit eventFinished(e);
}

StreamComponent Records::parseStreamComponenet(QString stream)
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

void Records::slotSendQuit()
{
    // qDebug() << "Records::slotSendQuit" << m_blockSendQuit;
    if (!m_blockSendQuit) sendQuit();
}


void Records::readyRead()
{
    //    qDebug("Records::readyRead()");

    while (m_tcpSocket.canReadLine()) {
        QString s = m_tcpSocket.readLine();
        //        qDebug() << "Line:" << s;
        SVDRPParser line(s);

       // qDebug() << "code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        if (line.isErrorCode()) {
            QString error = QString("%1: %2").arg(line.code()).arg(line.message());
            emit svdrpError(error);
            return;
        }

        //Recordzeile
        if (line.code() == 250) {
            switch (m_command) {
            case Commands::LSTR: addRecord(line.message()); break;
            case Commands::DELR: deleteRecord(line.message()); break;
            case Commands::MOVR: moveRecord(line.message()); break;
            case Commands::UPDR: break;
            case Commands::PLAY: playRecord(line.message()); break;
            case Commands::EDIT: editRecord(line.message()); break;
            }
        }

        //EPG Eintrag
        if (line.code() == 215) {
            addEvent(line.message());
        }

        if (line.lastLine() && m_tcpSocket.atEnd()) {
            qDebug("Records::readyRead Ende");
            switch (line.code()) {
            case 250:
                //Ende LSTR
                if (m_command == Commands::LSTR) {
                    emit recordsFinished();
                }
                else if (m_command == Commands::UPDR) {
                    emit recordsUpdated();
                }
                break;
            case 215:
                //Ende LSTR id, also Abfrage eines Events
                closeEvent();
                break;
            }
            //            return;
        }
    }
    //        if ((line.code() == 215) && (m_command == Commands::LSTR)) parseEvent(line.message());

}

RecordEvent::RecordEvent()
{
}

RecordEvent::~RecordEvent()
{
}
