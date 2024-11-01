#include "event.h"

#include <QDebug>

QDebug operator <<(QDebug dbg, const StreamComponent &sc)
{
    dbg.space() << "content:" << sc.content;
    dbg.space() << "type:" << sc.type;
    dbg.space() << "language:"  << sc.language;
    dbg.space() << "description:" << sc.description;
    return dbg.maybeSpace();
}

QDebug operator <<(QDebug dbg, const Event &event)
{
    dbg.space() << "id:" << event.id;
    dbg.space() << "channel:" << event.channelId;
    dbg.space() << "channelname:"  << event.channelName;
    // dbg.space() << "channelNumber:" << event.channelNumber;
    dbg.space() << "title:" << event.title;
    dbg.space() << "subtitle:" << event.shortText;
    dbg.space() << "start:" << event.startTime();
    // dbg.space() << "TimerId:" << event.timerId;
    // dbg.space() << "TimerExists:" << event.timerExists();
    // dbg.space() << "TimerFlags:" << event.timerFlags();
    dbg.space() << "StreamComponents:" << event.streamComponents;
    return dbg.maybeSpace();
}

Event::Event()
{
}

Event::~Event()
{
}

QVariantList Event::getStreamComponents() const
{
    QVariantList l;
    for (int i = 0; i < streamComponents.count(); ++i) {
        QVariantMap map;
        map.insert("content",streamComponents.at(i).content);
        map.insert("type",streamComponents.at(i).type);
        map.insert("language",streamComponents.at(i).language);
        map.insert("description",streamComponents.at(i).description);
        l.append(map);
    }
    return l;
}

QList<int> Event::genres() const
{
    return m_genres;
}

void Event::addGenres(QString genrelist)
{
    QStringList l = genrelist.split(" ");
    m_genres.clear();
    bool ok;
    for (int i=0; i < l.count(); ++i) {
        int g = l.at(i).toInt(&ok);
        if (ok) m_genres.append(g);
    }
}

void Event::setDuration(int duration)
{
    m_duration = duration;
    m_endDateTime = m_startDateTime.addSecs(m_duration);
}

QTime Event::getDuration() const
{
    QTime time = QTime(0,0);
    return time.addSecs(m_duration);
}
QDateTime Event::startDateTime() const
{
    return m_startDateTime;
}
QDateTime Event::endDateTime() const
{
    return m_endDateTime;
}

qint64 Event::startTime() const
{
    return m_starttime;
}

void Event::setStarttime(int starttime)
{
    m_starttime = starttime;
    m_startDateTime = QDateTime::fromSecsSinceEpoch(m_starttime);
}

void Event::setStartDateTime(const QDateTime &startDateTime)
{
    m_startDateTime = startDateTime;
    m_starttime = m_startDateTime.toSecsSinceEpoch();
}


bool Event::operator==(const Event &e)
{
    return (id == e.id);
}

bool Event::operator <(const Event &e) const
{
    return (m_starttime < e.startTime());
}


EventExtended::EventExtended() : Event() {}
EventExtended::EventExtended(const Event &event) : Event(event){}

bool EventExtended::timerExists() const
{
    return timerId > 0;
}

int EventExtended::timerFlags() const
{
    return m_timerFlags;
}

void EventExtended::setTimerFlags(int flags)
{
    m_timerFlags = flags;
}

bool EventExtended::operator==(const EventExtended &e) const
{
    return (id == e.id);
}

