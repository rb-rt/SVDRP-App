#ifndef EPGSEARCHQUERY_H
#define EPGSEARCHQUERY_H

#include <QObject>
#include <QDateTime>
#include <QVariantMap>

/**
 * @brief The EpgSearchQuery class
 * Enthält das Ergebnis eine Abfrage von epgsearch qrys
 */
class EpgSearchQuery
{
    Q_GADGET
    Q_PROPERTY(int searchID MEMBER searchID);
    Q_PROPERTY(int eventID MEMBER eventID);
    Q_PROPERTY(QString title MEMBER title);
    Q_PROPERTY(QString subtitle MEMBER episode_name);
    Q_PROPERTY(int eventStart MEMBER m_event_start);
    Q_PROPERTY(int eventStop MEMBER m_event_stop);
    Q_PROPERTY(QString channel MEMBER channel);
    Q_PROPERTY(int timerStart MEMBER m_timer_start);
    Q_PROPERTY(int timerStop MEMBER m_timer_stop);
    Q_PROPERTY(QString timerFile MEMBER timer_file);
    Q_PROPERTY(int timerFlag MEMBER timer_flag);
    Q_PROPERTY(int timerId MEMBER timer_id)

public:
    EpgSearchQuery();
    EpgSearchQuery(const QString s); //string aus Abrage mit qrys (id:title:episode:...)
    EpgSearchQuery(const QVariantMap &search);

    int searchID = -1; //the ID of the corresponding search timer
    int eventID = -1; // VDR event ID
    QString title = ""; // event title, any ':' will be converted to '|'
    QString episode_name = ""; // event short text, any ':' will be converted to '|'
    QString channel = ""; // channel ID in VDR's internal representation (e.g. 'S19.2E-1-1101-28106') ??
    QString timer_file = ""; // timer file (only valid if timer flag is > 0)

    // 0 = no timer needed, 1 = has timer, 2 timer planned for next update)
    // von EpgSearchQueryModel erweitert um 3 = Timer aktiv, 4 = Timer inaktiv, 5 = recording
    int timer_flag = -1;
    // von EpgSearchQueryModel ermittelt, nur wenn timer_flag = 3,4,5
    int timer_id = -1;

    int eventStart() const;
    QDateTime eventStartDateTime() const;
    void setEventStart(int newStart);
    int eventStop() const;
    QDateTime eventStopDateTime() const;
    void setEventStop(int newStop);

    qint64 timerStart() const;
    QDateTime timerStartDateTime() const;
    void setTimerStart(qint64 newTimerStart);
    void setTimerStart(QDateTime newTimerStart);

    qint64 timerStop() const;
    QDateTime timerStopDateTime() const;
    void setTimerStop(qint64 newTimerStop);
    void setTimerStop(QDateTime newTimerStop);

    bool isValid() { return (searchID =! -1); }

private:
    qint64 m_event_start = 0; // event start in seconds since 1970-01-01
    qint64 m_event_stop = 0; // event stop in seconds since 1970-01-01
    QDateTime m_eventStart;
    QDateTime m_eventStop;

    qint64 m_timer_start = 0; // timer start in seconds since 1970-01-01 (only valid if timer flag is > 0)
    qint64 m_timer_stop = 0; // timer stop in seconds since 1970-01-01 (only valid if timer flag is > 0)
    QDateTime m_timerStart;
    QDateTime m_timerStop;

    QString replaceSpecialCharacter(QString s);

};
QDebug operator <<(QDebug dbg, const EpgSearchQuery &e);

#endif // EPGSEARCHQUERY_H
