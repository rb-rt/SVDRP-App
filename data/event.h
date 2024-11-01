#ifndef EVENT_H
#define EVENT_H

#include <QObject>
#include <QDateTime>
#include <QVariantList>

struct StreamComponent {
    int content = 0;
    int type = 0;
    QString language = "";
    QString description = "";
};
Q_DECLARE_METATYPE(StreamComponent)
QDebug operator <<(QDebug dbg, const StreamComponent &sc);


class Event
{

    Q_GADGET
    Q_PROPERTY(int id MEMBER id)
    Q_PROPERTY(QString channel MEMBER channelId)
    Q_PROPERTY(QString channelname MEMBER channelName)
    Q_PROPERTY(QString title MEMBER title)
    Q_PROPERTY(QString subtitle MEMBER shortText)
    Q_PROPERTY(QString description MEMBER description)
    Q_PROPERTY(qint64 starttime MEMBER m_starttime)
    Q_PROPERTY(QDateTime startDateTime READ startDateTime)
    Q_PROPERTY(QDateTime endDateTime READ endDateTime)
    Q_PROPERTY(int duration MEMBER m_duration)
    Q_PROPERTY(QTime durationTime READ getDuration)
    Q_PROPERTY(int vps MEMBER vps)
    Q_PROPERTY(QVariantList components READ getStreamComponents CONSTANT)
    Q_PROPERTY(int parentalRating MEMBER parental_rating)
    Q_PROPERTY(QList<int> genres READ genres CONSTANT FINAL)

public:
    Event();
    ~Event();

    int id = -1;
    QString title = "";
    QString shortText = "";
    QString description = "";
    QString channelId = "";
    QString channelName = "";
    int table_id = 0;
    int version = 0;
    int parental_rating = 0;
    int vps = 0;

    QList<StreamComponent> streamComponents;
    QVariantList getStreamComponents() const;

    QList<int> genres() const;
    void addGenres(QString genrelist);

    void setDuration(int duration);
    QTime getDuration() const;

    QDateTime startDateTime() const;
    qint64 startTime() const;
    void setStarttime(int starttime); //starttime unixtimestamp
    void setStartDateTime(const QDateTime &startDateTime);
    QDateTime endDateTime() const;

    bool operator==(const Event &e);
    bool operator<(const Event &e) const;


private:

    qint64 m_starttime = 0; //unixtime
    QDateTime m_startDateTime;
    int m_duration = 0;
    QDateTime m_endDateTime;
    QList<int> m_genres;

};

QDebug operator <<(QDebug dbg, const Event &event);

//Erweiterte Informationen, hinzugefügt vom EventModel
class EventExtended: public Event
{
    Q_GADGET
    Q_PROPERTY(bool timerExists READ timerExists)
    Q_PROPERTY(int timerFlags READ timerFlags)

public:

    EventExtended();
    EventExtended(const Event &event);

    int channelNumber = -1;
    int timerId = -1; //s. timer.h
    bool timerExists() const;
    int timerFlags() const;
    void setTimerFlags(int flags);

    bool operator==(const EventExtended &e) const;

private:

    int m_timerFlags = -1; //identisch zu Timer::Flags

};


#endif // EVENT_H
