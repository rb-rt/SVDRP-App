#include "channelparser.h"
#include "qvariant.h"
#include <QRegularExpression>

ChannelParser::ChannelParser(bool useId, QObject *parent) :
    QObject(parent),
    m_useId(useId)
{
}

Channel ChannelParser::parseLine(QString line)
{
    Channel channel;

    QStringList list = line.split(":");
    QString firstChar = list.at(0);

    //Gruppe startet immer mit 0 und kann folgende Formate annehmen
    //0:Gruppenname
    //0:@Nummer Gruppenname
    //0:@Nummer <Ändert nur die nachfolgenden Kanalnummern>
    if (firstChar.startsWith("0") ) {
        channel.number = 0;
        QString z = list.at(1);

        static QRegularExpression re("@\\d*\\s(.*)"); //Sucht nach @123 Text
        QRegularExpressionMatch match = re.match(z);
        if (match.hasMatch()) {
            QString s = match.captured(1);
            // qDebug() << "match" << match << "s" << s;
            channel.name = s; //Leerer String -> Kanalnummernsprung
        }
        else {
            channel.name = z;
        }
    }
    else {

        QVariantMap channelFields = parseChannel(list.at(0));
        channel.bouquet = channelFields.value("bouquet", "unbekannt").toString();
        channel.channel_id = channelFields.value("id", "").toString();
        channel.number = channelFields.value("number",0).toInt();
        channel.name = channelFields.value("name","unbekannt").toString();
        channel.shortname = channelFields.value("shortname","").toString();

        channel.frequency = list.at(1).toInt();
        channel.parameter = list.at(2);

        parseSource(list.at(3), channel);
        channel.symbolrate = list.at(4).toInt();

        //            qDebug() << channel.number << channel.channel_id << channel.name << channel.shortname << channel.bouquet << channel.source;


        parseVPID(list.at(5), channel);
        channel.apid = list.at(6);
        channel.tpid = list.at(7);
        parseCA(list.at(8), channel);
        channel.sid = list.at(9);
        channel.nid = list.at(10);
        channel.tid = list.at(11);
        channel.rid = list.at(12);

        if (channel.channel_id.isEmpty()) {
            channel.channel_id = channel.source + channel.nid +
                                 channel.tid + channel.sid;
            int r = channel.rid.toInt();
            if (r > 0) channel.channel_id += channel.rid;
        }
    }
    return channel;
}

QVariantMap ChannelParser::parseChannel(QString s)
{
    QVariantMap map;

    QStringList b = s.split(";");
    if (b.count() > 1) map.insert("bouquet", b.at(1));

    QString c = b.at(0);//=> Nr ID Kanalname, Kurzname
    QString ch;
    int i = c.lastIndexOf(",");
    if (i != -1) {
        //Kurzname
        map.insert("shortname", c.right(c.length() - i -1));
        ch = c.left(i);
    }
    else {
        ch = c;
    }

    QStringList nr_id_name = ch.split(" "); //Nr ID Name_Name_Name
    QString nr = nr_id_name.at(0);
    map.insert("number",nr);

    //Nr entfernen
    nr_id_name.removeFirst();
    if (m_useId) {
        map.insert("id",nr_id_name.at(0));
        //ID entfernen
        nr_id_name.removeFirst();
    }
    QString name;
    nr_id_name.count() > 1 ? name = nr_id_name.join(" ") : name = nr_id_name.at(0);
    map.insert("name", name);
    return map;
}

void ChannelParser::parseSource(QString source, Channel &ch)
{
    ch.source = source;
    char c = source.at(0).toLatin1();
    switch (c) {
    case 'S': { ch.is_sat = true; break; }
    case 'C': { ch.is_cable = true; break; }
    case 'T': { ch.is_terr = true; break; }
    }
}

void ChannelParser::parseVPID(QString s, Channel &ch)
{
    //    qDebug() << "VPID" << s;
    ch.vpid = s;
    bool ok = false;
    int i = s.toInt(&ok);
    if (ok && i == 0) ch.is_radio = true; else ch.is_radio = false;
}

void ChannelParser::parseCA(QString s, Channel &ch)
{
    ch.caid = s;
    bool ok = false;
    int i = s.toInt(&ok);
    ch.is_fta = ok && (i == 0);
}

