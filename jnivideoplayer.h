#ifndef JNIVIDEOPLAYER_H
#define JNIVIDEOPLAYER_H

#include <QObject>
#include <QUrl>

class JniVideoPlayer : public QObject
{
    Q_OBJECT

public:
    explicit JniVideoPlayer(QObject *parent = nullptr);

    Q_INVOKABLE void playVideo(const QUrl &url);

signals:
    void jniError(QString error);

};

#endif // JNIVIDEOPLAYER_H
