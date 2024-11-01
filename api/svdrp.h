#ifndef SVDRP_H
#define SVDRP_H

#include <QObject>
#include <QTcpSocket>
#include <QUrl>

class SVDRP : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:

    explicit SVDRP (QObject *parent = nullptr);
    ~SVDRP();

    void sendCommand(QString command);

    QString host() const;
    void setHost(const QString &host);

    quint16 port() const;
    void setPort(const quint16 &port);

    QUrl url() const;
    void setUrl(const QUrl &url);

public slots:
    void sendQuit();


protected:

    QTcpSocket m_tcpSocket;

private:

    QString m_host;
    quint16 m_port;
    QUrl m_url;
    QString m_command;

    void connectToServer();

    void logMetaObject();

private slots:
    void slotConnected();
    void sendRequest();
    void connectionClosedByServer();
    void socketError(QAbstractSocket::SocketError socketError);
    void slotAbort();
    virtual void readyRead() = 0;

signals:
    void urlChanged();
    void svdrpFinished();
    void svdrpError(QString error); //Für Verbindungsprobleme
};

#endif // SVDRP_H
