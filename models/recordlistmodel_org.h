#ifndef RECORDLISTMODEL_H
#define RECORDLISTMODEL_H

#include <QIdentityProxyModel>
#include <QSortFilterProxyModel>
#include "recordtreemodel.h"
#include "api/records.h"


/**
 * Erstellt aus dem RecordTreeModel ein ListModel
 *
**/
class RecordListModel : public QIdentityProxyModel
{
    Q_OBJECT

public:
    enum Roles { SortRoleDate = Qt::UserRole + 100, SortRoleName }; //Überschneidung mit TreeModel?
    Q_ENUM(Roles)

    RecordListModel(QObject *parent = nullptr);

    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    //    QModelIndex parent(const QModelIndex &child) const;
    int rowCount(const QModelIndex &parent) const;
    //    int columnCount(const QModelIndex &parent) const;
        QVariant data(const QModelIndex &index, int role) const;


//        Q_INVOKABLE void deleteRecord(int id);

        // QAbstractProxyModel interface
//        QModelIndex mapToSource(const QModelIndex &proxyIndex) const;

private:

//    Records const *m_records_api = nullptr;
    Records *m_records_api = nullptr;

    // QAbstractItemModel interface


private slots:
    void slotSourceModelCanged();
    void slotTest(const QModelIndex &parent, int first, int last);


    // QAbstractItemModel interface
//public:
//    QModelIndex parent(const QModelIndex &child) const;
//    int columnCount(const QModelIndex &parent) const;

    // QAbstractProxyModel interface
public:

};


class RecordListSortFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(QString filterText READ filterText WRITE setFilterText NOTIFY filterTextChanged)

public:
    RecordListSortFilterProxyModel(QObject *parent = nullptr);

    void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override;
    void setSourceModel(QAbstractItemModel *sourceModel) override;

    Qt::SortOrder sortOrder() { return m_sortOrder; }
    void setSortOrder(Qt::SortOrder sortOrder);

    QString filterText() { return m_filterText; }
    void setFilterText(QString text); //Zum filtern von Titel und shorttext

//    Q_INVOKABLE void deleteRecord(int id);

public slots:
    void sortChanged(int sortRole);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;


private:
    QString m_filterText;
    Qt::SortOrder m_sortOrder;

private slots:
    void slotRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);

signals:
    void sortOrderChanged(Qt::SortOrder);
    void filterTextChanged(QString filterText);


};


#endif // RECORDLISTMODEL_H
