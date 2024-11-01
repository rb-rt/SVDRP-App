#include "channelgroupsmodel.h"

ChannelGroupsModel::ChannelGroupsModel(QObject *parent) : QAbstractListModel{parent}
{
    connect(this, &ChannelGroupsModel::epgSearchChanged, this, &ChannelGroupsModel::slotEPGSearchChanged);
}

int ChannelGroupsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    // return m_epgsearch->channelGroups().count();
    return m_groupNames.count();
}

QVariant ChannelGroupsModel::data(const QModelIndex &index, int role) const
{
    qDebug() << "ChannelGroupsModel::data QModelIndex:" << index << "Role:" << role;
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    switch (role) {
    case Qt::DisplayRole: return m_groupNames.at(index.row());
    case Roles::ChannelsRole: {
        QString groupName = m_groupNames.at(index.row());
        return m_epgsearch->channelGroups().value(groupName);
    }
    default:
        return QVariant();
    }
}
/*
bool ChannelGroupsModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug() << "ChannelGroupsModel::setData QModelIndex:" << index << "Value:" << value << "Role:" << role;
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid | QAbstractItemModel::CheckIndexOption::ParentIsInvalid));
    if (role == Qt::EditRole) {
        emit dataChanged(index, index);
        // emit dataChanged(index, index, {Roles::ChannelsRole});
        data(index, Roles::ChannelsRole);
        return true;
    }
    return false;
}
*/
bool ChannelGroupsModel::removeRows(int row, int count, const QModelIndex &parent)
{
    Q_UNUSED(count);
    qDebug("ChannelGroupsModel::removeRows()");
    QModelIndex mi = index(row);
    qDebug() << "Entferne row " << row << "ModelIndex" << mi.data();
    beginRemoveRows(parent, row, row);
    m_groupNames.removeAt(row);
    endRemoveRows();
    return true;
}

QHash<int, QByteArray> ChannelGroupsModel::roleNames() const
{
    QHash<int,QByteArray> roles = QAbstractItemModel::roleNames();
    roles[Roles::ChannelsRole] = "channels";
    return roles;
}

void ChannelGroupsModel::getChannelGroups()
{
    qDebug("ChannelGroupsModel::getChannelGroups()");
    beginResetModel();
    m_epgsearch->svdrpGetChannelGroups();
}

void ChannelGroupsModel::newChannelGroup(QString groupName, QStringList channels)
{
    qDebug("ChannelGroupsModel::newChannelGroup()");
    channels.prepend(groupName);
    m_epgsearch->svdrpNewChannelGroup(channels);
}

void ChannelGroupsModel::editChannelGroup(QString groupName, QStringList channels)
{
    channels.prepend(groupName);
    m_epgsearch->svdrpEditChannelGroup(channels);
}

void ChannelGroupsModel::renameChannelGroup(QString oldName, QString newName)
{
    m_epgsearch->svdrpRenameChannelGroup(oldName, newName);
}

void ChannelGroupsModel::deleteChannelGroup(QString groupName)
{
    m_epgsearch->svdrpDeleteChannelGroup(groupName);
}

EPGSearch *ChannelGroupsModel::getEPGSearch() const
{
    return m_epgsearch;
}

void ChannelGroupsModel::setEPGSearch(EPGSearch *epgsearch)
{
    Q_ASSERT(epgsearch);
    if (m_epgsearch == epgsearch) return;
    m_epgsearch = epgsearch;
    emit epgSearchChanged();
}

void ChannelGroupsModel::slotEPGSearchChanged()
{
    qDebug("ChannelGroupsModel::slotEPGSearchChanged");
    connect(m_epgsearch, &EPGSearch::channelGroupsFinished, this, &ChannelGroupsModel::slotChannelGroupsFinished);
    connect(m_epgsearch, &EPGSearch::channelGroupAdded, this, &ChannelGroupsModel::slotChannelGroupAdded);
    connect(m_epgsearch, &EPGSearch::channelGroupEdited, this, &ChannelGroupsModel::slotChannelGroupEdited);
    connect(m_epgsearch, &EPGSearch::channelGroupRenamed, this, &ChannelGroupsModel::slotChannelGroupRenamed);
    connect(m_epgsearch, &EPGSearch::channelGroupDeleted, this, &ChannelGroupsModel::slotChannelGroupDeleted);
    m_groupNames = m_epgsearch->channelGroups().keys();
}

void ChannelGroupsModel::slotChannelGroupsFinished()
{
    qDebug("ChannelGroupsModel::slotChannelGroupsFinished()");
    m_groupNames = m_epgsearch->channelGroups().keys();
    endResetModel();
}

void ChannelGroupsModel::slotChannelGroupAdded(QString groupName)
{
    qDebug("ChannelGroupsModel::slotChannelGroupAdded()");
    if (!m_groupNames.contains(groupName)) {
        beginResetModel();
        m_groupNames = m_epgsearch->channelGroups().keys();
        endResetModel();
    }
}

void ChannelGroupsModel::slotChannelGroupEdited(QString groupName)
{
    Q_UNUSED(groupName);
    qDebug("ChannelGroupsModel::slotChannelGroupEdited()");
}

void ChannelGroupsModel::slotChannelGroupRenamed(QString newName)
{
    Q_UNUSED(newName);
    qDebug("ChannelGroupsModel::slotChannelGroupRenamed()");
    beginResetModel();
    m_groupNames = m_epgsearch->channelGroups().keys();
    endResetModel();
}

void ChannelGroupsModel::slotChannelGroupDeleted(QString groupName)
{
    qDebug("ChannelGroupsModel::slotChannelGroupDeleted()");
    int index = m_groupNames.indexOf(groupName);
    if (index != -1) {
        removeRow(index);
    }
}
