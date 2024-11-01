#include "channelmodel.h"

ChannelModel::ChannelModel(QObject *parent) : QAbstractListModel(parent)
{
    qDebug("ChannelModel::ChannelModel");

    m_roleNames = QAbstractListModel::roleNames();
    m_roleNames[Roles::ChannelRole] = "channel";
    m_roleNames[Roles::ChannelNumberNameRole] = "channelnrname";
    m_roleNames[Roles::ChannelIdRole] = "id";
    m_roleNames[Roles::ChannelNumberRole] = "channelnr";
    m_roleNames[Roles::FrequencyRole] = "frequency";
    m_roleNames[Roles::GroupRole] = "group";

    connect(&m_channel_api, &Channels::channelsFinished, this, &ChannelModel::slotChannelFinished);
    connect(&m_channel_api, &Channels::channelUpdated, this, &ChannelModel::slotChannelUpdated);
    connect(&m_channel_api, &Channels::channelSwitched, this, &ChannelModel::channelSwitched);
    connect(&m_channel_api, &Channels::channelDeleted, this, &ChannelModel::slotChannelDeleted);
    connect(&m_channel_api, &Channels::svdrpError, this, &ChannelModel::error);
}

ChannelModel::~ChannelModel()
{
    qDebug("ChannelModel::~ChannelModel");
}

int ChannelModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid()) return 0;
    return m_channel_api.channelList().count();
}

QVariant ChannelModel::data(const QModelIndex &index, int role) const
{
    // qDebug() << "ChannelModel::data:" << index << "Role:" << role;

    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    switch (role) {
    case Qt::DisplayRole: return m_channel_api.channelList().at(index.row()).name;
    case Roles::ChannelNumberNameRole: {
        Channel ch = m_channel_api.channelList().at(index.row());
        return QString("%1 - %2").arg(ch.number).arg(ch.name); //Kanalnummer + Kanalname: 1 - ARD
    }
    case Roles::ChannelRole: {
        Channel ch = m_channel_api.channelList().at(index.row());
        return QVariant::fromValue(ch);
    }
    case Roles::ChannelIdRole: return m_channel_api.channelList().at(index.row()).channel_id;
    case Roles::ChannelNumberRole: return m_channel_api.channelList().at(index.row()).number;
    case Roles::FrequencyRole: return m_channel_api.channelList().at(index.row()).frequency;
    case Roles::GroupRole: return m_channel_api.channelList().at(index.row()).group;
    default: return QVariant();
    }
    return QVariant();
}

QHash<int, QByteArray> ChannelModel::roleNames() const
{
    qDebug() << "ChannelModel::roleNames";
    return m_roleNames;
}


void ChannelModel::getChannels()
{
    qDebug("ChannelModel::getChannels()");
    beginResetModel();
    m_channel_api.svdrpGetChannels();
}

void ChannelModel::deleteChannel(QString channelId)
{
    qDebug() << "ChannelModel::deleteChannel" << channelId;
    m_channel_api.svdrpDeleteChannel(channelId);
}

void ChannelModel::moveChannel(int nr, int to)
{
    beginResetModel();
    m_channel_api.svdrpMoveChannel(nr, to);
}

void ChannelModel::updateChannel(const QVariantMap &channel)
{
    //    qDebug() << "ChannelModel::updateChannel" << channel;
    Channel ch(channel);
    m_channel_api.svdrpUpdateChannel(ch);
}

void ChannelModel::switchToChannel(QString channel_id)
{
    m_channel_api.svdrpSwitchToChannel(channel_id);
}

void ChannelModel::deleteChannels(const QStringList &channelIds)
{
    qDebug() << "ChannelModel::deleteChannels" << channelIds;
    if (channelIds.isEmpty()) return;
    m_channelIds = channelIds;
    beginResetModel();
    deleteChannel(m_channelIds.at(0));
}

QUrl ChannelModel::getUrl() const
{
    qDebug("ChannelModel::getUrl");
    return m_channel_api.url();
}

void ChannelModel::setUrl(const QUrl &url)
{
    qDebug() << "ChannelModel::setUrl" << url;
    m_channel_api.setUrl(url);
    emit urlChanged();
}

Channel ChannelModel::getChannel(QString channel_id)
{
    return m_channel_api.getChannel(channel_id);
}

int ChannelModel::getChannelNumber(QString channel_id)
{
    return m_channel_api.getChannel(channel_id).number;
}

QString ChannelModel::getGroupName(int nr)
{
    // qDebug() << "ChannelModel::getGroupName" << nr;
    return m_channel_api.groups().value(nr,"Keine Kanalgruppen");
}

const QList<Channel> &ChannelModel::channelList() const
{
    return m_channel_api.channelList();
}

void ChannelModel::slotChannelFinished()
{
    qDebug("ChannelModel::slotChannelFinished");
    endResetModel();
    emit channelsFinished();
}

void ChannelModel::slotChannelUpdated(const Channel &channel)
{
    qDebug() << "ChannelModel::slotChannelUpdated";
    for (int i = 0; i < channelList().count(); ++i) {
        const Channel &ch = channelList().at(i);
        if (ch.channel_id == channel.channel_id) {
            QModelIndex mi = index(i);
            if (mi.isValid()) emit dataChanged(mi, mi);
            break;
        }
    }
}

void ChannelModel::slotChannelDeleted(const Channel &channel)
{
    qDebug() << "ChannelModel::slotChannelDeleted" << channel;
    qDebug() << "Noch vorhandene IDs in m_channelIds" << m_channelIds;

    if (m_channelIds.contains(channel.channel_id)) {
        bool ok = m_channelIds.removeOne(channel.channel_id);
        qDebug() << "RemoveOne erfolgreich?" << ok;
        if (m_channelIds.count() == 0) {
            qDebug("Keine ChannelIds mehr vorhanden");
            endResetModel();
            getChannels();
        }
        else {
            deleteChannel(m_channelIds.at(0));
        }
    }
    else {
        qDebug("Channel ID nicht gefunden");
    }
}



/* -------------------- FilterProxyModel ------------------------*/

ChannelSFProxyModel::ChannelSFProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    sort(0, Qt::AscendingOrder); //Bei Column -1 (Standard) wird nicht gefiltert
    // setSortRole(ChannelModel::SortRoleNumber); Ergibt falsche "sections" Einträge bei der ListView
}

bool ChannelSFProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
    if (!index.isValid()) return false;

    Channel ch = index.data(ChannelModel::ChannelRole).value<Channel>();

    bool channels;
    
    switch (m_channelType) {
    case 0: channels = true; break;
    case 1: channels = !ch.is_radio; break;
    case 2: channels = ch.is_radio; break;
    default: channels = false;
    }

    switch (m_filterCA) {
    case Qt::Unchecked: channels = channels && true; break;
    case Qt::PartiallyChecked: channels = (channels && ch.is_fta); break;
    case Qt::Checked: channels = channels && !ch.is_fta; break;
    }

    bool filteredText = true;

    if (!m_filterText.isEmpty()) {
        QString f = m_filterText;
        if (m_wordOnly) {
            f.prepend("\\b");
            f.append("\\b");
        }
        QRegularExpression re(f);
        if (!filterCaseSensitivity()) re.setPatternOptions(QRegularExpression::CaseInsensitiveOption);
        QRegularExpressionMatch match = re.match(ch.name);
        filteredText = match.hasMatch();
    }
    return filteredText && channels;
}

bool ChannelSFProxyModel::wordOnly() const
{
    return m_wordOnly;
}

void ChannelSFProxyModel::setWordOnly(bool newWordOnly)
{
    if (m_wordOnly == newWordOnly) return;
    m_wordOnly = newWordOnly;
    invalidateFilter();
    emit wordOnlyChanged();
}

bool ChannelSFProxyModel::sortNumber() const
{
    return m_sortNumber;
}

void ChannelSFProxyModel::setSortNumber(bool newSort)
{
    qDebug() << "FilterChannelProxyModel::setSort" << newSort;
    if (m_sortNumber == newSort) return;
    m_sortNumber = newSort;
    invalidate();
    emit sortNumberChanged();
}

bool ChannelSFProxyModel::lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const
{
    // qDebug("FilterChannelProxyModel::lessThan");
    int role;
    if (m_sortNumber) role = ChannelModel::ChannelNumberRole; else role = ChannelModel::FrequencyRole;
    int f1 = source_left.data(role).toInt();
    int f2 = source_right.data(role).toInt();
    return f1 < f2;
}

int ChannelSFProxyModel::filterCA() const
{
    return m_filterCA;
}

void ChannelSFProxyModel::setFilterCA(int filterCA)
{
    if (m_filterCA == filterCA) return;
    m_filterCA = filterCA;
    invalidateFilter();
    emit filterCAChanged();
}

int ChannelSFProxyModel::channelType() const
{
    return m_channelType;
}

void ChannelSFProxyModel::setChannelType(int type)
{
    if (type == m_channelType) return;
    m_channelType = type;
    invalidateFilter();
    emit channelTypeChanged();
}

void ChannelSFProxyModel::setSortOrder(Qt::SortOrder sortOrder)
{
    if (sortOrder == this->sortOrder()) return;
    sort(0, sortOrder);
    emit sortOrderChanged(sortOrder);
}

QString ChannelSFProxyModel::filterText() const
{
    return m_filterText;
}

void ChannelSFProxyModel::setFilterText(const QString &filterText)
{
    if (m_filterText == filterText) return;
    m_filterText = filterText;
    invalidateFilter();
    emit filterTextChanged();
}


/*
 * ChannelSelectProxyModel -----------------------------------------------------------------
 */

QVariant ChannelSelectProxyModel::data(const QModelIndex &index, int role) const
{
    // qDebug() << "ChannelSelectedProxyModel::data:" << index << "Role:" << role;
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid | QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    if (role == SelectRole) {
        QModelIndex mi = mapToSource(index);
        QString id = mi.data(ChannelModel::ChannelIdRole).toString();
        return m_channels.contains(id);
    }
    else {
        QModelIndex mi = mapToSource(index);
        return mi.data(role);
    }
}

bool ChannelSelectProxyModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    // qDebug() << "ChannelSelectedProxyModel::setData" << index << "Value" << value << "Role:" << role;
    QModelIndex mi = mapToSource(index);
    if (role == Roles::SelectRole) {
        QString id = mi.data(ChannelModel::ChannelIdRole).toString();
        bool ok = false;
        if (value.toBool()) {
            m_channels.insert(id);
            ok = true;
        }
        else if (m_channels.contains(id)) {
            ok = m_channels.remove(id);
        }
        if (ok) {
            emit dataChanged(index, index, {role});
            emit channelsChanged();
        }
        return ok;
    }
    else {
        return sourceModel()->setData(mi, value, role);
    }
}

QHash<int, QByteArray> ChannelSelectProxyModel::roleNames() const
{
    qDebug() << "ChannelSelectedProxyModel::roleNames" << QSortFilterProxyModel::roleNames();
    QHash<int,QByteArray> roles = QSortFilterProxyModel::roleNames();
    roles[Roles::SelectRole] = "select";
    return roles;
}

void ChannelSelectProxyModel::selectAll()
{
    qDebug() << "ChannelSelectedProxyModel::selectAll" << rowCount();
    for (int row = 0; row < rowCount(); ++row) {
        QModelIndex mi = index(row,0);
        setData(mi, true, Roles::SelectRole);
    }
}

void ChannelSelectProxyModel::selectNone()
{
    qDebug() << "ChannelSelectedProxyModel::selectNone" << sourceModel()->rowCount() << rowCount();
    setDynamicSortFilter(false);
    for (int row = 0; row < rowCount(); ++row) {
        QModelIndex mi = index(row,0);
        setData(mi, false, Roles::SelectRole);
    }
    setDynamicSortFilter(true);
    invalidateRowsFilter();
}

void ChannelSelectProxyModel::selectInvert()
{
    qDebug() << "ChannelSelectedProxyModel::selectInvert" << sourceModel()->rowCount() << rowCount();
    setDynamicSortFilter(false);
    for (int row = 0; row < rowCount(); ++row) {
        QModelIndex mi = index(row,0);
        bool selected = !mi.data(Roles::SelectRole).toBool();
        setData(mi, selected, Roles::SelectRole);
    }
    setDynamicSortFilter(true);
    invalidateRowsFilter();
}

void ChannelSelectProxyModel::selectIntervall(int a, int b) //a,b sind Kanalnummern
{
    if (a>b) std::swap(a,b);
    ChannelSFProxyModel *pm = qobject_cast<ChannelSFProxyModel*>(sourceModel());
    Q_ASSERT(pm);
    ChannelModel *cm = qobject_cast<ChannelModel*>(pm->sourceModel());
    Q_ASSERT(cm);
    const QList<Channel> channels = cm->channelList();
    beginResetModel();
    m_channels.clear();
    for (int i=0; i < channels.count(); ++i) {
        const Channel &ch = channels.at(i);
        if (ch.number < a) continue;
        if (ch.number > b) break;
        m_channels.insert(ch.channel_id);
    }
    endResetModel();
    emit channelsChanged();
}

bool ChannelSelectProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    // QModelIndex mi = sourceModel()->index(source_row,0,source_parent);
    if (m_filtered) {
        QModelIndex mi = sourceModel()->index(source_row,0,source_parent);
        QString id = mi.data(ChannelModel::ChannelIdRole).toString();
        return m_channels.contains(id);
    }
    else return true;
}

QStringList ChannelSelectProxyModel::channels() const
{
    return m_channels.values();
}

void ChannelSelectProxyModel::setChannels(const QStringList &newChannels)
{
    qDebug() << "ChannelSelectProxyModel::setChannels";
    beginResetModel();
    m_channels.clear();
    for (int i = 0; i < newChannels.count(); ++i) {
        m_channels.insert(newChannels.at(i));
    }
    endResetModel();
    emit channelsChanged();
}

bool ChannelSelectProxyModel::filtered() const
{
    return m_filtered;
}

void ChannelSelectProxyModel::setFiltered(bool newFiltered)
{
    if (m_filtered == newFiltered) return;
    m_filtered = newFiltered;
    invalidateFilter();
    emit filteredChanged();
}
