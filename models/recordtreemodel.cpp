#include "recordtreemodel.h"

RecordTreeModel::RecordTreeModel(QObject *parent) : QSortFilterProxyModel{parent}
{
    m_roleNames = QAbstractItemModel::roleNames();
    m_roleNames[Roles::IsDirRole] = "isDir";
    m_roleNames[Roles::RecordRole] = "record";
    m_roleNames[Roles::DirRole] = "dir";
    m_roleNames[Roles::SelectRole] = "select";
    m_roleNames[RecordListModel::Roles::TimeRole] = "time";

    sort(0, Qt::AscendingOrder); //Bei Column -1 (Standard) wird nicht gefiltert
    connect(this, &RecordTreeModel::sourceModelChanged, this, &RecordTreeModel::slotSourceModelChanged);
}

QVariant RecordTreeModel::data(const QModelIndex &index, int role) const
{
    // qDebug() << "RecordTreeModel::data" << index << role;
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid | QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    const QModelIndex &mi = mapToSource(index);

    switch (role) {
    case Qt::DisplayRole: {
        const QVariant &v = mi.data(RecordListModel::RecordRole);
        const QStringList &l = v.value<Record>().getNameStringList();
        if (m_column < l.count()) return l.at(m_column); else return "Error Column!";
    }
    case IsDirRole: {
        const QVariant &v = mi.data(RecordListModel::RecordRole);
        int count = v.value<Record>().getNameStringList().count();
        return m_column < (count - 1);
    }
    case RecordRole: return mi.data(RecordListModel::RecordRole);
    case SelectRole: return mi.data(RecordListModel::SelectRole);
    default: return mi.data(role);
    }
}

bool RecordTreeModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug() << "RecordFakeTreeModel::setData" << index << value << role;
    switch (role) {
    case DirRole: {
        qDebug("setData RoleDir");
        if (value.canConvert<QString>()) {
            beginResetModel();
            QString dir = value.toString();
            qDebug() << "dir" << dir;
            m_tree.append(dir);
            m_column++;
            m_cache.clear();
            endResetModel();
            emit levelChanged();
            return true;
        }
        break;
    }
    case SelectRole: {
        qDebug("setData RoleSelect");
        const QModelIndex &mi = mapToSource(index);
        return sourceModel()->setData(mi, value, RecordListModel::SelectRole);
    }
    default: return false;
    }
    return false;
}

QHash<int, QByteArray> RecordTreeModel::roleNames() const
{
    return m_roleNames;
}

void RecordTreeModel::levelUp()
{
    qDebug() << "RecordTreeModel::levelUp";
    if (m_column == 0) return;
    beginResetModel();
    m_column--;
    m_tree.removeLast();
    m_cache.clear();
    endResetModel();
    emit levelChanged();
}

void RecordTreeModel::setSortOrder(Qt::SortOrder sortOrder)
{
    if (sortOrder == this->sortOrder()) return;
    sort(0, sortOrder);
    emit sortOrderChanged(sortOrder);
}

bool RecordTreeModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    // qDebug() << "RecordTreeModel::filterAcceptsRow filterRole()" << filterRole();

    const QModelIndex &mi = sourceModel()->index(source_row,0,source_parent);
    const QVariant &v = mi.data(RecordListModel::RecordRole);
    const Record &record = v.value<Record>();
    const QStringList &nameList = record.getNameStringList();

    // qDebug() << "NameStringList" << nameList;

    if (nameList.count() < m_column + 1) return false; //Zu kurze Pfade aussortieren

    //Aussortieren "falscher Pfade"
    if (m_column > 0) {
        QStringList path = nameList.first(m_column);
        if (path != m_tree) return false;
    }

    if (nameList.count() == m_column + 1) return true; //Titel immer zeigen

    QStringList path = nameList.first(m_column + 1);
    if (m_cache.contains(path)) {
        return false;
    }
    else {
        m_cache.insert(path);
        return true;
    }
}

bool RecordTreeModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    // qDebug() << "RecordTreeModel::lessThan";
    QVariant v = source_left.data(RecordListModel::RecordRole);
    const Record &left_record = v.value<Record>();

    v = source_right.data(RecordListModel::RecordRole);
    const Record &right_record = v.value<Record>();

    bool left_isDir = (left_record.getNameStringList().count() - 1) > m_column;
    bool right_isDir = (right_record.getNameStringList().count() - 1) > m_column;

    //Verzeichnisse immer zuerst und alphabetisch sortieren
    if (left_isDir || right_isDir) {
        bool less = false;
        if (left_isDir && right_isDir) {
            QString left = left_record.getNameStringList().at(m_column);
            QString right = right_record.getNameStringList().at(m_column);
            int x = QString::compare(left,right, Qt::CaseInsensitive );
            less = (x <= 0);
        }
        else if (left_isDir) {
            less = true;
        }
        else {
            less = false;
        }
        if (sortOrder() == Qt::DescendingOrder) less = !less; //Verzeichnisse immer zuerst anzeigen
        return less;
    }
    //Sortierung der Titel
    else if (sortRole() == Qt::DisplayRole) {
        //Alphabetische Sortierung der Aufnahmen
        QString left = left_record.adjustedName();
        QString right = right_record.adjustedName();
        int x = QString::compare(left,right, sortCaseSensitivity());
        return (x <= 0);
    }
    else if (sortRole() == RecordListModel::SortDateRole) {
        //Sortierung nach Aufnahmedatum
        QDateTime left = left_record.getStartDateTime();
        QDateTime right = right_record.getStartDateTime();
        return (left < right);
    }
    return false;
}

void RecordTreeModel::slotSourceModelChanged()
{
    qDebug() << "RecordTreeModel::slotSourceModelChanged";
    m_recordFilterTextProxyModel = qobject_cast<RecordFilterTextModel*>(sourceModel());
    Q_ASSERT(m_recordFilterTextProxyModel);
    m_recordSelectedProxyModel = qobject_cast<RecordSelectedProxyModel*>(m_recordFilterTextProxyModel->sourceModel());
    Q_ASSERT(m_recordSelectedProxyModel);
    connect(m_recordSelectedProxyModel, &RecordSelectedProxyModel::filterSelectedRecordsChanged, this, &RecordTreeModel::slotClearCache);
    connect(m_recordFilterTextProxyModel, &RecordFilterTextModel::filterTextChanged, this, &RecordTreeModel::slotClearCache);
    connect(m_recordFilterTextProxyModel, &RecordFilterTextModel::filterCaseSensitivityChanged, this, &RecordTreeModel::slotClearCache);
    connect(m_recordFilterTextProxyModel, &RecordFilterTextModel::filterPathChanged, this, &RecordTreeModel::slotClearCache);
}

void RecordTreeModel::slotClearCache()
{
    qDebug() << "RecordTreeModel::slotClearCache";
    m_cache.clear();
}
