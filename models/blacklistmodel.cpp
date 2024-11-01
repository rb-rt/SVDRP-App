#include "blacklistmodel.h"

BlacklistModel::BlacklistModel(QObject *parent) : BaseModel(parent)
{
//    connect(this, &BaseModel::epgSearchChanged, this, &BlacklistModel::slotEPGSearchChanged);
}

int BlacklistModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    //    qDebug() << "BlacklistModel::rowCount parent" << parent;
    if (parent.isValid()) return 0;
    //    return m_blacklist_api.blacklists().count();
    if (m_epgsearch) {
        return m_epgsearch->blacklists().count();
    }
    else {
        return 0;
    }
    //    return m_blacklist.count();
}

QVariant BlacklistModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    //    qDebug() << QString("BlacklistModel::data row:%1 role:%2").arg(index.row()).arg(role) << "ModelIndex" << index;

    Blacklist bl = m_epgsearch->blacklists().at(index.row());

    switch (role) {
    case RoleBlacklist: return QVariant::fromValue(bl);
    case Qt::DisplayRole: return bl.search;
    case BaseModel::ChannelRole: {
        switch (bl.useChannel) {
        case 0: return "Alle";
        case 1: if (bl.channelMin == bl.channelMax) {
                if (m_channelModel) return m_channelModel->getChannel(bl.channelMin).name; else  return bl.channelMin;
            }
            else {
                if (m_channelModel) {
                    QString s1 = m_channelModel->getChannel(bl.channelMin).name;
                    QString s2 = m_channelModel->getChannel(bl.channelMax).name;
                    return s1 + " - " + s2;
                }
                else {
                    return QString("%1 - %2").arg(bl.channelMin,bl.channelMax);
                }
            }
        case 2: return bl.channels;
        case 3: return "FTA";
        default: return "Kanal X";
        }
    }
    case BaseModel::TimeRole: if (bl.useTime) { return bl.startTime().toString("hh:mm") + " - " + bl.stopTime().toString("hh:mm"); } else return "";
    case BaseModel::DurationRole: if (bl.useDuration) { return QString("%1 - %2 min.").arg(bl.getDurationMinInMinutes()).arg(bl.getDurationMaxInMinutes()); } else return "";
    case BaseModel::WeekdayRole: return bl.getWeekdays();
    default: return QVariant();
    }
}

bool BlacklistModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug() << "BlacklistModel::setData QModelIndex:" << index << "Value:" << value << "Role:" << role;
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));
    if (role == Qt::EditRole) {

        Blacklist bl = value.value<Blacklist>();
        bool ok = m_epgsearch->replaceBlacklist(bl);
        if (ok) emit dataChanged(index, index);
        return ok;
    }
    return false;
}

bool BlacklistModel::removeRows(int row, int count, const QModelIndex &parent)
{
    beginRemoveRows(parent, row, row + count - 1);
    bool ok = m_epgsearch->removeBlacklist(row);
    endRemoveRows();
    return ok;
}

QHash<int, QByteArray> BlacklistModel::roleNames() const
{
    QHash<int,QByteArray> roles = BaseModel::roleNames();
    roles[Roles::RoleBlacklist] = "blacklist";
    return roles;
}

void BlacklistModel::getBlacklists()
{
    qDebug("BlacklistModel::getBlacklists()");
    beginResetModel();
    m_epgsearch->svdrpGetBlacklists();
}

//void BlacklistModel::query(const QVariantMap &bl)
//{
//    qDebug("BlacklistModel::query");
//    qDebug() << bl;
//    Blacklist b(bl);
//    m_epgsearch->svdrpQuery(bl);
//}



void BlacklistModel::setBlacklist(const QVariantMap &bl)
{
    qDebug("BlacklistModel::setBlacklist");
    Blacklist b(bl);
    if (b.id >= 0) {
        m_epgsearch->svdrpEditBlacklist(b);
    }
    else {
        m_epgsearch->svdrpNewBlacklist(b);
    }
}

void BlacklistModel::deleteBlacklist(int id)
{
    m_epgsearch->svdrpDeleteBlacklist(id);
}

Blacklist BlacklistModel::getBlacklist()
{
    return Blacklist();
}

void BlacklistModel::slotEPGSearchChanged()
{
    qDebug("BlacklistModel::slotEPGSearchChanged");
    Q_ASSERT(m_epgsearch);
    qDebug() << "m_epgsearch:" << m_epgsearch;
    //    if (m_epgsearch) {
    //        disconnect(m_epgsearch, &EPGSearch::blacklistsFinished, this, &BlacklistModel::slotBlacklistsFinished);
    //        disconnect(m_epgsearch, &EPGSearch::blacklistAdded, this, &BlacklistModel::slotBlacklistAdded);
    //        disconnect(m_epgsearch, &EPGSearch::blacklistChanged, this, &BlacklistModel::slotBlacklistChanged);
    //        disconnect(m_epgsearch, &EPGSearch::blacklistDeleted, this, &BlacklistModel::slotBlacklistDeleted);
    //        disconnect(m_epgsearch, &EPGSearch::svdrpError, this, &BlacklistModel::error);
    //    }
    connect(m_epgsearch, &EPGSearch::blacklistsFinished, this, &BlacklistModel::slotBlacklistsFinished);
    connect(m_epgsearch, &EPGSearch::blacklistAdded, this, &BlacklistModel::slotBlacklistAdded);
    connect(m_epgsearch, &EPGSearch::blacklistChanged, this, &BlacklistModel::slotBlacklistChanged);
    connect(m_epgsearch, &EPGSearch::blacklistDeleted, this, &BlacklistModel::slotBlacklistDeleted);
}

void BlacklistModel::slotBlacklistsFinished()
{
    qDebug("BlacklistModel::slotBlacklistsFinished");
    endResetModel();
}

void BlacklistModel::slotBlacklistAdded(const Blacklist &bl)
{
    qDebug("BlacklistModel::slotBlacklistAdded");

    int rowIndex = rowCount();
    bool ok = m_epgsearch->addBlacklist(bl);

    if (ok) {
        //        int rowIndex = rowCount();
        beginInsertRows(QModelIndex(), rowIndex, rowIndex);
        endInsertRows();
    }
}

void BlacklistModel::slotBlacklistChanged(const Blacklist &bl)
{
    qDebug("BlacklistModel::slotBlacklistChanged");
    int index = m_epgsearch->blacklists().indexOf(bl);
    if (index >= 0) {
        QVariant v = QVariant::fromValue(bl);
        QModelIndex mi = this->index(index);
        setData(mi, v);
    }
}

void BlacklistModel::slotBlacklistDeleted(const Blacklist &bl)
{
    qDebug("BlacklistModel::slotDeleteBlacklist");
    int index = m_epgsearch->blacklists().indexOf(bl);
    if (index >= 0) {
        removeRow(index);
    }
}
