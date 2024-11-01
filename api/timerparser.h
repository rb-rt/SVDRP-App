#ifndef TIMERPARSER_H
#define TIMERPARSER_H

#include "data/timer.h"

class TimerParser
{
public:
    TimerParser();

    Timer parseLine(QString line);

private:

    void parseAux(QString aux, Timer &timer);
};

#endif // TIMERPARSER_H
