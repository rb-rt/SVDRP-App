#include "recordlistmodel.h"

RecordListModel::RecordListModel(QObject *parent) : QIdentityProxyModel(parent)
{
    connect(this, &QIdentityProxyModel::sourceModelChanged, this, &RecordListModel::slotSourceModelCanged);
}

QModelIndex RecordListModel::index(int row, int column, const QModelIndex &parent) const
{
//    qDebug("RecordListModel::index");
//    qDebug() << QString("row:%1 column: %2 parent").arg(row).arg(column) << parent;

    QModelIndex mi = createIndex(row, column);
    return mi;
}

int RecordListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
//    qDebug("RecordListModel::rowCount");
//    if (m_records_api) return m_records_api->recordList().count(); else return 0;
    int z = 0;
    if (m_records_api) z = m_records_api->recordList().count();
    qDebug() << "RecordListModel Anzahl Rows" << z;
    return z;
}

QVariant RecordListModel::data(const QModelIndex &index, int role) const
{
//    qDebug("RecordListModel::data");
//    qDebug() << QString("data: row: %1 column: %2 role: %3").arg(index.row()).arg(index.column()).arg(role);

//    QVariant v = QIdentityProxyModel::data(index, role);
//    qDebug() << "Variant:" << v.value<Record>();

    Record record = m_records_api->recordList().at(index.row());
//    qDebug() << "Record:" << record;

    if (role == Qt::DisplayRole) {
        return record.getStartDateTime().toString("ddd, dd.MM.yyyy");
    }

    if (role == RecordTreeModel::RoleDir) return false;

    if (role == RecordTreeModel::RoleFullRecord) {
        return QVariant::fromValue(record);
    }
    if (role == RecordTreeModel::RoleName) return record.getName();
    if (role == RecordTreeModel::RoleTitle) return record.getTitle();

    if (role == RecordTreeModel::RoleDuration) {
            int minutes = record.getDuration().hour()*60 + record.getDuration().minute();
            if (minutes < 60) {
                return QString("%1 min").arg(minutes);
            }
            else {
                return record.getDuration().toString("hh:mm");
            }
    }

    //vom ProxyModel für die Sortierung nach dem Aufnahmedatum
    if (role == SortRoleDate) {
        return record.getStartDateTime();
    }
    if (role == SortRoleName) {
        return record.getTitle();
    }

    return QVariant();
}

//void RecordListModel::deleteRecord(int id)
//{
//    qDebug("RecordListModel::deleteRecord");
//    Q_ASSERT(m_records_api);

//    Record r;
//    r.id = id;
//    int row = m_records_api->recordList().indexOf(r);
//    if (row == -1) return;
//    QModelIndex proxyIndex = index(row, 0, QModelIndex());
//    QModelIndex mi = mapToSource(proxyIndex);

//    RecordTreeModel *treeModel = static_cast<RecordTreeModel*>(this->sourceModel());
//    treeModel->deleteRecord(mi);
//}

//QModelIndex RecordListModel::mapToSource(const QModelIndex &proxyIndex) const
//{
//    qDebug("RecordListModel::mapToSource");
//    if (!proxyIndex.isValid()) return QModelIndex();
//    QModelIndex mi;
//    QVariant v = data(proxyIndex, RecordTreeModel::RoleFullRecord);
//    if (v.isValid() && v.canConvert<Record>()) {
//        Record record = v.value<Record>();
//        qDebug() << "gefundener Record:" << record;
//        RecordTreeItem *treeItem = m_records_api->findRecord(m_records_api->getRootItem(), record.getNameStringList() );
//        if (treeItem) {
//            qDebug() << "gefundener TreeRecord:" << *treeItem->record();
//            int row = treeItem->row();
//            RecordTreeItem *parentItem = treeItem->parentItem();
//            qDebug() << "gefundener TreeRecord Parent:" << parentItem->nodeString();
//            RecordTreeModel *treeModel = static_cast<RecordTreeModel*>(this->sourceModel());
//            mi = treeModel->index(row, 0, parentItem);
//        }
//    }
//    return mi;
//}

void RecordListModel::slotSourceModelCanged()
{
    qDebug("RecordListModel::slotSourceModelchanged()");

    RecordTreeModel *treeModel = static_cast<RecordTreeModel*>(this->sourceModel());
    m_records_api = &treeModel->m_records_api;

//    //Model wird nicht informiert?
//    QAbstractItemModel* model = this->sourceModel();
//    connect(model, &QAbstractItemModel::rowsRemoved, this, &RecordListModel::slotTest);
}


/**
 * @brief RecordListModel::slotTest
 * @param parent: Der QModlIndex kommt von RecordTreeModel -> data liefert ein RecordTreeItem
 * @param first
 * @param last
 *
 */
void RecordListModel::slotTest(const QModelIndex &parent, int first, int last)
{
    qDebug("RecordListModel::slotTest()");
    qDebug() << "Count" << m_records_api->recordList().count();
    qDebug() << "QModelindex parent" << parent;
    qDebug() << "first" << first << "last" << last;
    QVariant v = parent.data(RecordTreeModel::RoleFullRecord);
    qDebug() << "QModelindex data" << v.value<Record>();
    beginRemoveRows(parent, first, last);
    endRemoveRows();
//    beginResetModel();
//    endResetModel();
}



/*
 * ------------------------------ RecordListModelSortFilterProxy
*/

RecordListSortFilterProxyModel::RecordListSortFilterProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    setSortCaseSensitivity(Qt::CaseInsensitive); //keine Unterscheidung groß/klein
    m_sortOrder = Qt::DescendingOrder;
    //    sort(0,m_sortOrder);
    connect(this, &RecordListSortFilterProxyModel::sortRoleChanged,
            this, &RecordListSortFilterProxyModel::sortChanged);
    setSortRole(RecordListModel::SortRoleDate);

    //Cool, erspart den Aufruf Invalidate in setFilterText
    //    connect(this, &SortRecordingTableProxy::filterTextChanged, this, &SortRecordingTableProxy::invalidate);

}

void RecordListSortFilterProxyModel::sort(int column, Qt::SortOrder order)
{
//    qDebug("RecordListSortFilterProxyModel::sort");
QSortFilterProxyModel::sort(column,order); //ruft lessthan auf
}

void RecordListSortFilterProxyModel::setSourceModel(QAbstractItemModel *sourceModel)
{
    qDebug("RecordListSortFilterProxyModel::setSourceModel");
    QSortFilterProxyModel::setSourceModel(sourceModel);

    QAbstractItemModel* model = this->sourceModel();
    connect(model, &QAbstractItemModel::rowsAboutToBeRemoved, this, &RecordListSortFilterProxyModel::slotRowsAboutToBeRemoved);

}

void RecordListSortFilterProxyModel::setSortOrder(Qt::SortOrder sortOrder)
{
    if (sortOrder == m_sortOrder) return;
    m_sortOrder = sortOrder;
    sort(0, m_sortOrder);
    emit sortOrderChanged(m_sortOrder);
}

void RecordListSortFilterProxyModel::setFilterText(QString text)
{
    if (text == m_filterText) return;
    m_filterText = text;
    invalidateFilter();
    emit filterTextChanged(m_filterText);
}

void RecordListSortFilterProxyModel::sortChanged(int sortRole)
{
    Q_UNUSED(sortRole)
    qDebug("RecordListSortFilterProxyModel::sortChanged");
    sort(0, m_sortOrder);
}

bool RecordListSortFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_filterText.isEmpty()) return true;

    int row = source_row;
    //    qDebug() << "row" << row << "filterText" << m_filterText;

    QModelIndex indexTitle = sourceModel()->index(row, 0, source_parent);
    QString title = indexTitle.data().toString();
    return title.contains(m_filterText,Qt::CaseInsensitive);
}

bool RecordListSortFilterProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
//    qDebug("RecordListSortFilterProxyModel::lessThan");
return QSortFilterProxyModel::lessThan(source_left,source_right);
}

void RecordListSortFilterProxyModel::slotRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
    qDebug("RecordListSortFilterProxyModel::slotRowsAboutToBeRemoved()");
    qDebug() << "QModelindex parent" << parent;
    qDebug() << "first" << first << "last" << last;
//    QVariant v = parent.data(RecordTreeModel::RoleFullRecord);
    QVariant v = parent.data(RecordTreeModel::RoleFullRecord);
    qDebug() << "QModelindex data" << v.value<Record>();
    v = sourceModel()->data(parent, RecordTreeModel::RoleFullRecord);
    qDebug() << "RecordListModel data" << v.value<Record>();
    qDebug("MapToSource");

    QModelIndex mi = mapToSource(parent);
    qDebug() << "QModelindex source" << mi;
    qDebug() << "first" << first << "last" << last;
    v = mi.data(RecordTreeModel::RoleFullRecord);
    qDebug() << "QModelindex data" << v.value<Record>();
    v = sourceModel()->data(mi, RecordTreeModel::RoleFullRecord);
    qDebug() << "RecordListModel data" << v.value<Record>();
}
