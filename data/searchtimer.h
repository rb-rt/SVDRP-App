#ifndef SEARCHTIMER_H
#define SEARCHTIMER_H

#include <QObject>
#include <QDebug>

#include "search.h"


class SearchTimer : public Search
{

    Q_GADGET

   //Suchtimerfelder
    Q_PROPERTY(int useAsSearchtimer MEMBER use_as_searchtimer)
    Q_PROPERTY(int useAsSearchtimerFrom MEMBER use_as_searchtimer_from)
    Q_PROPERTY(int useAsSearchtimerTil MEMBER use_as_searchtimer_til)
    Q_PROPERTY(int searchtimerAction MEMBER search_timer_action)
    Q_PROPERTY(bool useSeriesRecording MEMBER use_series_recording)
    Q_PROPERTY(QString directory MEMBER directory)
    Q_PROPERTY(int deleteRecsAfterDays MEMBER delete_recs_after_days)
    Q_PROPERTY(int keepRecords MEMBER keep_records)
    Q_PROPERTY(int pauseOnRecords MEMBER pause_on_records)
    Q_PROPERTY(int switchMinBefore MEMBER switch_min_before)
    Q_PROPERTY(bool avoidRepeats MEMBER avoid_repeats)
    Q_PROPERTY(int allowedRepeats MEMBER allowed_repeats)
    Q_PROPERTY(int repeatsWithinDays MEMBER repeats_within_days)
    Q_PROPERTY(bool compareTitle MEMBER compare_title)
    Q_PROPERTY(int compareSubtitle MEMBER compare_subtitle)
    Q_PROPERTY(bool compareDescription MEMBER compare_description)
    Q_PROPERTY(int compareMatch MEMBER compare_match)
    Q_PROPERTY(int compareDate MEMBER compare_date)
    Q_PROPERTY(int compareCategories MEMBER compare_categories)
    Q_PROPERTY(int priority MEMBER priority)
    Q_PROPERTY(int lifetime MEMBER lifetime)
    Q_PROPERTY(int marginStart MEMBER margin_start)
    Q_PROPERTY(int marginStop MEMBER margin_stop)
    Q_PROPERTY(bool useVps MEMBER use_vps)
    Q_PROPERTY(int deleteMode MEMBER delete_mode)
    Q_PROPERTY(int deleteAfterCounts MEMBER delete_after_counts)
    Q_PROPERTY(int deleteAfterDays MEMBER delete_after_days)
    Q_PROPERTY(bool unMuteSound MEMBER unmute_sound)
    Q_PROPERTY(bool useInFavorites MEMBER use_in_favorites)

public:

    SearchTimer();
    SearchTimer(int id);
    ~SearchTimer();
    SearchTimer(const QVariantMap &search); //QVariantMap aus QML

    int use_as_searchtimer = 0;
    int use_as_searchtimer_from = 0; //unixtime
    int use_as_searchtimer_til = 0; //unixtime
    int search_timer_action = 0;
    bool use_series_recording = false;
    QString directory;
    int keep_records = 0;
    int pause_on_records = 0;
    int switch_min_before = 0;
    bool avoid_repeats = false;
    int allowed_repeats = 0;
    int repeats_within_days = 0;
    bool compare_title = false;
    int compare_subtitle = 0;
    bool compare_description = false;
    int compare_categories = 0;
    int delete_recs_after_days = 0;
    int priority = 50;
    int lifetime = 99;
    int margin_start = 2;
    int margin_stop = 10;
    bool use_vps = false;
    int delete_mode = 0;
    int delete_after_counts = 0;
    int delete_after_days = 0;
    bool unmute_sound = false;
    int compare_match = 90;
    int compare_date = 0;
    bool use_in_favorites = false;

    int template_number = 0; //Bedeutung?


    bool operator==(const SearchTimer &s) const;

    QString getParameterLine() const;
    QString getSearchLine() const;

};

QDebug operator <<(QDebug dbg, const SearchTimer &timer);

#endif // SEARCHTIMER_H
