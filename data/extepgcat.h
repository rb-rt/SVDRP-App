#ifndef EXTEPGCAT_H
#define EXTEPGCAT_H

#include <QObject>
#include <QDebug>


/**
 * @brief The ExtEpgCat class
 * Entspricht einem Eintrag in der epgsearchcats.conf
 * Wird auch vom Befehl LSTE zurückgegeben
 *
 * Auch verwendbar für Werte aus Listen (LSTB und LSTS)
 */
class ExtEpgCat
{
    Q_GADGET
    Q_PROPERTY(int id READ id)
    Q_PROPERTY(QString name READ name)
    Q_PROPERTY(QString category READ category)
    Q_PROPERTY(QString values READ values WRITE setValues)
    Q_PROPERTY(QStringList valuesList READ valuesAsList)
    Q_PROPERTY(int searchmode READ searchmode)

public:
    explicit ExtEpgCat();
    ExtEpgCat(int id);

    //für Werte aus der epgsearchcats.conf (LSTE)
    void parseFromFile(QString line);


    //für zurückgegebene Werten wie von LSTS und LSTB
    void setExtEpgCat(QString line);
    //Rückgabe in der Form id#wert1,wert2 wie in epgsearchcats.conf
    QString getExtEpgCat() const;

    int id() const;
    QString category() const;
    void setCategory(QString newCategory);

    QString name() const;
    void setName(QString newName);

    QString format() const;
    void setFormat(QString newFormat);

    QString values() const;
    QStringList valuesAsList() const;
    void setValues(const QString &values);
    void setValues(const QStringList &values);

    int searchmode() const;

    bool operator==(const ExtEpgCat &value) const;



private:
    //    Q_DISABLE_COPY(EpgSearchCat)

    int m_id = -1;
    QString m_category = "";
    QString m_name = "";
    QString m_values = ""; //Werte, getrennt durch ein ","
    QString m_format = "";
    int m_searchmode = 1; //Standardwert lt. Beschreibung

};
//Q_DECLARE_METATYPE(ExtEpgCat)

QDebug operator <<(QDebug dbg, const ExtEpgCat &value);

#endif // EXTEPGCAT_H
