#include "blacklist.h"


QDebug operator <<(QDebug dbg, const Blacklist &value)
{
    dbg.space() << "id:" << value.id;
    dbg.space() << "search:" << value.search;
    dbg.space() << "mode:"  << value.mode;
    dbg.space() << "tolerance:" << value.tolerance;
    dbg.space() << "match_case:" << value.matchCase;
    dbg.space() << "use_title:" << value.useTitle;
    dbg.space() << "use_subtitle:" << value.useSubtitle;
    dbg.space() << "use_description:" << value.useDescription;
    dbg.space() << "use_ext_epg_info:" << value.useExtEpgCats;
    dbg.space() << "ext_epg_info:" << value.extEpgCats;
    dbg.space() << "use_time:" << value.useTime;
    dbg.space() << "start_time:" << value.startTime();
    dbg.space() << "stop_time:" << value.stopTime();
    dbg.space() << "use_channel:" << value.useChannel;
    dbg.space() << "channel_min:" << value.channelMin;
    dbg.space() << "channel_max:" << value.channelMax;
    dbg.space() << "channels:" << value.channels;
    dbg.space() << "use_duration:" << value.useDuration;
    dbg.space() << "duration_min:" << value.getDurationMin();
    dbg.space() << "duration_max:" << value.getDurationMax();
    dbg.space() << "use_dayofweek:" << value.useDayOfWeek;
    dbg.space() << "dayofweek:" << value.dayOfWeek;
    dbg.space() << "is_global:" << value.is_global;

    return dbg.maybeSpace();
}

Blacklist::Blacklist() : BaseList()
{
}

Blacklist::Blacklist(int id)
{
    this->id = id;
}


Blacklist::Blacklist(const QVariantMap &bl) : BaseList(bl)
{
    is_global = bl.value("isGlobal", false).toInt();
}

bool Blacklist::operator==(const Blacklist &s) const
{
    return (s.id == id);
}



QString Blacklist::getParameterLine()
{
    QString line = BaseList::getParameterLine();

    //[16, 17] (laut Dokumentation zu epgsearch.conf)
    int d = dayOfWeek;
    if (dayOfWeek > 0) d = -dayOfWeek;
    line = line.append(":%1:%2").arg(useDayOfWeek).arg(d);

    //[18, 19]
    if (useExtEpgCats) {
        QString extepg = extEpgCats.join("|");
        line = line.append(":1:" + extepg);
    }
    else {
        line = line.append(":0:");
    }
    //[20, 21, 22]
    line = line.append(":%1:%2:%3").arg(tolerance).arg(ignoreMissingEpgCats).arg(is_global);

    return line;
}
