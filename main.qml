import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import vdr.models 1.0
import vdr.checkconfig 1.0
import vdr.epgsearch 1.0
import assets 1.0
import dialogs 1.0
import components 1.0
import controls 1.0
import models 1.0


ApplicationWindow {
    id: app

    width: Style.widthWindow
    height: Style.heightWindow
    // width: 1024
    // height: 400
    visible: true
    title: qsTr("Stack")

    readonly property alias pageStack: stackView
    readonly property alias startTimes: startTimesModel

    onClosing: function(close) {
        if (stackView.depth > 1) {
            stackView.pop()
            close.accepted = false
        }
    }

    property url streamUrl

    VdrModel {
        id:vdrModel
        Component.onCompleted: {
            console.log("main.qml VDRListModel onCompleted",currentUrl)
            logModel.addMessage("Lese aktuellen VDR")
            readCurrentHost()
        }
        onCurrentIndexChanged: {
            console.log("main.qml VDRModel onCurrentIndexChanged",currentIndex, "url", currentUrl,"stream", streamUrl)
            if (!logViewActive) {
                console.log("LogView nicht aktiv")
                stackView.replace(logView)
            }
            if (currentIndex === -1) {
                stackView.replace("qrc:/views/SettingsPage.qml", { channelModel:channelModel, vdrModel:vdrModel })
                errorDialog.titleText = "Keinen VDR gefunden"
                errorDialog.text = "Bitte zuerst einen neuen VDR anlegen."
                errorDialog.open()
            }
            else {
                checkConfig.url = currentUrl
                app.streamUrl = streamUrl
            }
        }
    }

    CheckConfig {
        id: checkConfig
        onUrlChanged: {
            console.log("CheckConfig onUrlchanged",url)
            var u = new URL(url)
            logModel.clear()
            logModel.addMessage("Prüfe VDR <b>" + u.host +"</b>")
            // checkConfig.checkVdr()
        }
        onCheckConfigFinished: {
            console.log("main.qml CheckConfig onCheckConfigFinished",url)
            // logModel.addMessage("CheckConfig onCheckConfigFinished")
            channelModel.url = url
        }
        onStatusChanged: function(status) {
            logModel.addMessage("CheckConfig Status: " + status)
        }
        onVdrErrorOccured: function(error) {
            console.log("main.qml CheckConfig onErrorOccured",error)
            logModel.addMessage("CheckConfig Error: " + error)
        }
    }

    // property int startStep: 0 //Wird hochgezählt
    property bool startOk: false
    onStartOkChanged: {
        console.log("main.qml onStartOkChanged",startOk)
        if (startOk) {
            logModel.addMessage("Programmstart erfolgreich")

            switch(Style.firstView) {
            case 0:
                stackView.replace("qrc:/views/EventListPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch, streamUrl: app.streamUrl })
                break;
            case 1:
                stackView.replace("qrc:/views/TimerListPage.qml", {timerModel: timerModel, channelModel: channelModel, epgsearch: epgsearch })
                break
            case 2:
                stackView.replace("qrc:/views/SearchtimerListPage.qml", { channelModel:channelModel, epgsearch: epgsearch, timerModel:timerModel})
                break;
            case 3:
                stackView.replace("qrc:/views/RecordListPage.qml", { url: channelModel.url, streamUrl: app.streamUrl})
                break
            case 4:
                stackView.replace("qrc:/views/RemoteControlPage.qml")
                break
            case 5:
                stackView.replace("qrc:/views/ChannelListPage.qml", { channelModel:channelModel,  epgsearch: epgsearch, timerModel: timerModel, streamUrl: app.streamUrl })
                break
            case 6:
                logView.keepOpen = true
                break
            }
            if (Style.firstView != 6) logModel.clear()
        }
    }

    ChannelModel {
        id: channelModel
        Component.onCompleted:{ console.log("main.qml ChannelModel.onCompleted",channelModel)
        }
        onUrlChanged: {
            console.log("main.qml ChannelModel onUrlChanged:", url)
            var u = new URL(url)
            logModel.addMessage("Hole Kanäle von " + u.host)
            getChannels()
        }
        onChannelsFinished: {
            console.log("main.qml onChannelsFinished")
            var d = new Date()
            logModel.addMessage("Kanäle erfolgreich empfangen")
            epgsearch.url = url
        }
        onError: {
            console.log("main.qml Fehler",error)
            logModel.addMessage("Fehler Kanalliste")
        }
    }

    EPGSearch {
        id: epgsearch
        // url: channelModel.url
        onUrlChanged: {
            console.log("EPGSearch onUrlChanged")
            logModel.addMessage("EPGSearch hole Listen")
            epgsearch.svdrpGetAllLists()
        }
        onDirectoriesFinished: logModel.addMessage("EPGSearch Verzeichnisse empfangen")
        onBlacklistsFinished: logModel.addMessage("EPGSearch Ausschlußlisten empfangen")
        onChannelGroupsFinished: logModel.addMessage("EPGSearch Kanalgruppen empfangen")
        onExtEpgCatFinished: logModel.addMessage("EPGSearch erweiterte EPG Kategorien empfangen")
        onOptionsFinished: logModel.addMessage("EPGSearch onOptionsFinished")

        onAllListsFinished: {
            console.log("EPGSearch onAllListsFinished getTimers url",timerModel.url)
            // timerModel.getTimers()
            logModel.addMessage("EPGSearch Ende")
            timerModel.url = url
            // startOk = true
        }
        onSvdrpError: {
            console.log("main.qml EPGSearch onSvdrpError", error)
            logModel.addMessage("Plugin EPGSearch: " + error)
        }
    }

    TimerModel {
        id: timerModel
        // url: channelModel.url
        channelModel: channelModel
        onUrlChanged: {
            console.log("main.qml TimerModel onUrlChanged",url)
            logModel.addMessage("Hole Timer")
            getTimers()
        }
        onError: function(error) {
            console.log("main.qml onError", error)
            logModel.addMessage("Fehler Timerliste:" + error)
            startOk = true
        }
        onTimersFinished: {
            console.log("TimerModel onTimersFinished")
            logModel.addMessage("Timer empfangen")
            startOk = true
        }
    }

    TextMetrics {
        id: textMetrics
        text: "Ausschlußlisten"
        font.pointSize: Style.pointSizeStandard
    }

    ListModel {
        id: drawerModel
        ListElement {icon: ""; family:""; left: 0; text:"Programm"; command: function() { stackView.replace("qrc:/views/EventListPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch, streamUrl: app.streamUrl })}}
        ListElement {icon: ""; family:""; left: 0; text:"Timer"; command: function() { stackView.replace("qrc:/views/TimerListPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch })}}
        ListElement {icon: ""; family:""; left: 0; text:"Suchtimer"; command: function() { stackView.replace("qrc:/views/SearchtimerListPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch })}}
        ListElement {icon: ""; family:""; left: 50; text:"Kanalgruppen"; command: function() { stackView.replace("qrc:/views/ChannelGroupsPage.qml", {channelModel:channelModel, epgsearch:epgsearch })}}
        ListElement {icon: ""; family:""; left: 50; text:"Ausschlußlisten"; command: function() { stackView.replace("qrc:/views/BlacklistPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch })}}
        ListElement {icon: ""; family:""; left: 50; text:"Favoritensuche"; command: function() { stackView.replace("qrc:/views/EpgSearchQueryPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch, isFavoritesSearch:true })}}
        ListElement {icon: ""; family:""; left: 0; text:"Aufnahmen"; command: function() { stackView.replace("qrc:/views/RecordListPage.qml", {url:channelModel.url, streamUrl:app.streamUrl, epgsearch:epgsearch })}}
        ListElement {icon: ""; family:""; left: 0; text:"Fernbedienung"; command: function() { stackView.replace("qrc:/views/RemoteControlPage.qml")}}
        ListElement {icon: ""; family:""; left: 0; text:"Kanäle"; command: function() { stackView.replace("qrc:/views/ChannelListPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch, streamUrl:app.streamUrl })}}
        ListElement {icon: ""; family:""; left: 0; text:"Einstellungen"; command: function() { stackView.replace("qrc:/views/SettingsPage.qml", {channelModel:channelModel, vdrModel:vdrModel })}}
        ListElement {icon: ""; family:""; left: 0; text:"Test"; command: function() { stackView.replace("qrc:/views/TestPage.qml")}}
        Component.onCompleted: {
            setProperty(0,"icon", Style.iconClock)
            setProperty(0,"family", Style.faRegular)
            setProperty(1,"icon", Style.iconTimer)
            setProperty(1,"family", Style.faRegular)
            setProperty(2,"icon", Style.iconCalenderAlt)
            setProperty(2,"family", Style.faSolid)
            setProperty(6,"icon", Style.iconDatabase)
            setProperty(6,"family", Style.faSolid)
            setProperty(7,"icon", Style.iconWifi)
            setProperty(7,"family", Style.faSolid)
            setProperty(8,"icon", Style.iconChannel)
            setProperty(8,"family", Style.faSolid)
            setProperty(9,"icon", Style.iconSettings)
            setProperty(9,"family", Style.faSolid)
        }
    }

    Drawer {
        id: drawer
        //        width: app.width * 0.5
        width: textMetrics.width + 2 * 50
        height: app.height
        enabled: startOk

        ListView {
            id: listView
            currentIndex: -1
            focus: true
            anchors.fill: parent
            model: drawerModel
            ScrollIndicator.vertical: ScrollIndicator { }
            delegate: ItemDelegate {
                width: parent.width
                leftPadding: model.left === 0 ? leftPadding : model.left
                highlighted: ListView.isCurrentItem
                contentItem: RowLayout {
                    Label {
                        text: model.icon
                        font.family: model.family
                    }
                    Label {
                        text: model.text
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    drawer.close()
                    model.command()
                    ListView.view.currentIndex = index
                }
            }
        }

/*
        Column {
            anchors.fill: parent

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconClock
                        font.family: Style.faRegular
                    }
                    Label {
                        text: qsTr("Programm")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    console.log("main.qml EventListpage",timerModel)
                    drawer.close()
                    stackView.replace("qrc:/views/EventListPage.qml", {channelModel:channelModel, timerModel: timerModel, epgsearch:epgsearch, streamUrl: app.streamUrl })
                }
            }

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconTimer
                        font.family: Style.faRegular
                    }
                    Label {
                        text: qsTr("Timer")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    console.log("main.qml Drawer Timer",timerModel)
                    //                    timerModel.getTimers()
                    drawer.close()
                    stackView.replace("qrc:/views/TimerListPage.qml", {
                                          timerModel: timerModel,
                                          channelModel: channelModel,
                                          epgsearch: epgsearch
                                      })
                }
            }

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconCalenderAlt
                        font.family: Style.faSolid
                    }
                    Label {
                        text:qsTr("Suchtimer")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    drawer.close()
                    stackView.replace("qrc:/views/SearchtimerListPage.qml", {
                                          channelModel:channelModel,
                                          epgsearch: epgsearch,
                                          timerModel:timerModel})
                    //                    stackView.replace("SearchtimerListPage.qml")
                }
            }

            ItemDelegate {
                text: qsTr("Kanalgruppen")
                leftPadding: 50
                width: parent.width
                font.pointSize: Style.pointSizeStandard
                onClicked: {
                    console.log("main.qml Kanalgruppen",channelModel, epgsearch)
                    stackView.replace("qrc:/views/ChannelGroupsPage.qml", { channelModel:channelModel,  epgsearch: epgsearch})
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Ausschlußlisten")
                leftPadding: 50
                width: parent.width
                font.pointSize: Style.pointSizeStandard
                onClicked: {
                    console.log("main.qml Ausschlußlisten",channelModel, epgsearch)
                    stackView.replace("qrc:/views/BlacklistPage.qml", { channelModel:channelModel,  epgsearch: epgsearch, timerModel: timerModel})
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Favoritensuche")
                leftPadding: 50
                width: parent.width
                font.pointSize: Style.pointSizeStandard
                onClicked: {
                    stackView.replace("qrc:/views/EpgSearchPage.qml", {
                                          channelModel:channelModel,
                                          epgsearch: epgsearch,
                                          timerModel: timerModel,
                                          isFavoritesSearch: true
                                      })
                    drawer.close()
                }
            }

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconDatabase
                        font.family: Style.faSolid
                    }
                    Label {
                        text: qsTr("Aufnahmen")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    drawer.close()
                    stackView.replace("qrc:/views/RecordListPage.qml", { url: channelModel.url, streamUrl: app.streamUrl})
                }
            }

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconWifi
                        font.family: Style.faSolid
                    }
                    Label {
                        text: qsTr("Fernbedienung")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    stackView.replace("qrc:/views/RemoteControlPage.qml")
                    drawer.close()
                }
            }

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconChannel
                        font.family: Style.faSolid
                    }
                    Label {
                        text: qsTr("Kanäle")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    drawer.close()
                    stackView.replace("qrc:/views/ChannelListPage.qml", { channelModel:channelModel,  epgsearch: epgsearch, timerModel: timerModel, streamUrl: app.streamUrl })
                }
            }

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconSettings
                        font.family: Style.faSolid
                    }
                    Label {
                        text: qsTr("Einstellungen")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    stackView.replace("qrc:/views/SettingsPage.qml", { channelModel:channelModel, vdrModel:vdrModel })
                    drawer.close()
                }
            }

            ItemDelegate {
                width: parent.width
                contentItem: RowLayout {
                    Label {
                        text: Style.iconSettings
                        font.family: Style.faSolid
                    }
                    Label {
                        text: qsTr("Test")
                        Layout.fillWidth: true
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                onClicked: {
                    // stackView.replace("qrc:/prefix1/views/TestPage.qml")
                    // stackView.replace("qrc:/views/TestPage.qml")
                    ScrollIndicator.vertical: ScrollIndicator { }
                    // stackView.replace(logView)
                    drawer.close()
                }
            }

        }

    */
    }

    // property int dauer: 3000

    StackView {
        id: stackView
        // initialItem: "qrc:/dialogs/TestGridView.qml" // "qrc:/views/RemoteForm.qml"
        // initialItem: "qrc:/views/RemoteControlPage.qml"
        initialItem: logView
        anchors.fill: parent
    }

    LogModel {
        id: logModel
    }

    property bool logViewActive: false

    LogView {
        id: logView
        logs: logModel
        StackView.onActivated: {
            console.log("LogView activated")
            // logModel.clear()
            logModel.addMessage("LogView StackView Activated")
            logViewActive = true
        }
        StackView.onDeactivated: console.log("LogView deactivated")
        StackView.onRemoved: {
            console.log("LogView removed")
            logViewActive = false
            // logModel.clear()
        }
        onCanceled: {
            checkConfig.cancel()
            stackView.replace("qrc:/views/SettingsPage.qml", { channelModel:channelModel, vdrModel:vdrModel })
        }
    }

    StartTimesModel {
        id: startTimesModel
    }

    // SimpleMessageDialog {
    //     id: errorDialog
    //     titleText: "TitleText"
    //     text: "text"
    // }

    Component.onCompleted: {
        console.log("ApplicationWindow",width,height)

    }
}
