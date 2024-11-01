#include "timermodel.h"
#include "settings.h"

#include <QMetaMethod>

TimerModel::TimerModel(QObject *parent) : QAbstractListModel(parent)
{
    qDebug("TimerModel::TimerModel");
    Settings settings;
    m_marginStart = settings.marginStart();
    m_marginStop = settings.marginStop();

    m_roleNames[Roles::TimerRole] = "timer";
    m_roleNames[Roles::EventRole] = "event";
    m_roleNames[Roles::EventTitleRole] = "eventtitle";
    m_roleNames[Roles::EventSubTitleRole] = "eventsubtitle";
    m_roleNames[Roles::ChannelNumberNameRole] = "channelnrname";
    m_roleNames[Roles::TimeRole] = "time";
    m_roleNames[Roles::hasEventRole] = "hasEvent";
    m_roleNames[Roles::TimerGapRole] = "timerGap";
    m_roleNames[Roles::WeekDaysRole] = "weekdays";
    m_roleNames[Roles::SectionRole] = "section";
    m_roleNames[Roles::StopRole] = "stop";

    connect(&m_timer_api, &Timers::timersFinished, this, &TimerModel::slotTimersFinished);
    connect(&m_timer_api, &Timers::timerCreated, this, &TimerModel::slotTimerCreated);
    connect(&m_timer_api, &Timers::timerUpdated, this, &TimerModel::slotTimerUpdated);
    connect(&m_timer_api, &Timers::timerDeleted, this, &TimerModel::slotTimerDeleted);
    connect(&m_events_api, &Events::eventFinished, this, &TimerModel::slotEvent);
    connect(this, &TimerModel::timersFinished, this, &TimerModel::slotGetTimerEvents);
    connect(&m_timer_api, &Timers::svdrpError, this, &TimerModel::error);
}

int TimerModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid()) return 0;
    return m_timers.count();
}

QVariant TimerModel::data(const QModelIndex &index, int role) const
{
    //    qDebug() << "TimerModel::data QModelIndex:" << index << "Role:" << role;

    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid |
                                   QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    TimerExtended timer = m_timers.at(index.row());

    switch (role) {
    case Roles::TimerRole: return QVariant::fromValue(timer);
    case Roles::EventRole: {
        if (timer.id < 0 || timer.event.id < 0) return QVariant();
        Event event = timer.event;
        return QVariant::fromValue(event);
    }
    case Roles::hasEventRole: return timer.event.id >= 0;
    case Roles::ChannelNumberNameRole: {
        //Kanalnummer + Kanalname: 1 - ARD
        QString channel_str = "";
        if (timer.id < 0) return QVariant();
        if (m_channelModel) {
            channel_str = QString("%1 - %2").arg(timer.channelNumber).arg(timer.channelName);
        }
        return channel_str;
    }
    case Roles::SectionRole: return QLocale::system().toString(timer.startDateTime(),"dddd, dd.MM.yyyy");
    case Roles::TimeRole: {
        QString von = QLocale::system().toString(timer.startDateTime(),"ddd, dd.MM hh:mm");
        QString bis = timer.stopDateTime().toString("hh:mm");
        return von + " - " + bis;
    }
    case Roles::StartRole: return timer.startDateTime();
    case Roles::StopRole: return timer.stopDateTime();
    case Roles::TimerGapRole: {
        if (timer.event.id == -1) return false;
        QDateTime timerStart = timer.startDateTime();
        QDateTime eventStart = timer.event.startDateTime();
        qint64 differenz = timerStart.secsTo(eventStart);
        return differenz != m_marginStart * 60 ;
    }
    case WeekDaysRole: {
        QString weekdays = "-------";
        for (int i=0; i < 7; ++i) {
            QString w = timer.weekdays().at(i);
            if (w == "-") continue;
            switch (i) {
            case 0: weekdays[i] = 'M'; break;
            case 1: weekdays[i] = 'D'; break;
            case 2: weekdays[i] = 'M'; break;
            case 3: weekdays[i] = 'D'; break;
            case 4: weekdays[i] = 'F'; break;
            case 5: weekdays[i] = 'S'; break;
            case 6: weekdays[i] = 'S'; break;
            default: weekdays[i] = '-';
            }
        }
        return weekdays;
    }
    case Roles::EventTitleRole: if (timer.event.id == -1) return "kein Eintrag"; else return timer.event.title;
    case Roles::EventSubTitleRole: return timer.event.shortText;
    default: return QVariant();
    }
}

bool TimerModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    // qDebug() << "TimerModel::setData QModelIndex:" << index << "Value:" << value << "Role:" << role;

    switch (role) {
    //Timerdaten haben sich geändert (z.B. Tag, Zeit, Kanal)
    case Qt::EditRole: {
        // qDebug() << "TimerModel::setData EditRole";

        //value muss zwingend ein TimerExtended sein!
        if (value.canConvert<TimerExtended>()) {
            TimerExtended t = value.value<TimerExtended>();
            Q_ASSERT(m_channelModel);
            Channel ch = m_channelModel->getChannel(t.channel_id);
            t.channelName = ch.name;
            t.channelNumber = ch.number;
            m_timers.replace(index.row(), t);
            emit dataChanged(index, index);
            return true;
        }
        return false;
    }
    case (Roles::EventRole): {
        // qDebug() << "TimerModel::setData EventRole";
        if (value.canConvert<Event>()) {
            int row = index.row();
            TimerExtended t = m_timers.at(row);
            t.event = value.value<Event>();
            t.event.setTimerFlags(t.flags());
            t.event.timerId = t.id;
            m_timers.replace(row, t);
            emit dataChanged(index,index);
            emit timerUpdated(t);
            return true;
        }
        return false;
    }
    default: return false;
    }
}

bool TimerModel::removeRows(int row, int count, const QModelIndex &parent)
{
    qDebug("TimerModel::removeRows");
    if (row < 0 || row >= m_timers.count()) return false;
    if (count != 1) return false;
    beginRemoveRows(parent, row, row);
    m_timers.removeAt(row);
    endRemoveRows();
    return true;
}

QHash<int, QByteArray> TimerModel::roleNames() const
{
    return m_roleNames;
}

void TimerModel::getTimers()
{
    qDebug("TimerModel::getTimers()");
    m_timer_api.svdrpGetTimers();
}

QUrl TimerModel::getUrl() const
{
    return m_timer_api.url();
}

void TimerModel::setUrl(const QUrl &url)
{
    m_timer_api.setUrl(url);
    m_events_api.setUrl(url);
    emit urlChanged();
}

void TimerModel::createTimer(const QVariantMap &timer)
{
    Timer t(timer);
    m_timer_api.svdrpCreateTimer(t);
}

void TimerModel::updateTimer(const QVariantMap &timer)
{
    Timer t(timer);
    m_timer_api.svdrpUpdateTimer(t);
}

void TimerModel::toggleTimer(int id)
{
    m_timer_api.svdrpToggleTimer(id);
}

void TimerModel::deleteTimer(int id)
{
    m_timer_api.svdrpDeleteTimer(id);
}

ChannelModel *TimerModel::getChannelModel() const
{
    return m_channelModel;
}

void TimerModel::setChannelModel(ChannelModel *channelModel)
{
    qDebug("TimerModel::setChannelModel");
    Q_ASSERT(channelModel);
    m_channelModel = channelModel;
    emit channelModelChanged();
}

const QList<TimerExtended> &TimerModel::timerList() const
{
    return m_timers;
}

TimerExtended TimerModel::getTimer(int id) const
{
    TimerExtended t;
    t.id = id;
    int index = m_timers.indexOf(t);
    if (index != -1) return m_timers.at(index); else return TimerExtended();
}

void TimerModel::getTimerEvents()
{
    // qDebug("TimerModel::getTimerEvents");
    Q_ASSERT(m_timerCounter < m_timer_api.timerList().count());
    m_singleEvent = false;
    Timer t = m_timer_api.timerList().at(m_timerCounter);
    qint64 time = calculateEventTime(t);
    m_events_api.svdrpGetEvent(t.channel_id, time);
}

void TimerModel::getTimerEvent(int index)
{
    qDebug("TimerModel::getTimerEvent(index:%d)",index);

    Q_ASSERT(index < m_timer_api.timerList().count());
    m_timerCounter = index;
    m_singleEvent = true;
    Timer t = m_timer_api.timerList().at(m_timerCounter);
    qint64 time = calculateEventTime(t);
    m_events_api.svdrpGetEvent(t.channel_id, time);
}

qint64 TimerModel::calculateEventTime(const Timer &t) const
{
    qint64 starttime = t.startDateTime().toSecsSinceEpoch() + m_marginStart*60;
    qint64 stoptime = t.stopDateTime().toSecsSinceEpoch() - m_marginStop*60;
    qint64 diff = stoptime - starttime;
    qint64 time = starttime + diff / 2;
    //    qint64 time = starttime + diff / 3;
    return time;
}

qint64 TimerModel::calculateEventTime(const Event &e) const
{
    qint64 starttime = e.startDateTime().toSecsSinceEpoch();
    qint64 stoptime = e.endDateTime().toSecsSinceEpoch();
    qint64 diff = stoptime - starttime;
    qint64 time = starttime + diff / 2;
    //    qint64 time = starttime + diff / 3;
    return time;
}

void TimerModel::slotTimersFinished()
{
    qDebug("TimerModel::slotTimersFinished");
    Q_ASSERT(m_channelModel);

    beginResetModel();
    m_timers.clear();
    QList<Timer>::ConstIterator it;
    for (it= m_timer_api.timerList().constBegin(); it != m_timer_api.timerList().constEnd(); ++it) {
        TimerExtended timerTmp(*it);
        Channel ch = m_channelModel->getChannel(it->channel_id);
        timerTmp.channelName = ch.name;
        timerTmp.channelNumber = ch.number;
        m_timers.append(timerTmp);
    }
    endResetModel();
    emit timersFinished();
}

void TimerModel::slotEvent(const Event &event)
{
    if (event.id != -1) {

        if (m_timerCounter >= m_timer_api.timerList().count() ) return;

        Timer t = m_timer_api.timerList().at(m_timerCounter);

        int i = m_timers.indexOf(t);
        if (i != -1) {
            QModelIndex mi = this->index(i);
            if (mi.isValid()) {
                QVariant v = QVariant::fromValue(event);
                setData(mi, v, EventRole);
            }
        }
    }
    if (!m_singleEvent) {
        m_timerCounter++;
        if (m_timerCounter < m_timer_api.timerList().count()) {
            getTimerEvents();
        }
        else {
            qDebug("TimerModel::slotEvent Letzter slotEvent");
            m_events_api.blockSendQuit(false);
        }
    }
}

void TimerModel::slotGetTimerEvents()
{
    qDebug("TimerModel::slotGetTimerEvents");
    m_timerCounter = 0;
    m_events_api.blockSendQuit(true);
    if (!m_timer_api.timerList().isEmpty()) getTimerEvents();
}

void TimerModel::slotTimerCreated(const Timer &timer)
{
    qDebug("TimerModel::slotTimerCreated");
    int index = m_timers.indexOf(timer);
    Q_ASSERT(index == -1); //sollte immer -1 sein, da der neue Timer noch nicht in der Liste vorkommt
    TimerExtended t(timer);
    Channel ch = m_channelModel->getChannel(timer.channel_id);
    t.channelName = ch.name;
    t.channelNumber = ch.number;
    int newRow = rowCount();
    beginInsertRows(QModelIndex(), newRow, newRow);
    m_timers.append(t);
    endInsertRows();
    getTimerEvent(newRow);
}

void TimerModel::slotTimerUpdated(const Timer &timer)
{
    qDebug("TimerModel::slotTimerUpdated");
    int index = m_timers.indexOf(timer);
    Q_ASSERT(index != -1); //Sollte immer > 0 sein

    QModelIndex mi = this->index(index);
    if (mi.isValid()) {
        TimerExtended t(timer);
        QVariant v = QVariant::fromValue(t);
        setData(mi, v, Qt::EditRole);
        index = m_timer_api.timerList().indexOf(timer);
        if (index != -1) getTimerEvent(index);
    }
}

void TimerModel::slotTimerDeleted(const Timer &timer)
{
    qDebug("TimerModel::slotTimerDeleted");
    int index = m_timers.indexOf(timer);
    if (index != -1) {
        TimerExtended t = m_timers.at(index);
        this->removeRow(index);
        emit timerDeleted(t);
    }
}


/*
 * -------------------- TimerSFProxyModel ----------------------
 */

TimerSFProxyModel::TimerSFProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    qDebug("TimerSortFilterProxyModel::TimerSortFilterProxyModel");
    sort(0);
    setSortRole(TimerModel::StartRole);
    connect(this, &TimerSFProxyModel::sourceModelChanged, this, &TimerSFProxyModel::slotSourceModelChanged);
}

EPGSearch *TimerSFProxyModel::epgsearch() const
{
    return m_epgsearch;
}

void TimerSFProxyModel::setEpgsearch(EPGSearch *epgsearch)
{
    qDebug() << "TimerSortFilterProxyModel::setEpgsearch" << epgsearch;
    Q_ASSERT(epgsearch);
    if (m_epgsearch == epgsearch) return;
    m_epgsearch = epgsearch;
    connect(m_epgsearch, &EPGSearch::conflictsFinished, this, &TimerSFProxyModel::invalidateRowsFilter);
    emit epgsearchChanged();
    m_epgsearch->svdrpCheckConflicts();
}

bool TimerSFProxyModel::filterConflicts() const
{
    return m_filterConflicts;
}

void TimerSFProxyModel::setFilterConflicts(bool newFilterConflicts)
{
    if (m_filterConflicts == newFilterConflicts) return;
    m_filterConflicts = newFilterConflicts;
    invalidateRowsFilter();
    emit filterConflictsChanged();
}

bool TimerSFProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    // qDebug("TimerSortFilterProxyModel::filterAcceptsRow");
    if (!m_filterConflicts) return true;
    QModelIndex mi = sourceModel()->index(source_row,0,source_parent);
    const QVariant &v = mi.data(TimerModel::TimerRole);
    int id = v.value<TimerExtended>().id;
    return m_epgsearch->conflicts().contains(id);
}

void TimerSFProxyModel::slotSourceModelChanged()
{
    m_timerModel = qobject_cast<TimerModel*>(sourceModel());
    Q_ASSERT(m_timerModel);
    connect(m_timerModel, &TimerModel::timersFinished, this, &TimerSFProxyModel::slotTimersFinished);
}

void TimerSFProxyModel::slotTimerConflicts(bool found)
{
    qDebug("TimerSortFilterProxyModel::slotTimerConflicts");
    if (found) invalidateRowsFilter();
}

void TimerSFProxyModel::slotTimersFinished()
{
    qDebug("TimerSortFilterProxyModel::slotTimersFinished");
    Q_ASSERT(m_epgsearch);
    m_epgsearch->svdrpCheckConflicts();
}

