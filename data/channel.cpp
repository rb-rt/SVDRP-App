#include "channel.h"
#include "qvariant.h"

#include <QDebug>

QDebug operator <<(QDebug dbg, const Channel &channel)
{
    dbg.space() << "number:" << channel.number;
    dbg.space() << "name:" << channel.name;
    dbg.space() << "channel_id:"  << channel.channel_id;
    dbg.space() << "bouquet:" << channel.bouquet;
    dbg.space() << "group:" << channel.group;
    return dbg;
}


Channel::Channel()
{
}

Channel::Channel(const QVariantMap &channel)
{
    name = channel.value("name","").toString();
    number =channel.value("number",0).toInt();
    channel_id = channel.value("id","").toString();
    image = channel.value("image",false).toBool();
    group = channel.value("group",0).toInt();
    transponder = channel.value("transponder",0).toInt();
    stream = channel.value("stream","").toString();
    is_atsc = channel.value("is_atsc",false).toBool();
    is_cable = channel.value("is_cable",false).toBool();
    is_terr = channel.value("is_terr",false).toBool();
    is_sat = channel.value("is_sat",false).toBool();
    is_radio = channel.value("is_radio",false).toBool();
    shortname = channel.value("shortname","").toString();
    bouquet = channel.value("bouquet","").toString();
    is_fta = channel.value("is_fta",false).toBool();
    frequency = channel.value("frequency",0).toInt();
    parameter = channel.value("parameter","").toString();
    source = channel.value("source","").toString();
    symbolrate = channel.value("symbolrate",0).toInt();
    vpid = channel.value("vpid","").toString();
    apid = channel.value("apid","").toString();
    tpid = channel.value("tpid","").toString();
    caid = channel.value("caid","").toString();
    sid = channel.value("sid","").toString();
    nid = channel.value("nid","").toString();
    tid = channel.value("tid","").toString();
    rid = channel.value("rid","").toString();
}

//Channel::Channel(const Channel &channel)
//{}


Channel::~Channel()
{
}

bool Channel::isValid()
{
    return number > 0 && !name.isEmpty() && !channel_id.isEmpty();
}

QString Channel::getParameterLine()
{
    QMap<int,QString> p;

    QString channelname = name;
    if (!shortname.isEmpty()) channelname += "," + shortname;
    channelname += ";" + bouquet;
    p.insert(0,channelname);
    p.insert(1, QString::number(frequency));
    p.insert(2, parameter);
    p.insert(3, source);
    p.insert(4, QString::number(symbolrate));
    p.insert(5, vpid);
    p.insert(6, apid);
    p.insert(7, tpid);
    p.insert(8, caid);
    p.insert(9, sid);
    p.insert(10, nid);
    p.insert(11, tid);
    p.insert(12, rid);

    QStringList l = p.values();
    return l.join(":");
}

bool Channel::operator ==(const Channel &ch) const
{
    return (number == ch.number);
}
