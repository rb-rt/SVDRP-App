#include "svdrp.h"

SVDRP::SVDRP(QObject *parent) : QObject(parent)
{
    qDebug() << "Konstructor SVDRP::SVDRP";
    connect(&m_tcpSocket, &QTcpSocket::connected, this, &SVDRP::slotConnected);
    connect(&m_tcpSocket, &QTcpSocket::disconnected, this, &SVDRP::connectionClosedByServer);
    connect(&m_tcpSocket, &QTcpSocket::errorOccurred, this, &SVDRP::socketError);
    connect(&m_tcpSocket, &QTcpSocket::readyRead, this, &SVDRP::readyRead);
    connect(this, &SVDRP::svdrpError, this, &SVDRP::slotAbort);
}

SVDRP::~SVDRP()
{
    qDebug() << "Destructor SVDRP::~SVDRP";
    if (m_tcpSocket.isOpen()) sendQuit();
}

void SVDRP::sendCommand(QString command)
{
//    qInfo() << "SVDRP::sendCommand(QString command)" << command;
    if (command.endsWith("\n")) m_command = command; else m_command = command + " \n";
    if (m_tcpSocket.isOpen())
        sendRequest();
    else
        connectToServer();
}

void SVDRP::sendQuit()
{
    qDebug("SVDRP::sendQuit");
    logMetaObject();
    if (m_tcpSocket.isOpen()) {
        qDebug("Port noch offen. Sende QUIT");
        sendCommand("QUIT \n");
    }
    else {
        qDebug("Port bereits geschlossen");
    }
}

QString SVDRP::host() const
{
    return m_host;
}

void SVDRP::setHost(const QString &host)
{
    m_host = host;
}

quint16 SVDRP::port() const
{
    return m_port;
}

void SVDRP::setPort(const quint16 &port)
{
    m_port = port;
}

QUrl SVDRP::url() const
{
    return m_url;
}

void SVDRP::setUrl(const QUrl &url)
{
    qDebug() << "SVDRP::setUrl" << url;
    if (url.isValid()) {
        m_url = url;
        m_host = url.host();
        m_port = url.port();
        emit urlChanged();
    }
}

void SVDRP::connectToServer()
{
    qDebug() << "SVDRP::connectToServer()" << m_host << m_port;
    logMetaObject();
    if (m_host.isEmpty()) return;
    if (m_tcpSocket.isOpen()) {
        qDebug("m_tcpSocket.isOpen = TRUE");
        return;
    }
    m_tcpSocket.connectToHost(m_host, m_port);
}

void SVDRP::logMetaObject()
{
    QMetaObject obj = *metaObject();
    qDebug() << "SVDRP::log Classname:" <<  obj.className() << "LocalPort:" << m_tcpSocket.localPort() << "PeerPort:" << m_tcpSocket.peerPort();
}

void SVDRP::slotConnected()
{
    qDebug() << "SVDRP::slotConnected()";
    logMetaObject();
    sendRequest();
}

void SVDRP::sendRequest()
{
//    qDebug() << "SVDRP::sendRequest()" << m_command;
    QByteArray b = m_command.toUtf8();
    m_tcpSocket.write(b);
}

void SVDRP::connectionClosedByServer()
{
    qDebug("SVDRP::connectionClosedByServer()");
    logMetaObject();
    if (m_tcpSocket.isOpen()) {
        qDebug() << "Port noch offen. wird geschlossen";
        m_tcpSocket.close();
    }
    else {
        qDebug() << "Port bereits geschlossen";
    }
}

void SVDRP::socketError(QAbstractSocket::SocketError socketError)
{
    qDebug() << "SVDRP::socketError" << socketError << m_tcpSocket.errorString();

    //QAbstractSocket::RemoteHostClosedError wird von SVDRP gesendet, wenn die Verbindung mit quit beendet wurde -> kein Fehler

    if (socketError != QAbstractSocket::RemoteHostClosedError) {
        QString s = QString("%1: %2").arg(socketError).arg(m_tcpSocket.errorString());
        qDebug() << "SVDR::error" << s;// "socketError:" << socketError << m_tcpSocket.errorString();
        QMetaObject obj = *metaObject();
        qDebug() << "Classname" <<  obj.className();
        emit svdrpError(s);
    }
}

void SVDRP::slotAbort()
{
    qDebug("SVDR::slotAbort()");
    if (m_tcpSocket.isOpen()) {
        qDebug("Port noch offen. -> abort() ");
        m_tcpSocket.abort();
    }
    else {
        qDebug("Port bereits geschlossen");
    }
}

void SVDRP::readyRead()
{
    qDebug("SVDR::readyRead()");
}
