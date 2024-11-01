#include "recordparser.h"

RecordParser::RecordParser(QObject *parent) : QObject(parent)
{
//    qDebug("RecordParser::RecordParser");
}

Record RecordParser::parseLine(QString line)
{
    Record record;

    QStringList list = line.split(" ");

    int id = list.at(0).toInt();
    if (id == 0) return record;
    record.setId(id);
    list.removeFirst();

    QDate date = QDate::fromString(list.at(0), "dd.MM.yy");
    if (date.isValid()) {
        if (date.year() < 2000) date = date.addYears(100);
    }
    list.removeFirst();
    QTime time = QTime::fromString(list.at(0), "hh:mm");
    list.removeFirst();

    //Dauer mit * oder ! oder *! am Ende
    QString s = list.at(0);
    if (s.endsWith("!")) {
        s = s.remove("!");
        record.setStatus(Record::Faulty);
    }
    if (s.endsWith("*")) {
        s = s.remove("*");
        record.setStatus(Record::New);
    }
    QTime duration = QTime::fromString(s, "h:mm");
//    qDebug() << "string" << s << "duration" << duration;

    record.setStartDateTime(date, time);
    record.setDuration(duration);

    list.removeFirst();
    //Den übriggebliebenen Verzeichnisnamen wieder zusammensetzen
    s = list.join(" ");
    record.setName(s.trimmed()); //Entfernt Leerzeichen am Anfang, die manchmal(!) vorkommen

    return record;
}

