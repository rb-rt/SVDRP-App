#ifndef STARTTIMESMODEL_H
#define STARTTIMESMODEL_H

#include <QStringListModel>
#include <QSettings>
#include <QTime>
#include <QDebug>

struct Times
{
    Times() {}
    QString time;
};
Q_DECLARE_METATYPE(Times)

class StartTimesModel : public QStringListModel
{
    Q_OBJECT

public:
    explicit StartTimesModel(QObject *parent = nullptr);
    ~StartTimesModel();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    Q_INVOKABLE void addTime(const QString &time);
    Q_INVOKABLE void delTime(int index);

private:
    void readParam();
    void writeParam();

    QSettings m_settings;
};

#endif // STARTTIMESMODEL_H
