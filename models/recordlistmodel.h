#ifndef RECORDLISTMODEL_H
#define RECORDLISTMODEL_H

#include <QSortFilterProxyModel>
#include "api/records.h"

/**
 * BasisModel für die Aufnahmen
 *
**/
class RecordListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(bool hasSelection READ hasSelection NOTIFY selectedRecordsChanged FINAL)

public:
    enum Roles { RecordRole = Qt::UserRole, DurationRole, TimeRole,
                 LastDirRole, SelectRole,
                 SortDateRole, SortNameRole,
                 StartMonthRole, StartYearRole, StartNameRole };
    Q_ENUM(Roles)

    RecordListModel(QObject *parent = nullptr);
    ~RecordListModel();

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void getRecords();
    Q_INVOKABLE void getEvent(int id);
    Q_INVOKABLE void deleteRecord(int id);
    Q_INVOKABLE void editRecord(int id);
    Q_INVOKABLE void moveRecord(int id, QString newName);
    Q_INVOKABLE void playRecord(int id, int type = 0, QString time = "");
    Q_INVOKABLE void updateRecords(); //UPDR

    Q_INVOKABLE void printMap(QVariantMap map);
    Q_INVOKABLE void deleteRecords(); //Schleife zum Löschen

    Q_INVOKABLE void clearSelection();

    QUrl url() const;
    void setUrl(const QUrl &url);

    const Records* recordApi = &m_records_api;

    bool hasSelection() const;

private:
    QHash<int,QByteArray> m_roleNames;

    QUrl m_url;
    Records m_records_api;
    QModelIndex m_lastUsedModelIndex; //der zuletzt benutzte Modelindex (zum Record)

    QList<int> m_selectedRecords; // Speichert die ausgewählten Record IDs

private slots:

    void slotRecordsFinished();
    void slotRecordDeleted(const Record &record);
    void slotEvent(const RecordEvent &event);
    void slotRecordMoved(const Record &record);

signals:

    void urlChanged();
    void recordsFinished();
    void recordMoved(const Record &record);
    void recordDeleted(const Record &record);
    void recordPlayed(const Record &record);
    void recordEdited(const Record &record);
    void eventFinished(const RecordEvent &event);
    void error(QString error);
    void selectedRecordsChanged();
    void recordsUpdated();
};


/*
 * ------------------------------ RecordSelectedProxyModel
*/
class RecordSelectedProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(bool filterSelectedRecords READ filterSelectedRecords WRITE setFilterSelectedRecords NOTIFY filterSelectedRecordsChanged FINAL)

public:

    bool filterSelectedRecords() const;
    void setFilterSelectedRecords(bool newFilterSelectedRecords);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    bool m_filterSelectedRecords = false;

signals:
    void filterSelectedRecordsChanged();

};



/*
 * ------------------------------ RecordListModelSortFilterProxy
*/
class RecordListSFProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)

public:

    RecordListSFProxyModel(QObject *parent = nullptr);
    void setSortOrder(Qt::SortOrder sortOrder);

private:
signals:
    void sortOrderChanged(Qt::SortOrder);
};

#endif // RECORDLISTMODEL_H
