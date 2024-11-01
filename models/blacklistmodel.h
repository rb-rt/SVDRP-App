#ifndef BLACKLISTMODEL_H
#define BLACKLISTMODEL_H

#include "basemodel.h"

/**
 * @brief The BlacklistModel class
 * Für die Ausschlußlisten von epgsearch
 */

class BlacklistModel : public BaseModel
{
    Q_OBJECT

public:

    enum Roles { RoleBlacklist = Qt::UserRole + 100 };

    explicit BlacklistModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    bool removeRows(int row, int count, const QModelIndex &parent) override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void getBlacklists();
    Q_INVOKABLE void setBlacklist(const QVariantMap &bl);
    Q_INVOKABLE void deleteBlacklist(int id);
    Q_INVOKABLE Blacklist getBlacklist(); //Liefert Standard Blacklist


private slots:

    void slotEPGSearchChanged() override;

    void slotBlacklistsFinished();
    void slotBlacklistAdded(const Blacklist &bl);
    void slotBlacklistChanged(const Blacklist &bl);
    void slotBlacklistDeleted(const Blacklist &bl);

signals:

};

#endif // BLACKLISTMODEL_H
