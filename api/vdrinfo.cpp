#include "vdrinfo.h"
#include "svdrpparser.h"
#include <QDebug>
#include <QRegularExpression>

VDRInfo::VDRInfo(QObject *parent) : SVDRP(parent)
{
    qDebug("VDRInfo::VDRInfo");

    m_statistics.insert("version", "0.0.0");
    m_statistics.insert("totalSpace", 0);
    m_statistics.insert("freeSpace", 0);
    m_statistics.insert("usedPercent", 0);

    connect(this, &VDRInfo::statisticsChanged, this, &SVDRP::sendQuit);
    connect(this, &VDRInfo::pluginsFinished, this, &SVDRP::sendQuit);
}

VDRInfo::~VDRInfo()
{
}

void VDRInfo::svdrpStat()
{
    qDebug() << "Info::svdrpStat";
    QString command = "STAT disk";
    m_command = Commands::STAT;
    sendCommand(command);    
}

void VDRInfo::getPlugins()
{
    qDebug() << "Info::getPlugins";
    m_plugins.clear();
    m_command = Commands::PLUG;
    QString command = "PLUG";
    sendCommand(command);
}

void VDRInfo::readyRead()
{
    while (m_tcpSocket.canReadLine()) {
        QString s = m_tcpSocket.readLine();
        //        qDebug() << "Line:" << s;

        SVDRPParser line(s);

        // qDebug() << "VDRInfo code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        if (line.isErrorCode()) {
            QString error = QString("%1: %2").arg(line.code()).arg(line.message());
            emit svdrpError(error);
            qDebug() << "Fehler aufgetreten" << error;
            return;
        }

        switch (m_command) {
        case Commands::STAT:
            if (line.code() == 220) setVersion(line.message());
            if (line.code() == 250) setDiskStatistic(line.message());
            if (line.lastLine()) emit statisticsChanged();
            break;
        case Commands::PLUG:
            if (line.code() == 214) {
                m_plugins.append(line.message());
                if (line.lastLine()) emit pluginsFinished();
            }
        }
    }
}


QStringList VDRInfo::plugins() const
{
    return m_plugins;
}

QVariantMap VDRInfo::statistics() const
{
    return m_statistics;
}


void VDRInfo::setVersion(QString s)
{
    static QRegularExpression re ("\\d+\\.\\d+\\.\\d+");
    QRegularExpressionMatch match = re.match(s);
    if (match.hasMatch()) {
        m_statistics.insert("version", match.captured(0));
    }
}

void VDRInfo::setDiskStatistic(QString s)
{
    QStringList l = s.split(" ");
    static QRegularExpression re ("\\d+");

    QRegularExpressionMatch match = re.match(l.at(0));
    if (match.hasMatch()) m_statistics.insert("totalSpace", match.captured(0).toInt() / 1024);

    match = re.match(l.at(1));
    if (match.hasMatch()) m_statistics.insert("freeSpace", match.captured(0).toInt() / 1024);

    match = re.match(l.at(2));
    if (match.hasMatch()) m_statistics.insert("usedPercent", match.captured(0).toInt());

}

