#ifndef CHANNELS_H
#define CHANNELS_H

#include <QObject>
#include "data/channel.h"
#include "svdrp.h"

class Channels : public SVDRP
{
    Q_OBJECT

public:
    explicit Channels(QObject *parent = nullptr);

    //SVDRP Methoden
    void svdrpGetChannels();
    void svdrpDeleteChannel(QString channel_id);
    void svdrpMoveChannel(int nr, int to);
    void svdrpUpdateChannel(Channel &ch); //ch enthält die neuen Daten
    void svdrpSwitchToChannel(QString channel_id); //leerer String liefert den aktuellen Kanal
    //SVDRP Methoden Ende

    const QList<Channel> &channelList() const;
    Channel getChannel(int channel_nr);
    Channel getChannel(QString channel_id);

    const QMap<int, QString> &groups() const;

private:

    QList<Channel> m_channels; //Kanalnummern können Sprünge haben!
    QHash<QString,int> m_channelsHash; //Zur schnelleren Suche per Channel ID (key), int = Index von m_channels

    bool m_useId = false;
    int m_groupNumber = 0; //Zähler
    QMap<int, QString> m_groups; //enthält die Kanalgruppen (Kanaltrenner)

    enum Commands {LSTC, DELC, MOVC, MODC, CHAN};
    Commands m_command;

    void addChannel(QString line);
    void updateChannel(QString line);
    void moveChannel(QString line);
    void switchChannel(QString line);
    void deleteChannel(QString line);

private slots:

    void readyRead() override;

signals:
    void channelsFinished(); //MOVC oder DELC holt die Kanalliste neu ab -> ebenfalls channelsFinished
    void channelUpdated(const Channel &channel);
    void channelSwitched(const Channel &channel); //Kanal wurde umgeschaltet
    void channelDeleted(const Channel &channel);

};

#endif // CHANNELS_H
