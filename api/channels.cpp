#include "channels.h"
#include "channelparser.h"
#include "svdrpparser.h"

Channels::Channels(QObject *parent) : SVDRP(parent)
{
    qDebug("Channels::Channels()");
    connect(this, &Channels::channelsFinished, this, &SVDRP::sendQuit);
    connect(this, &Channels::channelUpdated, this, &SVDRP::sendQuit);
    connect(this, &Channels::channelSwitched, this, &SVDRP::sendQuit);
    // connect(this, &Channels::channelDeleted, this, &SVDRP::sendQuit); nicht notwendig, es werden vom Model sofort alle Kanäle neu eingelesen
}

void Channels::svdrpGetChannels()
{
    qDebug("Channels::svdrpGetChannels()");
    m_useId = true;
    m_command = Commands::LSTC;
    m_channels.clear();
    m_channelsHash.clear();
    m_groupNumber = 0;
    m_groups.clear();
    sendCommand("LSTC :ids :groups");
}

void Channels::svdrpDeleteChannel(QString channel_id)
{
    qDebug("Channels::svdrpDeleteChannel");
    m_command = Commands::DELC;
    QString s = QString("DELC %1").arg(channel_id);
    sendCommand(s);
}

void Channels::svdrpMoveChannel(int nr, int to)
{
    qDebug("Channels::svdrpMoveChannel");
    if (nr == to) return;
    m_useId = false;
    m_command = Commands::MOVC;
    QString s = QString("MOVC %1 %2").arg(nr).arg(to);
    sendCommand(s);
}

void Channels::svdrpUpdateChannel(Channel &ch)
{
    qDebug("Channels::svdrpUpdateChannel(Channel)");
    if (!ch.isValid()) return;
    m_useId = false;
    QString settings = ch.getParameterLine();
    m_command = Commands::MODC;
    QString command = QString("MODC %1 ").arg(ch.number) + settings;
    sendCommand(command);
}

void Channels::svdrpSwitchToChannel(QString channel_id)
{
    m_command = Commands::CHAN;
    QString s = "CHAN " + channel_id;
    sendCommand(s);
}

const QList<Channel> &Channels::channelList() const
{
    return m_channels;
}

Channel Channels::getChannel(int channel_nr)
{
    for (const Channel &ch :  m_channels) {
        if (ch.number == channel_nr) return ch;
    }
    return Channel();
}

Channel Channels::getChannel(QString channel_id)
{
    int index = m_channelsHash.value(channel_id,-1);
    if ((index >= 0) && (index < m_channels.count())) {
        return m_channels.at(index);
    }
    else {
        return Channel();
    }
}

const QMap<int, QString> &Channels::groups() const
{
    return m_groups;
}

void Channels::addChannel(QString line)
{
    //    qDebug("Channels::addChannel");

    ChannelParser parser(m_useId);
    Channel ch = parser.parseLine(line);

    //Channel Groupseparator
    if (ch.number == 0 && !ch.name.isEmpty()) {
        m_groupNumber++;
        m_groups.insert(m_groupNumber, ch.name);
    }
    if (ch.isValid()) {
        if (!m_channels.contains(ch)) {
            ch.group = m_groupNumber;
            m_channels.append(ch);
            m_channelsHash.insert(ch.channel_id, m_channels.count()-1);
        }
    }
}

void Channels::updateChannel(QString line)
{
    qDebug("Channels::updateChannel");

    ChannelParser parser(m_useId);
    Channel ch = parser.parseLine(line);
    if (ch.isValid()) {
        int index = m_channels.indexOf(ch);
        if (index != -1) {
            ch.group = m_channels.at(index).group; //Kanalgruppe wieder zuweisen
            m_channels.replace(index,ch);
            emit channelUpdated(ch);
        }
    }
}

void Channels::moveChannel(QString line)
{
    qDebug("Channels::moveChannel");
    /* Vom VDR kommt bei erfolreicher Verschiebung folgendes zurück
     * 220: VDRSERVER SVDRP VideodiskReorder ...
     * 250: "Channel \"xy\" moved to \"yz\" zurück (Übergabe in line)
     * 221: VDRSERVER closing connection
     *
     * bei einem Fehler (2. Zeile)
     * 501: Fehlernachricht
     */

    QStringList split = line.split("\"");
    int nr = split.at(1).toInt();
    int to = split.at(3).toInt();

    if (nr == 0 || to == 0){
        emit svdrpError("Konnte Kanäle nicht verschieben");
    }
}

void Channels::switchChannel(QString line)
{
    qDebug("Channels::switchChannel (QString line)");
    // Rückgabe: kanalnr kanalname

    QStringList sl = line.split(" ");
    if (sl.isEmpty()) return;
    bool ok = false;
    int nr = sl.at(0).toInt(&ok);
    if (ok) {
        Channel ch = getChannel(nr);
        if (ch.isValid()) emit channelSwitched(ch);
    }
}

void Channels::deleteChannel(QString line)
{
    qDebug() << "Channels::deleteChannel (QString line)" << line;
    // Rückgabe: Channel "nr" deleted (nie benutzt)
    // Rückgabe: Channel "id" deleted

    QString id = line.section("\"",1,1);
    if (m_channelsHash.contains(id)) {
        int index = m_channelsHash.value(id);
        Channel ch = m_channels.at(index);
        // m_channels.removeAt(index); Fatal! -> Kanalliste nach Löschen unbedingt neu einlesen
        // m_channelsHash.remove(id);
        emit channelDeleted(ch);
    }
    else {
         emit svdrpError("Löschen des Kanals fehlgeschlagen.");
    }
}

void Channels::readyRead()
{
    // qDebug("Channels::readyRead()");

    while (m_tcpSocket.canReadLine()) {
        QString s = m_tcpSocket.readLine();

        SVDRPParser line(s);

        // qDebug() << "code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        if (line.isErrorCode()) {
            QString error = QString("%1: %2").arg(line.code()).arg(line.message());
            emit svdrpError(error);
            return;
        }

        if (line.code() != 250) continue;
        switch (m_command) {
        case Commands::LSTC: addChannel(line.message()); break;
        case Commands::MODC: updateChannel(line.message()); break;
        case Commands::MOVC: moveChannel(line.message()); break;
        case Commands::DELC: break;
        case Commands::CHAN: switchChannel(line.message()); break;
        }    

    if (line.lastLine()) {
        switch (m_command) {
        case Commands::LSTC: emit channelsFinished(); break;
        case Commands::MOVC: svdrpGetChannels(); break;
        case Commands::DELC: deleteChannel(line.message()); break;
        case Commands::CHAN: break;
        case Commands::MODC: break;
        }
    }
    }
}
