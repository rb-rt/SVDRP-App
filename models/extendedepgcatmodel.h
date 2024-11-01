#ifndef EXTENDEDEPGCATMODEL_H
#define EXTENDEDEPGCATMODEL_H

#include "data/extepgcat.h"
#include <QAbstractListModel>

class ExtendedEpgCatModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QList<ExtEpgCat> defaultValues READ defaultValues WRITE setDefaultValues NOTIFY defaultValuesChanged FINAL)
    Q_PROPERTY(QStringList values READ values WRITE setValues NOTIFY valuesChanged FINAL)
    Q_PROPERTY(bool emptyValues MEMBER m_emptyValues NOTIFY valuesEmptyChanged)

public:

    enum Roles { NameRole = Qt::UserRole, ValuesRole, ValuesAsListRole, DefaultValuesRole, SearchModeRole};
    Q_ENUM(Roles)

    explicit ExtendedEpgCatModel(QObject *parent = nullptr);


    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int,QByteArray> roleNames() const override;


    QList<ExtEpgCat> defaultValues() const;
    void setDefaultValues(const QList<ExtEpgCat> &newDefaultValues);

    QStringList values() const;
    void setValues(const QStringList &newValues); //als Array [ id#wert1,wert2, id2#wert1,wert2, .. ]

    bool emptyValues() const;

private:
    QHash<int,QByteArray> m_roleNames;

    QList<ExtEpgCat> m_values;
    QList<ExtEpgCat> m_defaultValues;
    bool m_emptyValues: true;

    void generateEmptyValues(); //Erstellt eine leere Liste -> id1#, id2#,
    void checkValues(); //ist überhaupt eine Kategorie vorhanden bzw gesetzt?

signals:
    void defaultValuesChanged();
    void valuesChanged();
    void valuesEmptyChanged();
};

#endif // EXTENDEDEPGCATMODEL_H
