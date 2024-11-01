#include "settings.h"
#include <QDebug>
#include <QGuiApplication>
#include <QFont>

Settings::Settings()
{
    qDebug() << "Settings::Settings()";
    readParams();
}

void Settings::readParams()
{
    qDebug() << "Settings::readParams()";

    QVariant v = m_settings.value("fontsize",0);
    v.canConvert<int>() ? m_fontsize = v.toInt() : m_fontsize = 0;
    if (m_fontsize == 0) m_fontsize = QGuiApplication::font().pointSize();

    v = m_settings.value("showLogos",false);
    v.canConvert<bool>() ? m_showLogos = v.toBool() : m_showLogos = false;

    v = m_settings.value("showLogosInLists",false);
    v.canConvert<bool>() ? m_showLogosInLists = v.toBool() : m_showLogosInLists = false;

    v = m_settings.value("showChannelTitle",true);
    v.canConvert<bool>() ? m_showChannelTitle = v.toBool() : m_showChannelTitle = false;

    v = m_settings.value("showSubtitle",false);
    v.canConvert<bool>() ? m_showEventSubtitle = v.toBool() : m_showEventSubtitle = false;

    v = m_settings.value("showFilename",false);
    v.canConvert<bool>() ? m_showFilename = v.toBool() : m_showFilename = false;

    v = m_settings.value("marginStart",2);
    v.canConvert<int>() ? m_marginStart = v.toInt() : m_marginStart = 2;

    v = m_settings.value("marginStop",10);
    v.canConvert<int>() ? m_marginStop = v.toInt() : m_marginStop = 10;

    v = m_settings.value("toChannel",0);
    v.canConvert<int>() ? m_toChannel = v.toInt() : m_toChannel = 0;

    v = m_settings.value("recordingsView",0);
    v.canConvert<int>() ? m_recordingsView = v.toInt() : m_recordingsView = 0;

    v = m_settings.value("priority",50);
    v.canConvert<int>() ? m_priority = v.toInt() : m_priority = 50;

    v = m_settings.value("lifetime",99);
    v.canConvert<int>() ? m_lifetime = v.toInt() : m_lifetime = 99;

    v = m_settings.value("showIndicatorIcon",false);
    v.canConvert<bool>() ? m_showIndicatorIcon = v.toBool() : m_showIndicatorIcon = false;

    v = m_settings.value("showEventDescription",false);
    v.canConvert<bool>() ? m_showEventDescription = v.toBool() : m_showEventDescription = false;

    v = m_settings.value("showMainTime", false);
    if (v.canConvert<bool>()) m_showMainTime = v.toBool(); else m_showMainTime = false;

    v = m_settings.value("colorMainTime", "#3383b546");
    if (v.canConvert<QColor>()) m_colorMainTime = v.value<QColor>();

    v = m_settings.value("mainTimeFrom", QTime(20,15)); //20:15 = 29700 s
    if (v.canConvert<QTime>()) m_mainTimeFrom = v.toTime();

    v = m_settings.value("mainTimeTo", QTime(23,59)); //86344 = 23:59:59
    if (v.canConvert<QTime>()) m_mainTimeTo = v.toTime();

    v = m_settings.value("showInfo", false);
    if (v.canConvert<bool>()) m_showInfo = v.toBool(); else m_showInfo = false;

    v = m_settings.value("showTimerGap", false);
    if (v.canConvert<bool>()) m_showTimerGap = v.toBool(); else m_showTimerGap = false;

    v = m_settings.value("timerGapColor", "yellow");
    if (v.canConvert<QColor>()) m_timerGapColor = v.value<QColor>();

    v = m_settings.value("showRecordError", false);
    if (v.canConvert<bool>()) m_showRecordError = v.value<bool>();

    v = m_settings.value("epgatnow", true);
    if (v.canConvert<bool>()) m_showEpgAtNow = v.value<bool>();

    v = m_settings.value("favoritesHours", 24);
    v.canConvert<int>() ? m_favoritesHours = v.toInt() : m_favoritesHours = 24;

    v = m_settings.value("firstView", 4); //4 = RemoteControl
    v.canConvert<int>() ? m_firstView = v.toInt() : m_firstView = 4;
}

void Settings::writeParams()
{
    qDebug() << "Settings::writeParams()";
    m_settings.setValue("fontsize",m_fontsize);
    m_settings.setValue("showLogos",m_showLogos);
    m_settings.setValue("showLogosInLists",m_showLogosInLists);
    m_settings.setValue("showChannelTitle",m_showChannelTitle);
    m_settings.setValue("showSubtitle",m_showEventSubtitle);
    m_settings.setValue("showFilename",m_showFilename);
    m_settings.setValue("marginStart",m_marginStart);
    m_settings.setValue("marginStop",m_marginStop);
    m_settings.setValue("toChannel",m_toChannel);
    m_settings.setValue("recordingsView", m_recordingsView);
    m_settings.setValue("priority",m_priority);
    m_settings.setValue("lifetime",m_lifetime);
    m_settings.setValue("showIndicatorIcon",m_showIndicatorIcon);
    m_settings.setValue("showEventDescription",m_showEventDescription);
    m_settings.setValue("showMainTime", m_showMainTime);
    m_settings.setValue("colorMainTime", m_colorMainTime);
    m_settings.setValue("mainTimeFrom", m_mainTimeFrom);
    m_settings.setValue("mainTimeTo", m_mainTimeTo);
    m_settings.setValue("showInfo", m_showInfo);
    m_settings.setValue("showTimerGap", m_showTimerGap);
    m_settings.setValue("timerGapColor", m_timerGapColor);
    m_settings.setValue("showRecordError", m_showRecordError);
    m_settings.setValue("epgatnow", m_showEpgAtNow);
    m_settings.setValue("favoritesHours", m_favoritesHours);
    m_settings.setValue("firstView", m_firstView);
}

void Settings::setFontSize(int newSize)
{
    qDebug() << "Settings::setFontSize()";
    if (newSize == m_fontsize) return;
    m_fontsize = newSize;
    writeParams();
    emit fontSizeChanged();
}

void Settings::setShowLogos(bool showLogos)
{
    qDebug() << "Settings::setShowLogos()";
 if (showLogos == m_showLogos) return;
 m_showLogos = showLogos;
    writeParams();
    emit showLogosChanged();
}

bool Settings::showLogosInLists() const
{
    return m_showLogosInLists;
}

void Settings::setShowLogosInLists(bool showLogosInLists)
{
    qDebug() << "Settings::setShowLogosInLists()";
    if (m_showLogosInLists == showLogosInLists) return;
    m_showLogosInLists = showLogosInLists;
    writeParams();
    emit showLogosInListsChanged();
}

bool Settings::showEventSubtitle() const
{
    return m_showEventSubtitle;
}

void Settings::setShowEventSubtitle(bool showEventSubtitle)
{
    qDebug() << "Settings::setShowEventSubtitle()";
    if (showEventSubtitle == m_showEventSubtitle) return;
    m_showEventSubtitle = showEventSubtitle;
    writeParams();
    emit showEventSubtitleChanged();
}

bool Settings::showFilename() const
{
    return m_showFilename;
}

void Settings::setShowFilename(bool showFilename)
{
    qDebug() << "Settings::setShowFilename()";
    if (showFilename == m_showFilename) return;
    m_showFilename = showFilename;
    writeParams();
    emit showFilenameChanged();
}

int Settings::recordingsView()
{
    return m_recordingsView;
}

void Settings::setRecordingsView(int view)
{
    qDebug() << "Settings::setRecordingsView()" << view;
    if (view == m_recordingsView) return;
    m_recordingsView = view;
    writeParams();
    emit recordingsViewChanged();
}

int Settings::firstView() const
{
    return m_firstView;
}

void Settings::setFirstView(int newFirstView)
{
    if (m_firstView == newFirstView) return;
    m_firstView = newFirstView;
    writeParams();
    emit firstViewChanged();
}

bool Settings::showChannelTitle() const
{
    return m_showChannelTitle;
}

void Settings::setShowChannelTitle(bool newShowChannelTitle)
{
    if (m_showChannelTitle == newShowChannelTitle) return;
    m_showChannelTitle = newShowChannelTitle;
    writeParams();
    emit showChannelTitleChanged();
}

int Settings::favoritesHours() const
{
    return m_favoritesHours;
}

void Settings::setFavoritesHours(int newFavoritesHours)
{
    if (m_favoritesHours == newFavoritesHours) return;
    m_favoritesHours = newFavoritesHours;
    writeParams();
    emit favoritesHoursChanged();
}

bool Settings::showEpgAtNow() const
{
    return m_showEpgAtNow;
}

void Settings::setShowEpgAtNow(bool newEpgAtNow)
{
    if (m_showEpgAtNow == newEpgAtNow) return;
    m_showEpgAtNow = newEpgAtNow;
    writeParams();
    emit showEpgAtNowChanged();
}

bool Settings::showRecordError() const
{
    return m_showRecordError;
}

void Settings::setShowRecordError(bool newRecordError)
{
    if (m_showRecordError == newRecordError) return;
    m_showRecordError = newRecordError;
    writeParams();
    emit showRecordErrorChanged();
}

QColor Settings::timerGapColor() const
{
    return m_timerGapColor;
}

void Settings::setTimerGapColor(const QColor &newTimerGapColor)
{
    if (m_timerGapColor == newTimerGapColor) return;
    m_timerGapColor = newTimerGapColor;
    writeParams();
    emit timerGapColorChanged();
}

bool Settings::showInfo() const
{
    return m_showInfo;
}

void Settings::setShowInfo(bool newShowInfo)
{
    if (m_showInfo == newShowInfo) return;
    m_showInfo = newShowInfo;
    writeParams();
    emit showInfoChanged();
}

bool Settings::showEventDescription() const
{
    return m_showEventDescription;
}

void Settings::setShowEventDescription(bool showEventDescription)
{
    if (m_showEventDescription == showEventDescription) return;
    m_showEventDescription = showEventDescription;
    writeParams();
    emit showEventDescriptionChanged();
}

bool Settings::showIndicatorIcon() const
{
    return m_showIndicatorIcon;
}

void Settings::setShowIndicatorIcon(bool show)
{
    if (m_showIndicatorIcon == show) return;
    m_showIndicatorIcon = show;
    writeParams();
    emit showIndicatorIconChanged();
}

int Settings::lifetime() const
{
    return m_lifetime;
}

void Settings::setLifetime(int lifetime)
{
    if (m_lifetime == lifetime) return;
    m_lifetime = lifetime;
    writeParams();
    emit lifetimeChanged();
}

int Settings::priority() const
{
    return m_priority;
}

void Settings::setPriority(int priority)
{
    if (m_priority == priority) return;
    m_priority = priority;
    writeParams();
    emit priorityChanged();
}

int Settings::toChannel() const
{
    return m_toChannel;
}

void Settings::setToChannel(int toChannel)
{
    if (m_toChannel == toChannel) return;
    m_toChannel = toChannel;
    writeParams();
    emit toChannelChanged();
}

int Settings::marginStart() const
{
    return m_marginStart;
}

void Settings::setMarginStart(int marginStart)
{
    qDebug() << "Settings::setMarginStart()";
    if (marginStart == m_marginStart) return;
    m_marginStart = marginStart;
    writeParams();
    emit marginStartChanged();
}

int Settings::marginStop() const
{
    return m_marginStop;
}

void Settings::setMarginStop(int marginStop)
{
    qDebug() << "Settings::setMarginStop()";
    if (marginStop == m_marginStop) return;
    m_marginStop = marginStop;
    writeParams();
    emit marginStopChanged();
}

bool Settings::showMainTime() const
{
    return m_showMainTime;
}

void Settings::setShowMainTime(bool newShowMainTime)
{
    if (m_showMainTime == newShowMainTime) return;
    m_showMainTime = newShowMainTime;
    writeParams();
    emit showMainTimeChanged();
}

const QTime &Settings::mainTimeTo() const
{
    return m_mainTimeTo;
}

void Settings::setMainTimeTo(const QTime &newMainTimeTo)
{
    if (m_mainTimeTo == newMainTimeTo) return;
    m_mainTimeTo = newMainTimeTo;
    writeParams();
    emit mainTimeToChanged();
}

const QTime &Settings::mainTimeFrom() const
{
    return m_mainTimeFrom;
}

void Settings::setMainTimeFrom(const QTime &newMainTimeFrom)
{
    if (m_mainTimeFrom == newMainTimeFrom) return;
    m_mainTimeFrom = newMainTimeFrom;
    writeParams();
    emit mainTimeFromChanged();
}

const QColor &Settings::colorMainTime() const
{
    return m_colorMainTime;
}

void Settings::setColorMainTime(const QColor &newColorMainTime)
{
    if (m_colorMainTime == newColorMainTime) return;
    m_colorMainTime = newColorMainTime;
    writeParams();
    emit colorMainTimeChanged();
}

bool Settings::showTimerGap() const
{
    return m_showTimerGap;
}

void Settings::setShowTimerGap(bool newShowTimerGap)
{
    if (m_showTimerGap == newShowTimerGap) return;
    m_showTimerGap = newShowTimerGap;
    writeParams();
    emit showTimerGapChanged();
}
