#ifndef VDRINFO_H
#define VDRINFO_H

#include "api/svdrp.h"
#include <QObject>

class VDRInfo : public SVDRP
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap statistics READ statistics NOTIFY statisticsChanged)
    Q_PROPERTY(QStringList plugins READ plugins NOTIFY pluginsFinished)

public:
    explicit VDRInfo(QObject *parent = nullptr);
    ~VDRInfo();

    Q_INVOKABLE void svdrpStat();
    Q_INVOKABLE void getPlugins();

    QStringList plugins() const;

    QVariantMap statistics() const;

private:

    enum Commands {STAT, PLUG};
    Commands m_command;

    QVariantMap m_statistics;


    QStringList m_plugins;

    void setVersion(QString s);
    void setDiskStatistic(QString s);


private slots:

    void readyRead() override;


signals:
    void pluginsFinished();    
    void statisticsChanged();
};

#endif // VDRINFO_H
