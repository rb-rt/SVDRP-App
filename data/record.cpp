#include "record.h"

QDebug operator <<(QDebug dbg, const Record &record)
{
    dbg.space() << "id:" << record.id();
    dbg.space() << "name:" << record.getName();
//    dbg.space() << "title:" << record.getTitle();
    dbg.space() << "start" << record.getStartDateTime();
    dbg.space() << "duration:" << record.getDuration();
    dbg.space() << "stop:" << record.getStopDateTime();
    dbg.space() << "status:" << record.getStatus();
    return dbg.maybeSpace();
}


Record::Record(int id) : m_id(id)
{
}

int Record::id() const
{
    return m_id;
}

void Record::setId(int id)
{
    m_id = id;
}


QTime Record::getDuration() const
{
    return m_duration;
}

void Record::setDuration(QTime duration)
{
    m_duration = duration;
    int sec = m_duration.hour() * 3600 + m_duration.minute() * 60 + m_duration.second();
    m_stopDateTime = m_startDateTime;
    m_stopDateTime = m_stopDateTime.addSecs(sec);
}


void Record::setStartDateTime(QDate date, QTime time)
{
    m_startDateTime.setDate(date);
    m_startDateTime.setTime(time);
}

QDateTime Record::getStartDateTime() const
{
    return m_startDateTime;
}

QDateTime Record::getStopDateTime() const
{
    return m_stopDateTime;
}

QString Record::lastName() const
{
    return m_nameStringList.last();
}

int Record::getStatus() const
{
    return m_status;
}

void Record::setStatus(const Status &status)
{
    m_status = m_status | status;
}

bool Record::isCut()
{
    return (m_status & Status::Cut) == Status::Cut;
}

bool Record::isNew()
{
    return (m_status & Status::New) == Status::New;
}

bool Record::isInstant()
{
    return (m_status & Status::Instant) == Status::Instant;
}

bool Record::isFaulty()
{
    return (m_status & Status::Faulty) == Status::Faulty;
}

bool Record::operator==(const Record &r) const
{
    return (r.id() == id());
}

QString Record::adjustedName() const
{
    return m_adjustedName;
}

QStringList Record::getNameStringList() const
{
    return m_nameStringList;
}

void Record::setName(QString name)
{
//    qDebug() << "Record::setName" << name;
//    m_nameStringList = name.split(QLatin1Char('~'));
    m_nameStringList = name.split(QChar::fromLatin1('~'));
    m_name = name;

    QString lastName = m_nameStringList.last();
    if (lastName.startsWith("%")) {
        setStatus(Status::Cut);
        m_adjustedName = lastName.remove(0,1);
    }
    else if (lastName.startsWith("@")) {
        setStatus(Status::Instant);
        m_adjustedName = lastName.remove(0,1);
    }
    else {
        m_adjustedName = lastName;
    }
}
