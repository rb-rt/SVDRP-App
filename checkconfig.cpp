#include "checkconfig.h"
#include "api/svdrpparser.h"
#include "qregularexpression.h"

CheckConfig::CheckConfig(QObject *parent) : QTcpSocket(parent)
{
    qDebug("CheckConfig::CheckConfig");
    connect(this, &QTcpSocket::readyRead, this, &CheckConfig::slotReadyRead);
    connect(this, &QTcpSocket::connected, this, &CheckConfig::slotConnected);
    connect(this, &QTcpSocket::stateChanged, this, &CheckConfig::slotStateChanged);
    connect(this, &QTcpSocket::errorOccurred, this, &CheckConfig::slotErrorOccured);
    connect(this, &CheckConfig::urlChanged, this, &CheckConfig::slotUrlChanged);
    connect(this, &CheckConfig::currentStepChanged, this, &CheckConfig::slotCurrentStepChanged);
}

void CheckConfig::checkVdr()
{
    qDebug("CheckConfig::checkVdr");
    QString command = "help\n";
    m_vdr_ok = false;
    QByteArray b = command.toUtf8();
    write(b);
}

bool CheckConfig::checkVdrVersion(QString s)
{
    qDebug("CheckConfig::checkVdrVersion");
    bool ok = false;

    //^This is VDR Version \d+.\d+.\d+
    static QRegularExpression re ("^This is VDR version \\d+\\.\\d+\\.\\d+");
    QRegularExpressionMatch match = re.match(s);
    if (match.hasMatch()) {
        re.setPattern("(\\d+)\\.(\\d+)\\.\\d+");
        match = re.match(s);
        int major = match.captured(1).toInt();
        int minor = match.captured(2).toInt();
        ok = (major >= 2) && (minor >= 4);
    }
    if (!ok) {
        abort();
        emit vdrErrorOccured(m_errorString.value(ErrorCode::vdrVersion));
    }
    return ok;
}

void CheckConfig::sendEpgSearchCommand()
{
    qDebug("CheckConfig::sendEpgSearchCommand");
    m_epgsearch_ok = false;
    QString command = "PLUG\n";
    QByteArray b = command.toUtf8();
    write(b);
}
bool CheckConfig::checkEpgSearch(QString s)
{
    // qDebug("CheckConfig::checkEpgSearch");
    return s.startsWith("epgsearch");
}

void CheckConfig::checkSuccessful()
{
    qDebug("CheckConfig::checkSuccessful");
    if (isOpen()) close();
    // if (isOpen()) {
    //     QByteArray b = QString("QUIT\n").toUtf8();
    //     write(b);
    // }
    emit checkConfigFinished();
}

void CheckConfig::cancel()
{
    qDebug("CheckConfig::cancel");
    abort();
    emit vdrErrorOccured(m_errorString.value(ErrorCode::canceled));
}

QUrl CheckConfig::url() const
{
    return m_url;
}

void CheckConfig::setUrl(const QUrl &url)
{
    qDebug() << "SVDRP::setUrl" << url;    
    if (url.isValid()) {
        m_url = url;
        emit urlChanged();
    }
}

int CheckConfig::startStep() const
{
    return m_currentStep;
}

void CheckConfig::setStartStep(int newStep)
{
    qDebug() << "CheckConfig::setStartStep" << newStep;
    // if (newStep <= m_currentStep) return;
    m_currentStep = newStep;
    emit currentStepChanged();
    switch (m_currentStep) {
    case 0: {
        qDebug("Check Start");
        m_vdr_ok = false;
        m_epgsearch_ok = false;
        break;
    }
    case 1: checkNetwork(); break;
    case 2: checkVdr(); break;
    case 3: sendEpgSearchCommand(); break;
    case 4: checkSuccessful(); break;
    default:
        break;
    }
}

void CheckConfig::checkNetwork()
{
    qDebug("CheckConfig::checkNetwork");
    if (!url().isValid()) qDebug("Falsche Url");
    connectToHost(url().host(), url().port());
}

void CheckConfig::slotCheckConfigFinished()
{
    qDebug() << "CheckConfig::slotCheckConfigFinished";
    // sendQuit();
}

void CheckConfig::slotErrorOccured(SocketError socketError)
{
    qDebug() << "CheckConfig::slotErrorOccured socketError" << socketError << error() << errorString() ;
    QString e = QTcpSocket::errorString();
    QString s = QString("%1 - %2").arg(socketError).arg(e);
    emit vdrErrorOccured(s);
}

void CheckConfig::slotUrlChanged()
{
    qDebug() << "CheckConfig::slotUrlChanged";
    m_currentStep = 0;
    setStartStep(0);
    setStartStep(1);
}

void CheckConfig::slotStateChanged(QAbstractSocket::SocketState socketState)
{
    qDebug()   << "CheckConfig::stateChanged:" << socketState << isSequential();
    switch (socketState) {
    case QAbstractSocket::HostLookupState: emit statusChanged("Suche nach VDR"); break;
    case QAbstractSocket::ConnectingState: emit statusChanged("Verbinde zu " + url().authority()); break;
    case QAbstractSocket::ConnectedState: emit statusChanged("Verbunden mit " + url().authority()); break;
    case QAbstractSocket::ClosingState: break;
    case QAbstractSocket::UnconnectedState: break;
    default: abort(); break;
    }
}

void CheckConfig::slotConnected()
{
    qDebug("CheckConfig::slotConnected()");
    setStartStep(2);
}

void CheckConfig::slotCurrentStepChanged()
{
    QString s = m_startSteps.value(m_currentStep,"Unbekannter Check");
    emit statusChanged(s);
}

void CheckConfig::slotReadyRead()
{
    // qDebug("CheckConfig::slotReadyRead()");

    while (canReadLine()) {
        QString s = readLine();

        SVDRPParser line(s);

        // qDebug() << "code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        // if (line.code() == 220) {
        //     qDebug() << "code 220";
        //     checkVdrVersion(line.message());
        // }
        if (line.code() == 214) {
            if (line.lastLine()) {
                switch (m_currentStep) {
                case 2:
                    if (m_vdr_ok) setStartStep(3);
                    break;
                case 3:
                    if (m_epgsearch_ok) {
                        setStartStep(4);
                    }
                    else {
                        abort();
                        emit vdrErrorOccured(m_errorString.value(ErrorCode::epgsearch));
                    }
                    break;
                default:
                    break;
                }
            }
            switch (m_currentStep) {
            case 2: {
                if (m_vdr_ok) break;
                qDebug() << "checkVdr";
                m_vdr_ok = checkVdrVersion(line.message());
                if (m_vdr_ok) {
                    qDebug() << "Version Ok";
                }
                break;
            }
            case 3: {
                if (m_epgsearch_ok) break;
                qDebug() << "check epgsearch";
                m_epgsearch_ok = checkEpgSearch(line.message());
                if (m_epgsearch_ok) qDebug("epgsearch ok");
            }
            }
        }
    }
}


