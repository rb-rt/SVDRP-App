#ifndef SEARCHTIMERMODEL_H
#define SEARCHTIMERMODEL_H

#include <QSortFilterProxyModel>
#include "models/basemodel.h"

class SearchtimerModel : public BaseModel
{
    Q_OBJECT

public:

    enum Roles {SearchTimerRole = Qt::UserRole + 100, ActiveRole, ActionRole, IdRole };

    explicit SearchtimerModel(QObject *parent = nullptr);
    ~SearchtimerModel();

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void getSearchTimers();
    Q_INVOKABLE void setSearchTimer(const QVariantMap &st);
    Q_INVOKABLE void deleteSearchTimer(int id);
    Q_INVOKABLE void toggleSearchTimer(int id);

    Q_INVOKABLE SearchTimer getSearchtimer(); //Liefert nur einen neuen Searchtimer

private:
    QHash<int,QByteArray> m_roleNames;

private slots:

    void slotEPGSearchChanged() override;

    void slotSearchtimersFinished();
    void slotSearchAdded(const SearchTimer &searchtimer);
    void slotSearchChanged(const SearchTimer &searchtimer);
    void slotSearchDeleted(const SearchTimer &searchtimer);

};





class SearchtimerSFProxyModel : public QSortFilterProxyModel
{

    Q_OBJECT
    Q_PROPERTY(Qt::SortOrder sortOrder READ sortOrder WRITE setSortOrder NOTIFY sortOrderChanged)
    Q_PROPERTY(bool favorites READ favorites WRITE setFavorites NOTIFY favoritesChanged FINAL)

public:
    SearchtimerSFProxyModel(QObject *parent = nullptr);

    void setSortOrder(Qt::SortOrder sortOrder);

    bool favorites() const;
    void setFavorites(bool newFavorites);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

private:
    bool m_favorites = false;


signals:
    void sortOrderChanged(Qt::SortOrder);    
    void favoritesChanged();

};

#endif // SEARCHTIMERMODEL_H
