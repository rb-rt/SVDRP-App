#ifndef RECORDPARSER_H
#define RECORDPARSER_H

#include "data/record.h"

class RecordParser : QObject
{
public:
    explicit RecordParser(QObject *parent = nullptr);

    Record parseLine(QString line);


private:

};

#endif // RECORDPARSER_H
