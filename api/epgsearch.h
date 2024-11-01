#ifndef EPGSEARCH_H
#define EPGSEARCH_H

#include "svdrp.h"
#include "data/blacklist.h"
#include "data/searchtimer.h"
#include "data/extepgcat.h"
#include "data/epgsearchquery.h"

class EPGSearch : public SVDRP
{
    Q_OBJECT
    Q_PROPERTY(QStringList channelGroupNames READ channelGroupNames CONSTANT)
    Q_PROPERTY(QStringList directories READ directories NOTIFY directoriesFinished)
    Q_PROPERTY(QList<Blacklist> blacklists READ blacklists NOTIFY blacklistsFinished)
    Q_PROPERTY(QList<ExtEpgCat> extEpgCats READ extEpgCats NOTIFY extEpgCatFinished) //Die Standardwerte aus epgsearchcats.conf
    Q_PROPERTY(QVariantMap options READ options NOTIFY optionsFinished)

public:

    EPGSearch(QObject *parent = nullptr);

    //SVDRP Aufrufe
    void svdrpGetDirectories();

    void svdrpGetSearches();
    void svdrpGetSearch(int id);
    void svdrpNewSearch(SearchTimer &s);
    void svdrpEditSearch(SearchTimer &s);
    void svdrpDeleteSearch(int id);
    void svdrpToggleSearch(int id);
    void svdrpCheckConflicts();

    Q_INVOKABLE void createSearch(const QVariantMap &searchtimer);

    void svdrpGetBlacklists();
    void svdrpGetBlacklist(int id);
    void svdrpNewBlacklist(Blacklist &b);
    void svdrpEditBlacklist(Blacklist &b);
    void svdrpDeleteBlacklist(int id);

    //ChannelGroups
    void svdrpGetChannelGroups();
    void svdrpGetChannelGroup(QString groupName);
    void svdrpNewChannelGroup(const QStringList &groupList);
    void svdrpRenameChannelGroup(QString oldName, QString newName);
    void svdrpDeleteChannelGroup(QString channelgroup);
    void svdrpEditChannelGroup(const QStringList &groupList); //mit Übergabe von name,id1,id2,...

    QMap<QString, QStringList> channelGroups() const;
    QStringList channelGroupNames();

    //Query
    void svdrpQrys(QList<int> ids); //QRYS
    void svdrpSearch(SearchTimer s); //QRYS
    void svdrpQryf(int hours = 24); //QRYF

    void svdrpFind(const QVariantMap &s);

    void svdrpGetExtendedEpgCategories(int id = -1);

    //Holt nacheinander notwendige Listen wie Channelgroups, Blacklists, Tempaltes und EPG categories
    Q_INVOKABLE void svdrpGetAllLists();

    void svdrpGetOptions(); //SETP
    Q_INVOKABLE void svdrpUpdate(); //UPDS Updatebefehl

    //SVDRP Ende


    const QList<SearchTimer> &searchtimers() const;
    const QStringList &directories() const;
    const QList<Blacklist> &blacklists() const;
    const QList<ExtEpgCat> &extEpgCats() const;
    const QList<EpgSearchQuery> &epgSearchQuery() const;
    QVariantMap options() const;

    bool addSearch(const SearchTimer &searchtimer);
    bool replaceSearch(const SearchTimer &searchtimer);
    bool removeSearch(const SearchTimer &searchtimer);
    bool removeSearch(int index);

    bool addBlacklist(const Blacklist &bl);
    bool replaceBlacklist(const Blacklist &bl);
    bool removeBlacklist(const Blacklist &bl);
    bool removeBlacklist(int index); //Entfernt die Blacklist aus m_blacklists

    Q_INVOKABLE Search getSearch(); //Liefert "leere" Suche
    Q_INVOKABLE Search readSearch(); //List eine gespeicherte Suche ein
    Q_INVOKABLE void writeSearch(const QVariantMap &search);  //Speichert eine Suche ab

    QList<int> conflicts() const;

private:

    QStringList m_directories; //LSRD
    QList<SearchTimer> m_searchtimers; //LSTS
    QList<Blacklist> m_blacklists; //erstellt von LSTB
    QMap<QString, QStringList> m_channelGroups; //erstellt von LSTC <name, channelids>
    QList<ExtEpgCat> m_extEpgCats; //erstellt über LSTE (Vorgabewerte)
    QList<EpgSearchQuery> m_epgSearchQuery; //von QRYS/QRYF gelieferte Ergebnisse
    QVariantMap m_options; //von SETP
    QList<int> m_conflicts;

    enum Commands { LSTS, NEWS, EDIS, DELS, MODS,
                    LSTC, NEWC, EDIC, DELC, RENC,
                    LSTB, NEWB, EDIB, DELB,
                    LSTE,
                    LSRD,
                    LSCC,
                    QRYS,QRYF,
                    SETP, UPDS };
    Commands m_command;

//    Die zuletzt ausgeführte Aktion, Hilfswerte zum bestimmen, was gemacht wurde
//    List = normale Abfrage
    enum Action {New, Edit, List };
    Action m_action;

    //Helfer fuer die Abfrage aller Listen nacheinander
    enum QueryLists { DIR, BLACK, GROUP, EPG, OPTIONS };
    QueryLists m_queryListCommand;
    void getAllLists(QueryLists query);

    void addDirectory(QString line);

    void addSearch(QString line);
    void newSearch(QString line);
    void editSearch(QString line);
    void deleteSearch(QString line);
    void finishSearch();

    void addBlacklist(QString line);
    void newBlacklist(QString line);
    void editBlacklist(QString line);
    void deleteBlacklist(QString line);
    void finishBlacklist();

    void addChannelGroup(QString line);
    void newChannelGroup(QString line);
    void editChannelGroup(QString line);
    void renameChannelGroup(QString line);
    void deleteChannelGroup(QString line);
    void finishChannelGroup();

    void addQuery(QString line);
    void addOption(QString line);

    void addExtendedEpgCategory(QString line);
    void completeExtEpgCats(QList<ExtEpgCat> &extEpgCats);

    int getBlacklistID(QString s);
    int getSearchID(QString s);

    void finishUpdate(QString line);

    void addConflict(QString line);

    void setConnections();
    void deleteConnections();

private slots:

    void slotAllLists();
    void readyRead() override;

signals:

    void directoriesFinished();

    //Search
    void searchFinished();
    void searchAdded(const SearchTimer &searchtimer); //New Search
    void searchChanged(const SearchTimer &searchtimer);
    void searchDeleted(const SearchTimer &searchtimer);

    void blacklistsFinished();
    void blacklistAdded(const Blacklist &bl);
    void blacklistChanged(const Blacklist &bl);
    void blacklistDeleted(const Blacklist &bl);

    void channelGroupsFinished();
    void channelGroupAdded(QString name);
    void channelGroupEdited(QString name);
    void channelGroupRenamed(QString newName);
    void channelGroupDeleted(QString name);

    void extEpgCatFinished();
    void allListsFinished();
    void queryFinished();
    void optionsFinished();
    void updateFinished();
    void conflictsFinished(bool found);
};

#endif // EPGSEARCH_H
