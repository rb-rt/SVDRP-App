#ifndef REMOTE_H
#define REMOTE_H

#include "svdrp.h"
#include <QObject>

class Remote : public SVDRP
{
    Q_OBJECT
    Q_PROPERTY(bool status READ status WRITE setStatus NOTIFY statusChanged FINAL)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged FINAL)

public:
    explicit Remote(QObject *parent = nullptr);

    Q_INVOKABLE void send(QString key);

    bool status() const;
    void setStatus(bool newStatus);

    int volume() const;
    void setVolume(int newVolume);

private:

    enum Commands {HITK, REMO, VOLU};
    Commands m_command;
    bool m_status = false; //Fernbedinung an = true
    int m_volume;


    void svdrpHitk(QString key);

    void switched(QString line);
    void volume(QString line);

private slots:

    void readyRead() override;

signals:
    void statusChanged();
    void volumeChanged();
};

#endif // REMOTE_H
