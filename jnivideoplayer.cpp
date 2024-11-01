#include "jnivideoplayer.h"

#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    #include <QtAndroid>
    #include <QAndroidJniEnvironment>
#else
    #include <QJniObject>
    #include "private/qandroidextras_p.h"
#endif



JniVideoPlayer::JniVideoPlayer(QObject *parent) : QObject{parent}
{
}

void JniVideoPlayer::playVideo(const QUrl &url)
{
#if QT_VERSION < QT_VERSION_CHECK(6,0,0)

    QAndroidJniObject javaUrl = QAndroidJniObject::fromString(url.toString());
    QAndroidJniObject intent = QAndroidJniObject::callStaticObjectMethod("sol/terra/PlayVideo",
                                                           "play",
                                                           "(Ljava/lang/String;)Landroid/content/Intent;",
                                                           javaUrl.object<jstring>());
    QAndroidJniEnvironment env;
    QtAndroid::startActivity(intent, 3);

#else

    QJniObject javaUrl = QJniObject::fromString(url.toString());
    QJniObject intent = QJniObject::callStaticObjectMethod("sol/terra/PlayVideo",
                                                           "play",
                                                           "(Ljava/lang/String;)Landroid/content/Intent;",
                                                           javaUrl.object<jstring>());
    QJniEnvironment env;
    QtAndroidPrivate::startActivity(intent, 3);

#endif

    bool flag = env->ExceptionCheck();
    if (flag) {
        env->ExceptionClear();
        emit jniError("Konnte keinen Player finden");
    }

}
