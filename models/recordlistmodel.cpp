#include "recordlistmodel.h"

RecordListModel::RecordListModel(QObject *parent) : QAbstractListModel(parent)
{
    qDebug("RecordListModel::RecordListModel");
    m_roleNames = QAbstractListModel::roleNames();
    m_roleNames[Roles::RecordRole] = "record";
    m_roleNames[Roles::LastDirRole] = "lastDir";
    m_roleNames[Roles::StartMonthRole] = "month";
    m_roleNames[Roles::StartYearRole] = "year";
    m_roleNames[Roles::StartNameRole] = "name";
    m_roleNames[Roles::SelectRole] = "select";
    m_roleNames[Roles::TimeRole] = "time";

    connect(&m_records_api, &Records::recordsFinished, this, &RecordListModel::slotRecordsFinished);
    connect(&m_records_api, &Records::eventFinished, this, &RecordListModel::slotEvent);
    connect(&m_records_api, &Records::recordDeleted, this, &RecordListModel::slotRecordDeleted);
    connect(&m_records_api, &Records::recordMoved, this, &RecordListModel::slotRecordMoved);
    connect(&m_records_api, &Records::recordsUpdated, this, &RecordListModel::recordsUpdated);
    connect(&m_records_api, &Records::recordPlayed, this, &RecordListModel::recordPlayed);
    connect(&m_records_api, &Records::recordEdited, this, &RecordListModel::recordEdited);
    connect(&m_records_api, &Records::svdrpError, this, &RecordListModel::error);
}

RecordListModel::~RecordListModel()
{
    qDebug("RecordListModel::~RecordListModel()");
}


int RecordListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    //    qDebug("RecordListModel::rowCount");
    //    if (m_records_api) return m_records_api->recordList().count(); else return 0;
    return m_records_api.recordList().count();
}

QVariant RecordListModel::data(const QModelIndex &index, int role) const
{
    //    qDebug("RecordListModel::data");
    // qDebug() << "RecordListModel::data" << index << role;
    //    if (role == RoleRecord) qDebug() << QString("RecordListModel::data: row: %1 column: %2 role: %3").arg(index.row()).arg(index.column()).arg(role) << index;
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    Record record = m_records_api.recordList().at(index.row());
    //    qDebug() << "Record:" << record;

    switch (role) {
    case Qt::DisplayRole: return record.lastName();
    case Roles::RecordRole: return QVariant::fromValue(record);
    // case Roles::RoleDuration: {
    //     int minutes = record.getDuration().hour()*60 + record.getDuration().minute();
    //     if (minutes < 60) { return QString("%1 min").arg(minutes); } else { return record.getDuration().toString("hh:mm"); }
    // }
    case Roles::TimeRole: {
        QString s1 = QLocale::system().toString(record.getStartDateTime(),"ddd, dd.MM.yyyy  hh:mm");
        QString s2 = record.getDuration().toString("  (h:mm)");
        // QTime d = record.getDuration();
        // if (d.hour() == 0) {
        //     s2 = QString("  (%1 min.)").arg(d.hour()*60 + d.minute());
        // }
        // else {
        //     s2 = d.toString("  (h:mm)");
        // }
        return s1 + s2;
    }
    case Roles::LastDirRole: {
        int a = record.getNameStringList().count();
        if ( a >= 2) return record.getNameStringList().at(a-2); else return "";
    }
    case StartMonthRole: return QLocale::system().toString(record.getStartDateTime(),"MMMM yyyy");
    case StartYearRole: return QLocale::system().toString(record.getStartDateTime(),"yyyy");
    case StartNameRole: return record.adjustedName();
    case SelectRole: return m_selectedRecords.contains(record.id());
        //        //vom ProxyModel für die Sortierung nach dem Aufnahmedatum
    case SortDateRole: return record.getStartDateTime();
    case SortNameRole: return record.adjustedName();
    default: return QVariant();
    }
}

bool RecordListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug() << "RecordListModel::setData" <<index << value << role;
    if (role == SelectRole) {
        const QVariant &v = index.data(RecordListModel::RecordRole);
        int id = v.value<Record>().id();
        bool selected = value.toBool();
        if (selected) m_selectedRecords.append(id); else m_selectedRecords.removeOne(id);
        qDebug() << "emit dataChanged";
        emit dataChanged(index, index, { RecordListModel::SelectRole });
        qDebug() << "m_selectedRecords" << m_selectedRecords;
        emit selectedRecordsChanged();
        return true;
    }
    return false;
}

bool RecordListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    qDebug("RecordListModel::removeRows");
    beginRemoveRows(parent, row, row + count - 1);
    endRemoveRows();
    return true;
}

QHash<int, QByteArray> RecordListModel::roleNames() const
{
    return m_roleNames;
}

void RecordListModel::getRecords()
{
    beginResetModel();
    m_records_api.svdrpGetRecords();
}

void RecordListModel::getEvent(int id)
{
    qDebug("RecordListModel::getEvent");
    m_records_api.svdrpGetRecordEvent(id);
}

void RecordListModel::deleteRecord(int id)
{
    Record r(id);
    m_lastUsedModelIndex = QModelIndex();
    int index = m_records_api.recordList().indexOf(r);
    if (index != -1) {
        m_lastUsedModelIndex = createIndex(index,0);
        m_records_api.svdrpDeleteRecord(id);
    }
}

void RecordListModel::editRecord(int id)
{
    m_records_api.svdrpEditRecord(id);
}

void RecordListModel::moveRecord(int id, QString newName)
{
    Record  r(id);
    int index = m_records_api.recordList().indexOf(r);
    m_lastUsedModelIndex = QModelIndex();
    if (index != -1) {
        m_lastUsedModelIndex = createIndex(index,0);
        m_records_api.svdrpMoveRecord(id, newName);
    }
}

void RecordListModel::playRecord(int id, int type, QString time)
{
    qDebug("RecordListModel::playRecord");
    m_records_api.svdrpPlayRecord(id,type,time);
}

void RecordListModel::updateRecords()
{
    qDebug("RecordListModel::updateRecords");
    m_records_api.svdrpUpdate();
}

void RecordListModel::printMap(QVariantMap map)
{
    qDebug("RecordListModel::printMap");
    qDebug() << "Map" << map;
}

QUrl RecordListModel::url() const
{
    return m_url;
}

void RecordListModel::setUrl(const QUrl &url)
{
    if (!url.isValid()) return;
    if (url == m_records_api.url()) return;
    m_records_api.setUrl(url);
    emit urlChanged();
}

void RecordListModel::deleteRecords()
{
    qDebug("RecordListModel::deleteRecords()");
    if (m_selectedRecords.isEmpty()) {
        m_records_api.blockSendQuit(false);
    }
    else {
        m_records_api.blockSendQuit(true);
        int id = m_selectedRecords.at(0);        
        deleteRecord(id);
    }    
}

void RecordListModel::slotRecordsFinished()
{
    qDebug("RecordListModel::slotRecordsFinished");
    endResetModel();
    emit recordsFinished();
}

void RecordListModel::slotRecordDeleted(const Record &record)
{
    qDebug("RecordListModel::slotRecordDeleted");
    qDebug() << "gelöschter Record" << record;
    if (m_lastUsedModelIndex.isValid()) {
        removeRow(m_lastUsedModelIndex.row(), m_lastUsedModelIndex.parent());
        m_lastUsedModelIndex = QModelIndex();
        emit recordDeleted(record);
    }
    if (m_selectedRecords.contains(record.id())) m_selectedRecords.removeOne(record.id());
    deleteRecords();
}

void RecordListModel::slotRecordMoved(const Record &record)
{
    qDebug("RecordListModel::slotRecordMoved");
    qDebug() << "Neuer Record" << record;
    if (m_lastUsedModelIndex.isValid()) {
        emit dataChanged(m_lastUsedModelIndex,m_lastUsedModelIndex);
        emit recordMoved(record);
    }
}

void RecordListModel::slotEvent(const RecordEvent &event)
{
    qDebug("RecordListModel::slotEvent");
    emit eventFinished(event);
}

bool RecordListModel::hasSelection() const
{
    return m_selectedRecords.count() > 0;
}

void RecordListModel::clearSelection()
{
    qDebug() << "RecordListModel::clearSelection";
    beginResetModel();
    m_selectedRecords.clear();
    endResetModel();
    emit selectedRecordsChanged();
}


/*
 * ------------------------------ RecordSelectedProxyModel
*/
bool RecordSelectedProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    // qDebug() << "RecordSelectedProxyModel::filterAcceptsRow";
    if (m_filterSelectedRecords) {
        QModelIndex mi = sourceModel()->index(source_row,0,source_parent);
        return mi.data(RecordListModel::SelectRole).toBool();
    }
    return true;
}

bool RecordSelectedProxyModel::filterSelectedRecords() const
{
    return m_filterSelectedRecords;
}

void RecordSelectedProxyModel::setFilterSelectedRecords(bool newFilterSelectedRecords)
{
    qDebug() << "RecordSelectedProxyModel::setFilterSelectedRecords" << newFilterSelectedRecords;
    if (m_filterSelectedRecords == newFilterSelectedRecords) return;
    m_filterSelectedRecords = newFilterSelectedRecords;
    invalidateFilter();
    emit filterSelectedRecordsChanged();
}



/*
 * ------------------------------ RecordListModelSortFilterProxy
*/

RecordListSFProxyModel::RecordListSFProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    setSortCaseSensitivity(Qt::CaseInsensitive);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
    sort(0, Qt::DescendingOrder); //Bei Column -1 (Standard) wird nicht gefiltert
}

void RecordListSFProxyModel::setSortOrder(Qt::SortOrder sortOrder)
{
    if (sortOrder == this->sortOrder()) return;
    sort(0, sortOrder);
    emit sortOrderChanged(sortOrder);
}
