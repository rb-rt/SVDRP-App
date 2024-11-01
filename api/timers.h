#ifndef TIMERS_H
#define TIMERS_H

#include <QObject>
#include <QDateTime>

#include "svdrp.h"
#include "data/timer.h"

class Timers : public SVDRP
{
    Q_OBJECT

public:
    explicit Timers(QObject *parent = nullptr);

    //SVDRP Methoden
    void svdrpGetTimers();
    void svdrpCreateTimer(Timer &timer); //NEWT
    void svdrpDeleteTimer(int id); //DELT
    void svdrpToggleTimer(int id); //MODT on|off
    void svdrpUpdateTimer(Timer &timer); //MODT
    //SVDRP Methoden Ende

    const QList<Timer> &timerList() const;
    Timer getTimer(int id) const; //Sucht den Timer mit der id, gibt ansonsten einen "neuen" zurück

private:

    QList<Timer> m_timers;

    enum Commands {LSTT, NEWT, DELT, MODT, TOGGLE};
    Commands m_command;

    void addTimer(QString line);
    void createTimer(QString line);
    void updateTimer(QString line);
    void deleteTimer(QString line);
    void toggleTimer(QString line);


private slots:

    void readyRead() override;

signals:
    void timersFinished(); //Wird nur bei Auflistung aller Timer ausgelöst
    void timerCreated(const Timer &newTimer);
    void timerUpdated(const Timer &timer);
    void timerDeleted(const Timer &deletedTimer);
};

#endif // TIMERS_H
