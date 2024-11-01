#include "timerparser.h"

#include <QDate>
#include <QXmlStreamReader>

TimerParser::TimerParser()
{
}

Timer TimerParser::parseLine(QString line)
{
//    qDebug() << "TimerParser::parseLine" << line;

    Timer timer;

    QStringList timerList = line.split(":");
    QString active = timerList.at(0); //"nr flags"
    QStringList l1 = active.split(" ");

    timer.id =  l1.at(0).toInt();

    int a = 0;
    if (l1.count() == 2 ) a = l1.at(1).toInt();
    timer.setFlags(a);

    timer.channel_id = timerList.at(1);

    timer.setStart(timerList.at(3).toInt());
    timer.setDay(timerList.at(2));
    timer.setStop (timerList.at(4).toInt());

    timer.priority = timerList.at(5).toInt();
    timer.lifetime = timerList.at(6).toInt();

    QString f = timerList.at(7);
    timer.setFilename(f.replace("|",":"));

    if (timerList.count() == 9) {
        timer.aux = timerList.at(8);
        parseAux(timer.aux, timer);
    }

    return timer;
}

void TimerParser::parseAux(QString aux, Timer &timer)
{
    QString x  = aux.replace("&","&amp;"); //& alleine ist nicht erlaubt und erzeugt einen Fehler
    QXmlStreamReader xml(x);

    QString s("searchtimer");
    while (!xml.atEnd()) {
        xml.readNext();
        if (xml.tokenType() == QXmlStreamReader::StartElement) {
            // qDebug() << "XML StartElement" << xml.name();
            if (xml.name() == s) {
                timer.isSearchtimer = true;
                timer.searchtimerName = xml.readElementText();
                break;
            }
        }
    }
}


