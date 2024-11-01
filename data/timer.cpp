#include "timer.h"
#include <QDebug>

QDebug operator <<(QDebug dbg, const Timer &timer)
{
    dbg.space() << "id:" << timer.id;
    dbg.space() << "filename:" << timer.filename();
    dbg.space() << "channel_id:" << timer.channel_id;
    // dbg.space() << "channelNumber:" << timer.channelNumber;
    // dbg.space() << "channelName:" << timer.channelName;
    // dbg.space() << "day:" << timer.day();
    dbg.space() << "start:" << timer.startDateTime();
    dbg.space() << "stop:" << timer.stopDateTime();
    dbg.space() << "firstDay:" << timer.firstDate();
    dbg.space() << "weekdays:" << timer.weekdays();
    dbg.space() << "is_active:" << timer.isActive();
    dbg.space() << "repeattimer:" << timer.isRepeatTimer();
    dbg.space() << "isSearchtimer:" << timer.isSearchtimer;
    dbg.space() << "searchtimerName:" << timer.searchtimerName;
    return dbg.maybeSpace();
}

Timer::Timer()
{
    m_timerDate = QDateTime::currentDateTime();
    m_stopDate = m_timerDate.addSecs(3600);
}

Timer::Timer(const QVariantMap &timer)
{
    qDebug() << "Timer(const QVariantMap &timer)" << timer;
    id = timer.value("id",-1).toInt();

    bool b = timer.value("active",false).toBool();
    setActive(b);
    b = timer.value("vps",false).toBool();
    setVps(b);

    QString s = timer.value("start","").toString(); //"20:15"
    setStart(s);

    m_weekdays = timer.value("weekdays").toString();
    m_repeatTimer = m_weekdays != "-------";

    QString day;

    if (m_repeatTimer) {
        bool hasStartDate = timer.value("hasFirstDate",false).toBool();
        if (hasStartDate) {
            QDate d = timer.value("firstDate").toDate();
            if (!d.isValid()) d = QDate::currentDate();
            day = m_weekdays + "@" + d.toString("yyyy-MM-dd");
            m_firstDate = d;
        }
        else {
            day = m_weekdays;
            m_firstDate = QDate();
        }
    }
    else {
        day = timer.value("day").toDate().toString("yyyy-MM-dd");
    }

    setDay(day);

    s = timer.value("stop","").toString();
    setStop(s);

    priority = timer.value("priority",50).toInt();
    lifetime = timer.value("lifetime",99).toInt();
    channel_id = timer.value("channel","").toString();
    m_filename = timer.value("filename","").toString();
    aux = timer.value("aux","").toString();

    searchtimerName = timer.value("searchtimer","").toString();
    isSearchtimer = timer.value("isSearchtimer",false).toBool();
}

Timer::~Timer()
{}

QString Timer::filename() const
{
    return m_filename;
}

void Timer::setFilename(QString filename)
{
    m_filename = filename;
}


bool Timer::isValid()
{
    return (id > 0) && m_timerDate.isValid() && m_stopDate.isValid();
}

void Timer::setActive(bool active)
{
    if (active) {
        m_flags = m_flags | Flags::Active;
    }
    else {
        m_flags &= ~Flags::Active;
    }
}

void Timer::setVps(bool vps)
{
    vps ? m_flags = m_flags | Flags::Vps : m_flags &= ~Flags::Vps;
}

void Timer::setFlags(uint flags)
{
    m_flags = flags;
}

uint Timer::flags() const
{
    return m_flags;
}

bool Timer::isActive() const
{
    return (m_flags & Flags::Active) == Flags::Active;
}

bool Timer::hasVps() const
{
    return (m_flags & Flags::Vps) == Flags::Vps;
}

bool Timer::isRecording() const
{
    return (m_flags & Flags::Recording) == Flags::Recording;
}

bool Timer::isInstant() const
{
    return (m_flags & Flags::Instant) == Flags::Instant;
}

QString Timer::start() const
{
    return m_timerDate.toString("hh:mm");
}

QDateTime Timer::startDateTime() const
{
    return m_timerDate;
}

void Timer::setStart(int start)
{
    int hour = start / 100;
    int min = start % 100;
    QTime t(hour,min);
    m_timerDate.setTime(t);
}

void Timer::setStart(QString newStart)
{
    m_timerDate.setTime(QTime::fromString(newStart,"hh:mm"));
}

QString Timer::stop() const
{
    return m_stopDate.toString("hh:mm");
}

QDateTime Timer::stopDateTime() const
{
    return m_stopDate;
}

void Timer::setStop(int stop)
{
    m_stopDate.setTime(QTime(stop/100, stop%100));
    calculateStopDate();
}

void Timer::setStop(QString newStop)
{
    m_stopDate.setTime(QTime::fromString(newStop,"hh:mm"));
    calculateStopDate();
}

QDate Timer::day() const
{
    return m_timerDate.date();
}
/*
QDate Timer::day() const
{
    return m_timerDate.date();
}
*/
void Timer::setDay(QString day)
{
    //    qDebug() << "Timer::setTimerDay" << day;
    // Format von LSTT, z.B. "----F--@2005-11-28")
    if (day.contains("@")) {
        //Wiederholtimer mit Startdatum
        QStringList list = day.split("@");
        m_weekdays = list.at(0);
        QDate date = QDate::fromString(list.at(1), "yyyy-MM-dd");
        if (date.isValid()) m_timerDate.setDate(date); else m_timerDate.setDate(QDate().currentDate());
        m_repeatTimer = true;
        m_firstDate = m_timerDate.date();
        calculateRepeatDate();
    }
    else {
        //Entweder ein Tag (yyyy-mm-dd) oder Wochentag "-------"
        QDate date = QDate::fromString(day, "yyyy-MM-dd");
        if (date.isValid()) {
            m_timerDate.setDate(date);
            m_weekdays = "-------";
            m_repeatTimer = false;
            m_firstDate = QDate();
        }
        else {
            //Nur Wochentage vorhanden
            m_weekdays = day;
            m_timerDate.setDate(QDate::currentDate());
            m_repeatTimer = true;
            m_firstDate = QDate();
            calculateRepeatDate();
        }
    }
}

bool Timer::hasFirstDate() const
{
    return m_firstDate.isValid();
}

QString Timer::weekdays() const
{
    return m_weekdays;
}

bool Timer::isRepeatTimer() const
{
    return m_repeatTimer;
}

QString Timer::getParameterLine()
{
    QString p = QString::number(m_flags) + ":";
    p.append(channel_id);
    p.append(":");
    if (m_repeatTimer) {
        if (m_firstDate.isValid()) {
            p.append(m_weekdays + "@" + m_firstDate.toString("yyyy-MM-dd"));
        }
        else {
            p.append(m_weekdays);
        }
    }
    else {
        p.append(m_timerDate.date().toString("yyyy-MM-dd"));
    }

    int start = m_timerDate.time().hour()*100 + m_timerDate.time().minute();
    int stop = m_stopDate.time().hour()*100 + m_stopDate.time().minute();

    QString intString = QString(":%1:%2:%3:%4:").arg(start).arg(stop).arg(priority).arg(lifetime);
    p.append(intString);

    QString f = m_filename.replace(":","|");
    p.append(f + ":");

    if (!aux.isEmpty()) p.append(aux);
    return p;
}

QDate Timer::firstDate() const
{
    return m_firstDate;
}

bool Timer::operator==(const Timer &t) const
{
    return (id == t.id);
}

bool Timer::operator<(const Timer &t)
{
    return startDateTime() < t.startDateTime();
}

void Timer::calculateRepeatDate()
{
    //Bestimmt den ersten Tag bei Wiederholungstimern
    //weekday bestimmt den Starttag

    if (!m_repeatTimer) return;

    QDateTime start = QDateTime::currentDateTime();

    if (m_firstDate.isValid()) start.setDate(m_firstDate);

    QChar m = QChar::fromLatin1('-');
    int dayOfWeek_index = start.date().dayOfWeek() - 1; //0 = Montag, 6 = Sonntag

    bool found = false;

    //Gleicher Tag
    if (m_weekdays.at(dayOfWeek_index) != m) {
        found = start.time() < m_timerDate.time();
    }

    if (!found) {

        QString right = m_weekdays.right(6 - dayOfWeek_index);
        QString noDays = QString(right.length(), m);

        //enthält rechte Hälfte den Wiederholungstag? (also noch diese Woche ab morgen)
        if (right != noDays) {
            for (int i=0; i < right.length(); ++i) {
                if (right.at(i) == m) continue;
                start = start.addDays(i+1);
                break;
            }
        }
        else {
            //Tag liegt in der Vergangenheit, also linke Hälfte
            QString left = m_weekdays.left(dayOfWeek_index);
            QString noDays = QString(left.length(), m);
            if (left != noDays) {
                for (int i=0; i < left.length(); ++i) {
                    if (left.at(i) == m) continue;
                    start = start.addDays(i - dayOfWeek_index + 7);
                    break;
                }
            }
        }
    }
    m_timerDate.setDate(start.date());
}

void Timer::calculateStopDate()
{
    //    qDebug() << "calculateStopDate" << getParameterLine();

    QDate d = m_timerDate.date();
    int diff = m_timerDate.time().secsTo(m_stopDate.time());
    if (diff < 0) {
        //Mitternacht überschritten
        d = d.addDays(1);
    }
    m_stopDate.setDate(d);
}



TimerExtended::TimerExtended() : Timer(){}
TimerExtended::TimerExtended(const Timer &t) : Timer(t){}
