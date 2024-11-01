QT += quick quickcontrols2 xml

CONFIG += c++17

# Suppress logging output for release build.
CONFIG(release, debug|release): DEFINES += QT_NO_DEBUG_OUTPUT
CONFIG(release, debug|release): DEFINES += QT_NO_INFO_OUTPUT
CONFIG(release, debug|release): DEFINES += QT_NO_WARNING_OUTPUT

#CONFIG += qmltypes
#QML_IMPORT_NAME = com.mycompany.messaging
# QML_IMPORT_NAME = sol.terra
QML_IMPORT_MAJOR_VERSION = 1

#INCLUDEPATH += com/mycompany/messaging
#INCLUDEPATH += data

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x050120

SOURCES += \
        api/channelparser.cpp \
        api/channels.cpp \
        api/epgsearch.cpp \
        api/epgsearchparser.cpp \
        api/events.cpp \
        api/recordparser.cpp \
        api/streamdev.cpp \
        api/svdrp.cpp \
        api/timerparser.cpp \
        api/timers.cpp \
        api/records.cpp \
        api/remote.cpp \
        api/vdrinfo.cpp \
        api/svdrpparser.cpp \
        checkconfig.cpp \
        data/baselist.cpp \
        data/blacklist.cpp \
        data/epgsearchquery.cpp \
        data/extepgcat.cpp \
        data/search.cpp \
        data/searchtimer.cpp \
        data/channel.cpp \
        data/event.cpp \
        data/timer.cpp \
        data/record.cpp \
        main.cpp \
        models/basemodel.cpp \
        models/blacklistmodel.cpp \
        models/channelgroupsmodel.cpp \
        models/channelmodel.cpp \
        models/epgsearchquerymodel.cpp \
        models/eventmodel.cpp \
        models/extendedepgcatmodel.cpp \
        models/recordfiltertextmodel.cpp \
        models/recordlistmodel.cpp \
        models/recordtreemodel.cpp \
        models/searchtimermodel.cpp \
        models/starttimesmodel.cpp \
        models/timermodel.cpp \
        models/vdrmodel.cpp \
        settings.cpp

RESOURCES += qml.qrc \
    assets.qrc \
    components.qrc \
    controls.qrc \
    dialogs.qrc \
    models.qrc

TRANSLATIONS += \
    SVDRP_en_DE.ts

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    api/channelparser.h \
    api/channels.h \
    api/epgsearch.h \
    api/epgsearchparser.h \
    api/events.h \
    api/recordparser.h \
    api/remote.h \
    api/streamdev.h \
    api/svdrp.h \
    api/timerparser.h \
    api/timers.h \
    api/records.h \
    api/vdrinfo.h \
    api/svdrpparser.h \
    checkconfig.h \
    data/baselist.h \
    data/blacklist.h \
    data/epgsearchquery.h \
    data/extepgcat.h \
    data/search.h \
    data/searchtimer.h \
    data/channel.h \
    data/event.h \
    data/timer.h \
    data/record.h \
    models/basemodel.h \
    models/blacklistmodel.h \
    models/channelgroupsmodel.h \
    models/channelmodel.h \
    models/epgsearchquerymodel.h \
    models/eventmodel.h \
    models/extendedepgcatmodel.h \
    models/recordfiltertextmodel.h \
    models/recordlistmodel.h \
    models/recordtreemodel.h \
    models/searchtimermodel.h \
    models/starttimesmodel.h \
    models/timermodel.h \
    models/vdrmodel.h \
    settings.h


android {

#    ANDROID_MIN_SDK_VERSION = 26

    equals(QT_MAJOR_VERSION, 5) {
        message ("QT 5")
        QT += androidextras
    }
    greaterThan(QT_MAJOR_VERSION, 5) {
        message ("QT 6")
        QT += core-private
    }
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    HEADERS += jnivideoplayer.h
    SOURCES += jnivideoplayer.cpp

    DISTFILES += \
        android/AndroidManifest.xml \
        android/build.gradle \
        android/gradle.properties \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew \
        android/gradlew.bat \
        android/res/values/libs.xml \
        android/src/sol/terra/PlayVideo.java \
        qtquickcontrols2.conf
}
