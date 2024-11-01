#ifndef EPGSEARCHPARSER_H
#define EPGSEARCHPARSER_H

#include "data/searchtimer.h"
#include "data/blacklist.h"

class EPGSearchParser : public QObject
{
public:
    explicit EPGSearchParser(QObject *parent = nullptr);

    SearchTimer parseEpgSearch(QString line); //für LSTS
    Blacklist parseBlacklist(QString line); //für LSTB (teilweise identisch zu EpgSearch)

private:

    void parseCommon(QString line, BaseList &value);
    void parseSearchTerm(QString line, BaseList &value);
    void parseExtendedEpgCategories(QString line, BaseList &value);

};

#endif // EPGSEARCHPARSER_H
