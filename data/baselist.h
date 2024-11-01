#ifndef BASELIST_H
#define BASELIST_H

#include <QObject>
#include <QDateTime>
#include <QVariantMap>

/**
 * @brief BaseList::BaseList
 * Enthält gemeinsame Daten von Blacklist und Searchtimer
 */

class BaseList
{
    Q_GADGET
    Q_PROPERTY(int id MEMBER id)
    Q_PROPERTY(QString search MEMBER search)
    Q_PROPERTY(int mode MEMBER mode)
    Q_PROPERTY(int tolerance MEMBER tolerance)
    Q_PROPERTY(bool matchCase MEMBER matchCase)
    Q_PROPERTY(bool useTitle MEMBER useTitle)
    Q_PROPERTY(bool useSubtitle MEMBER useSubtitle)
    Q_PROPERTY(bool useDescription MEMBER useDescription)

    Q_PROPERTY(bool useExtEpgCats MEMBER useExtEpgCats)
    Q_PROPERTY(QStringList extEpgCats MEMBER extEpgCats)
    Q_PROPERTY(bool ignoreMissingEpgCats MEMBER ignoreMissingEpgCats)

    Q_PROPERTY(int useChannel MEMBER useChannel)
    Q_PROPERTY(QString channelMin MEMBER channelMin)
    Q_PROPERTY(QString channelMax MEMBER channelMax)
    Q_PROPERTY(QString channels MEMBER channels)

    Q_PROPERTY(bool useTime MEMBER useTime)
    Q_PROPERTY(QString startTime READ start) //Übergabe nach QML mit Date-Datentypen vermeiden wegen falscher Uhrzeit
    Q_PROPERTY(QString stopTime READ stop)

    //Werte in QML werden in Minuten erwartet
    Q_PROPERTY(bool useDuration MEMBER useDuration);
    Q_PROPERTY(int durationMin READ getDurationMinInMinutes());
    Q_PROPERTY(int durationMax READ getDurationMaxInMinutes());

    Q_PROPERTY(bool useDayOfWeek MEMBER useDayOfWeek)
    Q_PROPERTY(int dayOfWeek MEMBER dayOfWeek)

public:

    BaseList();
    BaseList(int id);
    BaseList(const QVariantMap &search);
    virtual ~BaseList() = 0;

    int id=-1;
    QString search;
    int mode = 0;
    int tolerance = 1;
    bool matchCase = false;
    bool useTitle = true;
    bool useSubtitle = false;
    bool useDescription = false;

    //Erweiterte EPG Info
    bool useExtEpgCats = false;
    QStringList extEpgCats; //In der Form [id1#wert1,wert2, id2#... ]
    bool ignoreMissingEpgCats = false;


    bool useTime = false;
    QString start() const; //Format hh:mm z.B. 20:15
    QTime startTime() const;
    void setStartTime(QString newStartTime);
    void setStartTime(QTime newStartTime);

    QString stop() const;
    QTime stopTime() const;
    void setStopTime(QString newStopTime);
    void setStopTime(QTime newStopTime);

    int useChannel = 0;
    QString channelMin = ""; //bei useCannel = 1
    QString channelMax = ""; //bei useChannel = 1, max = min bei nur einem Kanal
    QString channels = ""; //bei useChannel = 2

    bool useDuration = false;

    bool useDayOfWeek = false;

    //LSTB liefert negativen Wert, intern wird positiv gerechnet
    //Umrechnung im Parser bzw. getParameterLine
    int dayOfWeek = 0; //LSTB liefert negativen Wert, intern wird positiv gerechnet, Umrechnung im Parser
    QString getWeekdays();

    QString getParameterLine() const; //Liefert die ersten gemeinsamen Werte zurück

    QTime getDurationMin() const;
    void setDurationMin(QTime value);
    int getDurationMinInMinutes() const;
    void setDurationMinInMinutes(int value);

    QTime getDurationMax() const;
    void setDurationMax(QTime value);
    int getDurationMaxInMinutes() const;
    void setDurationMaxInMinutes(int value);

/*
    QMap<int,QVariant> m_values; //int = Nummer wie in epgsearch.conf, Speicher die Werte (für Debugging)
    void toMap();
*/
private:
    QTime m_startTime = QTime(0,0);
    QTime m_stopTime = QTime(23,59);
    QTime m_duration_min = QTime(0,0);
    QTime m_duration_max = QTime(1,30);
};

#endif // BASELIST_H
