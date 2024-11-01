#ifndef CHANNELGROUPSMODEL_H
#define CHANNELGROUPSMODEL_H

#include <QAbstractListModel>
#include "api/epgsearch.h"

class ChannelGroupsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(EPGSearch *epgsearch READ getEPGSearch WRITE setEPGSearch NOTIFY epgSearchChanged)

public:
    enum Roles {ChannelsRole = Qt::UserRole};

    explicit ChannelGroupsModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    // bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    bool removeRows(int row, int count, const QModelIndex &parent) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void getChannelGroups();
    Q_INVOKABLE void newChannelGroup(QString groupName,  QStringList channels);
    Q_INVOKABLE void editChannelGroup(QString groupName, QStringList channels);
    Q_INVOKABLE void renameChannelGroup(QString oldName, QString newName);
    Q_INVOKABLE void deleteChannelGroup(QString groupName);

    EPGSearch *getEPGSearch() const;
    void setEPGSearch(EPGSearch *epgsearch);


private:
    QStringList m_groupNames;

    EPGSearch *m_epgsearch = nullptr;

private slots:

    void slotEPGSearchChanged();

    void slotChannelGroupsFinished();
    void slotChannelGroupAdded(QString groupName);
    void slotChannelGroupEdited(QString groupName);
    void slotChannelGroupRenamed(QString newName);
    void slotChannelGroupDeleted(QString groupName);

signals:
    void epgSearchChanged();

};

#endif // CHANNELGROUPSMODEL_H
