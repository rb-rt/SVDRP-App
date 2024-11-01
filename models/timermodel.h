#ifndef TIMERMODEL_H
#define TIMERMODEL_H

#include <QAbstractListModel>
#include <QUrl>
#include <QElapsedTimer>
#include "api/epgsearch.h"
#include "api/timers.h"
#include "models/channelmodel.h"
#include "api/events.h"


class TimerModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(ChannelModel* channelModel READ getChannelModel WRITE setChannelModel NOTIFY channelModelChanged)

public:

    enum Roles {TimerRole = Qt::UserRole, EventRole, EventTitleRole, EventSubTitleRole, ChannelNumberNameRole,
                 TimeRole, StopRole, hasEventRole, TimerGapRole, WeekDaysRole, SectionRole, StartRole};

    explicit TimerModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    QHash<int,QByteArray> roleNames() const override;

    Q_INVOKABLE void getTimers();
    Q_INVOKABLE void createTimer(const QVariantMap &timer);
    Q_INVOKABLE void updateTimer(const QVariantMap &timer);
    Q_INVOKABLE void toggleTimer(int id);
    Q_INVOKABLE void deleteTimer(int id);

    QUrl getUrl() const;
    void setUrl(const QUrl &url);

    ChannelModel *getChannelModel() const;
    void setChannelModel(ChannelModel *channelModel);

    //Liefert die modifizierte Timerliste
    //angefüllt mit Event- und Kanalinformationen
    const QList<TimerExtended> &timerList() const;

    Q_INVOKABLE TimerExtended getTimer(int id = -1) const; //Liefert den Timer mit der id, ansonsten neuen Timer mit id = -1

private:

    Timers m_timer_api;
    QHash<int,QByteArray> m_roleNames;

    //Enthält im ggs. zu m_timer_api.timerList() auch Kanal- und Event-Informationen
    QList<TimerExtended> m_timers;

    Events m_events_api;
    ChannelModel* m_channelModel = nullptr;

    int m_timerCounter;
    bool m_singleEvent;
    //Holt alle (oder einen) Events zu Timer mit m_timerCounter als index, nimmt keine Prüfung vom Index vor!
    //Index bezieht sich auf die original Timerliste von m_timer_api
    void getTimerEvents();
    void getTimerEvent(int index);
    qint64 calculateEventTime(const Timer &t) const; //Berechnet (mittelt) die Zeit aus den übergebenen Daten (abzgl. Vor-,Nachlaufzeit vom Timer)
    qint64 calculateEventTime(const Event &e) const; //Berechnet (mittelt) die Zeit aus den übergebenen Daten

    int m_marginStart = 2; //TimerVorlauf, ermittelt aus den Einstellungen. in Minuten
    int m_marginStop = 10; //Timernachlauf

private slots:

    void slotTimersFinished();
    void slotTimerCreated(const Timer &timer);
    void slotTimerUpdated(const Timer &timer);
    void slotTimerDeleted(const Timer &timer);

    void slotGetTimerEvents();
    void slotEvent(const Event &event); //Fügt das Event einem Timer zu

signals:
    void urlChanged();
    void channelModelChanged();
    void timersFinished(); //Wird verschickt, wenn alle Timer empfangen wurden
    //    void timerCreated(); //Kommt nicht vor, danach wird sofort das Event gesucht -> timerUpdated
    void timerUpdated(const TimerExtended &timer);
    void timerDeleted(const TimerExtended &timer); //enthält den gelöschten Timer
    void error(QString error);
};

/*
 * ------------------------ TimerSFProxyModel --------------------
 */

class TimerSFProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(EPGSearch *epgsearch READ epgsearch WRITE setEpgsearch NOTIFY epgsearchChanged FINAL)
    Q_PROPERTY(bool filterConflicts READ filterConflicts WRITE setFilterConflicts NOTIFY filterConflictsChanged FINAL)

public:

    TimerSFProxyModel(QObject *parent = nullptr);

    EPGSearch *epgsearch() const;
    void setEpgsearch(EPGSearch *epgsearch);

    bool filterConflicts() const;
    void setFilterConflicts(bool newFilterConflicts);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:

    EPGSearch* m_epgsearch = nullptr;
    TimerModel* m_timerModel = nullptr;
    bool m_filterConflicts = false;

private slots:
    void slotSourceModelChanged();
    void slotTimerConflicts(bool found);
    void slotTimersFinished();

signals:
    void epgsearchChanged();
    void filterConflictsChanged();
};

#endif // TIMERMODEL_H
