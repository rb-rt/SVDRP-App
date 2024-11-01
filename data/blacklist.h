#ifndef BLACKLIST_H
#define BLACKLIST_H

#include <QObject>
#include <QDebug>
#include <QTime>
#include "baselist.h"

class Blacklist : public BaseList
{
    Q_GADGET
    Q_PROPERTY(bool isGlobal MEMBER is_global)

public:

    Blacklist();
    Blacklist(int id);
//    Blacklist(const Blacklist &b);
//    Blacklist &operator=(const Blacklist &);
    Blacklist(const QVariantMap &bl);


    bool is_global = false;

    bool operator==(const Blacklist &s) const;


    QString getParameterLine();//Rückgabe der parameter für SVDRP z.B. NEWB

private:

};
//Q_DECLARE_METATYPE(Blacklist)

QDebug operator <<(QDebug dbg, const Blacklist &timer);

#endif // BLACKLIST_H
