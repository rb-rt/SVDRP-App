#ifndef SEARCH_H
#define SEARCH_H

#include <QObject>
#include <QDebug>
#include "baselist.h"

/*
 * Für das Plugin epgsearch verwendete Felder zum Suchen in den Events
 * Enthält für die Suche relevante Felder ohne spezielle Suchtimerfelder
 *
 */

class Search : public BaseList
{
    Q_GADGET
    Q_PROPERTY(QString contentDescriptors MEMBER content_descriptors)
    Q_PROPERTY(int blacklistMode MEMBER blacklist_mode)
    Q_PROPERTY(QList<int> blacklists MEMBER blacklists)

public:

    Search();
    Search(int id);
    Search(const QVariantMap &search);
    ~Search();


    QString content_descriptors = ""; //Verwende Kennung für Inhalt id1id2id3...
    int blacklist_mode = 0; //0=global, 1=Selection, 2=all, 3=none
    QList<int> blacklists; //enthält die ids

    //Nur für die Suche, füllt nicht relevante Suchfelder mit Standardwerten
    QString getParameterLine() const;

    //Seichert und liest die die Abfrage aus Settings()
    Search read();
    void write() const;
};

#endif // SEARCH_H
