#ifndef EVENTS_H
#define EVENTS_H

#include <QObject>

#include "data/event.h"
#include "svdrp.h"

class Events : public SVDRP
{
    Q_OBJECT

public:
    enum Schedule {now, next};

    explicit Events(QObject *parent = nullptr);

    //SVDRP Methoden
    void svdrpGetEvents(Schedule schedule); //nur für now und next
    void svdrpGetEvents(QString channel_id);
    void svdrpGetEvents(qint64 time); //für at
    void svdrpGetEvent(QString channel_id, qint64 time); //Holt ein Event zur angebegbenen Zeit von channel mit  Schedule = at
    //SVDRP Methoden Ende

    const QList<Event> &eventList() const;
    void blockSendQuit(bool block);

private:

    QList<Event> m_events;

    QString m_lastChannelId;
    QString m_LastChannelName;
    int m_lastChannelNumber;

    bool m_blockSendQuit = false; //unterdrückt das schließen des Ports (true), wird nur vom TimerModel benutzt (Einzelabfrage von Events)

    QList<QChar> EventCharacters = {'C','E','T','S','D','V','X','G','R'};

    //Falls kein Event vorhanden ist, wird ein "leeres" Event verschickt
    bool m_noEvent = true;
    Event* m_newEvent = nullptr;

    void addEvent(QString line);
    void closeEvent();
    void closeChannel();
    StreamComponent parseStreamComponent(QString stream);

private slots:

    void slotSendQuit();

    void readyRead() override;


signals:
    void eventsFinished(); //Ende der Abfrage erreicht
    void eventFinished(const Event &event); //Es wird jedes Event verschickt (-> closeEvent)
};

#endif // EVENTS_H
