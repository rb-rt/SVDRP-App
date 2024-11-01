#ifndef EPGSEARCHQUERYMODEL_H
#define EPGSEARCHQUERYMODEL_H

#include <QAbstractListModel>
#include "api/epgsearch.h"
#include "channelmodel.h"
#include "timermodel.h"

class EpgSearchQueryModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(EPGSearch *epgsearch READ getEPGSearch WRITE setEPGSearch NOTIFY epgSearchChanged)
    Q_PROPERTY(ChannelModel* channelModel READ getChannelModel WRITE setChannelModel NOTIFY channelModelChanged REQUIRED)
    Q_PROPERTY(TimerModel *timerModel READ timerModel WRITE setTimerModel NOTIFY timerModelChanged)

public:
    enum Roles {QueryRole = Qt::UserRole, ChannelRole, ChannelNumberRole,
                 TimeRole, TimerFlagRole, DeleteTimerRole, StartRole, TimerGapRole };

    explicit EpgSearchQueryModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int, QByteArray> roleNames() const override;

    EPGSearch *getEPGSearch() const;
    void setEPGSearch(EPGSearch *epgsearch);

    ChannelModel *getChannelModel() const;
    void setChannelModel(ChannelModel *channelModel);

    //Leider keine Unterscheidung bei gleichem Namen von QML aus(!?)
    Q_INVOKABLE void queryIds(QList<int> ids);
    Q_INVOKABLE void querySettings(const QVariantMap &searchtimer);
    Q_INVOKABLE void queryFavorites(int hours = 72);

    Q_INVOKABLE void createSearchtimer(const QVariantMap &searchtimer);

    TimerModel *timerModel() const;
    void setTimerModel(TimerModel *newTimerModel);

    Q_INVOKABLE TimerExtended getTimer(int id);
    Q_INVOKABLE void getEvent(EpgSearchQuery e);

private:

    QHash<int,QByteArray> m_roleNames;

    //Enthält im ggs. zu m_epgsearch->epgsearchquery auch erweiterte Timerinformationen
    //Wird von prepareQuery() erstellt
    QList<EpgSearchQuery> m_queryResult;

    EPGSearch *m_epgsearch = nullptr;
    ChannelModel *m_channelModel = nullptr;
    TimerModel *m_timerModel = nullptr;

    Events m_events_api;
    int m_marginStart = 2; //TimerVorlauf, ermittelt aus den Einstellungen. in Minuten

    void prepareQuery();

    TimerExtended findTimer(const EpgSearchQuery &e) const; //Sucht zu e den timer in timerModel
    TimerExtended findTimer(const QVariantMap &query); //ruft letztendlich findTimer(EpgSearchQuery e) auf
    int findQuery(const TimerExtended &timer); //sucht im m_queryResult nach dem Timr und liefert den Index

private slots:

    void slotQueryFinished();
    void slotTimerUpdated(const TimerExtended &timer);
    void slotTimerDeleted(const TimerExtended &timer);
    void slotEvent(const Event &event);

signals:
    void epgSearchChanged();
    void channelModelChanged();
    void error(QString error);
    void timerModelChanged();
    void searchtimerCreated();
    void eventFinished(const Event &event);

};

#endif // EPGSEARCHQUERYMODEL_H
