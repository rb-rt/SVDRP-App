#include "extepgcat.h"


QDebug operator <<(QDebug dbg, const ExtEpgCat &value)
{
    dbg.space() << "id:" << value.id();
    dbg.space() << "category:" << value.category();
    dbg.space() << "name:"  << value.name();
    dbg.space() << "values:" << value.values();
    dbg.space() << "format:" << value.format();
    return dbg.maybeSpace();
}



ExtEpgCat::ExtEpgCat()
{
}

ExtEpgCat::ExtEpgCat(int id) : m_id(id)
{
}

//Format ist id|categrory|name...
void ExtEpgCat::parseFromFile(QString line)
{
    QStringList list = line.split("|");
    Q_ASSERT(list.count() == 5);
    if (list.count() != 5) return;
    m_id = list.at(0).toInt();

    QStringList s = list.at(1).split(",");
    m_category = s.at(0);
    if (s.count() == 2) m_format = s.at(1);

    m_name = list.at(2);
//    QStringList l = list.at(3).split(",");
//    QStringList n;
//    for (int i=0; i < l.count(); ++i) {
//        QString s = l.at(i).trimmed();
//        n.append(s);
//    }
//    m_values = n.join(",");// list.at(3); //.split(",");
    m_values = list.at(3);// list.at(3); //.split(",");
    m_searchmode = list.at(4).toInt();
}

//Format ist id#werte
void ExtEpgCat::setExtEpgCat(QString line)
{
    QStringList list = line.split("#");
    m_id = list.at(0).toInt();

//    QStringList l = list.at(1).split(",");
//    QStringList n;
//    for (int i=0; i < l.count(); ++i) {
//        QString s = l.at(i).trimmed();
//        n.append(s);
//    }
//    m_values = n.join(",");// list.at(3); //.split(",");
    m_values = list.at(1);
}

QString ExtEpgCat::getExtEpgCat() const
{
    return QString("%1#%2").arg(m_id).arg(m_values);
}

int ExtEpgCat::id() const
{
    return m_id;
}

QString ExtEpgCat::category() const
{
    return m_category;
}

void ExtEpgCat::setCategory(QString newCategory)
{
    m_category = newCategory;
}

QString ExtEpgCat::name() const
{
    return m_name;
}

void ExtEpgCat::setName(QString newName)
{
    m_name = newName;
}

QString ExtEpgCat::format() const
{
    return m_format;
}

void ExtEpgCat::setFormat(QString newFormat)
{
    m_format = newFormat;
}

bool ExtEpgCat::operator==(const ExtEpgCat &value) const
{
    return m_id == value.id();
}

int ExtEpgCat::searchmode() const
{
    return m_searchmode;
}

QString ExtEpgCat::values() const
{
    return m_values;
}

QStringList ExtEpgCat::valuesAsList() const
{
    QStringList l;
    if (!m_values.isEmpty()) {
        if (m_values.count() == 1) {
            l.append(m_values.at(0));
        }
        else {
            l = m_values.split(",");
        }
    }
    return l;
}

void ExtEpgCat::setValues(const QString &values)
{
//    qDebug() << "EpgSearchCat::setValues" << values;
    m_values = values;
//    m_valuesAsList = values.split(",");
}

void ExtEpgCat::setValues(const QStringList &values)
{
//    m_valuesAsList = values;
    m_values = values.join(",");
}
