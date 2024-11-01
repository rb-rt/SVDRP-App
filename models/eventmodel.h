#ifndef EVENTMODEL_H
#define EVENTMODEL_H

#include <QAbstractListModel>
#include <QUrl>
#include "api/events.h"
#include "models/channelmodel.h"
#include "models/timermodel.h"

class EventModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(Schedule schedule READ getSchedule WRITE setSchedule NOTIFY scheduleChanged)
    Q_PROPERTY(ChannelModel* channelModel READ getChannelModel WRITE setChannelModel NOTIFY channelModelChanged)
    Q_PROPERTY(TimerModel* timerModel READ getTimerModel WRITE setTimerModel NOTIFY timerModelChanged)

public:

    enum Roles {EventRole = Qt::UserRole, EventTimeRole, ChannelNumberRole, ChannelNumberNameRole, TimerRole, StartRole, GroupRole };
    enum Schedule {WhatsNow, WhatsNext, WhatsAt, Program };
    Q_ENUM(Schedule)

    explicit EventModel(QObject *parent = nullptr);
    ~EventModel();

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int,QByteArray> roleNames() const override;

    Q_INVOKABLE void getEvents(EventModel::Schedule schedule); //für schedule=WhatsAt vorher Time mit setAt() setzen
    Q_INVOKABLE void getEvents(QString channel_id);
    Q_INVOKABLE void getEvents(QDateTime dateTime); //-> WhatsAt

    QUrl getUrl() const;
    void setUrl(const QUrl &url);

    ChannelModel *getChannelModel() const;
    void setChannelModel(ChannelModel *channelModel);

    EventModel::Schedule getSchedule() const;
    void setSchedule(const Schedule &schedule);    

    TimerModel *getTimerModel() const;
    void setTimerModel(TimerModel *timerModel);

private:

    Events m_event_api;
    QHash<int,QByteArray> m_roleNames;

    //Enthält im ggs. zu m_event_api.eventList() auch Kanal- und Timerinformationen
    QList<EventExtended> m_events;

    Schedule m_schedule; //aktueller Schedule

    ChannelModel* m_channelModel = nullptr;
    TimerModel *m_timerModel = nullptr;

private slots:

    void slotEventsFinished();
    void slotTimerUpdated(const TimerExtended &timer);
    void slotTimerDeleted(const TimerExtended &timer);

    /*ein slotTimerCreated() kommt nicht vor. Nach einem neuen timer
    //wird sofort vom TimerModel das Event geholt -> timerUpdated
    */

    void slotError(QString error);

signals:
    void urlChanged();
    void scheduleChanged();
    void channelModelChanged();
    void timerModelChanged();
    void eventsFinished();

    //Abhänig von schedule werden passende Texte verschickt, wie Was läuft jetzt?,
    //Was läuft am %1 um %2 auf Kanal %3.
    void infoText(QString infotext);
    void error(QString error);

};



class EventSFProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool filterEmptyEvents READ filterEmptyEvents WRITE setFilterEmptyEvents NOTIFY filterEmptyEventsChanged)
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)
    Q_PROPERTY(int toChannel READ toChannel WRITE setToChannel NOTIFY toChannelChanged)
    Q_PROPERTY(bool startEpgNow READ startEpgNow WRITE setStartEpgNow NOTIFY startEpgNowChanged)


public:
    EventSFProxyModel(QObject *parent = nullptr);

    bool filterEmptyEvents() const;
    void setFilterEmptyEvents(bool newFilterEmptyEvents);

    const QString &filterText() const;
    void setFilterText(const QString &newFilterText);

    int toChannel() const;
    void setToChannel(int newToChannel);

    bool startEpgNow() const;
    void setStartEpgNow(bool newStartTimeNow);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    bool m_filterEmptyEvents = true; //Leere EPG-Einträge ausblenden
    QString m_filterText = "";
    int m_toChannel = 0; //Beschränkt das Abfragelimit bis zu Kanal, 0 bedeutet kein Limit
    bool m_startEpgNow = false; //Alle Events vor "jetzt" ausblenden
    QDateTime m_now;

signals:
    void filterEmptyEventsChanged();
    void filterTextChanged();
    void toChannelChanged();
    void startEpgNowChanged();
};


#endif // EVENTMODEL_H
