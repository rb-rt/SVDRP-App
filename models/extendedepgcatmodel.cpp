#include "extendedepgcatmodel.h"

ExtendedEpgCatModel::ExtendedEpgCatModel(QObject *parent) : QAbstractListModel(parent)
{
    m_roleNames = QAbstractListModel::roleNames();
    m_roleNames[Roles::NameRole] = "name";
    m_roleNames[Roles::ValuesRole] = "values";
    m_roleNames[Roles::DefaultValuesRole] = "defaults";
    m_roleNames[Roles::ValuesAsListRole] = "list";
    m_roleNames[Roles::SearchModeRole] = "searchmode";
}

int ExtendedEpgCatModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_defaultValues.count();
}


QVariant ExtendedEpgCatModel::data(const QModelIndex &index, int role) const
{
    //    qDebug() << "ExtendedEpgCatModel::data index.row" << index.row() << "Role" << role;
    if (!index.isValid()) return QVariant();

    ExtEpgCat d = m_defaultValues.at(index.row());

    switch (role) {
    case NameRole: return d.name(); break;
    case ValuesRole: {
        QString v = "";
        int i = m_values.indexOf(d);
        if (i != -1) v = m_values.at(i).values();
        return v;
        break;
    }
    case ValuesAsListRole: {
        QStringList l;
        int i = m_values.indexOf(d);
        if (i != -1) l = m_values.at(i).valuesAsList();
        return l;
        break;
    }
    case DefaultValuesRole: return d.valuesAsList(); break;
    case SearchModeRole: return d.searchmode(); break;
    default: return QVariant(); break;
    }
}

bool ExtendedEpgCatModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug() << "ExtendedEpgCatModel::setData index.row" << index.row() << "Value" << value << "Role" << role;

    if (role == ValuesRole || role == ValuesAsListRole) {
        //Falls noch keine values vorliegen (-> neu!)
        if (m_values.count() != m_defaultValues.count()) generateEmptyValues();

        ExtEpgCat e = m_values.at(index.row());

        switch (role) {
        case ValuesRole: {
            QString s = value.toString();
            e.setValues(s);
            m_values.replace(index.row(),e);
            emit dataChanged(index, index, {role});
            checkValues();
            return true;
        }
        break;
        case ValuesAsListRole: {
            if (value.canConvert<QStringList>()) {
                QStringList l = value.value<QStringList>();
                e.setValues(l);
                m_values.replace(index.row(),e);
                emit dataChanged(index, index, {ValuesRole, ValuesAsListRole});
                checkValues();
                return true;
            }
        }
        break;
        default: break;
        }
    }
    return false;
}

QHash<int, QByteArray> ExtendedEpgCatModel::roleNames() const
{
    return m_roleNames;
}

QList<ExtEpgCat> ExtendedEpgCatModel::defaultValues() const
{
    return m_defaultValues;
}

void ExtendedEpgCatModel::setDefaultValues(const QList<ExtEpgCat> &newDefaultValues)
{
    qDebug() << "ExtendedEpgCatModel::setDefaultValues";// << newDefaultValues;
    m_defaultValues.clear();
    m_values.clear();
    m_defaultValues = newDefaultValues;
    emit defaultValuesChanged();
}

QStringList ExtendedEpgCatModel::values() const
{
    QStringList l;
    for (int i=0; i < m_values.count(); ++i) {
        QString s = QString("%1#%2").arg(m_values.at(i).id()).arg(m_values.at(i).values());
        l.append(s);
    }
    return l;
}

void ExtendedEpgCatModel::setValues(const QStringList &newValues)
{
    qDebug() << "ExtendedEpgCatModel::setValues" << newValues << newValues.count();
    beginResetModel();

    //Entweder keine Values oder die komplette Liste
    if (newValues.isEmpty()) {
        m_values.clear();
        m_emptyValues = true;
        emit valuesEmptyChanged();
    }
    else {
        generateEmptyValues();
        for (int i=0; i < newValues.count(); ++i) {
            QStringList l = newValues.at(i).split("#");
            bool ok;
            int id = l.at(0).toInt(&ok);
            if (!ok) continue;
            QString values = "";
            if (l.count() > 1) values = l.at(1);
            ExtEpgCat e(id);
            int index = m_values.indexOf(e);
            if (index != -1) {
                e = m_values.at(index);
                e.setValues(values);
                m_values.replace(index, e);
            }
        }
        checkValues();
    }

    endResetModel();
}

bool ExtendedEpgCatModel::emptyValues() const
{
    return m_emptyValues;
}

void ExtendedEpgCatModel::generateEmptyValues()
{
    m_values.clear();
    QList<ExtEpgCat>::ConstIterator it;
    for (it = m_defaultValues.constBegin(); it != m_defaultValues.constEnd(); it++) {
        ExtEpgCat e(it->id());
        m_values.append(e);
    }
}

void ExtendedEpgCatModel::checkValues()
{
    qDebug() << "ExtendedEpgCatModel::checkValues";
    m_emptyValues = true;
    QList<ExtEpgCat>::ConstIterator it;
    for (it = m_values.constBegin(); it != m_values.constEnd(); it++) {
        if (it->values().isEmpty()) {
            continue;
        }
        else {
            m_emptyValues = false;
            break;
        }
    }
    emit valuesEmptyChanged();
}
