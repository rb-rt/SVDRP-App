#include "searchtimermodel.h"

SearchtimerModel::SearchtimerModel(QObject *parent) : BaseModel(parent)
{
    qDebug("SearchtimerModel::SearchtimerModel");
    m_roleNames = BaseModel::roleNames();
    m_roleNames[Roles::SearchTimerRole] = "searchtimer";
    m_roleNames[Roles::ActiveRole] = "active";
    m_roleNames[Roles::ActionRole] = "action";
    m_roleNames[Roles::IdRole] = "id";

    //    connect(this, &BaseModel::epgSearchChanged, this, &SearchtimerModel::slotEPGSearchChanged);
}

SearchtimerModel::~SearchtimerModel()
{
    qDebug("SearchtimerModel::~SearchtimerModel");
    //    disconnect(this, &BaseModel::epgSearchChanged, this, &SearchtimerModel::slotEPGSearchChanged);
}

int SearchtimerModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid()) return 0;
    if (!m_epgsearch) return 0;
    return m_epgsearch->searchtimers().count();
}

QVariant SearchtimerModel::data(const QModelIndex &index, int role) const
{
    //    qDebug() << QString("SearchtimerModel::data row:%1 role:%2").arg(index.row()).arg(role);

    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    SearchTimer searchtimer = m_epgsearch->searchtimers().at(index.row());

    switch (role) {
    case SearchTimerRole: return QVariant::fromValue(searchtimer);
    case Qt::DisplayRole:  return searchtimer.search;
    case ActiveRole: return searchtimer.use_as_searchtimer != 0;
    case ActionRole: return searchtimer.search_timer_action;
    case IdRole: return searchtimer.id;
    case ChannelRole: {
        switch (searchtimer.useChannel) {
        case 0: return "Alle";
        case 1: if (searchtimer.channelMin == searchtimer.channelMax) {
                if (m_channelModel) return m_channelModel->getChannel(searchtimer.channelMin).name; else  return searchtimer.channelMin;
            }
            else {
                if (m_channelModel) {
                    QString s1 = m_channelModel->getChannel(searchtimer.channelMin).name;
                    QString s2 = m_channelModel->getChannel(searchtimer.channelMax).name;
                    return s1 + " - " + s2;
                }
                else {
                    return QString("%1 - %2").arg(searchtimer.channelMin,searchtimer.channelMax);
                }
            }
        case 2: return searchtimer.channels;
        case 3: return "FTA";
        default: return "Kanal X";
        }
    }
    case TimeRole:
        if (searchtimer.useTime) {
            QString t = searchtimer.start() + " - " + searchtimer.stop();
            if (searchtimer.useDuration) {
                QString s = QString(" (%1 min)").arg(searchtimer.getDurationMaxInMinutes() - searchtimer.getDurationMinInMinutes());
                t = t + s;
            }
            return t;
        } else return "";
    case DurationRole:
        if (searchtimer.useDuration) {
            return QString("%1 - %2 min.").arg(searchtimer.getDurationMin().toString("hh:mm"), searchtimer.getDurationMax().toString("hh:mm"));
        } else return "";
    case WeekdayRole: return searchtimer.getWeekdays();
    default: return QVariant();
    }
}

bool SearchtimerModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug() << "SearchtimerModel::setData QModelIndex:" << index << "Value:" << value << "Role:" << role;
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid | QAbstractItemModel::CheckIndexOption::ParentIsInvalid));
    if (role == Qt::EditRole) {

        SearchTimer st = value.value<SearchTimer>();
        bool ok = m_epgsearch->replaceSearch(st);
        if (ok) emit dataChanged(index, index);
        return ok;
    }
    return false;
}

bool SearchtimerModel::removeRows(int row, int count, const QModelIndex &parent)
{  
    beginRemoveRows(parent, row, row + count - 1);
    bool ok = m_epgsearch->removeSearch(row);
    endRemoveRows();
    return ok;
}

QHash<int, QByteArray> SearchtimerModel::roleNames() const
{
    return m_roleNames;
}

void SearchtimerModel::getSearchTimers()
{
    qDebug("SearchtimerModel::getSearchTimers()");
    Q_ASSERT(m_epgsearch->url().isValid());
    beginResetModel();
    m_epgsearch->svdrpGetSearches();
}

void SearchtimerModel::setSearchTimer(const QVariantMap &st)
{
    qDebug("SearchtimerModel::setSearchTimer");
    //    qDebug() << st;
    SearchTimer s(st);
    if (s.id >= 0) {
        m_epgsearch->svdrpEditSearch(s);
    }
    else {
        m_epgsearch->svdrpNewSearch(s);
    }
}

void SearchtimerModel::deleteSearchTimer(int id)
{
    m_epgsearch->svdrpDeleteSearch(id);
}

void SearchtimerModel::toggleSearchTimer(int id)
{
    m_epgsearch->svdrpToggleSearch(id);
}

SearchTimer SearchtimerModel::getSearchtimer()
{
    qDebug("SearchtimerModel::getSearchtimer");
    return SearchTimer();
}

void SearchtimerModel::slotEPGSearchChanged()
{
    qDebug("SearchtimerModel::slotEPGSearchChanged");
    qDebug() << "m_epgsearch:" << m_epgsearch;

    //    if (m_epgsearch) {
    //        qDebug("Disconnect alle");
    //        disconnect(m_epgsearch, &EPGSearch::searchFinished, this, &SearchtimerModel::slotSearchtimersFinished);
    //        disconnect(m_epgsearch, &EPGSearch::searchAdded, this, &SearchtimerModel::slotSearchAdded);
    //        disconnect(m_epgsearch, &EPGSearch::searchChanged, this, &SearchtimerModel::slotSearchChanged);
    //        disconnect(m_epgsearch, &EPGSearch::searchDeleted, this, &SearchtimerModel::slotSearchDeleted);
    //    }
    //    connect(m_epgsearch, &EPGSearch::searchFinished, this, &SearchtimerModel::endResetModel);
    connect(m_epgsearch, &EPGSearch::searchFinished, this, &SearchtimerModel::slotSearchtimersFinished);
    connect(m_epgsearch, &EPGSearch::searchAdded, this, &SearchtimerModel::slotSearchAdded);
    connect(m_epgsearch, &EPGSearch::searchChanged, this, &SearchtimerModel::slotSearchChanged);
    connect(m_epgsearch, &EPGSearch::searchDeleted, this, &SearchtimerModel::slotSearchDeleted);
    qDebug("SearchtimerModel::slotEPGSearchChanged Ende");
}

void SearchtimerModel::slotSearchtimersFinished()
{
    qDebug("SearchtimerModel::slotSearchtimersFinished");
    endResetModel();
}

void SearchtimerModel::slotSearchAdded(const SearchTimer &searchtimer)
{
    qDebug("SearchtimerModel::slotEditSearch");
    int rowIndex = rowCount();
    bool ok = m_epgsearch->addSearch(searchtimer);
    if (ok) {
        beginInsertRows(QModelIndex(), rowIndex, rowIndex);
        endInsertRows();
    }
}

void SearchtimerModel::slotSearchChanged(const SearchTimer &searchtimer)
{
    qDebug("SearchtimerModel::slotSearchChanged");
    int index = m_epgsearch->searchtimers().indexOf(searchtimer);
    if (index >= 0) {
        QVariant v = QVariant::fromValue(searchtimer);
        QModelIndex mi = this->index(index);
        setData(mi, v);
    }
}

void SearchtimerModel::slotSearchDeleted(const SearchTimer &searchtimer)
{
    qDebug("SearchtimerModel::slotDeleteSearch");
    int index = m_epgsearch->searchtimers().indexOf(searchtimer);
    if (index >= 0) {
        removeRow(index);
    }
}




SearchtimerSFProxyModel::SearchtimerSFProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    qDebug("SearchtimerFilterSortModel::SearchtimerFilterSortModel");
    sort(0);
}

void SearchtimerSFProxyModel::setSortOrder(Qt::SortOrder sortOrder)
{
    qDebug("SearchtimerFilterSortModel::setSortOrder");
    if (sortOrder == this->sortOrder()) return;
    sort(0, sortOrder);
    emit sortOrderChanged(sortOrder);
}

bool SearchtimerSFProxyModel::favorites() const
{
    return m_favorites;
}

void SearchtimerSFProxyModel::setFavorites(bool newFavorites)
{
    if (m_favorites == newFavorites) return;
    m_favorites = newFavorites;
    invalidateFilter();
    emit favoritesChanged();
}

bool SearchtimerSFProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (!m_favorites) return true;
    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
    SearchTimer s = index.data(SearchtimerModel::SearchTimerRole).value<SearchTimer>();
    return s.use_in_favorites;
}
