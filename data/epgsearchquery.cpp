#include "epgsearchquery.h"
#include <QDebug>

QDebug operator <<(QDebug dbg, const EpgSearchQuery &e)
{
    dbg.space() << "searchId:" << e.searchID;
    dbg.space() << "title:" << e.title;
    dbg.space() << "m_timer_start:"  << e.timerStart();
    dbg.space() << "timerStart:" << e.timerStartDateTime();
    dbg.space() << "eventId:" << e.eventID;
    dbg.space() << "eventStart:" << e.eventStart();
    dbg.space() << "eventStartDate:" << e.eventStartDateTime();
    dbg.space() << "timer_flag:" << e.timer_flag;
    dbg.space() << "timer_file:" << e.timer_file;
    return dbg.maybeSpace();
}

EpgSearchQuery::EpgSearchQuery()
{
}

EpgSearchQuery::EpgSearchQuery(const QString s)
{
    // qDebug() << "EpgSearchQuery::EpgSearchQuery (QString s)" << s;

    /* Rückgabe:
    [0] search ID    : // the ID of the corresponding search timer (0 bei einer Suche)
    [1] event ID     : // VDR event ID
    [2] title        : // event title, any ':' will be converted to '|'
    [3] episode name : // event short text, any ':' will be converted to '|'
    [4] event start  : // event start in seconds since 1970-01-01
    [5] event stop   : // event stop in seconds since 1970-01-01
    [6] channel      : // channel ID in VDR's internal representation (e.g. 'S19.2E-1-1101-28106')
    [7] timer start  : // timer start in seconds since 1970-01-01 (only valid if timer flag is > 0) invalid -> -1
    [8] timer stop   : // timer stop in seconds since 1970-01-01 (only valid if timer flag is > 0) invalid -> -1
    [9] timer file   : // timer file (only valid if timer flag is > 0)
    [10] timer flag   : // 0 = no timer needed, 1 = has timer, 2 timer planned for next update)
    */

    QStringList l = s.split(":");

    // qDebug() << "EpgSearchQuery::EpgSearchQuery Rückgabe:" << s;
    // qDebug() << "EpgSearchQuery::EpgSearchQuery Anzahl:" << l.count();

    //Rückgabe von QRYS nicht immer korrekt?
    if (l.count() != 11) {
        qDebug() << "EpgSearchQuery::EpgSearchQuery Felderanzahl falsch:" << l;
        Q_ASSERT(false);
        return;
    }

    searchID = l.at(0).toInt();
    eventID = l.at(1).toInt();

    //Title enthält "|" statt ":"
    QString str = l.at(2);
    if (str.contains("|")) {
        title = replaceSpecialCharacter(str);
    }
    else {
        title = str;
    }
    str = l.at(3);
    if (str.contains("|")) {
        episode_name = replaceSpecialCharacter(str);
    }
    else {
        episode_name = str;
    }

    setEventStart(l.at(4).toInt());
    setEventStop(l.at(5).toInt());
    channel = l.at(6);

    timer_flag = l.at(10).toInt();
    if (timer_flag > 0) {
        int t = l.at(7).toInt();
        setTimerStart(t);
        t = l.at(8).toInt();
        setTimerStop(t);
        str = l.at(9);
        if (str.contains("|")) {
            timer_file = replaceSpecialCharacter(str);
        }
        else {
            timer_file = str;
        }
    }
}

EpgSearchQuery::EpgSearchQuery(const QVariantMap &search)
{
    searchID = search.value("searchID", -1).toInt();
    eventID = search.value("eventID", -1).toInt();
    title = search.value("title", "").toString();
    episode_name = search.value("subtitle", "").toString();
    setEventStart(search.value("eventStart", 0).toInt());
    setEventStop(search.value("eventStop", 0).toInt());
    channel = search.value("channel", "").toString();
    setTimerStart(search.value("timerStart", 0).toInt());
    setTimerStop(search.value("timerStop", 0).toInt());
    timer_file = search.value("timerFile", "").toString();
    timer_flag = search.value("timerFlag", -1).toInt();
}

int EpgSearchQuery::eventStart() const
{
    return m_event_start;
}

QDateTime EpgSearchQuery::eventStartDateTime() const
{
    return m_eventStart;
}

void EpgSearchQuery::setEventStart(int newStart)
{
    m_event_start = newStart;
    m_eventStart = QDateTime::fromSecsSinceEpoch(m_event_start);
//    qDebug() << "Eventstart vorher" << QDateTime::fromSecsSinceEpoch(newStart) << "EventStart nachher" << m_eventStart;
}

int EpgSearchQuery::eventStop() const
{
    return m_event_stop;
}

QDateTime EpgSearchQuery::eventStopDateTime() const
{
    return m_eventStop;
}

void EpgSearchQuery::setEventStop(int newStop)
{
    m_event_stop = newStop;
    m_eventStop = QDateTime::fromSecsSinceEpoch(m_event_stop);
}

qint64 EpgSearchQuery::timerStart() const
{
    return m_timer_start;
}

QDateTime EpgSearchQuery::timerStartDateTime() const
{
    return m_timerStart;
}

void EpgSearchQuery::setTimerStart(qint64 newTimerStart)
{
    m_timer_start = newTimerStart;
    m_timerStart = QDateTime::fromSecsSinceEpoch(m_timer_start);
}

void EpgSearchQuery::setTimerStart(QDateTime newTimerStart)
{
    m_timerStart = newTimerStart;
    m_timer_start = newTimerStart.toSecsSinceEpoch();
}

qint64 EpgSearchQuery::timerStop() const
{
    return m_timer_stop;
}

QDateTime EpgSearchQuery::timerStopDateTime() const
{
    return m_timerStop;
}

void EpgSearchQuery::setTimerStop(qint64 newTimerStop)
{
    m_timer_stop = newTimerStop;
    m_timerStop = QDateTime::fromSecsSinceEpoch(m_timer_stop);
}

void EpgSearchQuery::setTimerStop(QDateTime newTimerStop)
{
    m_timerStop = newTimerStop;
    m_timer_stop = newTimerStop.toSecsSinceEpoch();
}

QString EpgSearchQuery::replaceSpecialCharacter(QString s)
{
    return s.replace("|",":");
}
