#ifndef CHANNELMODEL_H
#define CHANNELMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QUrl>
#include "api/channels.h"

class ChannelModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged)

public:

    enum Roles {ChannelRole = Qt::UserRole, ChannelNumberNameRole, ChannelIdRole, ChannelNumberRole, GroupRole, FrequencyRole};

    explicit ChannelModel(QObject *parent = nullptr);
    ~ChannelModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = ChannelRole) const override;
    // bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    QHash<int,QByteArray> roleNames() const override;

    Q_INVOKABLE void getChannels();
    Q_INVOKABLE void moveChannel(int nr, int to);
    Q_INVOKABLE void updateChannel(const QVariantMap &channel);
    Q_INVOKABLE void switchToChannel(QString channel_id);
    Q_INVOKABLE void deleteChannels(const QStringList &channelIds);

    QUrl getUrl() const;
    void setUrl(const QUrl &url);

    Q_INVOKABLE Channel getChannel(QString channel_id);
    Q_INVOKABLE int getChannelNumber(QString channel_id);
    Q_INVOKABLE QString getGroupName(int nr);

    const QList<Channel> &channelList() const;

private:

    Channels m_channel_api;
    QHash<int,QByteArray> m_roleNames;

    void deleteChannel(QString channelId);
    QStringList m_channelIds; //Enthält zu löschende Kanäle

private slots:
    void slotChannelFinished();
    void slotChannelUpdated(const Channel &channel);
    void slotChannelDeleted(const Channel &channel);

signals:
    void urlChanged();
    void channelsFinished();
    void channelSwitched(const Channel &channel); //Kanal umgeschaltet
    void channelChanged(); //Kanal wurde gelöscht oder verschoben
    // void channelsDeleted();

    void error(QString error);
};



class ChannelSFProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)
    Q_PROPERTY(int ca READ filterCA WRITE setFilterCA NOTIFY filterCAChanged)
    Q_PROPERTY(int channelType READ channelType WRITE setChannelType NOTIFY channelTypeChanged)
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(bool sortNumber READ sortNumber WRITE setSortNumber NOTIFY sortNumberChanged FINAL)
    Q_PROPERTY(bool wordOnly READ wordOnly WRITE setWordOnly NOTIFY wordOnlyChanged FINAL)

public:
    ChannelSFProxyModel(QObject *parent = nullptr);

    QString filterText() const;
    void setFilterText(const QString &filterText);

    int filterCA() const;
    void setFilterCA(int filterCA);

    int channelType() const;
    void setChannelType(int type);

    void setSortOrder(Qt::SortOrder sortOrder);

    bool sortNumber() const;
    void setSortNumber(bool newSort);

    bool wordOnly() const;
    void setWordOnly(bool newWordOnly);

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:

    //Unchecked = Alle Kanäle anzeigen, Partiallychecked = verschlüsselte ausblenden, Checked = nur Verschlüsselte anzeigen
    int m_filterCA = 0;

    int m_channelType = 0; //0=Alle, 1=Nur TV, 2=Nur Radio

    QString m_filterText; //Suche
    bool m_wordOnly = false; //nur nach ganzem Wort suchen

    bool m_sortNumber = true;

signals:
    void filterTextChanged();
    void filterCAChanged();
    void channelTypeChanged();
    void sortOrderChanged(Qt::SortOrder);
    void sortNumberChanged();
    void wordOnlyChanged();
};



class ChannelSelectProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool filtered READ filtered WRITE setFiltered NOTIFY filteredChanged FINAL)
    Q_PROPERTY(QStringList channels READ channels WRITE setChannels NOTIFY channelsChanged FINAL)

public:

    enum Roles {SelectRole = Qt::UserRole+100};

    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void selectAll();
    Q_INVOKABLE void selectNone();
    Q_INVOKABLE void selectInvert();
    Q_INVOKABLE void selectIntervall(int a, int b);

    bool filtered() const;
    void setFiltered(bool newFiltered);

    QStringList channels() const;
    void setChannels(const QStringList &newChannels);

protected:

    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:

    bool m_filtered = false; //Zeigt nur die ausgewählten Kanäle bei true
    QSet<QString> m_channels; //Enthält die ausgewählten Kanäle (channel id)

signals:
    void filteredChanged();
    void channelsChanged();
};

#endif // CHANNELMODEL_H
