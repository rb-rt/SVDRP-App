#include "timers.h"
#include "svdrpparser.h"
#include "timerparser.h"

bool sortTimer(Timer &t1, Timer &t2)
{
    return t1.startDateTime() < t2.startDateTime();
}


Timers::Timers(QObject *parent) : SVDRP(parent)
{
    connect (this, &Timers::timersFinished, this, &SVDRP::sendQuit);
    connect (this, &Timers::timerCreated, this, &SVDRP::sendQuit);
    connect (this, &Timers::timerUpdated, this, &SVDRP::sendQuit);
    connect (this, &Timers::timerDeleted, this, &SVDRP::sendQuit);
}

void Timers::svdrpGetTimers()
{
    qDebug("Timers::svdrpGetTimers()");
    QString command;
    m_command = Commands::LSTT;
    command = "LSTT id";
    m_timers.clear();
    sendCommand(command);
}

void Timers::svdrpCreateTimer(Timer &timer)
{
    qDebug("Timers::svdrpCreateTimer");
    qDebug() << "Timer:" << timer;
    QString settings = timer.getParameterLine();
    qDebug() << "Parameter:" << settings;
    //    return;
    QString command = "NEWT " + settings;
    m_command = Commands::NEWT;
    sendCommand(command);
}

void Timers::svdrpDeleteTimer(int id)
{
    qDebug("Timers::svdrpDeleteTimer (svdrp)");
    QString command = QString("DELT %1").arg(id);
    m_command = Commands::DELT;
    sendCommand(command);
}

void Timers::svdrpToggleTimer(int id)
{
    qDebug("Timers::svdrpToggleTimer");

    foreach (Timer t, m_timers) {
        if (t.id == id) {
            QString s;
            t.isActive() ? s = "off" : s = "on";
            m_command = Commands::TOGGLE;
            QString command = QString("MODT %1 %2").arg(id).arg(s);
            sendCommand(command);
            break;
        }
    }
}

void Timers::svdrpUpdateTimer(Timer &timer)
{
    qDebug("Timers::svdrpUpdateTimer(Timer &timer)");
    QString settings = timer.getParameterLine();
    QString command = QString("MODT %1 %2").arg(timer.id).arg(settings);
    m_command = Commands::MODT;
    sendCommand(command);
}

const QList<Timer> &Timers::timerList() const
{
    return m_timers;
}

Timer Timers::getTimer(int id) const
{
    if (id == -1) return Timer();
    foreach (Timer t, m_timers) {
        if (t.id == id) return t;
    }
    return Timer();
}

void Timers::addTimer(QString line)
{
    //    qDebug("Timers::addTimer");
    TimerParser parser;
    Timer timer = parser.parseLine(line);
    //    qDebug() << "Timer" << timer;
    m_timers.append(timer);
}

void Timers::createTimer(QString line)
{
    qDebug() << "Timers::createTimer"; //Rückgabe: geänderter Timer im LSTT-Format
    TimerParser parser;
    Timer timer = parser.parseLine(line);
    if (m_timers.contains(timer)) return;
    m_timers.append(timer);
    // std::sort(m_timers.begin(), m_timers.end(), sortTimer);
    emit timerCreated(timer);
}

void Timers::updateTimer(QString line)
{
    qDebug() << "Timers::updateTimer (QString line)" << line; //Rückgabe: geänderter Timer im LSTT-Format

    TimerParser parser;
    Timer newTimer = parser.parseLine(line);

    Timer oldTimer(newTimer);
    int oldIndex = m_timers.indexOf(oldTimer);
    oldTimer = m_timers.at(oldIndex);
    qDebug() << "oldTimer" << oldTimer;

    int newIndex = m_timers.indexOf(newTimer);
    if (newIndex != -1) m_timers.replace(newIndex,newTimer);

    // if (newTimer.timeDifference(oldTimer)) std::sort(m_timers.begin(), m_timers.end(), sortTimer);
    emit timerUpdated(newTimer);
}

void Timers::deleteTimer(QString line)
{
    qDebug("Timers::deleteTimer"); //Rückgabe: Timer "nr" deleted

    QString s = line.section("\"",1,1);
    int id = s.toInt();
    Timer t;
    t.id = id;
    int index = m_timers.indexOf(t);
    if (index >= 0) {
        t = m_timers.takeAt(index);
        emit timerDeleted(t);
    }
}

void Timers::toggleTimer(QString line)
{
    qDebug("Timers::toggleTimer"); //Rückgabe: geänderter Timer, nur der Status wurde geändert
       // qDebug()<< "line" << line;
    TimerParser parser;
    Timer timer = parser.parseLine(line);
    if (m_timers.contains(timer)) {
        int i = m_timers.indexOf(timer);
        Timer t = m_timers.at(i);
        t.setActive(timer.isActive());
        m_timers.replace(i,t);
        emit timerUpdated(t);
    }
}

void Timers::readyRead()
{
    //    qDebug("Timers::readyRead()");

    while (m_tcpSocket.canReadLine()) {
        QString s = m_tcpSocket.readLine();
        //        qDebug() << "Line:" << s;

        SVDRPParser line(s);

       // qDebug() << "Timers code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        if (line.isErrorCode()) {
            QString error = QString("%1: %2").arg(line.code()).arg(line.message());
            qDebug() << "Fehler aufgetreten" << error;
            emit svdrpError(error);
            return;
        }

        //Timer zurückgegeben
        if (line.code() == 250) {
            switch (m_command) {
            case Commands::LSTT: addTimer(line.message()); break;
            case Commands::NEWT: createTimer(line.message()); break;
            case Commands::MODT: updateTimer(line.message()); break;
            case Commands::DELT: deleteTimer(line.message()); break;
            case Commands::TOGGLE: toggleTimer(line.message()); break;
            }

            if (line.lastLine()) {
                if (m_command == Commands::LSTT) {
                    // std::sort(m_timers.begin(), m_timers.end(), sortTimer);
                    emit timersFinished();
                }
            }
        }
    }
}


