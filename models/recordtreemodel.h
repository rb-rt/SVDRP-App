#ifndef RECORDTREEMODEL_H
#define RECORDTREEMODEL_H

#include "models/recordfiltertextmodel.h"
#include "models/recordlistmodel.h"
#include <QSortFilterProxyModel>
#include <QSet>

class RecordTreeModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(int level MEMBER m_column NOTIFY levelChanged)
    Q_PROPERTY(QStringList tree MEMBER m_tree NOTIFY levelChanged)

public:
    enum Roles {IsDirRole = Qt::UserRole + 100, RecordRole, SelectRole, DirRole };
    Q_ENUM(Roles)

    explicit RecordTreeModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void levelUp();

    void setSortOrder(Qt::SortOrder sortOrder);

protected:
    virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    virtual bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    QHash<int,QByteArray> m_roleNames;

    int m_column = 0;
    QStringList m_tree; //Aktuell ausgewähltes Verzeichnis
    mutable QSet<QStringList> m_cache;

    RecordSelectedProxyModel* m_recordSelectedProxyModel = nullptr;
    RecordFilterTextModel* m_recordFilterTextProxyModel = nullptr;

private slots:
    void slotSourceModelChanged();
    void slotClearCache();

signals:
    void sortOrderChanged(Qt::SortOrder);
    void levelChanged();
};

#endif // RECORDTREEMODEL_H
