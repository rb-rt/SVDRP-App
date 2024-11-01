#ifndef RECORDTREEMODEL_H
#define RECORDTREEMODEL_H

#include <QAbstractItemModel>
#include <QSortFilterProxyModel>
#include <QUrl>
#include "data/recordtreeitem.h"
#include "api/records.h"

/**
 * @brief The RecordTreeModel class
 * Das Basismodel für die Aufnahmen. Datenmanipulation (Löschen) wird über dieses Model abgewickelt.\n
 * Eine Listnansicht wird von RecordListModel erstellt
 */
class RecordTreeModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QVariantMap recordEvent READ getRecordEvent)

public:

    enum Roles {RoleName = Qt::UserRole, RoleDir, RoleFullRecord, RoleChannelName, RoleTitle, RoleDuration, RoleEvent,
                 SortRoleDate, SortRoleName };

    explicit RecordTreeModel(QObject *parent = nullptr);

    // Basic functionality:
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Remove data:
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void getRecords();


    Q_INVOKABLE void getEvent(int id);
    void deleteRecord(const QModelIndex &index);
    Q_INVOKABLE void deleteRecord(int id);

    QUrl url() const;
    void setUrl(const QUrl &url);

    Records m_records_api;

private:

    QUrl m_url;
    QModelIndex m_deletedModelIndex; //der zuletzt gelöschte Modelindex

    void setConnections();

    QVariantMap getRecordEvent() const;

    void printModelIndex(QModelIndex index); //fürs debuggen


private slots:

    void slotRecordsFinished();
    void slotRecordDeleted(int id);


signals:

    void urlChanged();
    void eventFinished();
    void error(QString error);
};

class RecordTreeSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool sortDate READ getSortDate WRITE setSortDate NOTIFY sortDateChanged)

public:

    RecordTreeSortFilterProxyModel(QObject *parent = nullptr);

    //Sortierung der Aufnahmen nach Datum (true) oder Titel (false)
    bool getSortDate() { return m_sortDate; }
    void setSortDate(bool sort = false);

//    Q_INVOKABLE void printModelIndex(const QModelIndex &mi);
    Q_INVOKABLE void deleteRecord(const QModelIndex &index);
    //    Q_INVOKABLE void playRecord(const QModelIndex &index);

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    bool m_sortDate = false; //false sortiert nach Titel


signals:
    void sortDateChanged();

};

#endif // RECORDTREEMODEL_H
