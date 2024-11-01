#include "basemodel.h"

BaseModel::BaseModel(QObject *parent) : QAbstractListModel(parent)
{
    qDebug("BaseModel::BaseModel");

    m_roleNames = QAbstractListModel::roleNames();
    m_roleNames[Roles::ChannelRole] = "channels";
    m_roleNames[Roles::TimeRole] = "time";
    m_roleNames[Roles::DurationRole] = "duration";
    m_roleNames[Roles::WeekdayRole] = "weekday";

    connect(this, &BaseModel::epgSearchChanged, this, &BaseModel::slotEPGSearchChanged);
}

BaseModel::~BaseModel()
{
    qDebug("BaseModel::~BaseModel");
//    bool ok = m_epgsearch->disconnect();
//    qDebug() << "BaseModel::~BaseModel Disconnect Alle: " << ok;
}

QHash<int, QByteArray> BaseModel::roleNames() const
{
//    qDebug("BaseModel::roleNames");
    return m_roleNames;
}

EPGSearch *BaseModel::getEPGSearch() const
{
    return m_epgsearch;
}

void BaseModel::setEPGSearch(EPGSearch *epgsearch)
{
    qDebug("BaseModel::setEPGSearch");
    Q_ASSERT(epgsearch);
    qDebug() << "epgsearch:" << epgsearch;
    if (m_epgsearch == epgsearch) return;
    if (m_epgsearch) {
//        disconnect(m_epgsearch, &EPGSearch::svdrpError, this, &BaseModel::error);
        bool ok = m_epgsearch->disconnect();
        qDebug() << "BaseModel::setEPGSearch Disconnect Alle: " << ok;
    }
    m_epgsearch = epgsearch;
//    connect(m_epgsearch, &EPGSearch::svdrpError, this, &BaseModel::error);
    emit epgSearchChanged();
}

ChannelModel *BaseModel::getChannelModel() const
{
    return m_channelModel;
}

void BaseModel::setChannelModel(ChannelModel *channelModel)
{
    Q_ASSERT(channelModel);
    m_channelModel = channelModel;
    emit channelModelChanged();
}

