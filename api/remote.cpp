#include "remote.h"
#include "api/svdrpparser.h"
#include <QRegularExpression>

Remote::Remote(QObject *parent) : SVDRP{parent}
{

}

void Remote::send(QString key)
{
    svdrpHitk(key);
}

bool Remote::status() const
{
    return m_status;
}

void Remote::setStatus(bool newStatus)
{
    if (m_status == newStatus) return;
    QString command = newStatus ? "REMO on" : "REMO off";
    m_command = Commands::REMO;
    sendCommand(command);
}

int Remote::volume() const
{
    return m_volume;
}

void Remote::setVolume(int newVolume)
{
    if (m_volume == newVolume) return;
    QString command = QString ("VOLU %1").arg(newVolume);
    m_command = Commands::VOLU;
    sendCommand(command);
}

void Remote::svdrpHitk(QString key)
{
    QString command;
    if (key == "REMO") {
        command = "REMO";
        m_command = Commands::REMO;
    }
    else if (key == "VOLU") {
        command = "VOLU";
        m_command = Commands::VOLU;
    } else {
        command = "HITK " + key;
        m_command = Commands::HITK;
    }
    sendCommand(command);
}

void Remote::switched(QString line)
{
    /* Rückgabe:
     * Remote control enabled bei REMO on
     * Remote control disabled bei REMO off
     * Remote control is enabled/disabled bei REMO
     * */
    m_status = line.contains("enabled");
    emit statusChanged();
}

void Remote::volume(QString line)
{
    // Rückgabe: Audio volume is xyz
    static QRegularExpression re("\\s+\\d+", QRegularExpression::CaseInsensitiveOption);

    QRegularExpressionMatch match = re.match(line);
    if (match.hasMatch()) {
        QString m = match.captured().trimmed();
        bool ok;
        int i = m.toInt(&ok);
        if (ok) {
            m_volume = i;
            qDebug() << "Remote::volume" << i;
            emit volumeChanged();
        }
    }
}

void Remote::readyRead()
{
    while (m_tcpSocket.canReadLine()) {
        QString s = m_tcpSocket.readLine();
        SVDRPParser line(s);

        qDebug() << "Remote code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        if (line.isErrorCode()) {
            emit svdrpError(line.message());
            return;
        }

        if (line.code() == 250) {
            switch (m_command) {
            case Commands::HITK: break; //Keine sinvolle Rückgabe
            case Commands::REMO: switched(line.message()); break;
            case Commands::VOLU: volume(line.message()); break;
            }
        }

        if (line.lastLine()) sendQuit();
    }
}
