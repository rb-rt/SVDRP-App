#include "eventmodel.h"

EventModel::EventModel(QObject *parent) : QAbstractListModel(parent)
{
    qDebug("EventModel::EventModel");

    m_roleNames[Roles::EventRole] = "event";
    m_roleNames[Roles::EventTimeRole] = "time";
    m_roleNames[Roles::ChannelNumberRole] = "channelnr";
    m_roleNames[Roles::ChannelNumberNameRole] = "channelnrname";
    m_roleNames[Roles::TimerRole] = "timer";
    m_roleNames[Roles::StartRole] = "start";
    m_roleNames[Roles::GroupRole] = "group";

    connect(&m_event_api, &Events::eventsFinished, this, &EventModel::slotEventsFinished);
    connect(&m_event_api, &Events::svdrpError, this, &EventModel::slotError);
}

EventModel::~EventModel()
{
    qDebug("EventModel::~EventModel()");
}

int EventModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_events.count();
}

QVariant EventModel::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(checkIndex(index, QAbstractItemModel::CheckIndexOption::IndexIsValid | QAbstractItemModel::CheckIndexOption::ParentIsInvalid));

    EventExtended event = m_events.at(index.row());

    switch (role) {
    case Roles::EventRole: return QVariant::fromValue(event);
    case Roles::ChannelNumberRole: return event.channelNumber;
    case Roles::ChannelNumberNameRole: return QString("%1 - %2").arg(event.channelNumber).arg(event.channelName); //Kanalnummer + Kanalname: 1 - ARD
    case EventTimeRole: {
        QString time = QLocale::system().toString(event.startDateTime(),"ddd, dd.MM hh:mm") + " - " +
                       QLocale::system().toString(event.endDateTime(),"hh:mm");
        QTime diff = event.getDuration();
        QString d = QString("  (%1)").arg(diff.toString("h:mm"));
        return time + d;
    }
    case Roles::StartRole: return QLocale::system().toString(event.startDateTime(),"dddd, dd.MM.yyyy");
    case Roles::GroupRole: return m_channelModel->getChannel(event.channelId).group;
    //Holt einen Timer zu einem Event, wenn er existiert
    case TimerRole: {
        if (!m_timerModel) return QVariant();
        Timer t;
        if (event.timerExists()) t = m_timerModel->getTimer(event.timerId);
        return QVariant::fromValue(t);
    }
    default:  return QVariant();
    }
}

bool EventModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    qDebug("EventModel::setData");

    if (role == Qt::EditRole) {
        if (value.canConvert<EventExtended>()) {
            EventExtended e = value.value<EventExtended>();
            m_events.replace(index.row(), e);
            emit dataChanged(index, index);
            return true;
        }
    }
    return false;
}

QHash<int, QByteArray> EventModel::roleNames() const
{
    return m_roleNames;
}

void EventModel::getEvents(EventModel::Schedule schedule)
{
    qDebug("EventModel::getEvents schedule: %u", schedule);
    beginResetModel();
    setSchedule(schedule);

    switch (m_schedule) {
    case Schedule::WhatsNow: {
        m_event_api.svdrpGetEvents(Events::now);
        emit infoText("Was läuft gerade um " + QTime::currentTime().toString("hh:mm") + "?");
        break;
    }
    case Schedule::WhatsNext: {
        m_event_api.svdrpGetEvents(Events::next);
        emit infoText("Was läuft als Nächstes?");
        break;
    }
    case Schedule::WhatsAt:
    case Schedule::Program: {
        //nur über Kanalabfrage möglich
        Q_ASSERT(false);
        break;
    }
    }
}

void EventModel::getEvents(QString channel_id)
{
    qDebug("EventModel::getEvents(QString channel_id)");
    Channel ch = m_channelModel->getChannel(channel_id);
    emit infoText("Programm <b><i>"+ch.name+"</i></b>");
    beginResetModel();
    setSchedule(Schedule::Program);
    m_event_api.svdrpGetEvents(channel_id);
}

void EventModel::getEvents(QDateTime dateTime)
{
    qDebug("EventModel::getEvents(QDateTime)");
    setSchedule(Schedule::WhatsAt);
    // QDateTime jetzt = QDateTime::currentDateTime();
    // if (dateTime < jetzt) dateTime = jetzt;
    QString s = QString("Was läuft am %1 um %2").arg(QLocale::system().toString(dateTime,"ddd, dd.MM.yyyy"), QLocale::system().toString(dateTime,"hh:mm"));
    emit infoText(s);
    beginResetModel();
    m_event_api.svdrpGetEvents(dateTime.toSecsSinceEpoch());
}

QUrl EventModel::getUrl() const
{
    return m_event_api.url();
}

void EventModel::setUrl(const QUrl &url)
{
    if (!url.isValid()) return;
    if (url == m_event_api.url()) return;
    m_event_api.setUrl(url);
    emit urlChanged();
}

ChannelModel *EventModel::getChannelModel() const
{
    return m_channelModel;
}

void EventModel::setChannelModel(ChannelModel *channelModel)
{
    Q_ASSERT(channelModel);
    if (!channelModel) return;
    m_channelModel = channelModel;
    emit channelModelChanged();
}

EventModel::Schedule EventModel::getSchedule() const
{
    return m_schedule;
}

void EventModel::setSchedule(const Schedule &schedule)
{
    if (m_schedule == schedule) return;
    m_schedule = schedule;
    emit scheduleChanged();
}

TimerModel *EventModel::getTimerModel() const
{
    return m_timerModel;
}

void EventModel::setTimerModel(TimerModel *timerModel)
{
    Q_ASSERT(timerModel);
    if (!timerModel) return;
    if (m_timerModel) {
        disconnect(m_timerModel, &TimerModel::timerUpdated, this, &EventModel::slotTimerUpdated);
        disconnect(m_timerModel, &TimerModel::timerDeleted, this, &EventModel::slotTimerDeleted);
    }
    m_timerModel = timerModel;
    connect(m_timerModel, &TimerModel::timerUpdated, this, &EventModel::slotTimerUpdated);
    connect(m_timerModel, &TimerModel::timerDeleted, this, &EventModel::slotTimerDeleted);
    emit timerModelChanged();
}

void EventModel::slotEventsFinished()
{
    qDebug("EventModel::slotEventsFinished");

    Q_ASSERT(m_channelModel);
    Q_ASSERT(m_timerModel);

    m_events.clear();

    QList<TimerExtended>::ConstIterator timer_it;
    QList<EventExtended> events;
    QList<Event>::ConstIterator event_it;
    for (event_it = m_event_api.eventList().constBegin(); event_it != m_event_api.eventList().constEnd(); ++event_it) {
        EventExtended e(*event_it);
        events.append(e);
    }

    int eventsCount = events.count();

    //Gibt es Timer zu den Events?
    for (int i = 0; i < eventsCount; ++i) {
        EventExtended event = events.at(i);

        for (timer_it = m_timerModel->timerList().constBegin(); timer_it != m_timerModel->timerList().constEnd(); ++timer_it) {
            if (timer_it->id < 0) continue;
            if (timer_it->event.id == -1) continue;
            if (timer_it->channel_id != event.channelId) continue;

            if (timer_it->event.id == event.id) {
                event.timerId = timer_it->id;
                event.setTimerFlags(timer_it->flags());
                events.replace(i, event);
                break;
            }
        }
    }

    //Was läuft jetzt, als nächstes, ...
    if (m_schedule != Schedule::Program) {

        QList<Channel>::ConstIterator channel_it;

        for (channel_it = m_channelModel->channelList().constBegin(); channel_it != m_channelModel->channelList().constEnd(); ++channel_it) {

            bool found = false;
            int z = events.count();
            for (int i = 0; i < z; ++i) {
                EventExtended event = events.at(i);
                found = channel_it->channel_id == event.channelId;
                if (found) {
                    event.channelNumber = channel_it->number;
                    m_events.append(event);
                    events.removeAt(i);  //gefundenes Event entfernen um Liste zu verkleinern -> halbiert die Suchzeit
                    break;
                }
            }
            if (!found) {
                EventExtended emptyEvent;
                emptyEvent.channelNumber = channel_it->number;
                emptyEvent.channelId = channel_it->channel_id;
                emptyEvent.channelName = channel_it->name;
                emptyEvent.title = "Keine EPG Daten vorhanden";
                m_events.append(emptyEvent);
            }
        }
    }
    else {
        for (int i = 0; i < eventsCount; ++i) {
            EventExtended event = events.at(i);
            event.channelNumber = m_channelModel->getChannelNumber(event.channelId);
            m_events.append(event);
        }
    }

    endResetModel();
    emit eventsFinished();
}

void EventModel::slotTimerUpdated(const TimerExtended &timer)
{
    qDebug() << "EventModel::slotTimerUpdated" << timer;
    // qDebug() << "Timer:" << timer;
    Q_ASSERT(timer.id != -1);
    if (timer.id == -1) return;

    EventExtended e(timer.event);
    int index = m_events.indexOf(e);

    if (index != -1) {
        EventExtended e = m_events.at(index);
        e.timerId = timer.id;
        e.setTimerFlags(timer.flags());
        QModelIndex mi = this->index(index);
        if (mi.isValid()) {
            QVariant v = QVariant::fromValue(e);
            setData(mi, v);
        }
    }
    else {
        qDebug("Timer enhält kein Event");
        Q_ASSERT(false);
    }
}

void EventModel::slotTimerDeleted(const TimerExtended &timer)
{
    qDebug("EventModel::slotTimerDeleted");
    // qDebug() << "Timer:" << timer;
    Q_ASSERT(timer.id != -1);

    EventExtended e(timer.event);
    int index = m_events.indexOf(e);

    if (index != -1) {
        EventExtended e = m_events.at(index);
        e.timerId = -1;
        e.setTimerFlags(-1);
        QModelIndex mi = this->index(index);
        if (mi.isValid()) {
            QVariant v = QVariant::fromValue(e);
            setData(mi, v);                }
    }
    else {
        qDebug("Timer enhält kein Event");
        Q_ASSERT(false);
    }
}

void EventModel::slotError(QString error)
{
    qDebug("EventModel::slotError");
    slotEventsFinished();
    emit this->error(error);
}





EventSFProxyModel::EventSFProxyModel(QObject *parent) : QSortFilterProxyModel(parent)
{
    //    setFilterCaseSensitivity(Qt::CaseInsensitive);
    //    sort(0, Qt::DescendingOrder); //Bei Column -1 (Standard) wird nicht gefiltert
    m_now = QDateTime::currentDateTime();
}

bool EventSFProxyModel::filterEmptyEvents() const
{
    return m_filterEmptyEvents;
}

void EventSFProxyModel::setFilterEmptyEvents(bool newFilterEmptyEvents)
{
    if (m_filterEmptyEvents == newFilterEmptyEvents) return;
    m_filterEmptyEvents = newFilterEmptyEvents;
    invalidateFilter();
    emit filterEmptyEventsChanged();
}

bool EventSFProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    //    qDebug() << "EventFilterModel::filterAcceptsRow" << filterCaseSensitivity();

    QModelIndex mi = sourceModel()->index(source_row,0,source_parent);

    bool channels = true;
    if (m_toChannel != 0) {
        EventModel* em = qobject_cast<EventModel*>(sourceModel());
        Q_ASSERT(em);
        if (em->getSchedule() == EventModel::Program) {
            channels = true;
        }
        else {
            QVariant v = sourceModel()->data(mi, EventModel::Roles::ChannelNumberRole);
            int nr = v.toInt();
            channels = nr <= m_toChannel;
        }
    }

    bool filtered = true;
    if (m_filterEmptyEvents) {
        QVariant v = sourceModel()->data(mi, EventModel::Roles::EventRole);
        if (v.canConvert<Event>()) {
            Event event = v.value<Event>();
            filtered = event.id > 0;
        }
    }

    bool filterText = true;
    if (!m_filterText.isEmpty()) {
        QVariant v = sourceModel()->data(mi, EventModel::Roles::EventRole);
        if (v.canConvert<Event>()) {
            Event event = v.value<Event>();
            if (event.id > 0) {
                filterText = (event.title.contains(m_filterText, filterCaseSensitivity()) ||
                              event.shortText.contains(m_filterText, filterCaseSensitivity()));
            }
        }
    }

    bool filterNow = true;
    if (m_startEpgNow) {
        EventModel *em = qobject_cast<EventModel*>(sourceModel());
        Q_ASSERT(em);
        if (em->getSchedule() == EventModel::Program) {
            QVariant v = sourceModel()->data(mi, EventModel::Roles::EventRole);
            if (v.canConvert<Event>()) {
                Event event = v.value<Event>();
                filterNow = event.endDateTime() > m_now;
            }
        }
    }
    return filtered && channels && filterText && filterNow;
}

bool EventSFProxyModel::startEpgNow() const
{
    return m_startEpgNow;
}

void EventSFProxyModel::setStartEpgNow(bool newStartTimeNow)
{
    if (m_startEpgNow == newStartTimeNow) return;
    m_startEpgNow = newStartTimeNow;
    m_now = QDateTime::currentDateTime();
    invalidateFilter();
    emit startEpgNowChanged();
}

const QString &EventSFProxyModel::filterText() const
{
    return m_filterText;
}

void EventSFProxyModel::setFilterText(const QString &newFilterText)
{
    //    qDebug() << "EventFilterModel::setFilterText" << newFilterText;
    if (m_filterText == newFilterText) return;
    m_filterText = newFilterText;
    invalidateFilter();
    emit filterTextChanged();
}

int EventSFProxyModel::toChannel() const
{
    return m_toChannel;
}

void EventSFProxyModel::setToChannel(int newToChannel)
{
    if (m_toChannel == newToChannel) return;
    m_toChannel = newToChannel;
    emit toChannelChanged();
}
