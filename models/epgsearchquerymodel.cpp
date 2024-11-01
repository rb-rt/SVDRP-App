#include "epgsearchquerymodel.h"
#include "settings.h"


bool sortQuery(EpgSearchQuery &e1, EpgSearchQuery &e2)
{
    return e1.eventStart() < e2.eventStart();
}

EpgSearchQueryModel::EpgSearchQueryModel(QObject *parent) : QAbstractListModel(parent)
{
    Settings settings;
    m_marginStart = settings.marginStart();

    m_roleNames = QAbstractListModel::roleNames();
    m_roleNames[Roles::QueryRole] = "query";
    m_roleNames[Roles::ChannelRole] = "channel";
    m_roleNames[Roles::ChannelNumberRole] = "channelnr";
    m_roleNames[Roles::TimeRole] = "time";
    m_roleNames[Roles::TimerFlagRole] = "flag";
    m_roleNames[Roles::StartRole] = "start";
    m_roleNames[Roles::TimerGapRole] = "timerGap";

    connect(&m_events_api, &Events::eventFinished, this, &EpgSearchQueryModel::slotEvent);
}

int EpgSearchQueryModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid()) return 0;
    return m_queryResult.count();
}

QVariant EpgSearchQueryModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    EpgSearchQuery e = m_queryResult.at(index.row());

    switch (role) {
    case Roles::QueryRole: return QVariant::fromValue(e);
    case Roles::ChannelRole: {
        Channel ch = m_channelModel->getChannel(e.channel);
        return QString("%1 - %2").arg(ch.number).arg(ch.name);
    }
    case Roles::ChannelNumberRole: return m_channelModel->getChannel(e.channel).number;
    case Roles::TimeRole: {
        QString s1 = QLocale::system().toString(e.eventStartDateTime(),"ddd, dd.MM hh:mm");
        QString s2 = e.eventStopDateTime().toString("hh:mm");
        return s1 + " - " + s2;
    }
    case Roles::TimerGapRole: {
        if  ( !(e.timer_flag > 0) )return false;
        int diff = e.eventStart() - e.timerStart();
        return diff != m_marginStart * 60;
    }
    case Roles::StartRole: return QLocale::system().toString(e.eventStartDateTime(), "dddd, dd.MM.yyyy");
    case Roles::TimerFlagRole: return e.timer_flag;
    default: return QVariant();
    }
}

bool EpgSearchQueryModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    //    qDebug() << "EpgSearchQueryModel::setData QModelIndex:" << index << "Value:" << value << "Role:" << role;
    if (role == Qt::EditRole) {
        if (value.canConvert<Timer>()) {
            Timer t = value.value<Timer>();
            QVariant v = data(index, Roles::QueryRole);
            EpgSearchQuery e = v.value<EpgSearchQuery>();
            e.setTimerStart(t.startDateTime());
            e.setTimerStop(t.stopDateTime());
            if (t.isActive()) e.timer_flag = 3; else e.timer_flag = 4;
            m_queryResult.replace(index.row(), e);
            emit dataChanged(index, index);
            return true;
        }
    }
    if (role == Roles::DeleteTimerRole) {
        if (value.canConvert<Timer>()) {
            Timer t = value.value<Timer>();
            QVariant v = data(index, Roles::QueryRole);
            EpgSearchQuery e = v.value<EpgSearchQuery>();
            e.setTimerStart(-1);
            e.setTimerStop(-1);
            e.timer_flag = 0;
            e.timer_file = "";
            m_queryResult.replace(index.row(), e);
            emit dataChanged(index, index);
            return true;
        }
    }
    return false;
}

QHash<int, QByteArray> EpgSearchQueryModel::roleNames() const
{
    return m_roleNames;
}

EPGSearch *EpgSearchQueryModel::getEPGSearch() const
{
    return m_epgsearch;
}

void EpgSearchQueryModel::setEPGSearch(EPGSearch *epgsearch)
{
    Q_ASSERT(epgsearch);
    if (m_epgsearch) {
        disconnect(m_epgsearch, &EPGSearch::queryFinished, this, &EpgSearchQueryModel::slotQueryFinished);
        disconnect(m_epgsearch, &EPGSearch::svdrpError, this, &EpgSearchQueryModel::error);
        disconnect(m_epgsearch, &EPGSearch::searchAdded, this, &EpgSearchQueryModel::searchtimerCreated);
    }
    m_epgsearch = epgsearch;
    connect(m_epgsearch, &EPGSearch::queryFinished, this, &EpgSearchQueryModel::slotQueryFinished);
    connect(m_epgsearch, &EPGSearch::svdrpError, this, &EpgSearchQueryModel::error);
    connect(m_epgsearch, &EPGSearch::searchAdded, this, &EpgSearchQueryModel::searchtimerCreated);
    m_events_api.setUrl(epgsearch->url());
    emit epgSearchChanged();
}

ChannelModel *EpgSearchQueryModel::getChannelModel() const
{
    return m_channelModel;
}

void EpgSearchQueryModel::setChannelModel(ChannelModel *channelModel)
{
    qDebug() << "EpgSearchQueryModel::setChannelModel" << channelModel;
    Q_ASSERT(channelModel);
    m_channelModel = channelModel;
    emit channelModelChanged();
}

void EpgSearchQueryModel::queryIds(QList<int> ids)
{
    qDebug("EpgSearchQueryModel::query (QList)");
    beginResetModel();
    m_epgsearch->svdrpQrys(ids);
}

void EpgSearchQueryModel::querySettings(const QVariantMap &searchtimer)
{
    qDebug("EpgSearchQueryModel::querySettings (QVariantMap)");
    SearchTimer st(searchtimer);
    beginResetModel();
    m_epgsearch->svdrpSearch(st);
}

void EpgSearchQueryModel::queryFavorites(int hours)
{
    qDebug("EpgSearchQueryModel::queryFavorites");
    beginResetModel();
    m_epgsearch->svdrpQryf(hours);
}

void EpgSearchQueryModel::createSearchtimer(const QVariantMap &searchtimer)
{
    SearchTimer st (searchtimer);
    m_epgsearch->svdrpNewSearch(st);
}

TimerModel *EpgSearchQueryModel::timerModel() const
{
    return m_timerModel;
}

void EpgSearchQueryModel::setTimerModel(TimerModel *newTimerModel)
{
    Q_ASSERT(newTimerModel);
    if (!newTimerModel) return;
    if (m_timerModel == newTimerModel) return;
    if (m_timerModel) {
        disconnect(m_timerModel, &TimerModel::timerUpdated, this, &EpgSearchQueryModel::slotTimerUpdated);
        disconnect(m_timerModel, &TimerModel::timerDeleted, this, &EpgSearchQueryModel::slotTimerDeleted);
    }
    m_timerModel = newTimerModel;
    connect(m_timerModel, &TimerModel::timerUpdated, this, &EpgSearchQueryModel::slotTimerUpdated);
    connect(m_timerModel, &TimerModel::timerDeleted, this, &EpgSearchQueryModel::slotTimerDeleted);
    emit timerModelChanged();
}

TimerExtended EpgSearchQueryModel::getTimer(int id)
{
    qDebug() << "EpgSearchQueryModel::getTimer (id)" << id;
    return m_timerModel->getTimer(id);
}

TimerExtended EpgSearchQueryModel::findTimer(const EpgSearchQuery &e) const
{
    //    qDebug() << "EpgSearchQueryModel::findTimer (EpgSearchQuery)" << e;
    Q_ASSERT(m_timerModel);
    TimerExtended timer;
    QList<TimerExtended>::ConstIterator it;
    for (it = m_timerModel->timerList().constBegin(); it != m_timerModel->timerList().constEnd(); it++) {
        if (it->id < 0) continue;
        //gleicher Kanal & gleiche Startzeit
        if ( (e.channel == it->channel_id) && (e.timerStartDateTime() == it->startDateTime()) ) {
            timer = *it;
            break;
        }
    }
    return timer;
}

TimerExtended EpgSearchQueryModel::findTimer(const QVariantMap &query)
{
    Q_ASSERT(m_timerModel);
    EpgSearchQuery e(query);
    return findTimer(e);
}

void EpgSearchQueryModel::getEvent(EpgSearchQuery e)
{
    qDebug("EpgSearchQueryModel::getEvent");
    qint64 diff = e.eventStop() - e.eventStart();
    qint64 time = e.eventStart() + diff / 2;
    m_events_api.svdrpGetEvent(e.channel,time);
}

void EpgSearchQueryModel::prepareQuery()
{
    m_queryResult.clear();


    QList<EpgSearchQuery> queryList = m_epgsearch->epgSearchQuery();
    if (queryList.isEmpty()) return;

    for (int i = 0; i < queryList.count(); ++i) {
        EpgSearchQuery query = queryList.at(i);

        Timer t = findTimer(query);
        if (t.isValid()) {
            query.timer_id = t.id;
            if (t.isActive()) query.timer_flag = 3; else query.timer_flag = 4;
            if (t.isRecording()) query.timer_flag = 5;
        }
        m_queryResult.append(query);
    }

    std::sort(m_queryResult.begin(), m_queryResult.end(), sortQuery);
}

int EpgSearchQueryModel::findQuery(const TimerExtended &timer)
{
    //Suche passenden Query Eintrag zum timer
    for (int i = 0; i < m_queryResult.count(); ++i) {
        EpgSearchQuery e = m_queryResult.at(i);
        if (e.channel == timer.channel_id) {

            //Vergleich start eventtime evtl besser?
            if (e.eventID == timer.event.id) return i; else continue;
        }
    }
    return -1;
}

void EpgSearchQueryModel::slotQueryFinished()
{
    qDebug() << "EpgSearchQueryModel::slotQueryFinished";
    prepareQuery();
    endResetModel();
}

void EpgSearchQueryModel::slotTimerUpdated(const TimerExtended &timer)
{
    qDebug() << "EpgSearchQueryModel::slotTimerUpdated";
    Q_ASSERT(timer.id != -1);
    if (timer.id == -1) return;

    //Suche passenden Query Eintrag zum timer
    int index = findQuery(timer);
    if (index != -1) {
        QModelIndex mi = this->index(index);
        if (mi.isValid()) {
            QVariant v = QVariant::fromValue(timer);
            setData(mi, v, Qt::EditRole);
        }
    }
}

void EpgSearchQueryModel::slotTimerDeleted(const TimerExtended &timer)
{
    qDebug() << "EpgSearchQueryModel::slotTimerdeleted";
    Q_ASSERT(timer.id != -1);
    if (timer.id == -1) return;
    int index = findQuery(timer);
    if (index != -1) {
        QModelIndex mi = this->index(index);
        if (mi.isValid()) {
            QVariant v = QVariant::fromValue(timer);
            setData(mi, v, Roles::DeleteTimerRole);
        }
    }
}

void EpgSearchQueryModel::slotEvent(const Event &event)
{
    qDebug() << "EpgSearchQueryProxyModel::slotEvent";
    emit eventFinished(event);
}
