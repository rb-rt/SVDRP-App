#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QFileSelector>
#include <QQmlFileSelector>
#include <QQmlFileSelector>
#include <QFontDatabase>

#include <models/channelgroupsmodel.h>

#include "models/channelmodel.h"
#include "models/eventmodel.h"
#include "models/timermodel.h"
#include "models/recordlistmodel.h"
#include "models/recordfiltertextmodel.h"
#include "models/recordtreemodel.h"
#include "models/searchtimermodel.h"
#include "models/vdrmodel.h"
#include "models/starttimesmodel.h"
#include "api/epgsearch.h"
#include "settings.h"
#include "checkconfig.h"
#include "models/blacklistmodel.h"
#include "models/epgsearchquerymodel.h"
#include "models/extendedepgcatmodel.h"
#include "api/vdrinfo.h"
#include "api/remote.h"
#include "api/streamdev.h"

// #include <QLoggingCategory>

#ifdef Q_OS_ANDROID
 #include "jnivideoplayer.h"
   // fprintf(stderr, "ANDROID enabled.\n");
#endif

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    //    QQuickStyle::setStyle("Universal");
       // QQuickStyle::setStyle("Material");

    // qputenv("QT_FILE_SELECTORS", QString("test1").toUtf8());

    QFontDatabase::addApplicationFont(":/fonts/Roboto-Black.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-BlackItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Bold.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-BoldItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Italic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Light.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-LightItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Medium.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-MediumItalic.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Regular.ttf");
    QFontDatabase::addApplicationFont(":/fonts/Roboto-Thin.ttf");
    int fontId = QFontDatabase::addApplicationFont(":/fonts/Roboto-ThinItalic.ttf");
    qDebug() << "fontId" << fontId;

    QStringList fontFamily = QFontDatabase::applicationFontFamilies(fontId);
    qDebug() << "fontFamily" << fontFamily;

    QFont font = QFont(fontFamily.first()); //"Roboto"
    QStringList styles = QFontDatabase::styles(fontFamily.first());
    qDebug() << "styleString" << QFontDatabase::styleString(font);
    qDebug() << "styles" << styles;

    // qDebug() << "families" << QFontDatabase::families();

    for (int i = 0; i  < styles.count() ; ++i ) {
        qDebug() << "Style:" << styles.at(i) << "Weight:" << QFontDatabase::weight("Roboto",styles.at(i));
    }

    QGuiApplication::setFont(font);

    QCoreApplication::setOrganizationName("NightWatch");
    QCoreApplication::setApplicationName("SVDRP App");

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");

    /* ab 6.5 nicht mehr erforderlich
    qRegisterMetaType<Channel>();
    qRegisterMetaType<Timer>();
    qRegisterMetaType<Search>();
    qRegisterMetaType<SearchTimer>();
    qRegisterMetaType<Blacklist>();
    qRegisterMetaType<QList<Blacklist>>();
    qRegisterMetaType<ExtEpgCat>();
    qRegisterMetaType<QList<ExtEpgCat>>();
    qRegisterMetaType<Record>();
    qRegisterMetaType<RecordEvent>();
*/
    //Ermöglicht Zugriff auf enum Status in Record
    //https://stackoverflow.com/questions/20089196/how-to-access-c-enum-from-qml
    //    qmlRegisterUncreatableType<Record>("terra.sol.recordlistmodel", 1,0, "Record", "Uncreatable");

    qmlRegisterType<CheckConfig>("vdr.checkconfig", 1,0, "CheckConfig");
    qmlRegisterType<EPGSearch>("vdr.epgsearch", 1,0, "EPGSearch");

    qmlRegisterType<ChannelModel>("vdr.models", 1, 0, "ChannelModel");
    qmlRegisterType<ChannelSelectProxyModel>("vdr.models", 1,0, "ChannelSelectProxyModel");
    qmlRegisterType<ChannelSFProxyModel>("vdr.models", 1,0, "ChannelSFProxyModel");

    qmlRegisterType<EventModel>("vdr.models", 1,0, "EventModel");
    qmlRegisterType<EventSFProxyModel>("vdr.models", 1,0, "EventSFProxyModel");

    qmlRegisterType<RecordListModel>("vdr.models", 1,0, "RecordListModel");
    qmlRegisterType<RecordFilterTextModel>("vdr.models", 1,0, "RecordFilterTextModel");
    qmlRegisterType<RecordTreeModel>("vdr.models", 1,0, "RecordTreeModel");
    qmlRegisterType<RecordSelectedProxyModel>("vdr.models", 1,0, "RecordSelectedProxyModel");
    qmlRegisterType<RecordListSFProxyModel>("vdr.models", 1,0, "RecordListSFProxyModel");

    qmlRegisterType<TimerModel>("vdr.models", 1,0, "TimerModel");
    qmlRegisterType<TimerSFProxyModel>("vdr.models", 1,0, "TimerSFProxyModel");
    qmlRegisterType<SearchtimerModel>("vdr.models", 1,0, "SearchtimerModel");
    qmlRegisterType<SearchtimerSFProxyModel>("vdr.models", 1,0, "SearchtimerSFProxyModel");

    qmlRegisterType<VDRInfo>("vdr.vdrinfo", 1,0, "VdrInfo");
    qmlRegisterType<Settings>("vdr.settings", 1,0, "Settings");
    qmlRegisterType<VdrModel>("vdr.models", 1,0, "VdrModel");
    qmlRegisterType<StartTimesModel>("vdr.models", 1,0, "StartTimesModel");
    qmlRegisterType<BlacklistModel>("vdr.models", 1,0, "BlacklistModel");

    qmlRegisterType<EpgSearchQueryModel>("vdr.models", 1,0, "EpgSearchQueryModel");
    qmlRegisterType<ExtendedEpgCatModel>("vdr.models", 1,0, "ExtendedEpgCatModel");
    qmlRegisterType<ChannelGroupsModel>("vdr.models", 1,0, "ChannelGroupsModel");

    qmlRegisterType<Remote>("vdr.remote", 1,0, "Remote");
    qmlRegisterType<Streamdev>("vdr.streamdev", 1,0, "Streamdev");


#ifdef Q_OS_ANDROID
    qmlRegisterType<JniVideoPlayer>("vdr.jniplayer", 1,0, "JniPlayer");
    engine.rootContext()->setContextProperty("JNI_SUPPORT", QVariant(true)); //Krücke zum laden in QML
#else
    engine.rootContext()->setContextProperty("JNI_SUPPORT", QVariant(false));
#endif
    // engine.rootContext()->setContextProperty("JNI_SUPPORT", QVariant(false));

    // QQmlFileSelector* selector = new QQmlFileSelector(&engine);
    // // selector = QQmlFileSelector.selector();
    // // selector->setExtraSelectors(QStringList() << QString("test"));
    // qDebug() << QQmlFileSelector::get(engine);

        //Nur für Testausgabe
    QFileSelector sel;
    qDebug() << sel.allSelectors();

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
