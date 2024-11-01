#include "baselist.h"

BaseList::BaseList()
{
}

BaseList::BaseList(int id) : id(id)
{
}

BaseList::BaseList(const QVariantMap &search)
{
    id = search.value("id",-1).toInt();

    this->search = search.value("search","").toString();
    mode = search.value("mode",0).toInt();
    tolerance = search.value("tolerance",1).toInt();
    matchCase = search.value("matchCase",false).toBool();
    useTitle  = search.value("useTitle",true).toBool();
    useSubtitle  = search.value("useSubtitle",true).toBool();
    useDescription  = search.value("useDescription",true).toBool();

    useExtEpgCats = search.value("useExtEpgCats",false).toBool();
    extEpgCats = search.value("extEpgCats").toStringList();
    ignoreMissingEpgCats = search.value("ignoreMissingEpgCats",false).toBool();

    useTime = search.value("useTime",false).toBool();
    setStartTime(search.value("startTime",0).toString()); //20:15
    setStopTime(search.value("stopTime").toString());
    useChannel = search.value("useChannel",0).toInt(); //0 = timer.value("no, 1 = timer.value("interval, 2 = timer.value("channel group, 3 = timer.value("only FTA
    channelMin = search.value("channelMin","").toString();
    channelMax = search.value("channelMax","").toString();
    channels = search.value("channels","").toString();

    //Werte in QML sind in Minuten
    useDuration = search.value("useDuration",false).toBool();
    int m = search.value("durationMin",0).toInt();
    setDurationMinInMinutes(m);
    m = search.value("durationMax",90).toInt();
    setDurationMaxInMinutes(m);

    useDayOfWeek = search.value("useDayOfWeek",false).toBool();
    dayOfWeek = search.value("dayOfWeek",0).toInt();
}

BaseList::~BaseList()
{
}

QString BaseList::getParameterLine() const
{
    QMap<int,QString> parameter;

    //[1, 2] Nicht der index, sondern Zeile wie in der Dokumentation zu epgsearch
    parameter.insert(1,QString::number(id));

    //Sonderbehandlung von ':' und '|' lt. epgsearch Dokumentation
    QString s = search;
    if (search.contains("|")) s.replace("|","!^pipe^!");
    if (search.contains(":")) s.replace(":","|");
    parameter.insert(2,s);

    parameter.insert(3,QString::number(useTime));

    //epgsearch verlangt das Format HHMM
    QString time = m_startTime.toString("hhmm");
    parameter.insert(4, time);
    time = m_stopTime.toString("hhmm");
    parameter.insert(5,time);

    parameter.insert(6,QString::number(useChannel));
    switch (useChannel) {
    case 0: parameter.insert(7,"0");; break;
    case 1: parameter.insert(7,channelMin + "|" + channelMax); break;
    case 2: parameter.insert(7,channels); break;
    case 3: parameter.insert(7,"0"); break;
    }

    parameter.insert(8,QString::number(matchCase));
    parameter.insert(9,QString::number(mode));

    parameter.insert(10,QString::number(useTitle));
    parameter.insert(11,QString::number(useSubtitle));
    parameter.insert(12,QString::number(useDescription));

    parameter.insert(13,QString::number(useDuration));
    time = m_duration_min.toString("hhmm");
    parameter.insert(14,time);
    time = m_duration_max.toString("hhmm");
    parameter.insert(15,time);

    QStringList l = parameter.values();
    QString line = l.join(":");
    return line;
}


QString BaseList::start() const
{
    return m_startTime.toString("hh:mm");
}

QTime BaseList::startTime() const
{
    return m_startTime;
}

void BaseList::setStartTime(QString newStartTime)
{
    m_startTime = QTime::fromString(newStartTime,"hh:mm");
}

void BaseList::setStartTime(QTime newStartTime)
{
    m_startTime = newStartTime;
}


QString BaseList::stop() const
{
    return m_stopTime.toString("hh:mm");
}

QTime BaseList::stopTime() const
{
    return m_stopTime;
}

void BaseList::setStopTime(QString newStopTime)
{
    m_stopTime = QTime::fromString(newStopTime,"hh:mm");
}

void BaseList::setStopTime(QTime newStopTime)
{
    m_stopTime = newStopTime;
}

QString BaseList::getWeekdays()
{
    if (!useDayOfWeek) return "";
    QString weekdays ="-------"; //MDMDFSS
    int w = dayOfWeek;
    if (w & 2) weekdays.insert(0,"M"); //Montag = 2
    if (w & 4) weekdays.insert(1,"D");
    if (w & 8) weekdays.insert(2,"M");
    if (w & 16) weekdays.insert(3,"D");
    if (w & 32) weekdays.insert(4,"F");
    if (w & 64) weekdays.insert(5,"S"); //Samstag = 64
    if (w & 1) weekdays.insert(6,"S"); //Sonntag = 1
    return weekdays;
}

QTime BaseList::getDurationMin() const
{
    return m_duration_min;
}

void BaseList::setDurationMin(QTime value)
{
    m_duration_min = value;
}

int BaseList::getDurationMinInMinutes() const
{
    return m_duration_min.hour()*60 + m_duration_min.minute();
}

void BaseList::setDurationMinInMinutes(int value)
{
    int h = value / 60;
    int m = value % 60;
    m_duration_min.setHMS(h,m,0);
}

QTime BaseList::getDurationMax() const
{
    return m_duration_max;
}

void BaseList::setDurationMax(QTime value)
{
    m_duration_max = value;
}


int BaseList::getDurationMaxInMinutes() const
{
    return m_duration_max.hour()*60 + m_duration_max.minute();
}

void BaseList::setDurationMaxInMinutes(int value)
{
    int h = value / 60;
    int m = value % 60;
    m_duration_max.setHMS(h,m,0);
}
/*
void BaseList::toMap()
{
    qDebug("BaseList::toMap()");
    m_values.clear();
    m_values.insert(1, id);
    m_values.insert(2, search);
    m_values.insert(3, useTime);
    m_values.insert(4, startTime());
    m_values.insert(5, stopTime());
    m_values.insert(6, useChannel);
    QString channel;
    switch (useChannel) {
    case 0: channel = ""; break;
    case 1: channel = channelMin + "|" + channelMax; break;
    case 2: channel = channels; break;
    }
    m_values.insert(7, channels);
    m_values.insert(8, matchCase);
    m_values.insert(9, mode);
    m_values.insert(10, useTitle);
    m_values.insert(11, useSubtitle);
    m_values.insert(12, useDescription);
    m_values.insert(13, useDuration);
    m_values.insert(14, m_duration_min);
    m_values.insert(15, m_duration_max);

    m_values.insert(17, useDayOfWeek);
    m_values.insert(18, dayOfWeek);

    m_values.insert(27, useExtEpgCats);
    m_values.insert(28, extEpgCats);

    m_values.insert(42, tolerance);

    m_values.insert(50, ignoreMissingEpgCats);
}
*/
