#ifndef CHANNEL_H
#define CHANNEL_H

#include <QObject>

class Channel
{
    Q_GADGET
    Q_PROPERTY(QString id MEMBER channel_id)
    Q_PROPERTY(int number MEMBER number)
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(QString shortname MEMBER shortname)
    Q_PROPERTY(QString source MEMBER source)
    Q_PROPERTY(QString bouquet MEMBER bouquet)
    Q_PROPERTY(QString parameter MEMBER parameter)
    Q_PROPERTY(int group MEMBER group)
    Q_PROPERTY(int frequency MEMBER frequency)
    Q_PROPERTY(bool isFTA MEMBER is_fta)
    Q_PROPERTY(bool isRadio MEMBER is_radio)
    Q_PROPERTY(QString vpid MEMBER vpid)
    Q_PROPERTY(QString apid MEMBER apid)
    Q_PROPERTY(QString tpid MEMBER tpid)
    Q_PROPERTY(QString caid MEMBER caid)
    Q_PROPERTY(QString sid MEMBER sid)
    Q_PROPERTY(QString nid MEMBER nid)
    Q_PROPERTY(QString tid MEMBER tid)
    Q_PROPERTY(QString rid MEMBER rid)

public:
    explicit Channel();
//    Channel(const Channel &channel);
    Channel (const QVariantMap &channel);
    virtual ~Channel();

    //Dahinter die Spalte, wie in channels.conf erwartet
    QString name; //0
    int number = -1;
    QString channel_id;
    bool image;
    int transponder;
    QString stream;
    bool is_atsc = false;
    bool is_cable = false;
    bool is_terr = false;
    bool is_sat = false;
    bool is_radio = false;
    bool is_fta; //true = unverschlüsselt

    QString shortname = ""; //0
    QString bouquet = ""; //0

    int frequency = 0; //1
    QString parameter; //2
    QString source; //3
    int symbolrate = 0; //4
    QString vpid; //5
    QString apid; //6
    QString tpid; //7
    QString caid; //8
    QString sid; //9
    QString nid; //10
    QString tid; //11
    QString rid; //12

    bool isValid();
    QString getParameterLine();//Rückgabe der parameter wie in channels.conf gefordert

    bool operator == (const Channel &ch) const;

    int group = 0;

};
//Q_DECLARE_METATYPE(Channel)

QDebug operator <<(QDebug dbg, const Channel &channel);

#endif // CHANNEL_H
