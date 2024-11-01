#include "recordtreemodel.h"

RecordTreeModel::RecordTreeModel(QObject *parent) : QAbstractItemModel(parent)
{
    setConnections();
}

QModelIndex RecordTreeModel::index(int row, int column, const QModelIndex &parent) const
{
//        qDebug("RecordTreeModel::index");
//        qDebug() << QString("row:%1 column: %2 parent").arg(row).arg(column) << parent;
    if (!hasIndex(row, column, parent)) return QModelIndex();

    RecordTreeItem *parentItem;

    if (!parent.isValid())
        parentItem = m_records_api.getRootItem();
    else
        parentItem = static_cast<RecordTreeItem*>(parent.internalPointer());

    RecordTreeItem *childItem = parentItem->child(row);

    if (childItem) {
        QModelIndex mi = createIndex(row, column, childItem);
//        qDebug() << "index ModelIndex:" << mi;
//        qDebug() << "data" << data(mi);
        return mi;
    }
    qDebug("Kein Index erstellt");
    return QModelIndex();
}

QModelIndex RecordTreeModel::parent(const QModelIndex &index) const
{
//        qDebug("RecordTreeModel::parent");
    if (!index.isValid()) return QModelIndex();

    RecordTreeItem *childItem = static_cast<RecordTreeItem*>(index.internalPointer());
    RecordTreeItem *parentItem = childItem->parentItem();

    if (parentItem == m_records_api.getRootItem()) return QModelIndex();

    int row = parentItem->row();
    QModelIndex p = createIndex(row, 0, parentItem);
//    qDebug() << "Parent Modelindex:" << p;
    return p; //createIndex(parentItem->row(), 0, parentItem);
}

int RecordTreeModel::rowCount(const QModelIndex &parent) const
{
//        qDebug("RecordTreeModel::rowCount");
//        qDebug() << "Modelindex parent" << parent;

        RecordTreeItem *parentItem = nullptr;
        if (parent.isValid()) {
            parentItem = static_cast<RecordTreeItem*>(parent.internalPointer());
        }
        else {
            parentItem = m_records_api.getRootItem();
        }

        if (!parentItem) return 0;

        int anzahl = parentItem->childCount();
//        qDebug() << "Anzahl Reihen" << anzahl;
        return anzahl;
}

int RecordTreeModel::columnCount(const QModelIndex &parent) const
{
    return 1;
    qDebug("RecordTreeModel::columnCount");
    qDebug() << "Modelindex parent" << parent;
//    if (!parent.isValid()) return 0;
    qDebug("ColumnCount = 1");
    return 1;
}

QVariant RecordTreeModel::data(const QModelIndex &index, int role) const
{
//    qDebug("RecordTreeModel::data");

    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid));
//    if (!index.isValid()) return QVariant();
//    qDebug() << QString("data: row: %1 column: %2 role: %3").arg(index.row()).arg(index.column()).arg(role);

    RecordTreeItem *item = static_cast<RecordTreeItem*>(index.internalPointer());
    if (!item) return QVariant();

//    qDebug() << "Nodestring" << item->nodeString();

    if (role == Qt::DisplayRole) {
        if (item->isDir()) return item->nodeString(); else return item->record()->getTitle();
    }

    if (role == Roles::RoleDir) {
        if (item->isDir()) return true; else return false;
    }

    if (role == RoleFullRecord) {
        //            RecordTreeItem *item = static_cast<RecordTreeItem*>(index.internalPointer());
        return QVariant::fromValue(*item->record());
    }

    if (role == RoleTitle) {
        if (item->record()) return item->record()->getTitle(); else return "";
    }

    if (role == Roles::RoleName) {
        if (item->record()) {
            qDebug("data: item->record()");
            return item->record()->getName();
        }
        else {
            qDebug("data: kein item->record()");
            return "kein item->record()";
        }
    }

    if (role == RoleDuration) {
        if (item->record()) {
            int minutes = item->record()->getDuration().hour()*60 + item->record()->getDuration().minute();
            if (minutes < 60) {
                return QString("%1 min").arg(minutes);
            }
            else {
                return item->record()->getDuration().toString("hh:mm");
            }
        }
        else {
            return "";
        }
    }

    //vom ProxyModel für die Sortierung nach dem Aufnahmedatum
    if (role == SortRoleDate) {
        if (item->record()){
            return item->record()->getStartDateTime();
        }
    }

    if (role == SortRoleName) {
        if (item->record()) return item->record()->getTitle();
    }

    return QVariant();
}

bool RecordTreeModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (!m_deletedModelIndex.isValid()) return false;
    beginRemoveRows(parent, row, row + count - 1);

    QVariant v = data(m_deletedModelIndex, Roles::RoleFullRecord);
    Record r = v.value<Record>();
    qDebug() << "Record:" << r;
    bool ok = m_records_api.removeRecord(r.id);
    endRemoveRows();
    return ok;
}

QHash<int, QByteArray> RecordTreeModel::roleNames() const
{
    QHash<int,QByteArray> roles = QAbstractItemModel::roleNames();
    roles[Roles::RoleDir] = "dir";
    roles[Roles::RoleName] = "name";
    roles[Roles::RoleFullRecord] = "record";
    roles[Roles::RoleChannelName] = "channelname";
    roles[Roles::RoleName] = "name";
    roles[Roles::RoleTitle] = "title";
    roles[Roles::RoleDuration] = "duration";
    roles[Roles::RoleEvent] = "event";
    return roles;
}

void RecordTreeModel::getRecords()
{
    if (!m_records_api.url().isValid()) return;
    beginResetModel();
    m_records_api.getRecords();
}

void RecordTreeModel::getEvent(int id)
{
    qDebug("RecordModel::getEvent");
    if (!m_records_api.url().isValid()) return;
    m_records_api.getRecordEvent(id);
}

void RecordTreeModel::deleteRecord(const QModelIndex &index)
{
    qDebug("RecordTreeModel::deleteRecord(QModelindex");

    m_deletedModelIndex = QModelIndex();
    QVariant v = data(index, Roles::RoleFullRecord);
    if (v.canConvert<Record>()) {
        Record record = v.value<Record>();
        if (record.id > 0) {
            m_deletedModelIndex = index;
            m_records_api.deleteRecord(record.id);
        }
    }
}

void RecordTreeModel::deleteRecord(int id)
{
    qDebug("RecordTreeModel::deleteRecord(int)");
    Record record = m_records_api.findRecord(id);
    if (record.id > 0) {
        qDebug() << "gefundener Record:" << record;
        RecordTreeItem *treeItem = m_records_api.findRecord(m_records_api.getRootItem(), record.getNameStringList() );
        if (treeItem) {
            qDebug() << "gefundener TreeRecord:" << *treeItem->record();
            int row = treeItem->row();
//            RecordTreeItem *parentItem = treeItem->parentItem();
            qDebug() << "gefundener TreeRecord Parent:" << treeItem->parentItem()->nodeString();
            QModelIndex mi = createIndex(row, 0, treeItem);
            qDebug() << "QModelindex" << mi;
            qDebug() << "QModelindex row" << mi.row();
            qDebug() << "QModelindex column" << mi.column();
            qDebug() << "QModelindex data" << mi.data();

            QModelIndex parent = mi.parent();
            qDebug() << "QModelindex Parent" << parent;
            qDebug() << "QModelindex row" << parent.row();
            qDebug() << "QModelindex column" << parent.column();
            qDebug() << "QModelindex data" << parent.data();

            deleteRecord(mi);
        }
    }
}

QUrl RecordTreeModel::url() const
{
    return m_url;
}

void RecordTreeModel::setUrl(const QUrl &url)
{
    if (!url.isValid()) return;
    if (url == m_records_api.url()) return;
    m_records_api.setUrl(url);
    emit urlChanged();
}

void RecordTreeModel::setConnections()
{
    connect(&m_records_api, &Records::recordsFinished, this, &RecordTreeModel::slotRecordsFinished);
    connect(&m_records_api, &Records::eventFinished, this, &RecordTreeModel::eventFinished);
    connect(&m_records_api, &Records::recordDeleted, this, &RecordTreeModel::slotRecordDeleted);

    connect(&m_records_api, &Records::svdrpError, this, &RecordTreeModel::error);
}

QVariantMap RecordTreeModel::getRecordEvent() const
{
    return m_records_api.getRecordEvent().toVariantMap();
}

void RecordTreeModel::printModelIndex(QModelIndex index)
{
    qDebug("RecordTreeModel::printModelIndex");
    if (!index.isValid()) qDebug("ungültigerIndex");
    qDebug() << "index" << index;
    QVariant v = index.data(Roles::RoleFullRecord);
    qDebug() << "index.data" << v.value<Record>();
    RecordTreeItem *treeItem = static_cast<RecordTreeItem*>(index.internalPointer());
    qDebug() << "TreeItem" << treeItem;
    qDebug() << "TreeItem.row" << treeItem->row();
    qDebug() << "TreeItem.childCount" << treeItem->childCount();
    qDebug() << "TreeItem.nodeString" << treeItem->nodeString();
    qDebug() << "TreeItem.record" << *treeItem->record();
}

void RecordTreeModel::slotRecordsFinished()
{
    qDebug("RecordTreeModel::slotRecordsFinished");
    endResetModel();
}

void RecordTreeModel::slotRecordDeleted(int id)
{
    qDebug("RecordTreeModel::slotRecordDeleted");
    qDebug() << "gelöschter Record" << id;
    if (m_deletedModelIndex.isValid()) {
        QVariant v = m_deletedModelIndex.data(Roles::RoleFullRecord);
        //Check, ob der gelöschte Record vorhanden ist bzw. identisch ist
        if (v.canConvert<Record>()) {
            Record record = v.value<Record>();
            if (record.id == id) {
                removeRow(m_deletedModelIndex.row(), m_deletedModelIndex.parent());
            }
        }
    }
}


/*
 * ------------------- RecordTreeSortFilterProxyModel -----------------------
 */

RecordTreeSortFilterProxyModel::RecordTreeSortFilterProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{

}

void RecordTreeSortFilterProxyModel::setSortDate(bool sort)
{
    qDebug("SortTreeProxy::setSortDate");
    m_sortDate = sort;
    if (m_sortDate) setSortRole(RecordTreeModel::SortRoleDate); else setSortRole(Qt::DisplayRole);
    this->sort(0, Qt::AscendingOrder);
    emit sortDateChanged();
}

void RecordTreeSortFilterProxyModel::deleteRecord(const QModelIndex &index)
{
    qDebug("RecordTreeSortFilterProxyModel::deleteRecord");
//    if (!index.isValid()) qDebug("ungültigerIndex");

    QModelIndex mi = mapToSource(index);
    RecordTreeModel* recordTreeModel = static_cast<RecordTreeModel*>(sourceModel());
    recordTreeModel->deleteRecord(mi);
}

bool RecordTreeSortFilterProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    RecordTreeItem *leftItem = static_cast<RecordTreeItem*>(source_left.internalPointer());
    RecordTreeItem *rightItem = static_cast<RecordTreeItem*>(source_right.internalPointer());
    if (!leftItem || !rightItem) return false;

    //Nur Verzeichnisse vergleichen
    if (leftItem->isDir() && rightItem->isDir()) {
        QString left = leftItem->nodeString().toUpper();
        QString right = rightItem->nodeString().toUpper();
        return (left < right);
    }

    //Zweimal Titel
    if (!leftItem->isDir() && !rightItem->isDir()) {

        if (m_sortDate) {
            if (leftItem->record() && rightItem->record()) {
                QDateTime left = leftItem->record()->getStartDateTime();
                QDateTime right = rightItem->record()->getStartDateTime();
                return (left < right);
            }
            else {
                return false;
            }
        }
        else {
            //Eventtitle vergleichen
            QString left = "";
            QString right = "";
            if (leftItem->record() && rightItem->record()) {
                left = leftItem->record()->getTitle().toUpper();
                right = rightItem->record()->getTitle().toUpper();
            }
            return (left < right);
        }
    }
    if (leftItem->isDir() && !rightItem->isDir()) return true; else return false;
}
