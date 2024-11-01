#ifndef SETTINGS_H
#define SETTINGS_H

#include "qcolor.h"
#include "qdatetime.h"
#include <QObject>
#include <QSettings>

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)
    Q_PROPERTY(bool showLogos READ showLogos WRITE setShowLogos NOTIFY showLogosChanged)
    Q_PROPERTY(bool showLogosInLists READ showLogosInLists WRITE setShowLogosInLists NOTIFY showLogosInListsChanged)
    Q_PROPERTY(bool showChannelTitle READ showChannelTitle WRITE setShowChannelTitle NOTIFY showChannelTitleChanged FINAL)
    Q_PROPERTY(bool showEventSubtitle READ showEventSubtitle WRITE setShowEventSubtitle NOTIFY showEventSubtitleChanged)
    Q_PROPERTY(bool showFilename READ showFilename WRITE setShowFilename NOTIFY showFilenameChanged)
    Q_PROPERTY(int marginStart READ marginStart WRITE setMarginStart NOTIFY marginStartChanged)
    Q_PROPERTY(int marginStop READ marginStop WRITE setMarginStop NOTIFY marginStopChanged)
    Q_PROPERTY(int recordingsView READ recordingsView WRITE setRecordingsView NOTIFY recordingsViewChanged)
    Q_PROPERTY(int priority READ priority WRITE setPriority NOTIFY priorityChanged)
    Q_PROPERTY(int lifetime READ lifetime WRITE setLifetime NOTIFY lifetimeChanged)
    Q_PROPERTY(bool showIndicatorIcon READ showIndicatorIcon WRITE setShowIndicatorIcon NOTIFY showIndicatorIconChanged)
    Q_PROPERTY(bool showEventDescription READ showEventDescription WRITE setShowEventDescription NOTIFY showEventDescriptionChanged)
    Q_PROPERTY(QColor colorMainTime READ colorMainTime WRITE setColorMainTime NOTIFY colorMainTimeChanged)
    Q_PROPERTY(QTime mainTimeFrom READ mainTimeFrom WRITE setMainTimeFrom NOTIFY mainTimeFromChanged)
    Q_PROPERTY(QTime mainTimeTo READ mainTimeTo WRITE setMainTimeTo NOTIFY mainTimeToChanged)
    Q_PROPERTY(bool showMainTime READ showMainTime WRITE setShowMainTime NOTIFY showMainTimeChanged)
    Q_PROPERTY(bool showInfo READ showInfo WRITE setShowInfo NOTIFY showInfoChanged)
    Q_PROPERTY(int toChannel READ toChannel WRITE setToChannel NOTIFY toChannelChanged)
    Q_PROPERTY(bool showTimerGap READ showTimerGap WRITE setShowTimerGap NOTIFY showTimerGapChanged)
    Q_PROPERTY(QColor timerGapColor READ timerGapColor WRITE setTimerGapColor NOTIFY timerGapColorChanged)
    Q_PROPERTY(bool showRecordError READ showRecordError WRITE setShowRecordError NOTIFY showRecordErrorChanged)
    Q_PROPERTY(bool showEpgAtNow READ showEpgAtNow WRITE setShowEpgAtNow NOTIFY showEpgAtNowChanged)
    Q_PROPERTY(int favoritesHours READ favoritesHours WRITE setFavoritesHours NOTIFY favoritesHoursChanged FINAL)
    Q_PROPERTY(int firstView READ firstView WRITE setFirstView NOTIFY firstViewChanged FINAL)

public:
    Settings();


    int marginStart() const;
    void setMarginStart(int marginStart);

    int marginStop() const;
    void setMarginStop(int marginStop);

    int toChannel() const;
    void setToChannel(int toChannel);


    int priority() const;
    void setPriority(int priority);

    int lifetime() const;
    void setLifetime(int lifetime);

    bool showIndicatorIcon() const;
    void setShowIndicatorIcon(bool show);

    bool showEventDescription() const;
    void setShowEventDescription(bool showEventDescription);

    const QColor &colorMainTime() const;
    void setColorMainTime(const QColor &newColorMainTime);

    const QTime &mainTimeFrom() const;
    void setMainTimeFrom(const QTime &newMainTimeFrom);

    const QTime &mainTimeTo() const;
    void setMainTimeTo(const QTime &newMainTimeTo);

    bool showMainTime() const;
    void setShowMainTime(bool newShowMainTime);

    bool showInfo() const;
    void setShowInfo(bool newShowInfo);

    bool showTimerGap() const;
    void setShowTimerGap(bool newShowTimerGap);

    QColor timerGapColor() const;
    void setTimerGapColor(const QColor &newTimerGapColor);

    bool showRecordError() const;
    void setShowRecordError(bool newRecordError);

    bool showEpgAtNow() const;
    void setShowEpgAtNow(bool newEpgAtNow);

    int favoritesHours() const;
    void setFavoritesHours(int newFavoritesHours);

    bool showChannelTitle() const;
    void setShowChannelTitle(bool newShowChannelTitle);

    int firstView() const;
    void setFirstView(int newFirstView);

private:

    QSettings m_settings;

    void readParams();
    void writeParams();

    int fontSize() { return m_fontsize; }
    void setFontSize(int newSize);

    bool showLogos() { return m_showLogos; }
    void setShowLogos(bool showLogos);

    bool showLogosInLists() const;
    void setShowLogosInLists(bool showLogosInLists);

    bool showEventSubtitle() const;
    void setShowEventSubtitle(bool showEventSubtitle);

    bool showFilename() const;
    void setShowFilename(bool showFilename);

    int recordingsView();
    void setRecordingsView(int view);

    int m_fontsize;
    bool m_showLogos; //in der Eventübersicht
    bool m_showLogosInLists; //in der Auswahlübersicht (ComboBox)
    bool m_showChannelTitle; //"Erste Zeile" mit Kanalnamen und Zeitinformationen
    bool m_showEventSubtitle;
    bool m_showFilename;
    int m_marginStart; //Für Suchtimer Vorlauf
    int m_marginStop; //Nachlauf
    int m_toChannel; //der letzte anzuzeigende Kanal
    int m_recordingsView; //Baum- oder Listenansicht
    int m_priority; //Priorität
    int m_lifetime; //Lebensdauer
    bool m_showIndicatorIcon; //Icons einzeln zeigen anstatt dem Ellipse-Icon
    bool m_showEventDescription; //Zeigt in der Programmübersicht zusätzlich die EPG-Description an
    bool m_showMainTime;
    bool m_showTimerGap;
    QColor m_timerGapColor;
    QColor m_colorMainTime; //Farbe für die Hauptzeit
    QTime m_mainTimeFrom;
    QTime m_mainTimeTo;
    bool m_showInfo;
    bool m_showRecordError; //Fehler bei der Aufnahmeliste anzeigen
    bool m_showEpgAtNow; //Programm zeigt das EPG ab "jetzt" (bei Kanalauswahl, SVDRP liefert auch ältere Einträge)
    int m_favoritesHours;
    int m_firstView; //Erste Ansicht bei Programmstart: 0 = Programm, 1 = Timer,

signals:
    void fontSizeChanged();
    void showLogosChanged();
    void showLogosInListsChanged();
    void showEventSubtitleChanged();
    void showFilenameChanged();
    void marginStartChanged();
    void marginStopChanged();
    void toChannelChanged();
    void recordingsViewChanged();
    void priorityChanged();
    void lifetimeChanged();
    void showIndicatorIconChanged();
    void showEventDescriptionChanged();
    void colorMainTimeChanged();
    void mainTimeFromChanged();
    void mainTimeToChanged();
    void showMainTimeChanged();
    void showInfoChanged();
    void showTimerGapChanged();
    void timerGapColorChanged();
    void showRecordErrorChanged();
    void showEpgAtNowChanged();
    void favoritesHoursChanged();
    void showChannelTitleChanged();
    void firstViewChanged();
};

#endif // SETTINGS_H
