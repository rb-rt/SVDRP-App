#include "epgsearchparser.h"

EPGSearchParser::EPGSearchParser(QObject *parent) : QObject(parent)
{

}

SearchTimer EPGSearchParser::parseEpgSearch(QString line)
{
    SearchTimer st;
    parseCommon(line, st);

    QStringList list = line.split(":");

    //Anzahl Werte sind 54

    //use as search timer? 0/1/2 (with 2 one can specify time margins in
    st.use_as_searchtimer = list.at(15).toInt();

    //use day of week? 0/1
    st.useDayOfWeek = (list.at(16).toInt() == 1);
    //day of week (0 = Sunday, 1 = Monday...; -1 Sunday, -2 Monday, -4 Tuesday, ...; -7 Sun, Mon, Tue)
//    qDebug() << "search" << st.search << "dayofweek" << list.at(17);
    st.dayOfWeek = list.at(17).toInt();//Negativ, programmintern wird positiv gerechnet
    if (st.dayOfWeek < 0) st.dayOfWeek = -st.dayOfWeek;

    //use series recording? 0/1
    st.use_series_recording = (list.at(18).toInt() == 1);
    st.directory = list.at(19);
    //priority of recording
    st.priority = list.at(20).toInt();
    //lifetime of recording
    st.lifetime = list.at(21).toInt();
    //time margin for start in minutes
    st.margin_start = list.at(22).toInt();
    //time margin for stop in minutes
    st.margin_stop = list.at(23).toInt();
    //use VPS? 0/1
    st.use_vps = (list.at(24).toInt() == 1);
    //action:
    st.search_timer_action = list.at(25).toInt();

    //use extended EPG info? 0/1
    st.useExtEpgCats = (list.at(26).toInt() == 1);
    if (st.useExtEpgCats) parseExtendedEpgCategories(list.at(27), st);

    //avoid repeats? 0/1
    st.avoid_repeats = (list.at(28).toInt() == 1);
    //allowed repeats
    st.allowed_repeats = list.at(29).toInt();

    //compare title when testing for a repeat? 0/1
    st.compare_title = (list.at(30).toInt() == 1);
    // 32 - compare subtitle when testing for a repeat? 0=no/1=yes/2=yes-if present
    st.compare_subtitle = list.at(31).toInt();
    //compare description when testing for a repeat? 0/1
    st.compare_description = (list.at(32).toInt() == 1);
    //compare extended EPG info when testing for a repeat?
    //    This entry is a bit field of the category IDs.
    st.compare_categories = list.at(33).toInt();
    //accepts repeats only within x days
    st.repeats_within_days = list.at(34).toInt();
    //delete a recording automatically after x days
    st.delete_recs_after_days = list.at(35).toInt();
    //but keep this number of recordings anyway
    st.keep_records = list.at(36).toInt();
    //minutes before switch (if action = 2)
    st.switch_min_before = list.at(37).toInt();
    //pause if x recordings already exist
    st.pause_on_records = list.at(38).toInt();

    //blacklist usage mode (0 none, 1 selection, 2 all)    
    st.blacklist_mode = list.at(39).toInt();
    //41 - selected blacklist IDs separated with '|'
    QStringList blacklist_ids = list.at(40).split("|");

    for(int i=0; i < blacklist_ids.count(); i++) {
        bool ok = false;
        int id = blacklist_ids.at(i).toInt(&ok);
        if (ok) st.blacklists.append(id);
    }

    //fuzzy tolerance value for fuzzy searching
    st.tolerance = list.at(41).toInt();
    //use this search in favorites menu (0 no, 1 yes)
    st.use_in_favorites = (list.at(42).toInt() == 1);
    //number of the search menu template to use (only available if multiple
    //   search result templates are defined in epgsearchmenu.conf)
    st.template_number = list.at(43).toInt();
    //auto deletion mode (0 don't delete search timer, 1 delete after given
    //      count of recordings, 2 delete after given days after first recording)
    st.delete_mode = list.at(44).toInt();
    //count of recordings after which to delete the search timer
    st.delete_after_counts = list.at(45).toInt();
    //count of days after the first recording after which to delete the search timer
//    st.delete_after_days = list.at(46).toInt();

    st.use_as_searchtimer_from = list.at(47).toInt();
    st.use_as_searchtimer_til = list.at(48).toInt();

    //ignore missing EPG categories? 0/1
    st.ignoreMissingEpgCats = (list.at(49).toInt() == 1);
    //unmute sound if off when used as switch timer
    st.unmute_sound = (list.at(50).toInt() == 1);
    //the minimum required match in percent when descriptions are compared to avoid repeats
    st.compare_match = list.at(51).toInt();

    st.content_descriptors = list.at(52);
//    qDebug() << "ContentDescriptors" << st.content_descriptors;
    if (st.content_descriptors.length() == 1) st.content_descriptors = "";
    st.compare_date = list.at(53).toInt();

    return st;
}

Blacklist EPGSearchParser::parseBlacklist(QString line)
{
    Blacklist bl;
    parseCommon(line, bl);

    QStringList list = line.split(":");

    bl.useDayOfWeek = (list.at(15).toInt() == 1);
    //day of week (0 = Sunday, 1 = Monday...; -1 Sunday, -2 Monday, -4 Tuesday, ...; -7 Sun, Mon, Tue)
    //    qDebug() << "search" << st.search << "dayofweek" << list.at(17);
    bl.dayOfWeek = list.at(16).toInt(); //Negativ, programmintern wird positiv gerechnet
    if (bl.dayOfWeek < 0) bl.dayOfWeek = -bl.dayOfWeek;

    bl.useExtEpgCats = (list.at(17).toInt() == 1);
    if (bl.useExtEpgCats) parseExtendedEpgCategories(list.at(18), bl);

    //fuzzy tolerance value for fuzzy searching
    bl.tolerance = list.at(19).toInt();

    bl.ignoreMissingEpgCats = (list.at(20).toInt() == 1);

    bl.is_global = (list.at(21).toInt() == 1);

//    qDebug() << "Blacklist" << bl;
    return bl;
}

//parst die gemeinsamen Parameter von [1] bis [15]
void EPGSearchParser::parseCommon(QString line, BaseList &value)
{
    QStringList list = line.split(":");

    //id [1]
    value.id = list.at(0).toInt();

    //the search term [2]
    parseSearchTerm(list.at(1), value);

    //use time? [3]
    value.useTime = (list.at(2).toInt() == 1);

    //start time in HHMM [4]
    QTime time = QTime::fromString(list.at(3),"hhmm");
    value.setStartTime(time);
    //stop time in HHMM [5]
    time = QTime::fromString(list.at(4),"hhmm");
    value.setStopTime(time);

    //use channel 0 = no,  1 = Interval, 2 = Channel group, 3 = FTA only [6,7]
    value.useChannel = list.at(5).toInt();
    QStringList channels =  list.at(6).split("|");
    switch (value.useChannel) {
    case 0:
        value.channelMin = "";
        value.channelMax = "";
        value.channels = "";
        break;
    case 1:
        if (channels.count() == 1) {
            value.channelMin = channels.at(0);
            value.channelMax = value.channelMin;
        }
        else {
            value.channelMin = channels.at(0);
            value.channelMax = channels.at(1);
        }
        break;
    case 2:
        value.channelMin = "";
        value.channelMax = "";
        value.channels = channels.at(0);
        break;
    }

    //match case? [8]
    value.matchCase = (list.at(7).toInt() == 1);

    //search mode [9]
    value.mode = list.at(8).toInt();

    //use title? [10]
    value.useTitle = (list.at(9).toInt() == 1);
    //use subtitle? [11]
    value.useSubtitle = (list.at(10).toInt() == 1);
    //use description? [12]
    value.useDescription = (list.at(11).toInt() == 1);
    //use duration? [13]
    value.useDuration = (list.at(12).toInt() == 1);

    //min duration in minutes (kommt als HHMM zurück wie start_time!) [14,15]
    if (value.useDuration) {
        QTime t = QTime::fromString(list.at(13),"hhmm");
        value.setDurationMin(t);
        //max duration in Format HHMM
        t = QTime::fromString(list.at(14),"hhmm");
        value.setDurationMax(t);
    }
    else {
        value.setDurationMinInMinutes(0);
        value.setDurationMaxInMinutes(90);
    }
}

void EPGSearchParser::parseSearchTerm(QString line, BaseList &value)
{
/*
 * A ':' in the search term or the directory entry will be translated in a '|'.
 * If a '|' exists in the search term, e.g. when using regular expressions,
 * it will be translated to "!^pipe^!" (I know it's ugly ;-))
 *  */
    QString s = line;
    if (line.contains("|")) s = line.replace("|",":");
    if (line.contains("!^pipe^!")) s = line.replace("!^pipe^!","|");
    value.search = s;
}

void EPGSearchParser::parseExtendedEpgCategories(QString line, BaseList &value)
{
    /*extended EPG info values. This entry has the following format
      (delimiter is '|' for each category, '#' separates id and value):
      1 - the id of the extended EPG info category as specified in
          epgsearchcats.conf
      2 - the value of the extended EPG info category
          (a ':' will be translated to "!^colon^!", e.g. in "16:9")*/

//    value.epg_search_cats = line.split("|");
//    qDebug() << "SearchtimerParser::parseExtendedEpgCategories" << line << "split:" << value.epg_search_cats;

    value.extEpgCats = line.split("|");
}
