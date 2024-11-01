#ifndef TIMER_H
#define TIMER_H

#include "data/event.h"
#include <QObject>
#include <QVariantMap>
#include <QDateTime>

class Timer
{

    Q_GADGET
    Q_PROPERTY(int id MEMBER id)
    Q_PROPERTY(bool active READ isActive)
    Q_PROPERTY(bool instant READ isInstant)
    Q_PROPERTY(bool recording READ isRecording)
    Q_PROPERTY(bool vps READ hasVps)
    Q_PROPERTY(QString start READ start) //Übergabe nach QML mit Date-Datentypen vermeiden wegen falscher Uhrzeit (Zeitzone!)
    Q_PROPERTY(QString stop READ stop)
    Q_PROPERTY(QDate day READ day)
    Q_PROPERTY(int priority MEMBER priority)
    Q_PROPERTY(int lifetime MEMBER lifetime)
    Q_PROPERTY(QString weekdays READ weekdays)
    Q_PROPERTY(QString channel MEMBER channel_id)
    Q_PROPERTY(QString filename READ filename)
    Q_PROPERTY(bool hasFirstDate READ hasFirstDate)
    Q_PROPERTY(QDate firstDate READ firstDate CONSTANT FINAL)

    Q_PROPERTY(QString searchtimer MEMBER searchtimerName)
    Q_PROPERTY(bool isSearchtimer MEMBER isSearchtimer)
    Q_PROPERTY(bool repeatTimer READ isRepeatTimer)
    // Q_PROPERTY(QString aux MEMBER aux)

public:

    enum Flags { None=0x0000, Active=0x0001, Instant=0x0002, Vps=0x0004, Recording=0x0008, All=0xFFFF };

    Timer();
    Timer (const QVariantMap &timer);
    ~Timer();

    int id = -1; //Seit vdr 2.4.0 eindeutig bis Neustart

    QString filename() const;
    void setFilename(QString filename);

    int priority = 50;
    int lifetime = 99;

    QString channel_id = ""; //ChannelId
    QString aux = "";

    bool isValid(); //Gültiger Timer?

    //Zum setzen von flags
    void setActive(bool active);
    void setVps(bool vps);
    void setFlags(uint flags);
    uint flags() const;

    bool isActive() const;
    bool hasVps() const;
    bool isRecording() const;
    bool isInstant() const;

    // Zur korrekten Berechnung sollte setStop als letztes aufgerufen werden!
    //setStart -> setDay -> setStop

    QString start() const; //Format "20:15"
    QDateTime startDateTime() const;
    void setStart(int start); //Format 2015 wie von LSTT ausgegeben
    void setStart(QString newStart); //Format "20:15"

    QString stop() const; //Format "20:15"
    QDateTime stopDateTime() const;
    void setStop(int stop); //Format 2015 wie von LSTT ausgegeben
    void setStop(QString newStop);

    //Erster Timertag
    QDate day() const;
    void setDay(QString day); //day im allg. Format wie vom LSTT geliefert (z.B. "----F--@2005-11-28"), s. timers.conf

    QString weekdays() const;

    QString getParameterLine(); //Rückgabe der Parameter wie bei MODT und UPDT gefordert

    //Hilfswerte
    bool isSearchtimer = false; //Gehört zu einem suchtimer (in aux gesetzt)
    QString searchtimerName = "";
    bool isRepeatTimer() const;
    bool hasFirstDate() const; //Existiert ein Startdatum bei einem Repeattimer?
    QDate firstDate() const;

    bool operator==(const Timer &t) const;
    bool operator<(const Timer &t);

private:
    uint m_flags = 0; // 0/1  == Inaktiv/aktiv vps gesetzt = 4 (aktiv+vps)=5
    QDateTime m_timerDate; //Bei Repeattimer der ermittelte erste Aufnahmetag
    QDateTime m_stopDate;
    QString m_weekdays = "-------"; //Die zu wiederholenden Tage
    QString m_filename = "";

    bool m_repeatTimer = false; //wiederholender Timer "MDM--SS"
    QDate m_firstDate; //Das gesetzte Startdatum, ungültig wenn keines existiert

    void calculateRepeatDate();
    void calculateStopDate();

};
QDebug operator <<(QDebug dbg, const Timer &timer);


//Erweiterte Informationen, hinzugefügt und benutzt vom TimerModel
class TimerExtended: public Timer
{
    Q_GADGET
    Q_PROPERTY(int channelnr MEMBER channelNumber)
    Q_PROPERTY(EventExtended event MEMBER event CONSTANT FINAL)


public:

    TimerExtended();
    TimerExtended(const Timer &t);

    QString channelName = "";
    int channelNumber = -1;
    EventExtended event; //Enhält das ermittelte Event zum Timer
};


#endif // TIMER_H
