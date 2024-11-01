#include "search.h"
#include <QSettings>

Search::Search() : BaseList() {}

Search::Search(int id) : BaseList(id) {}

Search::Search(const QVariantMap &search) : BaseList(search)
{
    content_descriptors = search.value("contentDescriptors","").toString();
    blacklist_mode = search.value("blacklistMode",0).toInt();
    blacklists.clear();
    QVariantList l = search.value("blacklists").toList();
    for (int i=0; i < l.count(); ++i) {
        blacklists.append(l.at(i).toInt());
    }
}

Search::~Search() {}

//Nur für die Suche, füllt nicht relevante Suchfelder mit Standardwerten
QString Search::getParameterLine() const
{
    QString line = BaseList::getParameterLine();

    QMap<int,QString> parameter;

    parameter.insert(16,"0"); //useAsSearchtimer

    int d = 0;
    if (dayOfWeek > 0) d = -dayOfWeek;
    parameter.insert(17,QString::number(useDayOfWeek));
    parameter.insert(18,QString::number(d));

    parameter.insert(19,"0");
    parameter.insert(20,"");
    parameter.insert(21,"0");
    parameter.insert(22,"0");
    parameter.insert(23,"2"); //Margin Start
    parameter.insert(24,"10");//Margin Stop
    parameter.insert(25,"0");
    parameter.insert(26,"0");

    parameter.insert(27,"0");
    parameter.insert(28,"");
    if (useExtEpgCats) {
        QString extepg = extEpgCats.join("|");
        parameter.insert(27,"1");
        parameter.insert(28,extepg);
    }

    parameter.insert(29,"0");
    parameter.insert(30,"0");
    parameter.insert(31,"0");
    parameter.insert(32,"0");
    parameter.insert(33,"0");
    parameter.insert(34,"0");
    parameter.insert(35,"0");
    parameter.insert(36,"0");
    parameter.insert(37,"0");
    parameter.insert(38,"0");
    parameter.insert(39,"0");

    parameter.insert(40,"0");
    parameter.insert(41,"");
    if(blacklist_mode) {
        parameter.insert(40,"1");
        QStringList l;
        for (int i=0; i < blacklists.count(); i++) {
            l.append(QString::number(blacklists.at(i)));
        }
        QString p = l.join("|");
        parameter.insert(41,p);
    }

    parameter.insert(42,QString::number(tolerance));

    parameter.insert(43,"0");
    parameter.insert(44,"0");
    parameter.insert(45,"0");
    parameter.insert(46,"0");
    parameter.insert(47,"0");
    parameter.insert(48,"0");
    parameter.insert(49,"0");

    parameter.insert(50,QString::number(ignoreMissingEpgCats));
    parameter.insert(51,"0");
    parameter.insert(52,"0");

    parameter.insert(53,"");
    int l = content_descriptors.length();
    if ( (l > 0) && (l % 2 == 0) ) parameter.insert(53,content_descriptors);

    parameter.insert(54,"0");

    QStringList list = parameter.values();
    QString p = line + ":" + list.join(":");
    return p;
}

Search Search::read()
{
    qDebug("Search::read");
    QSettings m_settings;
    id = -1;
    m_settings.beginGroup("search");
    search = m_settings.value("search","").toString();
    mode = m_settings.value("mode",0).toInt();
    tolerance = m_settings.value("tolerance",0).toInt();
    matchCase = m_settings.value("match_case",false).toBool();
    useTitle = m_settings.value("use_title",true).toBool();
    useSubtitle = m_settings.value("use_subtitle",true).toBool();
    useDescription = m_settings.value("use_description",true).toBool();
    content_descriptors = m_settings.value("content_descriptors","").toString();
    useExtEpgCats = m_settings.value("use_ext_epg_cats",false).toBool();
    extEpgCats = m_settings.value("extEpgInfo").toStringList(); //Werte liegen als [id1#w1,w2  id2#w1,w2 ...] vor
    ignoreMissingEpgCats = m_settings.value("ignore_missing_epg_cats",false).toBool();
    useTime = m_settings.value("use_time",false).toBool();
    setStartTime(m_settings.value("start_time","00:00").toString());
    setStopTime(m_settings.value("stop_time","23:59").toString());
    useChannel = m_settings.value("use_channel",0).toInt();
    channelMin = m_settings.value("channel_min","").toString();
    channelMax = m_settings.value("channel_max","").toString();
    channels = m_settings.value("channels","").toString();
    useDuration = m_settings.value("use_duration",false).toBool();
    setDurationMinInMinutes(m_settings.value("duration_min",0).toInt());
    setDurationMaxInMinutes(m_settings.value("duration_max",90).toInt());
    useDayOfWeek = m_settings.value("use_dayofweek",false).toBool();
    dayOfWeek = m_settings.value("dayofweek",0).toInt();
    blacklist_mode = m_settings.value("blacklist_mode",0).toInt();

    QStringList sl =  m_settings.value("blacklists").toStringList();
    blacklists.clear();
    for (int i=0; i < sl.count(); ++i) {
        int n = sl.at(i).toInt();
        blacklists.append(n);
    }
    m_settings.endGroup();
    return *this;
}

void Search::write() const
{
    qDebug("Search::write");
    QSettings m_settings;

    m_settings.beginGroup("search");
    m_settings.setValue("search",search);
    m_settings.setValue("mode",mode);
    m_settings.setValue("tolerance",tolerance);
    m_settings.setValue("match_case",matchCase);
    m_settings.setValue("use_title",useTitle);
    m_settings.setValue("use_subtitle",useSubtitle);
    m_settings.setValue("use_description",useDescription);
    m_settings.setValue("content_descriptors",content_descriptors);
    m_settings.setValue("use_ext_epg_info",useExtEpgCats);
    m_settings.setValue("extEpgInfo",extEpgCats);
    m_settings.setValue("ignore_missing_epg_cats",ignoreMissingEpgCats);
    m_settings.setValue("use_time",useTime);
    m_settings.setValue("start_time",start());
    m_settings.setValue("stop_time",stop());
    m_settings.setValue("use_channel",useChannel);
    m_settings.setValue("channel_min",channelMin);
    m_settings.setValue("channel_max",channelMax);
    m_settings.setValue("channels",channels);
    m_settings.setValue("use_duration",useDuration);
    m_settings.setValue("duration_min",getDurationMinInMinutes());
    m_settings.setValue("duration_max",getDurationMaxInMinutes());
    m_settings.setValue("use_dayofweek",useDayOfWeek);
    m_settings.setValue("dayofweek",dayOfWeek);
    m_settings.setValue("blacklist_mode",blacklist_mode);
    QStringList sl;
    for (int i=0; i < blacklists.count(); ++i) {
        sl.append(QString::number(blacklists.at(i)));
    }
    m_settings.setValue("blacklist_ids",sl);
    m_settings.endGroup();
}
