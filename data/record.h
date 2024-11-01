#ifndef RECORD_H
#define RECORD_H

#include <QObject>
#include <QDateTime>
#include <QDebug>

class Record
{
    Q_GADGET
    Q_PROPERTY(int id READ id)
    Q_PROPERTY(QString name MEMBER m_name)
    Q_PROPERTY(QString lastName READ lastName)
    Q_PROPERTY(QDateTime starttime READ getStartDateTime)
    Q_PROPERTY(QTime duration READ getDuration)
    Q_PROPERTY(bool cut READ isCut)
    Q_PROPERTY(bool new READ isNew)
    Q_PROPERTY(bool instant READ isInstant)
    Q_PROPERTY(bool faulty READ isFaulty)

public:

    enum Status { None = 0x0000, New = 0x0001, Cut = 0x0002, Instant = 0x0004, Faulty = 0x0008  };

    Record(int id = -1);

    int id() const;
    void setId(int id);

    QString getName() const { return m_name; }
    void setName(QString name);
    QStringList getNameStringList() const;

    QTime getDuration() const;
    void setDuration(QTime duration);

    QDateTime getStartDateTime() const;
    void  setStartDateTime(QDate date, QTime time);

    QDateTime getStopDateTime() const;

    QString lastName() const; //letzter Eintrag von m_name
    QString adjustedName() const; //wie lastname() ohne sonderzeichen (%, @)

    int getStatus() const;
    void setStatus(const Status &status);

    bool isCut();
    bool isNew();
    bool isInstant();
    bool isFaulty();

    bool operator==(const Record &r) const;


private:
    int m_id = -1;
    QString m_name; //Verzeichnis~Verzeichnis~Name, wie von LSTR ausgegeben
    QString m_adjustedName; //letzter Eintrag von m_name ohne Sonderzeichen (%, @)

    QStringList m_nameStringList; //m_name aufgetrennt durch '~'

    int m_status = Status::None;

    QDateTime m_startDateTime;
    QTime m_duration;
    QDateTime m_stopDateTime;

};

QDebug operator <<(QDebug dbg, const Record &record);


#endif // RECORD_H
