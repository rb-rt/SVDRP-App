import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models

import assets 1.0
import dialogs 1.0
import vdr.models 1.0
import vdr.epgsearch 1.0
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

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader { }

            ColumnLayout {
                spacing: 0
                Layout.topMargin: 5
                Layout.bottomMargin: 5

                RowLayout {

                    Label {
                        text: Style.iconTimer
                        font.pointSize: Style.pointSizeHeaderIcon
                        font.family: Style.faRegular
                        Layout.alignment: Qt.AlignCenter
                        Layout.leftMargin: 5
                        Layout.rightMargin: 10
                    }
                    Label {
                        id: headerLabel
                        text: conflictButton.checked ? "Timerkonflikte" : "Timerliste"
                        font.pointSize: Style.pointSizeHeader
                        font.weight: Style.fontweightHeader
                        Layout.alignment: Qt.AlignCenter
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
                RowLayout {
                    CheckBox {
                        id: checkBoxSubtitle
                        font.pointSize: Style.pointSizeHeaderSmall
                        text: "Untertitel"
                        checked: Style.showEventSubtitle
                    }
                    CheckBox {
                        id: checkBoxFilename
                        font.pointSize: Style.pointSizeHeaderSmall
                        text: "Dateiname"
                        checked: Style.showFilename
                    }
                    CheckBox {
                        id: checkBoxSearchtimer
                        font.pointSize: Style.pointSizeHeaderSmall
                        text: "Suchtimer"
                    }
                }
            }
        }
    }

    Connections {
        target: timerModel
        //Verhindert ein "zu schnelles klicken (Reload)"
        function onModelAboutToBeReset() {
            console.log("TimerListPage.qml onModelAboutToBeReset")
            commandBar.enabled = false
        }
        function onModelReset() {
            console.log("TimerListPage.qml onModelReset")
            commandBar.enabled = true
        }
        function onTimersFinished() {
            console.log("TimerListPage.qml onTimersFinished")
            now = new Date()
        }
    }

    Connections {
        target: epgsearch
        function onConflictsFinished(found) {
            console.log("TimerListpage.qml onConflictsFinished",found)
            conflictButton.visible = found
        }
    }

    property TimerEditView  timerEditView
    Connections {
        target: timerEditView
        function onSaveTimer() {
            if (timerEditView.timer.id > 0) {
                timerModel.updateTimer(timerEditView.timer) //timer muss ein Javascipt-Object sein -> QVariantMap
            }
            else {
                timerModel.createTimer(timerEditView.timer)
            }
            pageStack.pop()
        }
        function onDeleteTimer() {
            timerModel.deleteTimer(timerEditView.timer.id)
            pageStack.pop()
        }
    }

    TimerSFProxyModel {
        id: timerSFProxyModel
        sourceModel: timerModel
        epgsearch: root.epgsearch
    }

    ListView {
        id: timerListView
        model: timerSFProxyModel
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}
        delegate: timerDelegate

        populate: ListViewPopulate {}
        displaced: ListViewDisplaced {}
        add: Transition { NumberAnimation { properties: "x,y"; duration: 800; easing.type: Easing.OutBounce } }
        addDisplaced: Transition { NumberAnimation { properties: "x,y"; duration: 400 } }

        MyControls.EmptyListLabel {
            text: "Keine Timer vorhanden."
            visible: parent.count === 0
        }

        section.property: "section"
        section.criteria: ViewSection.FullString
        section.delegate: sectionHeading
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

            Label {
                text: parent.section
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

    property int channelIconWidth: Math.ceil(tm.advanceWidth) * Math.floor( Math.log10(channelModel.rowCount()) + 2)
    property date now: new Date()

    TextMetrics {
        id: tm
        font.pointSize: Style.pointSizeStandard
        font.bold: true
        text: "7"
    }

    property int margin: (Style.showChannelTitle || checkBoxFilename.checked ||
                          checkBoxSearchtimer.checked || checkBoxSubtitle.checked) ? 5 : 10

    Component {
        id: timerDelegate

        Rectangle {

            id: recTarget
            property var tt: model.timer

            width: ListView.view.width
            height: columnEvent.height
            gradient: Style.gradientList
            enabled: now < model.stop

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard

                //Kanallogo
                ChannelIcon {
                    id: channelRectangle
                    Layout.minimumWidth: root.channelIconWidth
                    Layout.preferredHeight: columnEvent.height
                    fontSizeMode: Text.HorizontalFit
                    text: tt.channelnr
                    active: true
                    onIconClicked: {
                        pageStack.replace("qrc:/views/EventListPage.qml",
                                          { channelModel:root.channelModel,
                                              timerModel:root.timerModel,
                                              epgsearch: root.epgsearch,
                                              channelID: tt.channel })
                    }
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
                            Layout.bottomMargin: root.margin
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: model.hasEvent
                        onClicked: pageStack.push("qrc:/views/subviews/EventDetailsView.qml", {event:model.event})
                    }
                }

                //Icons
                ExclamationLabel {
                    id: exclamationLabel
                    visible: Style.showTimerGap && model.timerGap
                    Layout.preferredHeight: columnEvent.height
                    onIconClicked: {
                        timeDiffDlg.timerTime = tt.start
                        timeDiffDlg.eventTime = Qt.formatTime(model.event.startDateTime,"hh:mm")
                        timeDiffDlg.open()
                    }
                }

                CheckIcon {
                    id: toggleIcon
                    isSearchtimer: tt.isSearchtimer
                    visible: !Style.showIndicatorIcon
                    Layout.preferredHeight: columnEvent.height
                    state: tt.active ? (tt.recording ? "recording" : "active") : ""
                    onIconClicked: timerModel.toggleTimer(tt.id)
                }
                EditIcon {
                    id: editIcon
                    visible: toggleIcon.visible
                    Layout.preferredHeight: columnEvent.height
                    onIconClicked: {
                        var timer = JSON.parse(JSON.stringify(tt))
                        var header = "Timer bearbeiten"
                        if (timer.id > 0 ) {
                            header = "Timer <i>" + model.eventtitle + "</i> bearbeiten"
                        }
                        timerEditView = pageStack.push("qrc:/views/subviews/TimerEditView.qml", {
                                                           timer:timer,
                                                           headerTitle: header,
                                                           channelModel: root.channelModel,
                                                           directories: root.epgsearch.directories })
                    }
                }
                DeleteIcon {
                    id: deleteIcon
                    visible: toggleIcon.visible
                    Layout.preferredHeight: columnEvent.height
                    onIconClicked: {
                        var timer = tt
                        var event = model.event
                        confirmDeleteMsgBox.timer = timer
                        confirmDeleteMsgBox.text = event.title
                        //                        confirmDeleteMsgBox.informativeText = event.subtitle
                        confirmDeleteMsgBox.open()
                    }
                }
                IndicatorIcon {
                    id: indicatorIcon
                    visible: Style.showIndicatorIcon
                    Layout.preferredHeight: columnEvent.height
                    state: tt.active ? (tt.recording ? "recording" : "active") : ""
                    onIconClicked: {
                        contextMenu.timer = tt
                        contextMenu.event = model.event
                        contextMenu.popup(indicatorIcon)
                    }
                }
            }
        }
    }

    component EventColumn: ColumnLayout {
        spacing: 2
        width: parent.width
        LabelSubtitle {
            text: model.channelnrname + "  " + model.time
            Layout.preferredWidth: parent.width
            visible: Style.showChannelTitle
        }
        LabelTitle {
            text: model.eventtitle
            Layout.preferredWidth: parent.width
        }
        LabelSubtitle {
            text: model.eventsubtitle
            visible: checkBoxSubtitle.checked
            Layout.preferredWidth: parent.width
        }
        LabelDescription {
            text: tt.filename
            visible: checkBoxFilename.checked
            Layout.preferredWidth: parent.width
        }
        LabelSubtitle {
            text: "Wochentag: " + model.weekdays + (tt.hasFirstDate ? "  (ab " + Qt.locale().toString(tt.firstDate,"ddd, dd.MM.yyyy") + ")" : "")
            visible: tt.repeatTimer
            Layout.preferredWidth: parent.width
        }
        LabelSubtitle {
            text: "Suchtimer: " + tt.searchtimer
            visible: checkBoxSearchtimer.checked && tt.isSearchtimer
            Layout.preferredWidth: parent.width
        }
    }

    Menu {
        id: contextMenu

        property var timer //als Timer
        property var event //Event()

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
            iconCharacter: contextMenu.timer ? (contextMenu.timer.isSearchtimer ? Style.iconCalenderCheck : Style.iconCheck) : ""
            iconColor: contextMenu.timer ? (contextMenu.timer.active ? Style.colorListIconStandard : Style.colorListIconActive) : "yellow"
            iconFont: contextMenu.timer ? (contextMenu.timer.isSearchtimer ? Style.faRegular : Style.faSolid) : Style.faSolid
            description: contextMenu.timer ? (contextMenu.timer.active ? "Deaktivieren" : "Aktivieren") : ""
            onMenuItemClicked: {
                if (contextMenu.timer) {
                    contextMenu.close()
                    timerModel.toggleTimer(contextMenu.timer.id)
                }
            }
        }

        MyControls.ContextMenuItem {
            iconCharacter: Style.iconEdit
            iconColor: Style.colorListIconEdit
            iconFont: Style.faSolid
            description: qsTr("Bearbeiten")
            onMenuItemClicked: {
                if (contextMenu.timer) {
                    contextMenu.close()
                    var timer = JSON.parse(JSON.stringify(contextMenu.timer)) //.toVariantMap()
                    var header = "Timer bearbeiten"
                    if (contextMenu.timer.id > 0) {
                        header = "Timer <i>" + contextMenu.event.title + "</i> bearbeiten"
                    }
                    timerEditView = pageStack.push("qrc:/views/subviews/TimerEditView.qml", {
                                                       timer:timer,
                                                       headerTitle: header,
                                                       channelModel: root.channelModel,
                                                       directories: root.epgsearch.directories })

                }
            }
        }

        MyControls.ContextMenuItem {
            iconCharacter: Style.iconTrash
            iconColor: Style.colorListIconDelete
            iconFont: Style.faRegular
            description: qsTr("Löschen")
            onMenuItemClicked: {
                if (contextMenu.timer) {
                    contextMenu.close()
                    confirmDeleteMsgBox.timer = contextMenu.timer
                    confirmDeleteMsgBox.text = contextMenu.event.title
                    //                    confirmDeleteMsgBox.informativeText = contextMenu.event.subtitle
                    confirmDeleteMsgBox.open()
                }
            }
        }
    }

    footer: ToolBar {

        background: Loader { sourceComponent: Style.footerBackground }

        MyControls.CommandBar {
            id: commandBar

            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 1

            commandList: ObjectModel {
                CheckBox {
                    id: conflictButton
                    Layout.rightMargin: 20
                    visible: false
                    text: "Konflikte"
                    checked: timerSFProxyModel.filterConflicts
                    onCheckedChanged: {
                        console.log("onCheckedChanged",checked)
                        timerSFProxyModel.filterConflicts = checked
                    }
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconRedo
                    description: "Aktualisieren" // "Refresh"
                    onCommandButtonClicked: timerModel.getTimers()
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconCalenderPlus
                    description: "Neu"
                    onCommandButtonClicked: {
                        var t = JSON.parse(JSON.stringify(timerModel.getTimer()))
                        timerEditView = pageStack.push("qrc:/views/subviews/TimerEditView.qml", {
                                                           timer:t,
                                                           headerTitle: "Neuen Timer anlegen",
                                                           channelModel: root.channelModel,
                                                           directories: root.epgsearch.directories })
                    }
                }
            }
        }
    }


    MyMessageDialog {
        id: confirmDeleteMsgBox
        property var timer //Timer()
        titleText: "Timer löschen?"
        onAccepted: {
            if (timer) {
                timerModel.deleteTimer(timer.id)
            }
            else {
                console.log("Timer nicht vorhanden")
            }
        }
    }
    MyMessageDialog {
        id: timeDiffDlg
        property string timerTime
        property string eventTime
        titleText: "Zeitunterschied festgestellt"
        text: "Anfangszeiten von Timer und Ereignis stimmen nicht überein.\nTimer:\t" + timerTime
              + "\nEreignis:\t" + eventTime
              + "\nVorlauf:\t" + Style.marginStart + " min."
        simple: true
    }
}
