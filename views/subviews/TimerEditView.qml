import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import components 1.0
import dialogs 1.0
import controls 1.0 as MyControls

Page {
    property var timer
    signal saveTimer()
    signal deleteTimer()

    property alias headerTitle: headerLabel.text
    property alias channelModel: channelComboBox.channelModel
    property alias directories: dirBox.model

    id: root

    property string filename: ""
    property string directory: ""

    function timerPath() {
        if (directory.length === 0) {
            return filename
        }
        else {
            return directory + "~" + filename
        }
    }

    property string start: timer.start //"20:15"
    property string stop: timer.stop
    property date selectedDate: timer.hasFirstDate ? timer.firstDate : timer.day
    property string weekdays: timer.weekdays
    property bool repeatTimer: weekdays !== "-------" //   timer.repeatTimer

    onWeekdaysChanged: console.log("root onWeekdaysChanged",weekdays)
    onRepeatTimerChanged: console.log("onRepeatTimerChanged",repeatTimer)
    onStartChanged: console.log("root onStartTimeChanged",start)
    onStopChanged: console.log("root onStopTimeChanged",stop)
    onSelectedDateChanged: {
        console.log("root onSelectedDateChanged",selectedDate)
        // for (var prop in timer) console.log("prop:",prop,"item:",timer[prop])
    }
    onTimerChanged: {
        // for (var prop in timer) console.log("prop:",prop,"item:",timer[prop])
        // var datum = new Date(timer.startEpoch * 1000)
        // console.log(datum)
    }

    Component.onCompleted: {
        console.log("TimerEditView onCompleted")

        var arr = timer.filename.split("~")
        //Keine Verzeichnis im Dateinamen
        if (arr.length === 1) {
            root.filename = timer.filename
        }
        else {
            root.filename = arr.pop()
            root.directory = arr.join("~")
            dirBox.setDirectory(root.directory)
        }
    }

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader { }

            Label {
                text: Style.iconTimer
                font.pointSize: Style.pointSizeHeaderIcon
                font.family: Style.faRegular
            }
            Label {
                id: headerLabel
                font.pointSize: Style.pointSizeHeader
                Layout.alignment: Qt.AlignCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.leftMargin: 10
            }
        }
    }

    ScrollView {
        id: scrollView
        anchors.fill: parent
        anchors {
            leftMargin: 10
            rightMargin: 0
            topMargin: 5
            bottomMargin: 5
        }
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true
        contentWidth: parent.width - 25 //ScrollBar abziehen

        GridLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 25
            columns: 2

            Label {
                text: "Aktiv:"
                font.pointSize: Style.pointSizeStandard
            }
            RowLayout {
                Layout.fillWidth: true

                CheckBox {
                    id: timerActive
                    checked: timer.active
                    onToggled: {
                        // checked ? timer.flags = timer.flags | 1 : timer.flags = timer.flags &~ 1
                        timer.active = checked
                    }
                }
                Label {
                    text: timer.isSearchtimer ? "Suchtimer <i>" + timer.searchtimer + "</i>" : ""
                    font.pointSize: Style.pointSizeStandard
                    visible: text !== ""
                    elide: Text.ElideRight
                    Layout.preferredWidth: filenameLabel.width - timerActive.width
                }
            }

            Label {
                text: "Kanal:"
                font.pointSize: Style.pointSizeStandard
            }
            ChannelComboBox {
                id: channelComboBox
                selectedChannel: timer.channel
                Layout.fillWidth: true
                onSelectedChannelChanged: timer.channel = selectedChannel
            }

            // ComboBox {
            //     id: channelComboBox
            //     textRole: "channelnrname"
            //     Layout.fillWidth: true
            // }

            Label {
                text: "Titel:"
                font.pointSize: Style.pointSizeStandard
            }
            MyControls.LineInput {
                id: timerTitle
                placeholderText: "..."
                text: root.filename
                Layout.fillWidth: true
                onTextChanged: root.filename = text
            }

            Label {
                text: "Verzeichnis:"
                font.pointSize: Style.pointSizeStandard
            }
            MyControls.ComboBoxAuto {
                id: dirBox
                displayText: if (count === 0)  "keine Verzeichnisse"
                enabled: count !== 0
                function setDirectory(dir) {
                    var i = find(dir, Qt.MatchExactly | Qt.MatchCaseSensitive)
                    if (i !== dirBox.currentIndex) dirBox.currentIndex = i
                }
                onActivated: root.directory = textAt(currentIndex)
                Layout.fillWidth: true
            }

            Label {
                text: "Dateiname:"
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                id: filenameLabel
                text: root.timerPath()
                font.pointSize: Style.pointSizeStandard
                font.italic: true
                elide: Text.ElideMiddle
                Layout.preferredWidth: scrollView.width - vpsLabel.width - 20
                onTextChanged: function(text) { timer.filename= text }
            }

            Label {
                text: repeatTimer ? "Erster Tag:" : "Tag:"
                font.pointSize: Style.pointSizeStandard
                enabled: repeatTimer ? repeatCheckBox.checked : true
                Layout.topMargin: 20
            }
            RowLayout {
                Layout.topMargin: 20
                spacing: 0
                DateComponent {
                    datum: selectedDate
                    enabled: repeatTimer ? repeatCheckBox.checked : true
                }
                CheckBox {
                    id: repeatCheckBox
                    font.pointSize: Style.pointSizeStandard
                    visible: repeatTimer
                    checked: timer.hasFirstDate
                    Layout.leftMargin: 12
                }
                Label {
                    text: "Startdatum setzen"
                    font.pointSize: Style.pointSizeStandard
                    elide: Text.ElideRight
                    visible: repeatTimer
                    Layout.fillWidth: true
                }
            }

            Label {
                text: "Wochentag:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 20
            }

            TimerWeekdays {
                id: weekdaysBox
                weekdays: root.weekdays // "-------"
                Layout.fillWidth: true
                Layout.topMargin: 20
                onWeekdaysChanged: {
                    console.log("Weekdays",weekdaysBox.weekdays)
                    root.weekdays  = weekdaysBox.weekdays
                }
            }

            Label {
                text: "Anfang:"
                font.pointSize: Style.pointSizeStandard
                Layout.topMargin: 20
            }

            MyControls.TimeSpinBox {
                time: start
                Layout.topMargin: 20
                onTimeChanged: {
                    console.log("onTimeChanged", time)
                    root.start = time
                    timer.start = time
                }
            }
            Label {
                text: "Ende:"
                font.pointSize: Style.pointSizeStandard
                // Layout.topMargin: 20
            }
            MyControls.TimeSpinBox {
                time: stop
                onTimeChanged: {
                    console.log("TimerEditView onTimeChanged", time)
                    stop = time
                    timer.stop = time
                }
            }

            Label {
                id: vpsLabel
                text: "VPS verwenden:"
                font.pointSize: Style.pointSizeStandard
                Layout.topMargin: 20
            }
            CheckBox {
                id: timerVps
                Layout.topMargin: 20
                checked: timer.vps
                onToggled: {
                    timer.vps = checked
                }
            }
            Label {
                text: "Priorität:"
                font.pointSize: Style.pointSizeStandard
                Layout.topMargin: 20
            }
            RowLayout {
                MyControls.SpinBox {
                    id: timerPriority
                    to: 99
                    stepSize: 1
                    Layout.topMargin: 20
                    editable: true
                    value: timer.priority
                    onValueChanged: timer.priority = value
                }
            }

            Label {
                text: "Lebensdauer:"
                font.pointSize: Style.pointSizeStandard
            }
            RowLayout {
                MyControls.SpinBox {
                    id: timerLifetime
                    to: 99
                    stepSize: 1
                    editable: true
                    value: timer.lifetime
                    onValueChanged: timer.lifetime = value
                }
            }
        }
    }

    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }

        MyControls.CommandBar {
            id: commandBar
            anchors.right: parent.right
            commandList: ObjectModel {
                MyControls.CommandButton {
                    id: deleteButton
                    iconCharacter: Style.iconTrash
                    description: "Löschen"
                    visible: timer.id > 0
                    onCommandButtonClicked: {
                        confirmDeleteMsgBox.text = timerTitle.text
                        confirmDeleteMsgBox.open()
                    }
                }
                MyControls.CommandButton {
                    id: saveButton
                    iconCharacter: Style.iconSave
                    description: "Speichern"
                    onCommandButtonClicked: {
                        console.log("TimerEditView Speichern saveButton")
                        timer.hasFirstDate = repeatCheckBox.checked
                        if (repeatCheckBox.checked) timer.firstDate = selectedDate
                        timer.weekdays = root.weekdays
                                               // for (var prop in timer) console.log("prop:",prop,"item:",timer[prop])
                        saveTimer()
                    }
                    enabled: timerTitle.text.trim().length > 0
                    opacity: enabled ? 1.0 : 0.5
                }
            }
        }
    }

    component DateComponent: RowLayout {
        property date datum
        spacing: 10
        Label {
            text: datum.toLocaleDateString(locale,"ddd, dd.MM.yyyy")
            font.pointSize: Style.pointSizeStandard
        }
        Label {
            text: Style.iconCalender
            font.pointSize: Style.pointSizeDialogIcon
            font.family: Style.faRegular
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    dateDlg.datum = selectedDate
                    dateDlg.open()
                }
            }
        }
    }

    CalendarDlg {
        id: dateDlg
        onApplied: {
            selectedDate = datum
            timer.day = datum
        }
    }


    SimpleMessageDialog {
        id: confirmDeleteMsgBox
        titleText: "Timer löschen?"
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: deleteTimer()
    }
}
