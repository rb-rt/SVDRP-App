import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models

import assets 1.0
import components 1.0
import dialogs 1.0
import controls 1.0
import vdr.models 1.0
import vdr.epgsearch 1.0
import "labels"
import "icons"
import "subviews"
import "transitions"

Page {

    id: root

    property var ids: []
    property var searchTimer //QVariantMap

    property ChannelModel channelModel
    property EPGSearch epgsearch
    property TimerModel timerModel

    property alias headerLabel: headerLabel.text

    //Favoritensuche
    property bool isFavoritesSearch: false
    property int hours: Style.favoritesHours

    header: ToolBar {
        id: header

        background: Loader { sourceComponent: Style.headerBackground }

        GridLayout {
            columns: 3
            anchors.fill: parent
            rowSpacing: 0

            ToolButtonHeader {
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
                    text: isFavoritesSearch ? "Suchtimer Favoritensuche bis " + Style.favoritesHours + " Stunden" : "Unbekannt"
                    font.pointSize: Style.pointSizeHeader
                    font.weight: Style.fontweightHeader
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
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
                    id: checkBoxFile
                    text: qsTr("Dateiname")
                    font.pointSize: Style.pointSizeHeaderSmall
                    checked: Style.showFilename
                }
            }
        }
    }//Header

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

    EpgSearchQueryModel {
        id: queryModel
        epgsearch: root.epgsearch
        channelModel: root.channelModel
        timerModel: root.timerModel
        onEventFinished: function(event) {
            pageStack.push("qrc:/views/subviews/EventDetailsView.qml", {event:event})
        }
        onError: {
            console.log("EpgSearchPage.qml EpgSearchQueryModel onError")
            busyIndicator.close()
            errorDialog.errorText = error
            errorDialog.open()
        }
        onSearchtimerCreated: {
            console.log("EpgSearchPage.qml onSearchtimerCreated")
            msgDialog.titleText = qsTr("Suchtimer angelegt")
            msgDialog.text = qsTr("Suchtimer wurde erfolgreich angelegt")
            msgDialog.open()
        }
        onModelAboutToBeReset: {
            console.log("EpgSearchPage.qml onModelAboutToBeReset")
            busyIndicator.open()
        }
        onModelReset: {
            console.log("EpgSearchPage.qml onModelReset")
            busyIndicator.close()
        }
        Component.onCompleted: {
            if (isFavoritesSearch) {
                queryModel.queryFavorites(root.hours)
            }
            else if (root.searchTimer) {
                queryModel.querySettings(root.searchTimer)
            }
            else if (ids.length > 0) {
                queryModel.queryIds(ids)
            }
        }
    }

    // property int channelIconWidth: Math.ceil(tm.advanceWidth)
    property int channelIconWidth: Math.ceil(tm.advanceWidth) * 4
    TextMetrics {
        id: tm
        font.pointSize: Style.pointSizeStandard
        font.bold: true
        text: "7"
    }

    ListView {
        model: queryModel
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}

        EmptyListLabel {
            text: "Keine Ergebnisse vorhanden"
            visible: parent.count === 0
        }

        delegate: Rectangle {
            width: ListView.view.width
            height: columnEvent.height
            gradient: Style.gradientList

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard

                //Kanallogo
                ChannelIcon {
                    id: channelRectangle
                    Layout.minimumWidth: root.channelIconWidth
                    Layout.preferredHeight: columnEvent.height
                    text: model.channelnr
                    // active: true
                    // onIconClicked: pageStack.push("qrc:/views/EventListPage.qml",
                    //                                  { channelModel:root.channelModel,
                    //                                      timerModel:root.timerModel,
                    //                                      epgsearch: root.epgsearch,
                    //                                      channelID: model.query.channel })
                }
            Rectangle {
                Layout.fillWidth: true
                color: "transparent"
                Layout.preferredHeight: columnEvent.height

                ColumnLayout {
                    id: columnEvent
                    spacing: 0
                    anchors.left: parent.left
                    anchors.right: parent.right

                    LabelSubtitle {
                        text: model.channel + "  " + model.time
                        Layout.topMargin: 5
                        Layout.preferredWidth: parent.width
                        visible: Style.showChannelTitle
                    }

                    LabelTitle {
                        text: model.query.title
                        Layout.preferredWidth: parent.width
                    }

                    LabelSubtitle {
                        text: model.query.subtitle
                        Layout.preferredWidth: parent.width
                        visible: checkBoxSubtitle.checked
                    }
                    LabelDescription {
                        text: model.query.timerFile
                        Layout.preferredWidth: parent.width
                        visible: checkBoxFile.checked
                    }
                    Rectangle {
                        Layout.preferredWidth: parent.width
                        Layout.bottomMargin: 5
                    }
                }
                MouseArea {
                    width: parent.width
                    height: parent.height
                    hoverEnabled: true
                    onClicked: queryModel.getEvent(model.query)
                }
            }

            //Icons
            ExclamationLabel {
                visible: Style.showTimerGap && model.timerGap
                Layout.preferredHeight: columnEvent.height
            }

            Label {
                id: timerIcon
                text: Style.iconTimer
                font.pointSize: Style.pointSizeListIcon
                Layout.preferredHeight: columnEvent.height
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                leftPadding: Style.listIconPadding
                rightPadding: Style.listIconPadding

                //flag = 0,1,2 (von EPGearchQuery), hinzugefügt 3 (Timer aktiv), 4 (Timer inaktiv), 5 (Recording)
                state: model.flag

                states: [
                    State {
                        name: "0"
                        PropertyChanges {
                            target: timerIcon
                            color: Style.colorListIconStandard
                            font.family: Style.faRegular
                        }
                    },
                    State {
                        name: "1"
                        PropertyChanges {
                            target: timerIcon
                            color: Style.colorListIconActive
                            font.family: Style.faRegular
                        }
                    },
                    State {
                        name: "2"
                        PropertyChanges {
                            target: timerIcon
                            color: Style.colorListIconSearch
                            font.family: Style.faRegular
                        }
                    },
                    State {
                        name: "3"
                        PropertyChanges {
                            target: timerIcon
                            color: Style.colorListIconActive
                            font.family: Style.faSolid
                        }
                    },
                    State {
                        name: "4"
                        PropertyChanges {
                            target: timerIcon
                            color: Style.colorListIconInactive
                            font.family: Style.faSolid
                        }
                    },
                    State {
                        name: "5"
                        PropertyChanges {
                            target: timerIcon
                            color: Style.colorListIconRecording
                            font.family: Style.faSolid
                        }
                    }
                ]

                background: Rectangle { gradient: Style.gradientList }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: timerIcon.background.gradient = Style.gradientListHover
                    onExited: timerIcon.background.gradient = Style.gradientList
                    onClicked: {
                        var e = JSON.parse(JSON.stringify(model.query))
                        switch (e.timerFlag) {
                        case 0:
                            var t = query2Timer(e)
                            timerEditView = pageStack.push("qrc:/views/subviews/TimerEditView.qml", {
                                                               timer:t,
                                                               headerTitle: "Neuen Timer anlegen",
                                                               channelModel: root.channelModel,
                                                               directories: root.epgsearch.directories })
                            break
                        case 1:
                        case 3:
                        case 4:
                            t = JSON.parse(JSON.stringify(queryModel.getTimer(e.timerId)))
                            var h = "Timer bearbeiten"
                            if (t.id === -1) {
                                h = "Unbekannter Timer"
                                t = query2Timer(e)
                            }
                            timerEditView = pageStack.push("qrc:/views/subviews/TimerEditView.qml", {
                                                               timer:t,
                                                               headerTitle: h,
                                                               channelModel: root.channelModel,
                                                               directories: root.epgsearch.directories })
                            break
                        case 2:
                            msgDialog.titleText = "Timer"
                            msgDialog.text = "Timer für nächstes Update geplant"
                            msgDialog.open()
                            break
                        }
                    }
                }
            }

            DeleteIcon {
                Layout.preferredHeight: columnEvent.height
                enabled: model.flag > 2
                onIconClicked: {
                    var e = JSON.parse(JSON.stringify(model.query))
                    var t = JSON.parse(JSON.stringify(queryModel.getTimer(e.timerId)))
                    if (t.id !== -1) {
                        confirmDeleteMsgBox.text = model.query.title
                        confirmDeleteMsgBox.id = t.id
                        confirmDeleteMsgBox.open()
                    }
                }
            }
        }
    }

    section.property: "start"
    section.criteria: ViewSection.FullString
    section.delegate: sectionHeading

    populate: ListViewPopulate{}

}//ListView

Component {
    id: sectionHeading
    Rectangle {
        id: sectionRec
        width: ListView.view.width
        height: childrenRect.height
        gradient: Style.gradientTageswechsel

        required property string section
        onSectionChanged: sectionAnimation.start()

        Label {
            // text: Qt.formatDate(Date.fromLocaleDateString(locale,parent.section,"dd.MM.yyyy"),"dddd, dd.MM.yyyy")
            text: parent.section
            font.pointSize: Style.pointSizeSmall
            padding: 5
            leftPadding: 10
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("Section",section, Date.fromLocaleDateString(locale,section,"dd.MM.yyyy"))
                console.log(Qt.formatDate(Date.fromLocaleDateString(locale,section,"dd.MM.yyyy"),"dddd, dd.MM.yyyy"))
            }
        }
        ListViewSectionAnimation {
            id: sectionAnimation
            target: sectionRec
        }
    }
}

footer: ToolBar {
    background: Loader { sourceComponent: Style.footerBackground }
    height: 48
    CommandBar {
        anchors.right: parent.right
        anchors.rightMargin: 10
        commandList: ObjectModel {
            CommandButton {
                iconCharacter: Style.iconQuestion
                description: "Legende"
                fontSolid: false
                onCommandButtonClicked: legendPopup.open()
            }
        }
    }
}

//Erzeugt aus einem EPGSearchQuery einen Timer
function query2Timer(query) {
    //        for(var p in query) console.log("query2Timer query:",p ,"Wert:",query[p])
    var t = JSON.parse(JSON.stringify(root.timerModel.getTimer()))
    t.filename = query.title
    t.channel = query.channel
    var start = new Date((query.eventStart - Style.marginStart * 60) * 1000)
    var stop = new Date((query.eventStop + Style.marginStop * 60) * 1000)
    t.day = start
    t.start = start.toLocaleTimeString(locale, "hh:mm")
    t.stop = stop.toLocaleTimeString(locale, "hh:mm")
    t.priority = Style.priority
    t.lifetime = Style.lifetime
    return t
}

MyMessageDialog {
    id: msgDialog
    simple: true
}
MyMessageDialog {
    id: confirmDeleteMsgBox
    property int id: -1
    titleText: "Timer löschen?"
    onAccepted: {
        if (id !== -1) timerModel.deleteTimer(id)
    }
}
ErrorDialog {
    id: errorDialog
    title: "Fehler bei der Abfrage"
}
Popup {
    id: legendPopup
    modal: true
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.max(parent.width / 2, refRow.width + leftPadding + rightPadding)
    // closePolicy: Popup.CloseOnEscape || Popup.CloseOnPressOutside || Popup.CloseOnPressOutsideParent

    ColumnLayout {
        width: parent.width //- parent.leftPadding - parent.rightPadding
        Label {
            text: "Bedeutung der Icons"
            font.pointSize: Style.pointSizeLarge
        }
        //[0]
        RowLayout {
            Layout.topMargin: 10
            Label {
                text: Style.iconTimer
                font.pointSize: Style.pointSizeListIcon
                font.family: Style.faRegular
                color: Style.colorListIconStandard
            }
            Label {
                text: "Kein Timer vorhanden"
            }
        }
        //{1]
        RowLayout {
            Label {
                text: Style.iconTimer
                font.pointSize: Style.pointSizeListIcon
                font.family: Style.faRegular
                color: Style.colorListIconActive
            }
            Label {
                text: "Timer vorhanden"
            }
        }
        // [2]
        RowLayout {
            id: refRow
            Label {
                text: Style.iconTimer
                font.pointSize: Style.pointSizeListIcon
                font.family: Style.faRegular
                color: Style.colorListIconSearch
            }
            Label {
                id: refLabel
                text: "Timer für nächstes Update geplant"
            }
        }
        Label {
            text: "Die drei Icons zeigen Statusmeldungen vom Plugin <i>epgsearch</i>. Ein gefundener Timer existiert auf dem VDR, konnte aber in der eigenen Timerliste nicht gefunden werden. Eine Ursache sind meist Zeitdifferenzen."
            Layout.minimumWidth: refLabel.width
            Layout.preferredWidth: parent.width
            wrapMode: Text.WordWrap
            font.pointSize: Style.pointSizeSmall
        }

        // [3]
        RowLayout {
            Layout.topMargin: 10
            Label {
                text: Style.iconTimer
                font.pointSize: Style.pointSizeListIcon
                font.family: Style.faSolid
                color: Style.colorListIconActive
            }
            Label {
                text: "Timer gefunden und aktiv"
            }
        }
        // [4]
        RowLayout {
            Label {
                text: Style.iconTimer
                font.pointSize: Style.pointSizeListIcon
                font.family: Style.faSolid
                color: Style.colorListIconInactive
            }
            Label {
                text: "Timer gefunden, aber inaktiv"
            }
        }
        // [5]
        RowLayout {
            Label {
                text: Style.iconTimer
                font.pointSize: Style.pointSizeListIcon
                font.family: Style.faSolid
                color: Style.colorListIconRecording
            }
            Label {
                text: "Timer zeichnet gerade auf"
            }
        }
        Label {
            text: "Der Timer wurde in der eigenen Timerliste gefunden und kann hier direkt bearbeitet werden."
            Layout.minimumWidth: refLabel.width
            Layout.preferredWidth: parent.width
            wrapMode: Text.WordWrap
            font.pointSize: Style.pointSizeSmall
        }
    }

}

BusyIndicatorPopup {
    id: busyIndicator
}

}


