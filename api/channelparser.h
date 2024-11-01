#ifndef CHANNELPARSER_H
#define CHANNELPARSER_H

#include <QObject>
#include <QDebug>

#include "data/channel.h"

class ChannelParser : public QObject
{
    Q_OBJECT

public:
    explicit ChannelParser(bool useId, QObject *parent = nullptr);

    Channel parseLine(QString line); //parst nur eine Zeile von LSTC

private:

    bool m_useId = false;

    //Ermittelt aus dem ersten String die Kanaldaten
    //Nr ID Kanalname, Kurzname; Bouquet
    QVariantMap parseChannel(QString s);

    void parseSource(QString source, Channel &ch);

    void parseVPID(QString s, Channel &ch);
    void parseCA(QString s, Channel &ch);

};

#endif // CHANNELPARSER_H
