#include "epgsearch.h"
#include "epgsearchparser.h"
// #include "qmetaobject.h"
#include "svdrpparser.h"
#include <QRegularExpression>

EPGSearch::EPGSearch(QObject *parent) : SVDRP(parent)
{
    qDebug("EPGSearch::EPGSearch");
}

void EPGSearch::svdrpGetDirectories()
{
    qDebug("EPGSearch::getDirectories");
    m_command = Commands::LSRD;
    m_directories.clear();
    sendCommand("PLUG epgsearch LSRD");
}

void EPGSearch::svdrpGetSearches()
{
    m_searchtimers.clear();
    m_command = Commands::LSTS;
    m_action = Action::List;
    sendCommand("PLUG epgsearch LSTS");
}

void EPGSearch::svdrpGetSearch(int id)
{
    m_command = Commands::LSTS;
    QString c = QString("PLUG epgsearch LSTS %1").arg(id);
    sendCommand(c);
}

void EPGSearch::svdrpNewSearch(SearchTimer &s)
{
    m_command = Commands::NEWS;
    m_action = Action::New;
    s.id = 0; //Der gesetzte Wert -1 wird als Fehler zurückgemeldet, die id wird von epgsearch eh verworfen
    QString command = "PLUG epgsearch NEWS " + s.getParameterLine();
    //    qDebug() << "svdrpNewSearchtimer" << command;
    sendCommand(command);
}

void EPGSearch::svdrpEditSearch(SearchTimer &s)
{
    m_command = Commands::EDIS;
    m_action = Action::Edit;
    qDebug() << "SearchTimer ParameterLine" << s.getParameterLine();
    QString command = "PLUG epgsearch EDIS " + s.getParameterLine();
    sendCommand(command);
}

void EPGSearch::svdrpDeleteSearch(int id)
{
    m_command = Commands::DELS;
    QString command = QString("PLUG epgsearch DELS %1").arg(id);
    sendCommand(command);
}

void EPGSearch::svdrpToggleSearch(int id)
{
    SearchTimer st(id);
    int index = m_searchtimers.indexOf(st);
    if (index != -1) {
        st = m_searchtimers.at(index);
        m_command = Commands::MODS;
        QString command;
        if (st.use_as_searchtimer == 0) {
            command = QString("PLUG epgsearch MODS %1 ON").arg(id);
        }
        else {
            command = QString("PLUG epgsearch MODS %1 OFF").arg(id);
        }
        sendCommand(command);
    }
}

void EPGSearch::svdrpCheckConflicts()
{
    qDebug("EPGSearch::svdrpCheckConflicts");
    m_conflicts.clear();
    m_command = Commands::LSCC;
    QString command = "PLUG epgsearch LSCC";
    sendCommand(command);
}

void EPGSearch::createSearch(const QVariantMap &searchtimer)
{
    qDebug("EPGSearch::createSearch");
    SearchTimer st (searchtimer);
    svdrpNewSearch(st);
}

void EPGSearch::svdrpGetBlacklists()
{
    qDebug("EPGSearch::svdrpGetBlacklists()");
    m_command = Commands::LSTB;
    m_action = Action::List;
    m_blacklists.clear();
    sendCommand("PLUG epgsearch LSTB");
}

void EPGSearch::svdrpGetBlacklist(int id)
{
    m_command = Commands::LSTB;
    QString c = QString("PLUG epgsearch LSTB %1").arg(id);
    sendCommand(c);
}

void EPGSearch::svdrpNewBlacklist(Blacklist &b)
{
    m_command = Commands::NEWB;
    m_action = Action::New;
    QString s = "PLUG epgsearch NEWB " + b.getParameterLine();
    sendCommand(s);
}

void EPGSearch::svdrpEditBlacklist(Blacklist &b)
{
    qDebug("EPGSearch::svdrpEditBlacklist");
    m_command = Commands::EDIB;
    m_action = Action::Edit;
    QString s = "PLUG epgsearch EDIB " + b.getParameterLine();
    sendCommand(s);
}

void EPGSearch::svdrpDeleteBlacklist(int id)
{
    m_command = Commands::DELB;
    QString command = QString("PLUG epgsearch DELB %1").arg(id);
    sendCommand(command);
}


void EPGSearch::svdrpGetChannelGroups()
{
    qDebug("EPGSearch::svdrpGetChannelGroups()");
    m_channelGroups.clear();
    m_command = Commands::LSTC;
    m_action = Action::List;
    sendCommand("PLUG epgsearch LSTC");
}

void EPGSearch::svdrpGetChannelGroup(QString groupName)
{
    m_command = Commands::LSTC;
    QString command = "PLUG epgsearch LSTC " + groupName;
    sendCommand(command);
}

void EPGSearch::svdrpNewChannelGroup(const QStringList &groupList)
{
    m_command = Commands::NEWC;
    m_action = Action::New;
    QString command = "PLUG epgsearch NEWC " + groupList.join("|");
    sendCommand(command);
}

void EPGSearch::svdrpEditChannelGroup(const QStringList &groupList)
{
    m_command = Commands::EDIC;
    m_action =Action::Edit;
    QString command = "PLUG epgsearch EDIC " + groupList.join("|");
    sendCommand(command);
}

void EPGSearch::svdrpRenameChannelGroup(QString oldName, QString newName)
{
    m_command = Commands::RENC;
    QString command = "PLUG epgsearch RENC " + oldName + "|" + newName;
    sendCommand(command);
}

void EPGSearch::svdrpDeleteChannelGroup(QString channelgroup)
{
    m_command = Commands::DELC;
    QString command = "PLUG epgsearch DELC " + channelgroup;
    sendCommand(command);
}
/*
void EPGSearch::editChannelGroup(QString name, QStringList channelgroups)
{
    channelgroups.prepend(name);
    svdrpEditChannelGroup(channelgroups);
}
*/

const QStringList &EPGSearch::directories() const
{
    return m_directories;
}

const QList<SearchTimer> &EPGSearch::searchtimers() const
{
    return m_searchtimers;
}

bool EPGSearch::addSearch(const SearchTimer &searchtimer)
{
    qDebug("EPGSearch::addSearch");
    if (m_searchtimers.contains(searchtimer)) return false;
    m_searchtimers.append(searchtimer);
    return true;
}

bool EPGSearch::replaceSearch(const SearchTimer &searchtimer)
{
    int index = m_searchtimers.indexOf(searchtimer);
    if (index >= 0) {
        m_searchtimers.replace(index, searchtimer);
        return true;
    }
    return false;
}

bool EPGSearch::removeSearch(const SearchTimer &searchtimer)
{
    int index = m_searchtimers.indexOf(searchtimer);
    if (index >= 0) {
        m_searchtimers.removeAt(index);
        return true;
    }
    return false;
}

bool EPGSearch::removeSearch(int index)
{
    if (index >=0 && index < m_searchtimers.count()) {
        m_searchtimers.removeAt(index);
        return true;
    }
    return false;
}

const QList<Blacklist> &EPGSearch::blacklists() const
{
    //    qDebug("EPGSearch::blacklists()");
    return m_blacklists;
}

bool EPGSearch::addBlacklist(const Blacklist &bl)
{
    qDebug("EPGSearch::addBlacklist");
    if (m_blacklists.contains(bl)) return false;
    m_blacklists.append(bl);
    return true;
}

bool EPGSearch::replaceBlacklist(const Blacklist &bl)
{
    int index = m_blacklists.indexOf(bl);
    if (index >= 0) {
        m_blacklists.replace(index, bl);
        return true;
    }
    return false;
}

bool EPGSearch::removeBlacklist(const Blacklist &bl)
{
    int index = m_blacklists.indexOf(bl);
    if (index >= 0) {
        m_blacklists.removeAt(index);
        return true;
    }
    return false;
}


bool EPGSearch::removeBlacklist(int index)
{
    if (index >= 0 && index < m_blacklists.count()) {
        m_blacklists.removeAt(index);
        return true;
    }
    return false;
}

Search EPGSearch::getSearch()
{
    return Search();
}

Search EPGSearch::readSearch()
{
    Search s;
    return s.read();
}

void EPGSearch::writeSearch(const QVariantMap &search)
{
    Search s(search);
    s.write();
}

QList<int> EPGSearch::conflicts() const
{
    return m_conflicts;
}

QMap<QString, QStringList> EPGSearch::channelGroups() const
{
    return m_channelGroups;
}

const QList<ExtEpgCat> &EPGSearch::extEpgCats() const
{
    return m_extEpgCats;
}

const QList<EpgSearchQuery> &EPGSearch::epgSearchQuery() const
{
    return m_epgSearchQuery;
}

QVariantMap EPGSearch::options() const
{
    return m_options;
}
/*
QMap<QString, QStringList> EPGSearch::channelGroups()
{
    return m_channelGroups;
}
*/
QStringList EPGSearch::channelGroupNames()
{
    return m_channelGroups.keys();
}
/*
QStringList EPGSearch::channelsFromGroup(QString groupName)
{
    return m_channelGroups.value(groupName);
}
*/
void EPGSearch::svdrpQrys(QList<int> ids)
{
    qDebug("EPGSearch::svdrpQuery (QList)");
    m_epgSearchQuery.clear();
    if (ids.isEmpty()) return;
    m_command = Commands::QRYS;
    QString s = "";
    for (int i=0; i < ids.count(); i++ ) {
        s += "|" + QString::number(ids.at(i));
    }
    sendCommand("PLUG epgsearch QRYS " + s);
}

void EPGSearch::svdrpSearch(SearchTimer s)
{
    qDebug("EPGSearch::svdrpSearch (SearchTimer)");
    s.id = 0; //id wird hier nicht genutzt
    QString p = s.getSearchLine();

    m_epgSearchQuery.clear();
    m_command = Commands::QRYS;
    QString command = "PLUG epgsearch QRYS " + p;
    qDebug() << "svdrpCommand" << command;
    sendCommand(command);
}

void EPGSearch::svdrpQryf(int hours)
{
    qDebug("EPGSearch::svdrpQryf");
    m_epgSearchQuery.clear();
    m_command = Commands::QRYF;
    QString s = QString("PLUG epgsearch QRYF %1").arg(hours);
    sendCommand(s);

}
/*
void EPGSearch::svdrpQuery(SearchTimer &s)
{
    qDebug("EPGSearch::svdrpQuery (SearchTimer)");
    m_epgSearchQuery.clear();
//    if (m_svdrpActive) return;
    m_command = Commands::QRYS;
//    qDebug() << "Parameter Searchtimer:" << s.getParameterLine();
    if (s.id == -1) s.id = 0; //-1 findet gar nichts und die id wird hier nicht genutzt
//    qDebug() << "Parameter Search:" << s.getSearchLine();
//    s.write();
//    qDebug("*** Ausgabe TESTSTRING ***");
    //Funktionierender String
//    QString test = "0:Hubert:0:::3:0:0:0:1:0:0:0:::0:0:0:0::50:99:2:10:0:5:0::1:1:1:1:0:0:0:0:0:0:0:0::13:13:0:0:0:0:0:0:0:0:0::0";
//    QString test = "0:Hubert:0:0000:2359:3:0:0:2:1:0:0:0:0000:2359:0:0:0:0::50:99:2:10:0:5:0::1:1:1:1:0:0:0:0:0:0:0:0::1:0:0:0:0:0:0:0:0:0:90::0";
//    SearchtimerParser p;
//    s = p.parseEpgSearch(test);
//    s.print();
    QString command;
    if (s.id == -1) {
        //Kein Suchtimer sondern Suche: -1 findet gar nichts und die id wird hier nicht genutzt
        s.id = 0;
        command = "PLUG epgsearch QRYS " + s.getSearchLine();
    }
    else {
        command = "PLUG epgsearch QRYS " + s.getParameterLine();

    }
    qDebug() << "svdrpCommand" << command;
    sendCommand(command);
}
*/
//Ausgabe wie bei QRYS, aber statt ChannelID wird die Kanalnummer zurückgegeben
//Vorformatiert zum Alegen eines Timers mit NEWT
//Funktion nicht notwendig bzw. wird nie genutzt
void EPGSearch::svdrpFind(const QVariantMap &s)
{
    Q_UNUSED(s);
    qDebug("EPGSearch::svdrpFind");
    Q_ASSERT(false);
    //    m_command = Commands::FIND;
    //    SearchTimer st(s);
    //    if (st.id == -1) st.id = 0; //-1 findet gar nichts und die id wird hier nicht genutzt
    //    qDebug() << "Parameter:" << st.getParameterLine();
    //    QString command = "PLUG epgsearch FIND " + st.getParameterLine();
    //    sendCommand(command);
}



void EPGSearch::svdrpGetExtendedEpgCategories(int id)
{
    m_command = Commands::LSTE;
    m_extEpgCats.clear();
    QString command = "PLUG epgsearch LSTE ";
    if ( id != -1) command += QString(" %1").arg(id);
    sendCommand(command);
}


void EPGSearch::svdrpGetAllLists()
{
    qDebug("EPGSearch::svdrpGetAllLists()");
    // bool c = this->disconnect(); nicht empfohlen
    // qDebug() << "disconnect all" << c;

    deleteConnections();

    /*
    QMetaObject moTest = *this->metaObject();

    QList<QString> slotSignatures;
    QList<QString> signalSignatures;

    // Start from MyClass members
    for(int methodIdx = moTest.methodOffset(); methodIdx < moTest.methodCount(); ++methodIdx) {
        QMetaMethod mmTest = moTest.method(methodIdx);
        switch((int)mmTest.methodType()) {
        case QMetaMethod::Signal:
            signalSignatures.append(QString(mmTest.methodSignature())); // Requires Qt 5.0 or newer
            break;
        case QMetaMethod::Slot:
            slotSignatures.append(QString(mmTest.methodSignature())); // Requires Qt 5.0 or newer
            break;
        }
    }

    // Just to visualize the contents of both lists
    qDebug() << "Slots:";
    foreach(QString signature, slotSignatures) qDebug() << "\t" << signature.toStdString();
    qDebug() << "Signals:";
    foreach(QString signature, signalSignatures) qDebug() << "\t" << signature.toStdString();

    // c = disconnect(&m_tcpSocket, &QTcpSocket::readyRead, nullptr, nullptr);
    // qDebug() << "disconnect readyRead" << c;
*/

    getAllLists(QueryLists::DIR);
}

void EPGSearch::svdrpGetOptions()
{
    qDebug("EPGSearch::svdrpGetOptions");
    m_command = Commands::SETP;
    sendCommand("PLUG epgsearch SETP");
}

void EPGSearch::svdrpUpdate()
{
    qDebug("EPGSearch::svdrpUpdate");
    m_command = Commands::UPDS;
    sendCommand("PLUG epgsearch UPDS");
}

void EPGSearch::getAllLists(QueryLists query)
{
    //Reihenfolge der Abfrage ist einzuhalten!
    //    qDebug() << "EPGSearch::getAllLists" << query;

    m_queryListCommand = query;
    switch (query) {
    case QueryLists::DIR:
        connect(this, &EPGSearch::directoriesFinished, this, &EPGSearch::slotAllLists);
        svdrpGetDirectories();
        break;
    case QueryLists::BLACK:
        connect(this, &EPGSearch::blacklistsFinished, this, &EPGSearch::slotAllLists);
        svdrpGetBlacklists();
        break;
    case QueryLists::GROUP:
        connect(this, &EPGSearch::channelGroupsFinished, this, &EPGSearch::slotAllLists);
        svdrpGetChannelGroups();
        break;
    case QueryLists::EPG:
        connect(this, &EPGSearch::extEpgCatFinished, this, &EPGSearch::slotAllLists);
        svdrpGetExtendedEpgCategories();
        break;
    case QueryLists::OPTIONS:
        connect(this, &EPGSearch::optionsFinished, this, &EPGSearch::slotAllLists);
        svdrpGetOptions();
        break;
    }
}

void EPGSearch::addDirectory(QString line)
{
    m_directories.append(line);
}

void EPGSearch::addSearch(QString line)
{
    //    qDebug() << "EPGSearch::addSearch (QString)" << line;

    EPGSearchParser parser;
    SearchTimer st = parser.parseEpgSearch(line);
    switch (m_action) {
    case Action::List: m_searchtimers.append(st); break;
    case Action::New: emit searchAdded(st); break;
    case Action::Edit: emit searchChanged(st);
    }
}

void EPGSearch::newSearch(QString line)
{
    qDebug("EPGSearch::newSearch");
    int id = getSearchID(line);
    if (id != -1) {
        m_action = Action::New;
        svdrpGetSearch(id);
    }
}

void EPGSearch::editSearch(QString line)
{
    qDebug("EPGSearch::editSearch");
    int id = getSearchID(line);
    SearchTimer st(id);
    int index = m_searchtimers.indexOf(st);
    if (index != -1) {
        m_action = Action::Edit;
        svdrpGetSearch(id);
    }
}

void EPGSearch::deleteSearch(QString line)
{
    qDebug("EPGSearch::deleteSearch");
    int id = getSearchID(line);
    SearchTimer st(id);
    int index = m_searchtimers.indexOf(st);
    if (index != -1) {
        SearchTimer st = m_searchtimers.at(index);
        emit searchDeleted(st);
    }
}

void EPGSearch::finishSearch()
{
    qDebug("EPGSearch::finishSearch");
    if (m_action == Action::List) emit searchFinished();
}


void EPGSearch::addBlacklist(QString line)
{
    //    qDebug("EPGSearch::addBlacklist (QString)");
    EPGSearchParser parser;
    Blacklist bl = parser.parseBlacklist(line);
    switch (m_action) {
    case Action::List: m_blacklists.append(bl); break;
    case Action::New: emit blacklistAdded(bl); break;
    case Action::Edit: emit blacklistChanged(bl);
    }
}


void EPGSearch::newBlacklist(QString line)
{
    //    qDebug("EPGSearch::newBlacklist");
    int id = getBlacklistID(line);
    if (id != -1) {
        m_action = Action::New;
        svdrpGetBlacklist(id);
    }
}

void EPGSearch::editBlacklist(QString line)
{
    //    qDebug("EPGSearch::updatetBlacklist");
    int id = getBlacklistID(line);
    Blacklist bl(id);
    int index = m_blacklists.indexOf(bl);
    if (index >= 0) {
        m_action = Action::Edit;
        svdrpGetBlacklist(id);
    }
}

void EPGSearch::deleteBlacklist(QString line)
{
    //    qDebug("EPGSearch::deleteBlacklist");
    int id = getBlacklistID(line);
    Blacklist bl(id);
    int index = m_blacklists.indexOf(bl);
    if (index >= 0) {
        Blacklist bl = m_blacklists.at(index);
        emit blacklistDeleted(bl);
    }
}

void EPGSearch::finishBlacklist()
{
    qDebug("EPGSearch::finishBlacklist");
    if (m_action == Action::List) emit blacklistsFinished();
}


void EPGSearch::addChannelGroup(QString line)
{
    // qDebug() << "EPGSearch::addChannelGroup" << line;
    QStringList list = line.split("|");
    QString name = list.at(0);
    list.removeFirst();
    // qDebug() << QString("EPGSearch::addChannelGroup %1").arg(name);
    m_channelGroups.insert(name, list);
    switch (m_action) {
    case Action::List:; break;
    case Action::New: emit channelGroupAdded(name); break;
    case Action::Edit: emit channelGroupEdited(name); break;
    }
}
void EPGSearch::newChannelGroup(QString line)
{
    //    qDebug("EPGSearch::newChannelGroup");
    //Rückgabe: channel group 'xyz' added
    QString name = line.section("'",1,1);
    if (!name.isEmpty()) {
        m_action = Action::New;
        svdrpGetChannelGroup(name);
    }
}
void EPGSearch::editChannelGroup(QString line)
{
    // qDebug("EPGSearch::editChannelGroup");
    //Rückgabe: channel group 'xyz' modified
    QString name = line.section("'",1,1);
    if (m_channelGroups.contains(name)) {
        m_action = Action::Edit;
        svdrpGetChannelGroup(name);
    }
}
void EPGSearch::renameChannelGroup(QString line)
{
    //    qDebug("EPGSearch::renameChannelGroup");
    //Rückgabe: renamed channel group 'abc' to 'xyz'"
    QStringList list = line.split("'");
    QString oldName = list.at(1);
    QString newName = list.at(3);
    QStringList values = m_channelGroups.value(oldName);
    m_channelGroups.remove(oldName);
    m_channelGroups.insert(newName,values);
    emit channelGroupRenamed(newName);
}
void EPGSearch::deleteChannelGroup(QString line)
{
    //    qDebug("EPGSearch::deleteChannelGroup");
    //Rückgabe: channel group 'xyz' deleted
    QString s = line.section("'",1,1);
    if (m_channelGroups.contains(s)) {
        m_channelGroups.remove(s);
        emit channelGroupDeleted(s);
    }
}
void EPGSearch::finishChannelGroup()
{
    qDebug("EPGSearch::finishChannelGroup");
    // qDebug() << "Command" << m_command << "Action" << m_action;
    if (m_action == Action::List) emit channelGroupsFinished();
}

void EPGSearch::addQuery(QString line)
{
    //    qDebug() << "EPGSearch::addQuery" << line;
    EpgSearchQuery q(line) ;
    //    qDebug() << "EPGSearchQuery" << q;
    if (q.searchID >=0) m_epgSearchQuery.append(q);
}

void EPGSearch::addOption(QString line)
{
    //    qDebug() << "EPGSearch::addOption" << line;
    QStringList l = line.split(":");
    if (l.count() == 2) {
        m_options.insert(l.at(0),l.at(1).trimmed());
    }
}


void EPGSearch::addExtendedEpgCategory(QString line)
{
    //    qDebug("EPGSearch::addExtendedEpgCategory");
    ExtEpgCat epgCat;
    epgCat.parseFromFile(line);
    m_extEpgCats.append(epgCat);
}

void EPGSearch::completeExtEpgCats(QList<ExtEpgCat> &extEpgCats)
{
    for (int i=0; i < extEpgCats.count(); ++i) {
        ExtEpgCat e = extEpgCats.at(i);
        int index = m_extEpgCats.indexOf(e);
        if (index != -1) {
            e.setName(m_extEpgCats.at(index).name());
            e.setCategory(m_extEpgCats.at(index).category());
            e.setFormat(m_extEpgCats.at(index).format());
            extEpgCats.replace(i,e);
        }
    }
}

int EPGSearch::getBlacklistID(QString s)
{
    //Rückgabe: "blacklist 'asdf' (with new ID 1) added"
    //Rückgabe: blacklist 'asdf' with ID 14 modified"
    //Rückgabe: blacklist id x deleted

    qDebug() << "getBlacklistID" << s;
    static QRegularExpression re("ID(\\s*)(\\d+)", QRegularExpression::CaseInsensitiveOption);
    QRegularExpressionMatch match = re.match(s);
    if (match.hasMatch()) {
        QString m = match.captured(2);
        bool ok;
        int i = m.toInt(&ok);
        if (ok) return i;
    }
    return -1;
}

int EPGSearch::getSearchID(QString s)
{
    //Rückgabe: search 'xyz' with 52 modified"
    //Rückgabe: search id 53 deleted
    //Rückgabe: search 'asdf' (with new ID 53) added

    qDebug() << "getSearchID" << s;
    static QRegularExpression re("\\s\\d+");
    QRegularExpressionMatch match = re.match(s);
    if (match.hasMatch()) {
        QString m = match.captured().trimmed();
        bool ok;
        int i = m.toInt(&ok);
        if (ok) return i;
    }
    return -1;
}

void EPGSearch::finishUpdate(QString line)
{
    qDebug("EPGSearch::finishUpdate");
    //Rückgabe: update triggered
    if (line == "update triggered") emit updateFinished();
}

void EPGSearch::addConflict(QString line)
{
    qDebug("EPGSearch::addConflict");
    QStringList conflicts = line.split(":");
    //Ersten Eintrag verwerfen (Zeitangabe)
    conflicts.removeFirst();

    for (int i=0; i < conflicts.count(); ++i) {
        //id|zeit|id0#id1#...
        QString s = conflicts.at(i);
        QStringList timers = s.split("|");

        bool ok;
        int id = timers.at(0).toInt(&ok);
        if (ok && !m_conflicts.contains(id)) m_conflicts.append(id);
        //weitere betroffene Timer
        s = timers.at(2);
        timers = s.split("#");
        for (int k=0; k < timers.count(); ++k) {
            id = timers.at(k).toInt(&ok);
            if (ok && !m_conflicts.contains(id)) m_conflicts.append(id);
        }
    }
}

void EPGSearch::setConnections()
{
    qDebug("EPGSearch::setConnections()");

    // connect(this, &EPGSearch::directoriesFinished, this, &EPGSearch::slotTest);

    connect(this, &EPGSearch::searchFinished, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::searchAdded, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::searchChanged, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::searchDeleted, this, &SVDRP::sendQuit);

    connect(this, &EPGSearch::blacklistsFinished, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::blacklistChanged, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::blacklistAdded, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::blacklistDeleted, this, &SVDRP::sendQuit);

    connect(this, &EPGSearch::channelGroupsFinished, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::channelGroupAdded, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::channelGroupEdited, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::channelGroupRenamed, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::channelGroupDeleted, this, &SVDRP::sendQuit);

    connect(this, &EPGSearch::queryFinished, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::updateFinished, this, &SVDRP::sendQuit);
    connect(this, &EPGSearch::conflictsFinished, this, &SVDRP::sendQuit);
}

void EPGSearch::deleteConnections()
{
    // disconnect(this, &EPGSearch::directoriesFinished, this, &EPGSearch::slotTest);

    disconnect(this, &EPGSearch::searchFinished, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::searchAdded, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::searchChanged, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::searchDeleted, this, &SVDRP::sendQuit);

    disconnect(this, &EPGSearch::blacklistsFinished, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::blacklistChanged, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::blacklistAdded, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::blacklistDeleted, this, &SVDRP::sendQuit);

    disconnect(this, &EPGSearch::channelGroupsFinished, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::channelGroupAdded, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::channelGroupEdited, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::channelGroupRenamed, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::channelGroupDeleted, this, &SVDRP::sendQuit);

    disconnect(this, &EPGSearch::queryFinished, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::updateFinished, this, &SVDRP::sendQuit);
    disconnect(this, &EPGSearch::conflictsFinished, this, &SVDRP::sendQuit);
}

void EPGSearch::slotAllLists()
{
    //    qDebug("EPGSearch::slotAllLists()");
    //Reihenfolge der Abfrage ist einzuhalten!
    switch (m_queryListCommand) {
    case QueryLists::DIR:
        disconnect(this, &EPGSearch::directoriesFinished, this, &EPGSearch::slotAllLists);
        getAllLists(QueryLists::BLACK);
        break;
    case QueryLists::BLACK:
        disconnect(this, &EPGSearch::blacklistsFinished, this, &EPGSearch::slotAllLists);
        getAllLists(QueryLists::GROUP);
        break;
    case QueryLists::GROUP:
        disconnect(this, &EPGSearch::channelGroupsFinished, this, &EPGSearch::slotAllLists);
        getAllLists(QueryLists::EPG);
        break;
    case QueryLists::EPG:
        disconnect(this, &EPGSearch::extEpgCatFinished, this, &EPGSearch::slotAllLists);
        getAllLists(QueryLists::OPTIONS);
        break;
    case QueryLists::OPTIONS:
        disconnect(this, &EPGSearch::optionsFinished, this, &EPGSearch::slotAllLists);
        emit allListsFinished();
        sendQuit();
        setConnections();
    }
}

void EPGSearch::readyRead()
{
    //    qDebug("EPGSearch::readyRead()");

    while (m_tcpSocket.canReadLine()) {
        QString s = m_tcpSocket.readLine();
        //                qDebug() << "Line:" << s;

        SVDRPParser line(s);

        // qDebug() << "EPGSearch code:" << line.code() << "Message:" << line.message() << "lastline:" << line.lastLine();

        if (line.isErrorCode() || line.code() > 900) {
            QString error = QString("%1: %2").arg(line.code()).arg(line.message());

            //Spezialfall von 901: Keine Ergebnisse -> keine Fehlermeldung
            if (line.code() == 901 && line.lastLine()) {
                qDebug() << "EPGSearch::readyRead 901" << line.message();
                switch (m_command) {
                case Commands::LSTS: if (line.message().startsWith("no searches defined")) finishSearch(); break;
                case Commands::LSTB: if (line.message().startsWith("no blacklists defined")) finishBlacklist(); break;
                case Commands::LSTC: if (line.message().startsWith("no channel groups defined")) emit channelGroupsFinished(); break;
                case Commands::QRYF:
                case Commands::QRYS: if (line.message().startsWith("no results")) emit queryFinished(); break;
                case Commands::LSRD: if (line.message().startsWith("no recording directories found")) emit directoriesFinished(); break;
                case Commands::LSTE: if (line.message().startsWith("no EPG categories defined")) emit extEpgCatFinished(); break;
                case Commands::LSCC: if (line.message().startsWith("no conflicts found")) emit conflictsFinished(false); break;
                default: emit svdrpError(error);
                }
            }
            else {
                emit svdrpError(error);
                return;
            }
        }

        if (line.code() == 900) {
            switch (m_command) {
            case Commands::LSRD: addDirectory(line.message()); break;

            case Commands::LSTS: addSearch(line.message()); break;
            case Commands::NEWS: break;
            case Commands::EDIS: break;
            case Commands::DELS: break;
            case Commands::MODS: break;

            case Commands::LSTB: addBlacklist(line.message()); break;
            case Commands::NEWB: break;
            case Commands::EDIB: break;
            case Commands::DELB: break;

            case Commands::LSTC: addChannelGroup(line.message()); break;
            case Commands::NEWC: break;
            case Commands::EDIC: break;
            case Commands::DELC: break;
            case Commands::RENC: break;

            case Commands::QRYS: addQuery(line.message()); break;
            case Commands::QRYF: addQuery(line.message()); break;

            case Commands::LSTE: addExtendedEpgCategory(line.message()); break;
            case Commands::LSCC: addConflict(line.message()); break;

            case Commands::SETP: addOption(line.message()); break;
            case Commands::UPDS: qDebug("UPDS"); break;
            }

            if (line.lastLine()) {
                //                qDebug() << "EPGSearch: readyRead Ende" << m_command;
                switch (m_command) {
                case Commands::LSRD:
                    if (!m_directories.isEmpty()) m_directories.prepend("<kein Verzeichnis>"); //Leerer Eintrag als Erstes
                    emit directoriesFinished();
                    break;
                case Commands::LSTS: finishSearch(); break;
                case Commands::NEWS: newSearch(line.message()); break;
                case Commands::EDIS: editSearch(line.message()); break;
                case Commands::DELS: deleteSearch(line.message()); break;

                case Commands::MODS: editSearch(line.message()); break; //Toggle entspricht einem Edit

                case Commands::LSTB: finishBlacklist(); break;
                case Commands::NEWB: newBlacklist(line.message()); break;
                case Commands::EDIB: editBlacklist(line.message()); break;
                case Commands::DELB: deleteBlacklist(line.message()); break;

                case Commands::LSTC: finishChannelGroup(); break;
                case Commands::NEWC: newChannelGroup(line.message()); break;
                case Commands::EDIC: editChannelGroup(line.message()); break;
                case Commands::RENC: renameChannelGroup(line.message()); break;
                case Commands::DELC: deleteChannelGroup(line.message()); break;

                case Commands::LSTE: emit extEpgCatFinished(); break;
                case Commands::LSCC: emit conflictsFinished(!m_conflicts.empty()); break;

                case Commands::QRYS: emit queryFinished(); break;
                case Commands::QRYF: emit queryFinished(); break;

                case Commands::SETP: emit optionsFinished(); break;
                case Commands::UPDS: finishUpdate(line.message()); break;
                }
            }
        }                
    }
}
