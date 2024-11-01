import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models

import assets 1.0
import components 1.0
import vdr.models 1.0
import vdr.epgsearch 1.0
import dialogs 1.0
import controls 1.0 as MyControls
import "labels"
import "icons"
import "subviews"
import "transitions"

Page {

    id: root

    property TimerModel timerModel
    property ChannelModel channelModel
    property EPGSearch epgsearch

    property url streamUrl
    property bool streamingAvailable: streamUrl.toString() !== ""

    property bool isSearchView: eventModel.schedule === EventModel.Program //Ansicht Tagesansicht (true)

    //Wenn gesetzt, werden die Events vom Kanal abgerufen
    //Wird von TimerListPage und ChannelListPage benutzt
    property string channelID: ""

    property var jniPlayer

    header: ToolBar {
        id: header

        background: Loader { sourceComponent: Style.headerBackground }

        GridLayout {
            columns: 3
            anchors.fill: parent
            rowSpacing: 0

            MyControls.ToolButtonHeader {
                Layout.rowSpan: 2
                Layout.row: 0
                Layout.column: 0
            }

            RowLayout {
                Layout.row: 0
                Layout.column: 1
                Layout.leftMargin: 5
                Layout.topMargin: 5
                Layout.alignment: Qt.AlignTop
                Label {
                    id: headerIcon
                    text: Style.iconClock
                    font.pointSize: Style.pointSizeHeaderIcon
                    font.weight: Font.Bold
                    font.family: Style.faRegular
                }
                Label {
                    id: headerLabel
                    text: "Unbekannt"
                    font.pointSize: Style.pointSizeHeader
                    font.weight: Style.fontweightHeader
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }

            ToolButton {
                id: channelsButton
                background: Rectangle {
                    id: bkg
                    anchors.fill: parent
                    gradient: Style.gradientListToolButton
                    radius: 4
                    border.width: 2
                    border.color: Qt.lighter(Style.colorPrimary)
                    states: State {
                        when: channelsButton.down
                        PropertyChanges {
                            target: bkg
                            gradient: Style.gradientList
                            border.color: Qt.darker(Style.colorPrimary, 1.2)
                        }
                        PropertyChanges {
                            target: channelsButton
                            scale: 1.2
                        }
                    }
                }
                text: Style.iconChannel
                font.family: Style.faSolid
                font.pointSize: Style.pointSizeHeaderIcon
                Layout.row: 0
                Layout.column: 2
                Layout.rightMargin: 10
                Layout.rowSpan: 2
                Layout.preferredHeight: parent.height - 16
                Layout.preferredWidth: height
                onClicked: drawerChannels.open()
            }

            RowLayout {
                Layout.column: 1
                Layout.row: 1
                CheckBox {
                    id: checkBoxSubtitle
                    font.pointSize: Style.pointSizeHeaderSmall
                    text: qsTr("Untertitel")
                    checked: Style.showEventSubtitle
                }
                CheckBox {
                    id: showEventDescription
                    text: qsTr("Details")
                    font.pointSize: Style.pointSizeHeaderSmall
                    checked: Style.showEventDescription
                }
                CheckBox {
                    id: filterCheckBox
                    text: qsTr("Ohne EPG")
                    font.pointSize: Style.pointSizeHeaderSmall
                    visible: !isSearchView
                    checked: false
                }
                CheckBox {
                    id: filterEpgNow
                    text: qsTr("EPG ab jetzt")
                    font.pointSize: Style.pointSizeHeaderSmall
                    visible: isSearchView
                    checked: Style.showEpgAtNow
                }
            }
        }
    }//Header

    ChannelsDrawer {
        id: drawerChannels
        channelModel: root.channelModel
        selectedChannel: ""
        onSelectedChannelChanged: {
            startTimeComboBox.currentIndex = -1
            eventModel.getEvents(selectedChannel)
        }
    }

    EventSFProxyModel {
        id: eventsSFProxyModel
        sourceModel: eventModel
        filterEmptyEvents: !filterCheckBox.checked
        startEpgNow: filterEpgNow.checked
        toChannel: Style.toChannel
        filterCaseSensitivity: filterCaseSensitivityCheckBox.checked ? Qt.CaseSensitive : Qt.CaseInsensitive
    }

    EventModel {
        id: eventModel
        url: root.channelModel.url
        channelModel: root.channelModel
        timerModel: root.timerModel
        //        onInfoText: headerLabel.text = infotext //ab qt6 veraltet
        //        onInfoText: function(infoText) { headerLabel.text = infoText } geht auch
        onInfoText: infoText => headerLabel.text = infoText //neue Syntax
        onModelAboutToBeReset: busyIndicator.open()
        onModelReset: busyIndicator.close()

        onError: {
            console.log("EventListPage.qml Fehler",error)
            errorDialog.titleText = "Fehler Progamm"
            errorDialog.text = error
            errorDialog.open()
        }
        Component.onCompleted: {
            console.log("EventListPage.qml EventModel.Completed", channelID)
            if (channelID !== "") {
                drawerChannels.selectedChannel = channelID
            }
            else {
                eventModel.getEvents(EventModel.WhatsNow)
            }
        }
    }

    property TimerEditView timerEditView
    Connections {
        target: timerEditView
        function onSaveTimer() {
            if (timerEditView.timer.id > 0) timerModel.updateTimer(timerEditView.timer); else timerModel.createTimer(timerEditView.timer)
            pageStack.pop()
        }
        function onDeleteTimer() {
            if (timerEditView.timer.id >  0) timerModel.deleteTimer(timerEditView.timer.id)
            pageStack.pop()
        }
    }

    SearchView {
        id: searchView
        visible: false
        search: root.epgsearch.getSearch()
        channelModel: root.channelModel
        epgsearch: root.epgsearch
        timerModel: root.timerModel
    }

    property bool isOverMidnight: false
    property int startMainTime: 0
    property int endMainTime: 0
    property int channelIconWidth: Math.ceil(tm.advanceWidth) * Math.floor( Math.log10(channelModel.rowCount()) + 2)

    TextMetrics {
        id: tm
        font.pointSize: Style.pointSizeStandard
        font.bold: true
        text: "7"
    }

    ListView {
        id: eventList
        model: eventsSFProxyModel
        anchors.fill: parent
        delegate: eventDelegate
        ScrollBar.vertical: ScrollBar{}
        clip: true

        section.property: isSearchView ? "start" : "group"
        section.criteria: ViewSection.FullString
        section.delegate: isSearchView ? sectionHeading : sectionGroup
        //        section.labelPositioning: ViewSection.CurrentLabelAtStart

        MyControls.EmptyListLabel {
            text: "Keine EPG-Daten vorhanden."
            visible: parent.count === 0
        }
        populate: ListViewPopulate {}
    }

    Component {
        id: sectionGroup
        Rectangle {
            id: sectionRec
            width: ListView.view.width
            height: childrenRect.height
            gradient: Style.gradientTageswechsel

            required property string section
            onSectionChanged: sectionAnimation.start()

            Label {
                text: channelModel.getGroupName(parent.section)
                font.pointSize: Style.pointSizeSmall
                padding: 5
                leftPadding: 10
            }
            ListViewSectionAnimation {
                id: sectionAnimation
                target: sectionRec
            }
        }
    }

    Component {
        id: sectionHeading
        Rectangle {
            id: sectionRec
            width: ListView.view.width
            height: childrenRect.height
            gradient: Style.gradientTageswechsel

            required property string section

            onSectionChanged: sectionAnimation.start()

            ListViewSectionAnimation {
                id: sectionAnimation
                target: sectionRec
            }

            Label {
                text: parent.section
                font.pointSize: Style.pointSizeSmall
                padding: 5
                leftPadding: 10
            }
        }
    }

    property int margin: (Style.showChannelTitle || checkBoxSubtitle.checked) ? 5 : 10

    Component {
        id: eventDelegate

        Rectangle {
            id: delegateRectangle

            width: ListView.view.width
            height: columnEvent.height
            gradient: mainTime ? Style.gradientListMainTime : Style.gradientList

            property bool mainTime: {
                if (!Style.showMainTime || !isSearchView) return false
                var d = model.event.startDateTime
                var t =d.getHours()*60 + d.getMinutes() //+ d.getSeconds()
                if (isOverMidnight) {
                    return !( (t >= endMainTime) && (t < startMainTime) )
                }
                else {
                    return (t >= startMainTime) && (t <= endMainTime)
                }
            }

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard

                //Kanallogo
                ChannelIcon {
                    id: channelRectangle
                    Layout.preferredHeight: columnEvent.height
                    Layout.minimumWidth: root.channelIconWidth
                    text: model.channelnr
                    mainTime: delegateRectangle.mainTime
                    active: !isSearchView
                    onIconClicked: drawerChannels.selectedChannel = event.channel
                }

                //Eventspalte
                Rectangle {
                    Layout.fillWidth: true
                    color: "transparent"
                    Layout.preferredHeight: columnEvent.height

                    ColumnLayout {
                        id: columnEvent
                        anchors.left: parent.left
                        anchors.right: parent.right

                        EventColumn {
                            Layout.topMargin: root.margin
                        }

                        ProgressBar {
                            id: progressbar
                            value: (Date.now() / 1000) - model.event.starttime
                            from: 0
                            to: model.event.duration
                            visible: !isSearchView && (model.event.id > 0) && (value > from) && (value < to)
                            Layout.preferredWidth: parent.width
                            background: Rectangle {
                                id: background
                                color: Style.colorPrimary
                                implicitWidth: parent.width
                                implicitHeight: 3
                                radius: 3
                            }
                            contentItem: Item {
                                implicitWidth: parent.width
                                implicitHeight: 3
                                anchors.top: background.top

                                Rectangle {
                                    width: progressbar.visualPosition * parent.width
                                    height: 3
                                    color: Style.colorAccent
                                    radius: 3
                                }
                            }
                        }
                        Loader {
                            id: eventLoader
                            active: showEventDescription.checked
                            visible: showEventDescription.checked
                            Layout.preferredWidth: parent.width
                            sourceComponent: Label {
                                text: model.event.description
                                width: parent.width
                                wrapMode: Text.WordWrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                font.pointSize: Style.pointSizeSmall
                                font.weight: Font.Thin
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width
                            Layout.bottomMargin: root.margin
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: event.id > 0
                        onClicked: pageStack.push("qrc:/views/subviews/EventDetailsView.qml", {event:model.event})
                    }
                }

                //Icons
                TimerIcon {
                    id: timerIcon
                    visible: event.id > 0 && !Style.showIndicatorIcon
                    exists: event.timerExists
                    flags: event.timerFlags
                    Layout.preferredHeight: columnEvent.height
                    mainTime: delegateRectangle.mainTime
                    onIconClicked: {
                        var timer = JSON.parse(JSON.stringify(model.timer))
                        var headerLabel
                        if (timer.id > 0) {
                            headerLabel = "Timer <i>" + model.event.title + "</i> bearbeiten"
                        }
                        else {
                            timer = event2NewTimer(model.event)
                            headerLabel = "Neuen Timer erstellen"
                        }
                        timerEditView = pageStack.push("qrc:/views/subviews/TimerEditView.qml", {
                                                           timer:timer,
                                                           headerTitle: headerLabel,
                                                           channelModel: root.channelModel,
                                                           directories: root.epgsearch.directories })
                    }
                }
                SearchIcon {
                    id: searchIcon
                    Layout.preferredHeight: columnEvent.height
                    mainTime: delegateRectangle.mainTime
                    visible: timerIcon.visible
                    onIconClicked: {
                        var event = model.event
                        var s = event2Search(event)
                        var title = "Suche nach Wiederholungen von: <i>" + event.title + "</i>"
                        pageStack.push(searchView, { search:s, headerTitle: title })
                        //                        pageStack.push("qrc:/views/subviews/SearchView.qml", {
                        //                                           search:s,
                        //                                           headerTitle:"Suche nach Wiederholungen von: <i>" + event.title + "</i>",
                        //                                           channelModel:root.channelModel,
                        //                                           epgsearch:root.epgsearch,
                        //                                           timerModel:root.timerModel
                        //                                       })
                    }
                }
                PlayIcon {
                    id: playIcon
                    visible: timerIcon.visible
                    Layout.preferredHeight: columnEvent.height
                    mainTime: delegateRectangle.mainTime
                    onIconClicked: {
                        playContextMenu.channel = channelModel.getChannel(model.event.channel)
                        playContextMenu.popup(playIcon)
                    }
                }
                IndicatorIcon {
                    id: indicatorIcon
                    visible: event.id > 0 && Style.showIndicatorIcon
                    Layout.preferredHeight: columnEvent.height
                    mainTime: delegateRectangle.mainTime
                    state: model.event.timerExists ? (model.event.timerActive ? "active" : "inactive") : ""
                    onIconClicked: {
                        contextMenu.event = model.event
                        contextMenu.timer = model.timer
                        contextMenu.popup(indicatorIcon)
                    }
                }
            }
        }//Rectangle
    }//searchDelegate


    component EventColumn: ColumnLayout {
        spacing: 2
        width: parent.width
        LabelSubtitle {
            text: (event.id > 0) ? model.event.channelname + "  " + model.time : model.event.channelname
            Layout.preferredWidth: parent.width
            visible: Style.showChannelTitle
        }
        LabelTitle {
            text: model.event.title
            Layout.preferredWidth: parent.width
            state: event.id === -1 ? "ohneEpg" : ""
        }
        LabelSubtitle {
            text: model.event.subtitle
            Layout.preferredWidth: parent.width
            visible: checkBoxSubtitle.checked
        }
    }

    Menu {
        id: playContextMenu

        property var channel

        rightMargin: parent.width

        width: {
            var result = 0;
            var padding = 0;
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i);
                result = Math.max(item.contentItem.implicitWidth, result);
                padding = Math.max(item.padding, padding);
            }
            return result + padding * 2;
        }

        MyControls.ContextMenuItem {
            isLabel: true
            description: playContextMenu.channel ? playContextMenu.channel.name : ""
        }
        MyControls.ContextMenuItem {
            enabled: streamingAvailable
            description: qsTr("Lokale Wiedergabe")
            iconCharacter: Style.iconMobile
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayLocal
            onMenuItemClicked: {
                var u = streamUrl + "/" + playContextMenu.channel.id + ".ts"
                console.log("EventListPage.qml url",u)
                jniPlayer.playVideo(u)
            }
        }
        MyControls.ContextMenuItem {
            description: qsTr("Umschalten auf VDR")
            iconCharacter: Style.iconSwitch
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayVdr
            onMenuItemClicked: channelModel.switchToChannel(playContextMenu.channel.id)
        }
    }

    Menu {
        id: contextMenu

        property var timer:0
        property var event:0

        rightMargin: parent.width

        width: {
            var result = 0;
            var padding = 0;
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i);
                result = Math.max(item.contentItem.implicitWidth, result);
                padding = Math.max(item.padding, padding);
            }
            return result + padding * 2;
        }

        MyControls.ContextMenuItem {
            isLabel: true
            description: contextMenu.event ? contextMenu.event.title : ""
        }

        MyControls.ContextMenuItem {
            id: contextMenuItem
            enabled: contextMenu.event.id > 0
            iconCharacter: contextMenu.event ? Style.iconTimer : ""
            iconColor: "transparent"
            iconFont: contextMenu.event ? (contextMenu.event.timerExists ? Style.faSolid : Style.faRegular) : ""
            description: contextMenu.event ? (contextMenu.event.timerExists ? qsTr("Timer bearbeiten") : qsTr("Timer erstellen")) : ""
            states: [
                State {
                    when: contextMenu.event && contextMenu.event.timerExists && contextMenu.event.timerFlags === 1 // && contextMenu.event.timerActive
                    PropertyChanges {
                        target: contextMenuItem
                        iconColor: Style.colorListIconActive
                    }
                },
                State {
                    when: contextMenu.event && contextMenu.event.timerExists
                    PropertyChanges {
                        target: contextMenuItem
                        iconColor: Style.colorListIconInactive
                    }
                },
                State {
                    when: contextMenu.event
                    PropertyChanges {
                        target: contextMenuItem
                        iconColor: Style.colorListIconStandard
                    }
                }
            ]
            onMenuItemClicked: {
                var timer = JSON.parse(JSON.stringify(contextMenu.timer))
                var headerLabel
                if (timer.id > 0) {
                    headerLabel = "Timer <i>" + contextMenu.event.title + "</i> bearbeiten"
                }
                else {
                    var event = JSON.parse(JSON.stringify(contextMenu.event))
                    timer = event2NewTimer(contextMenu.event)
                    headerLabel = "Neuen Timer erstellen"
                }
                contextMenu.close()
                timerEditView = pageStack.push("qrc:/views/subviews/TimerEditView.qml", {
                                                   timer:timer,
                                                   headerTitle: headerLabel,
                                                   channelModel: root.channelModel,
                                                   directories: root.epgsearch.directories })
            }
        }

        MyControls.ContextMenuItem {
            iconCharacter: Style.iconSearch
            iconColor: Style.colorListIconSearch
            iconFont: Style.faSolid
            description: "Suchen"
            enabled: contextMenu.event.id > 0
            onMenuItemClicked: {
                if (contextMenu.event) {
                    contextMenu.close()
                    var s = event2Search(contextMenu.event)
                    var title = "Suche nach Wiederholungen von: <i>" + contextMenu.event.title + "</i>"
                    pageStack.push(searchView, { search:s, headerTitle: title })
                    //                    pageStack.push("qrc:/views/subviews/SearchView.qml", {
                    //                                       search:s,
                    //                                       headerTitle:"Suche nach Wiederholungen von: <i>" + contextMenu.event.title + "</i>",
                    //                                       channelModel:root.channelModel,
                    //                                       epgsearch:root.epgsearch,
                    //                                       timerModel:root.timerModel
                    //                                   })
                }
            }
        }
        MyControls.ContextMenuItem {
            enabled: streamingAvailable
            description: qsTr("Lokale Wiedergabe")
            iconCharacter: Style.iconMobile
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayLocal
            onMenuItemClicked: {
                var u = streamUrl + "/" + playContextMenu.channel.id + ".ts"
                console.log("EventListPage.qml url",u)
                jniPlayer.playVideo(u)
            }
        }
        MyControls.ContextMenuItem {
            description: qsTr("Umschalten auf VDR")
            iconCharacter: Style.iconSwitch
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayVdr
            onMenuItemClicked: channelModel.switchToChannel(playContextMenu.channel.id)
        }
    }

    ObjectModel {
        id: commandList

        MyControls.CommandButton {
            iconCharacter: Style.iconCalender;
            description: qsTr("Uhrzeit")
            fontSolid: false
            onCommandButtonClicked: dateTimeTumblerDlg.open()
        }
        MyControls.CommandButton {
            iconCharacter: Style.iconSearch
            description: qsTr("Suchen")
            onCommandButtonClicked: {
                var s = JSON.parse(JSON.stringify(epgsearch.readSearch()))
                var title = "Suche nach \"" + s.search +"\""
                if (s.search.length === 0) title = "Suche nach..."
                pageStack.push(searchView, { search:s, headerTitle: title })
                //                pageStack.push("qrc:/views/subviews/SearchView.qml", {
                //                                   search:s,
                //                                   headerTitle: title,
                //                                   channelModel:root.channelModel,
                //                                   epgsearch:root.epgsearch,
                //                                   timerModel:root.timerModel
                //                               })
            }
        }
        MyControls.CommandButton {
            iconCharacter: Style.iconClock;
            description: qsTr("Jetzt")
            fontSolid: true
            onCommandButtonClicked: {
                startTimeComboBox.currentIndex = -1
                drawerChannels.selectedChannel = ""
                eventModel.getEvents(EventModel.WhatsNow)
            }
        }
        MyControls.CommandButton {
            iconCharacter: Style.iconClock
            description: qsTr("Nächstes")
            fontSolid: false
            onCommandButtonClicked: {
                startTimeComboBox.currentIndex = -1
                drawerChannels.selectedChannel = ""
                eventModel.getEvents(EventModel.WhatsNext)
            }
        }
    }

    footer: ToolBar {

        background: Loader { sourceComponent: Style.footerBackground }

        height: commandBar.height

        SwipeView {
            id: swipeView

            anchors.fill: parent

            RowLayout {

                Label {
                    text: ""
                    Layout.fillWidth: true
                }
                MyControls.ComboBoxAuto {
                    id: startTimeComboBox
                    model: startTimes
                    textRole: "display"
                    currentIndex: -1
                    visible: count > 0
                    displayText: currentIndex === -1 ? qsTr("Um...") : currentText
                    Layout.rightMargin: 10
                    onActivated: {
                        var date = Date.fromLocaleTimeString(locale,currentText,"hh:mm")
                        eventModel.getEvents(date)
                    }
                }
                MyControls.CommandBar {
                    id: commandBar
                    Layout.alignment: Qt.AlignRight
                    Layout.topMargin: 1
                    commandList: commandList
                }
            }

            RowLayout {
                Label {
                    text: "Filter:"
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 10
                }
                CheckBox {
                    id: filterCaseSensitivityCheckBox
                    text: checked ? "aa" : "Aa"
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 10
                    enabled: eventsSFProxyModel.filterText.length > 0
                }
                MyControls.LineInput {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.rightMargin: 20
                    Layout.leftMargin: 10
                    placeholderText: "Textfilter..."
                    onTextChanged: eventsSFProxyModel.filterText = text
                }
            }
        }

        PageIndicator {
            id: indicator
            visible: swipeView.visible
            count: swipeView.count
            currentIndex: swipeView.currentIndex
            anchors.left: swipeView.left
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    DateTimeTumblerDlg {
        id: dateTimeTumblerDlg
        datum: new Date()
        onAccepted: {
            console.log("EventListPage.qml onAccepted")
            var t = Qt.formatTime(dateTimeTumblerDlg.datum,"hh:mm")
            var index = startTimeComboBox.find(t)
            if (index !== -1) {
                startTimeComboBox.currentIndex = index
            }
            else {
                startTimeComboBox.currentIndex = -1
            }
            drawerChannels.selectedChannel = ""
            eventModel.getEvents(dateTimeTumblerDlg.datum)
        }
    }

    Component.onCompleted: {
        console.log("EventListpage.qml onCompleted")
        var begin = Style.mainTimeFrom
        var end = Style.mainTimeTo
        startMainTime = begin.getHours()*60 + begin.getMinutes() // + begin.getSeconds()
        endMainTime = end.getHours()*60 + end.getMinutes() //+ end.getSeconds()
        isOverMidnight = endMainTime < startMainTime
        console.log("JNI_SUPPORT",JNI_SUPPORT)
        if (JNI_SUPPORT) {
            jniPlayer = Qt.createQmlObject('
                        import vdr.jniplayer 1.0;

                        JniPlayer {
                            id: jniPlayer
                            onJniError: {
                                messageDlg.text = error
                            }
                        }', root, "JniPlayer")
        }
    }

    function event2NewTimer(event) {

        var t = JSON.parse(JSON.stringify(timerModel.getTimer()))
        var datetime = event.startDateTime
        var epoch = datetime.getTime() - Style.marginStart * 60000
        var date =  new Date(epoch)
        t.start = date.toLocaleTimeString(locale, "hh:mm")
        t.day = date
        datetime = event.endDateTime
        epoch = datetime.getTime() + Style.marginStop * 60000
        date = new Date(epoch)
        t.stop = date.toLocaleTimeString(locale, "hh:mm")
        t.channel = event.channel
        t.channel_name = event.channelname
        t.filename = event.title
        t.priority = Style.priority
        t.lifetime = Style.lifetime
        return t
    }

    function event2Search(event) {
        var s = JSON.parse(JSON.stringify(epgsearch.getSearch()))
        s.search = event.title
        s.useTitle = true
        s.useSubtitle = false
        s.useDescription = false

        var datetime = event.startDateTime
        s.startTime =  Qt.formatTime(datetime,"hh:mm")
        datetime = event.endDateTime
        s.stopTime = Qt.formatTime(datetime,"hh:mm")

        s.channelMin = event.channel
        s.channelMax = event.channel
        s.durationMin = 0
        s.durationMax = event.duration / 60

        return s
    }

    MyMessageDialog {
        id: errorDialog
        simple: true
    }

    MyControls.BusyIndicatorPopup {
        id: busyIndicator
    }
}


