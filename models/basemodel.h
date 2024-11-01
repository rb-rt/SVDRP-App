#ifndef BASEMODEL_H
#define BASEMODEL_H

#include <QAbstractListModel>
#include "api/epgsearch.h"
#include "models/channelmodel.h"

/**
 * @brief The BaseModel class
 * Basis für Searchtimer- und BlacklistModel (und TemplateModel)
 */

class BaseModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(EPGSearch *epgsearch READ getEPGSearch WRITE setEPGSearch NOTIFY epgSearchChanged)
    Q_PROPERTY(ChannelModel* channelModel READ getChannelModel WRITE setChannelModel NOTIFY channelModelChanged)

public:

    //Gemeinsam genutzte Rollen
    enum Roles { ChannelRole = Qt::UserRole, TimeRole, DurationRole, WeekdayRole };

    explicit BaseModel(QObject *parent = nullptr);
    ~BaseModel();

    QHash<int, QByteArray> roleNames() const override;

    EPGSearch *getEPGSearch() const;
    void setEPGSearch(EPGSearch *epgsearch);

    ChannelModel *getChannelModel() const;
    void setChannelModel(ChannelModel *channelModel);

private:
    QHash<int,QByteArray> m_roleNames;

protected:

    EPGSearch *m_epgsearch = nullptr;
    ChannelModel *m_channelModel = nullptr;

private slots:

    virtual void slotEPGSearchChanged() = 0;

signals:
    void urlChanged();
    void epgSearchChanged();
    void channelModelChanged();
};

#endif // BASEMODEL_H
