#include "searchtimer.h"


QDebug operator <<(QDebug dbg, const SearchTimer &s)
{
    dbg.space() << "id:" << s.id;
    dbg.space() << "search:" << s.search;
    dbg.space() << "mode:"  << s.mode;
    dbg.space() << "tolerance:" << s.tolerance;
    dbg.space() << "match_case:" << s.matchCase;
    dbg.space() << "use_title:" << s.useTitle;
    dbg.space() << "use_subtitle:" << s.useSubtitle;
    dbg.space() << "use_description:" << s.useDescription;
    dbg.space() << "content_descriptors:" << s.content_descriptors;
    dbg.space() << "use_ext_epg_info:" << s.useExtEpgCats;
    dbg.space() << "use_in_favorites:" << s.use_in_favorites;
    dbg.space() << "use_time:" << s.useTime;
    dbg.space() << "start_time:" << s.startTime();
    dbg.space() << "stop_time:" << s.stopTime();
    dbg.space() << "use_channel:" << s.useChannel;
    dbg.space() << "channel_min:" << s.channelMin;
    dbg.space() << "channel_max:" << s.channelMax;
    dbg.space() << "channels:" << s.channels;
    dbg.space() << "use_duration:" << s.useDuration;
    dbg.space() << "duration_min:" << s.getDurationMin();
    dbg.space() << "duration_max:" << s.getDurationMax();
    dbg.space() << "use_dayofweek:" << s.useDayOfWeek;
    dbg.space() << "dayofweek:" << s.dayOfWeek;
    dbg.space() << "use_as_searchtimer:" << s.use_as_searchtimer;
    dbg.space() << "use_as_searchtimer_from:" << s.use_as_searchtimer_from;
    dbg.space() << "use_as_searchtimer_til:" << s.use_as_searchtimer_til;
    dbg.space() << "search_timer_action:" << s.search_timer_action;
    dbg.space() << "use_series_recording:" << s.use_series_recording;
    dbg.space() << "directory:" << s.directory;
    dbg.space() << "keep_recs:" << s.keep_records;
    dbg.space() << "pause_on_recs:" << s.pause_on_records;
    dbg.space() << "blacklist_mode:" << s.blacklist_mode;
    dbg.space() << "blacklists:" << s.blacklists;
    dbg.space() << "switch_min_before:" << s.switch_min_before;
    dbg.space() << "avoid_repeats:" << s.avoid_repeats;
    dbg.space() << "allowed_repeats:" << s.allowed_repeats;
    dbg.space() << "repeats_within_days:" << s.repeats_within_days;
    dbg.space() << "compare_title:" << s.compare_title;
    dbg.space() << "compare_subtitle:"<< s.compare_subtitle;
    dbg.space() << "compare_match:"<< s.compare_match;
    dbg.space() << "compare_categories:"<< s.compare_categories;
    dbg.space() << "priority:" << s.priority;
    dbg.space() << "lifetime:" << s.lifetime;
    dbg.space() << "margin_start:" << s.margin_start;
    dbg.space() << "margin_stop:" << s.margin_stop;
    dbg.space() << "use_vps:" << s.use_vps;
    dbg.space() << "delete_mode:" << s.delete_mode;
    dbg.space() << "delete_after_counts:" << s.delete_after_counts;
    dbg.space() << "delete_after_days:" << s.delete_after_days;
    dbg.space() << "ignore_missing_epg_cats:" << s.ignoreMissingEpgCats;
    dbg.space() << "unmute_sound_on_switch:" << s.unmute_sound;
    dbg.space() << "compare_date:" << s.compare_date;

    return dbg.maybeSpace();
}

SearchTimer::SearchTimer() : Search()
{
}

SearchTimer::SearchTimer(int id) : Search(id)
{
}

SearchTimer::SearchTimer(const QVariantMap &search) : Search(search)
{
    qDebug("SearchTimer::SearchTimer(const QVariantMap &timer)");

//    id = timer.value("id",-1).toInt();

    //von QML kommen Minuten zurück
    int x = search.value("durationMin",0).toInt();
    setDurationMinInMinutes(x);
    x = search.value("durationMax",90).toInt();
    setDurationMaxInMinutes(x);

    use_as_searchtimer = search.value("useAsSearchtimer",0).toInt();
    use_as_searchtimer_from = search.value("useAsSearchtimerFrom",0).toInt();
    use_as_searchtimer_til = search.value("useAsSearchtimerTil",0).toInt();
    search_timer_action = search.value("searchtimerAction",0).toInt();
    use_series_recording = search.value("useSeriesRecording",false).toBool();
    directory = search.value("directory","").toString();
    keep_records = search.value("keepRecords",0).toInt();
    pause_on_records = search.value("pauseOnRecords",0).toInt();
    switch_min_before = search.value("switchMinBefore",0).toInt();
    avoid_repeats = search.value("avoidRepeats",false).toBool();
    allowed_repeats  = search.value("allowedRepeats",0).toInt();
    delete_recs_after_days  = search.value("deleteRecsAfterDays",0).toInt();
    repeats_within_days = search.value("repeatsWithinDays",0).toInt();
    compare_title = search.value("compareTitle",false).toBool();
    compare_subtitle = search.value("compareSubtitle",0).toInt();
    compare_description = search.value("compareDescription",false).toBool();
    compare_categories = search.value("compareCategories",0).toInt();
    priority  = search.value("priority",50).toInt();
    lifetime  = search.value("lifetime",99).toInt();
    margin_start  = search.value("marginStart",2).toInt();
    margin_stop  = search.value("marginStop",10).toInt();
    use_vps  = search.value("useVps",false).toBool();
    delete_mode  = search.value("deleteMode",0).toInt();
    delete_after_counts  = search.value("deleteAfterCcounts",0).toInt();
    delete_after_days  = search.value("deleteAfterDays",0).toInt();
    unmute_sound  = search.value("unmuteSound",false).toBool();
    compare_match = search.value("compareMatch",90).toInt();
    compare_date  = search.value("compareDate",0).toInt();
    use_in_favorites  = search.value("useInFavorites",false).toBool();
}


SearchTimer::~SearchTimer()
{

}

bool SearchTimer::operator==(const SearchTimer &s) const
{
    return (s.id == id);
}


QString SearchTimer::getParameterLine() const
{
    //nicht Search::getParameterLine() aufrufen!
    QString line = BaseList::getParameterLine(); //clazy:exclude=skipped-base-method

    QMap<int,QString> parameter;

    parameter.insert(16,QString::number(use_as_searchtimer));

    int d = 0;
    if (dayOfWeek > 0) d = -dayOfWeek;
    parameter.insert(17,QString::number(useDayOfWeek));
    parameter.insert(18,QString::number(d));

    parameter.insert(19,QString::number(use_series_recording));
    parameter.insert(20,directory);
    parameter.insert(21,QString::number(priority));
    parameter.insert(22,QString::number(lifetime));
    parameter.insert(23,QString::number(margin_start));
    parameter.insert(24,QString::number(margin_stop));
    parameter.insert(25,QString::number(use_vps));
    parameter.insert(26,QString::number(search_timer_action));

    parameter.insert(27,"0");
    parameter.insert(28,"");
    if (useExtEpgCats) {
        QString extepg = extEpgCats.join("|");
        parameter.insert(27,"1");
        parameter.insert(28,extepg);
    }

    parameter.insert(29,QString::number(avoid_repeats));
    parameter.insert(30,QString::number(allowed_repeats));
    parameter.insert(31,QString::number(compare_title));
    parameter.insert(32,QString::number(compare_subtitle));
    parameter.insert(33,QString::number(compare_description));
    parameter.insert(34,QString::number(compare_categories));
    parameter.insert(35,QString::number(repeats_within_days));
    parameter.insert(36,QString::number(delete_recs_after_days));
    parameter.insert(37,QString::number(keep_records));
    parameter.insert(38,QString::number(switch_min_before));
    parameter.insert(39,QString::number(pause_on_records));

    if(blacklist_mode == 1 && blacklists.count() > 0) {
        parameter.insert(40,"1");
        QStringList l;
        for (int i=0; i < blacklists.count(); i++) {
            l.append(QString::number(blacklists.at(i)));
        }
        QString p = l.join("|");
        parameter.insert(41,p);
    }
    else {
        parameter.insert(40,"0");
        parameter.insert(41,"");
    }

    parameter.insert(42,QString::number(tolerance));

    parameter.insert(43,QString::number(use_in_favorites));
    parameter.insert(44,QString::number(template_number));
    parameter.insert(45,QString::number(delete_mode));
    parameter.insert(46,QString::number(delete_after_counts));
    parameter.insert(47,QString::number(delete_after_days));
    parameter.insert(48,QString::number(use_as_searchtimer_from));
    parameter.insert(49,QString::number(use_as_searchtimer_til));
    parameter.insert(50,QString::number(ignoreMissingEpgCats));
    parameter.insert(51,QString::number(unmute_sound));
    parameter.insert(52,QString::number(compare_match));

    parameter.insert(53,"");
    int l = content_descriptors.length();
    if ( (l > 0) && (l % 2 == 0) ) parameter.insert(53,content_descriptors);

    parameter.insert(54,QString::number(compare_date));

    QStringList list = parameter.values();
    QString p = line + ":" + list.join(":");
    return p;
}

QString SearchTimer::getSearchLine() const
{
    return Search::getParameterLine();
}



