#ifndef RECORDS_H
#define RECORDS_H

#include "svdrp.h"
#include "data/record.h"
#include "data/event.h"

class RecordEvent : public Event
{
    Q_GADGET
    Q_PROPERTY(QString name MEMBER name)
    Q_PROPERTY(int priority MEMBER priority)
    Q_PROPERTY(int lifetime MEMBER lifetime)
    Q_PROPERTY(int frames MEMBER frames)
    Q_PROPERTY(int errors MEMBER errors)

public:

    RecordEvent();
    ~RecordEvent();

    QString name; //Verzeichnis~Verzeichnis~Name, wie von LSTR ausgegeben, nicht bei LSTR id enthalten
    int priority;
    int lifetime;
    int frames;
    int errors;
};
//Q_DECLARE_METATYPE(RecordEvent)


class Records : public SVDRP
{
    Q_OBJECT

public:

    Records(QObject *parent = nullptr);

    void svdrpGetRecords();
    void svdrpGetRecordEvent(int id); //Event zum Record mit id
    void svdrpMoveRecord(int id, QString newName); //NewName als kompletter Pfad
    void svdrpDeleteRecord(int id);
    void svdrpPlayRecord(int id, int type = 0, QString time = ""); //Spielt die Aufnahme auf dem VDR ab, type 0=begin, 1=letzte Position 2=Zeitangabe
    void svdrpEditRecord(int id); //Startet einen Schneidevorgang -> EDIT
    void svdrpUpdate(); //Setzt nur UPDR ab

    void blockSendQuit(bool block);

    const QList<Record> &recordList() const;

private:

    const bool m_useId = false;
    bool m_blockSendQuit = false; //unterdrückt das schließen des Ports (true), wird nur vom RecordListModel benutzt (Löschen mehrerer Records)

    QList<Record> m_records; //Liste mit den Aufnahmen

    int m_lastRecordId; //Enthält die Id bei der Eventabfrage
    RecordEvent* m_recordEvent = nullptr; //Speichert die letzte Eventabfrage

    enum Commands {LSTR, DELR, MOVR, UPDR, PLAY, EDIT};
    Commands m_command;

    void addRecord(QString line);
    void moveRecord(QString line);
    void deleteRecord(QString line);
    void playRecord(QString line);
    void editRecord(QString line);
    void addEvent(QString line);
    void closeEvent();
    StreamComponent parseStreamComponenet(QString stream);

private slots:
    void slotSendQuit();

    void readyRead() override;

signals:

    void recordsFinished();
    void eventFinished(const RecordEvent &event);
    void recordMoved(const Record &record);
    void recordDeleted(const Record &record);
    void recordPlayed(const Record &record);
    void recordEdited(const Record &record);
    void recordsUpdated();
};
QDebug operator <<(QDebug dbg, const RecordEvent &event);

#endif // RECORDS_H
