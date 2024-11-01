#ifndef CHECKCONFIG_H
#define CHECKCONFIG_H

#include <QTcpSocket>
#include <QUrl>

class CheckConfig : public QTcpSocket
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(int startStep READ startStep WRITE setStartStep NOTIFY currentStepChanged FINAL)

public:

    CheckConfig(QObject *parent = nullptr);

    Q_INVOKABLE void cancel(); //Abbruch der Tests

    QUrl url() const;
    void setUrl(const QUrl &url);

    int startStep() const;
    void setStartStep(int newStep);

private:

    QUrl m_url;

    bool m_vdr_ok = false;
    bool m_epgsearch_ok = false;

    int m_currentStep = 0;
    const QMap<int,QString> m_startSteps =
        {
         {0, "Starte Checks"},
         {1, "Prüfe Netzwerk"},
         {2, "Prüfe VDR Version"},
         {3, "Prüfe auf Plugin epgsearch"},
         {4, "Prüfung erfolgeich"},
         };

    enum ErrorCode {noError, vdrVersion, epgsearch, canceled};
    const QMap<ErrorCode,QString> m_errorString =
    {
        { ErrorCode::noError, "Kein Fehler aufgetreten" },
        { ErrorCode::vdrVersion, "Mindestens VDR 2.4.0 erforderlich" },
        { ErrorCode::epgsearch, "Plugin \"epgsearch\" nicht vorhanden" },
        { ErrorCode::canceled, "Abbruch durch Benutzer" }
    };

    void checkVdr();
    void checkNetwork();
    bool checkVdrVersion(QString s);
    void sendEpgSearchCommand();
    bool checkEpgSearch(QString s);
    void checkSuccessful();

private slots:

    void slotStateChanged(QAbstractSocket::SocketState socketState);
    void slotConnected();
    void slotCurrentStepChanged();
    void slotCheckConfigFinished();
    void slotErrorOccured(QAbstractSocket::SocketError socketError);
    void slotUrlChanged();
    void slotReadyRead();

signals:
    void urlChanged();
    void checkConfigFinished();
    void statusChanged(QString status);
    void currentStepChanged();
    void vdrErrorOccured(QString error);
};

#endif // CHECKCONFIG_H
