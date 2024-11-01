import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
//import QtQuick.Dialogs 1.3

import assets 1.0
import components 1.0
import controls 1.0 as MyControls
import vdr.models 1.0
import vdr.epgsearch 1.0


Page {
    id: root

    property var searchTimer

    signal saveSearchTimer()

    property alias headerTitle: headerLabel.text

    property ChannelModel channelModel
    property EPGSearch epgsearch

    onSearchTimerChanged: {
        console.log("SearchTimerEditView.qml onSearchTimerChanged",searchTimer)
        // for(var p in searchTimer) console.log("p",p,"Wert",searchTimer[p])
        action.currentIndex = searchTimer.searchtimerAction
        //        console.log("SearchTimer.compareCategories",searchTimer.compareCategories)
    }

    Component.onCompleted: {
        console.log("SearchTimerEditView onCompleted")

    }

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {
            }
            Label {
                text: Style.iconCalenderAlt
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

    readonly property int topAbstand: 30


    //    Rectangle {
    //        width: parent.width
    //        height: 3
    //        color: "lightgreen"
    //    }

    ExtEpgCatsCompareView {
        id: extEpgCatsCompareView
        visible: false
        defaultExtEpgCats: root.epgsearch.extEpgCats
        compareCategories: root.searchTimer.compareCategories
        onCategoriesSaved: {
            root.searchTimer.compareCategories = compareCategories
            pageStack.pop()
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
        //        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        contentWidth: parent.width - 25

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 1

            SearchViewCommon {
                id: searchViewCommon
                searchTimer: root.searchTimer
                channelModel: root.channelModel
                epgsearch: root.epgsearch
                onEmptySearch: function (empty) { saveButton.enabled = !empty }
                Layout.fillWidth: true
            }

            CheckBox {
                text: qsTr("In Favoritenmenü verwenden")
                font.pointSize: Style.pointSizeStandard
                checked: searchTimer.useInFavorites
                onToggled: searchTimer.useInFavorites = checked
                Layout.bottomMargin: 20
            }

            GridLayout {
                columns: 2
                width: parent.width

                CheckBox {
                    id: useSearchTimer
                    text: qsTr("Als Suchtimer verwenden")
                    font.pointSize: Style.pointSizeLarge
                    font.bold: true
                    checked: searchTimer.useAsSearchtimer > 0
                    Layout.columnSpan: 2
                    Layout.topMargin: 20
                    onToggled: checked ? searchTimer.useAsSearchtimer = 1 :  searchTimer.useAsSearchtimer = 0
                    //                    Layout.preferredWidth: text.length * Style.pixelSizeLarge
                    Layout.preferredWidth: implicitWidth * Style.pointSizeLarge/Style.pointSizeStandard
                }

                //----- Ab hier Suchtimer Einstellungen --------------------------------------------------

                UseSearchTimerUserDefined {
                    id: useSearchTimerUserDefined
                    userdefined: searchTimer.useAsSearchtimer
                    from: searchTimer.useAsSearchtimerFrom
                    til: searchTimer.useAsSearchtimerTil
                    Layout.columnSpan: 2
                    // Layout.fillWidth: true
                    enabled: useSearchTimer.checked
                    Layout.topMargin: topAbstand
                    onUserdefinedChanged: searchTimer.useAsSearchtimer = userdefined
                    onFromChanged: searchTimer.useAsSearchtimerFrom = from
                    onTilChanged: searchTimer.useAsSearchtimerTil = til
                }

                Label {
                    text: qsTr("Aktion:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: action.enabled ? 1.0 : 0.5
                    Layout.topMargin: topAbstand
                }
                MyControls.ComboBoxAuto {
                    id: action
                    model: [ qsTr("Aufnehmen"), qsTr("per OSD ankündigen"), qsTr("Nur umschalten"),
                        qsTr("Ankündigen und umschalten"), qsTr("per Mail ankündigen"),
                        qsTr("inaktive Aufnahme") ]
                    currentIndex: searchTimer.searchtimerAction
                    enabled: useSearchTimer.checked
                    Layout.topMargin: topAbstand
                    Layout.preferredWidth: width
                    onActivated: searchTimer.searchtimerAction = currentIndex
                }

                // --- Aktionen: Nur umschalten/Ankündigen und umschalten -------
                Label {
                    text: action.currentIndex === 2 ? qsTr("Umschalten:") : qsTr("Nachfrage:")
                    font.pointSize: Style.pointSizeStandard
                    visible: action.currentIndex === 2 || action.currentIndex === 3
                    Layout.topMargin: topAbstand
                }
                RowLayout {
                    spacing: 10
                    visible: action.currentIndex === 2 || action.currentIndex === 3
                    Layout.topMargin: topAbstand
                    MyControls.SpinBox {
                        id: switchMinBefore
                        from: 0
                        to: 99
                        value: searchTimer.switchMinBefore
                        editable: true
                        enabled: useSearchTimer.checked
                        onValueChanged: searchTimer.switchMinBefore = value
                    }
                    Label {
                        text: qsTr("Minuten vor dem Start")
                        font.pointSize: Style.pointSizeStandard
                    }
                }

                Label {
                    text: qsTr("Ton anschalten:")
                    font.pointSize: Style.pointSizeStandard
                    visible: action.currentIndex === 2 || action.currentIndex === 3
                }
                CheckBox {
                    id: unmuteSound
                    visible: action.currentIndex === 2 || action.currentIndex === 3
                    checked: searchTimer.unMuteSound
                    onToggled: searchTimer.unMuteSound = checked
                }

                //--- Aktionen: Aufnehmen/inaktive Aufnahme --------------
                Label {
                    text: qsTr("Serienaufnahme:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: useSeriesRecording.enabled ? 1.0 : 0.5
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    Layout.topMargin: topAbstand
                }
                CheckBox {
                    id: useSeriesRecording
                    checked: searchTimer.useSeriesRecording
                    enabled: useSearchTimer.checked
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    onToggled: searchTimer.useSeriesRecording = checked
                }

                Label {
                    id: verzeichnisLabel
                    text: qsTr("Verzeichnis:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: directory.enabled ? 1.0 : 0.5
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                MyControls.LineInput {
                    id: directory
                    text: searchTimer.directory
                    placeholderText: "..."
                    Layout.fillWidth: true
                    enabled: useSearchTimer.checked

                    property string displayText: textInput.displayText
                    onDisplayTextChanged: {
                        console.log("onDisplayTextChanged",displayText)
                        dirBox.setDirectory(displayText)
                        searchTimer.directory = displayText
                    }
                    Keys.onTabPressed: {
                        console.log("Key: Tab", dirBox.currentText)
                        if (dirBox.currentIndex !== 0) text = dirBox.currentText
                    }

                    //Funktioniert auf Androidgeräten nur über displayText
                    //                    onDisplayTextChanged: {
                    //                        dirBox.setDirectory(displayText)
                    //                        searchTimer.directory = displayText
                    //                    }
                    //                onTextChanged: {
                    //                    console.log("TextField text",text)
                    //                    dirBox.setDirectory(text)
                    //                }
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                // Label {
                //     text: " "
                //     font.pointSize: Style.pointSizeStandard
                //     visible: action.currentIndex === 0 || action.currentIndex === 5
                // }
                // Label {
                //     text: "Taste TAB übernimmt das Verzeichnis"
                //     font.pointSize: Style.pointSizeSmall
                //     visible: action.currentIndex === 0 || action.currentIndex === 5
                //     enabled: directory.focus && (directory.displayText !== dirBox.currentText)
                // }
                Label {
                    text: " "
                    font.pointSize: Style.pointSizeStandard
                    opacity: dirBox.enabled ? 1.0 : 0.5
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                MyControls.ComboBoxAuto {
                    id: dirBox
                    model: epgsearch.directories
                    Layout.fillWidth: true
                    enabled: useSearchTimer.checked && count !== 0
                    displayText: if (count === 0) "Keine Verzeichnisse"
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    onActivated: currentIndex === 0 ? directory.text = "" : directory.text = textAt(currentIndex)

                    function setDirectory(dir) {
                        var i = find(dir, Qt.MatchStartsWith | Qt.MatchCaseSensitive)
                        if (i !== dirBox.currentIndex) {
                            dirBox.currentIndex = i
                        }
                    }
                }

                Label {
                    text: qsTr("Aufnahme nach")
                    font.pointSize: Style.pointSizeStandard
                    opacity: delRecsAfterDays.enabled ? 1.0 : 0.5
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                RowLayout {
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    MyControls.SpinBox {
                        id: delRecsAfterDays
                        value: searchTimer.deleteRecsAfterDays
                        from: 0
                        to: 999
                        editable: true
                        enabled: useSearchTimer.checked
                        onValueChanged: searchTimer.deleteRecsAfterDays = value
                    }
                    Label {
                        text: qsTr("Tagen löschen")
                        font.pointSize: Style.pointSizeStandard
                        opacity: delRecsAfterDays.enabled ? 1.0 : 0.5
                        Layout.fillWidth: true
                    }
                }

                Label {
                    text: qsTr("Behalte")
                    font.pointSize: Style.pointSizeStandard
                    opacity: keepRecs.enabled ? 1.0 : 0.5
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                RowLayout {
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    MyControls.SpinBox {
                        id: keepRecs
                        value: searchTimer.keepRecords
                        from: 0
                        to: 999
                        editable: true
                        enabled: useSearchTimer.checked && delRecsAfterDays.value > 0
                        onValueChanged: searchTimer.keepRecords = value
                    }
                    Label {
                        text: qsTr("Aufnahmen")
                        font.pointSize: Style.pointSizeStandard
                        opacity: keepRecs.enabled ? 1.0 : 0.5
                    }
                }

                Label {
                    text: qsTr("Pause, wenn")
                    font.pointSize: Style.pointSizeStandard
                    opacity: pauseOnRecs.enabled ? 1.0 : 0.5
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                RowLayout {
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    MyControls.SpinBox {
                        id: pauseOnRecs
                        value: searchTimer.pauseOnRecords
                        from: 0
                        to: 999
                        editable: true
                        enabled: useSearchTimer.checked
                        onValueChanged: searchTimer.pauseOnRecords = value
                    }
                    Label {
                        text: qsTr("Aufnahmen existieren")
                        font.pointSize: Style.pointSizeStandard
                        opacity: pauseOnRecs.enabled ? 1.0 : 0.5
                    }
                }

                //------- Vermeide Wiederholungen -----------
                GroupBox {
                    enabled: useSearchTimer.checked
                    label: CheckBox {
                        id: avoidRepeats
                        checked: searchTimer.avoidRepeats
                        text: qsTr("Vermeide Wiederholungen")
                        onToggled: searchTimer.avoidRepeats = checked
                    }
                    font.pointSize: Style.pointSizeStandard
                    Layout.columnSpan: 2
                    Layout.topMargin: topAbstand
                    // Layout.fillWidth: true
                    visible: action.currentIndex === 0 || action.currentIndex === 5

                    GridLayout {
                        columns: 2
                        id: gridRepeat
                        enabled: avoidRepeats.checked
                        width: parent.width

                        Label {
                            text: qsTr("Erlaubte Wiederholungen:")
                            font.pointSize: Style.pointSizeStandard
                            opacity: gridRepeat.enabled ? 1.0 : 0.5
                        }
                        RowLayout {
                            MyControls.SpinBox {
                                id: allowedRepeats
                                value: searchTimer.allowedRepeats
                                to: 99
                                stepSize: 1
                                editable: true
                                onValueChanged: searchTimer.allowedRepeats = value
                            }
                        }

                        Label {
                            text: qsTr("Nur Wiederholung innerhalb von")
                            font.pointSize: Style.pointSizeStandard
                            opacity: repeatsWithinDays.enabled ? 1.0 : 0.5
                        }
                        RowLayout {
                            spacing: 10
                            MyControls.SpinBox {
                                id: repeatsWithinDays
                                from: 0
                                to: 999
                                editable: true
                                value: searchTimer.repeatsWithinDays
                                enabled: allowedRepeats.value > 0
                                onValueChanged: searchTimer.repeatsWithinDays = value
                                //                            opacity: enabled ? 1.0 : 0.5
                            }
                            Label {
                                text: qsTr("Tagen")
                                font.pointSize: Style.pointSizeStandard
                                opacity: repeatsWithinDays.enabled ? 1.0 : 0.5
                            }
                        }
                        Label {
                            text: qsTr("Vergleiche Titel:")
                            font.pointSize: Style.pointSizeStandard
                            opacity: gridRepeat.enabled ? 1.0 : 0.5
                        }
                        CheckBox {
                            id: compareTitle
                            checked: searchTimer.compareTitle
                            onToggled: searchTimer.compareTitle = checked
                        }
                        Label {
                            text: qsTr("Vergleiche Untertitel:")
                            font.pointSize: Style.pointSizeStandard
                            opacity: gridRepeat.enabled ? 1.0 : 0.5
                        }
                        CheckBox {
                            id: compareSubtitle
                            checked: searchTimer.compareSubtitle === 1
                            text: checked ? "wenn vorhanden" : ""
                            onToggled: checked ? searchTimer.compareSubtitle = 1 : searchTimer.compareSubtitle = 0
                        }
                        Label {
                            text: qsTr("Vergleiche Beschreibung:")
                            font.pointSize: Style.pointSizeStandard
                            opacity: gridRepeat.enabled ? 1.0 : 0.5
                        }
                        CheckBox {
                            id: compareSummary
                            checked: searchTimer.compareDescription
                            onToggled: searchTimer.compareDescription = checked
                        }
                        Label {
                            text: qsTr("Minimale Übereinstimmung in %:")
                            font.pointSize: Style.pointSizeStandard
                            opacity: summaryMatch.enabled ? 1.0 : 0.5
                        }
                        RowLayout {
                            MyControls.SpinBox {
                                id: summaryMatch
                                value: searchTimer.compareMatch
                                enabled: compareSummary.checked
                                from: 1
                                to: 99
                                stepSize: 1
                                editable: true
                                onValueChanged: searchTimer.compareMatch = value
                            }
                        }
                        Label {
                            text: qsTr("Vergleiche Zeitpunkt:")
                            font.pointSize: Style.pointSizeStandard
                            opacity: gridRepeat.enabled ? 1.0 : 0.5
                        }
                        MyControls.ComboBoxAuto {
                            id: compareTime
                            model: [qsTr("nein"),qsTr("gleicher Tag"),qsTr("gleiche Woche"),qsTr("gleicher Monat")]
                            currentIndex: searchTimer.compareDate
                            Layout.preferredWidth: width
                            onCurrentIndexChanged: searchTimer.compareTime = currentIndex
                        }
                        Label {
                            text: qsTr("Vergleiche Kategorien:")
                            font.pointSize: Style.pointSizeStandard
                            opacity: gridRepeat.enabled ? 1.0 : 0.5
                        }
                        Label {
                            text: Style.iconEdit
                            font {
                                family: Style.faRegular
                                pointSize: Style.pointSizeDialogIcon
                            }
                            color: extEpgCatsCompareView.compareCategories === 0 ? Style.colorForeground : Style.colorAccent
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var header = "Vergleiche Kategorien von <i>" + searchTimer.search + "</i>"
                                    pageStack.push(extEpgCatsCompareView, { headerLabel: header, compareCategories: searchTimer.compareCategories })
                                }
                            }
                        }
                    }
                }//GroupBox Vermeide Wiederholungen

                Label {
                    text: qsTr("Priorität:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: priority.enabled ? 1.0 : 0.5
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                RowLayout {
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    MyControls.SpinBox {
                        id: priority
                        value: searchTimer.priority
                        enabled: useSearchTimer.checked
                        Layout.topMargin: topAbstand
                        to: 99
                        stepSize: 1
                        editable: true
                        onValueChanged: searchTimer.priority = value
                    }
                }
                Label {
                    text: qsTr("Lebensdauer:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: lifetime.enabled ? 1.0 : 0.5
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                RowLayout {
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    MyControls.SpinBox {
                        id: lifetime
                        value: searchTimer.lifetime
                        enabled: useSearchTimer.checked
                        to: 99
                        stepSize: 1
                        editable: true
                        onValueChanged: searchTimer.lifetime = value
                    }
                }
                Label {
                    text: qsTr("Timer-Beginn:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: marginStart.enabled ? 1.0 : 0.5
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                RowLayout {
                    spacing: 10
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    MyControls.SpinBox {
                        id: marginStart
                        from: 0
                        to: 99
                        editable: true
                        value: searchTimer.marginStart
                        onValueChanged: searchTimer.marginStart = value
                        enabled: useSearchTimer.checked
                        Layout.preferredWidth: Math.max(marginStart.width,marginStop.width)
                    }
                    Label {
                        text: qsTr("Minuten Vorlauf")
                        font.pointSize: Style.pointSizeStandard
                        opacity: marginStart.enabled ? 1.0 : 0.5
                    }
                }
                Label {
                    text: qsTr("Timer-Ende:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: marginStop.enabled ? 1.0 : 0.5
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                RowLayout {
                    spacing: 10
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    MyControls.SpinBox {
                        id: marginStop
                        from: 0
                        to: 99
                        editable: true
                        value: searchTimer.marginStop
                        onValueChanged: searchTimer.marginStop = value
                        enabled: useSearchTimer.checked
                        Layout.preferredWidth: Math.max(marginStart.width,marginStop.width)
                    }
                    Label {
                        text: qsTr("Minuten Nachlauf")
                        font.pointSize: Style.pointSizeStandard
                        opacity: marginStop.enabled ? 1.0 : 0.5
                    }
                }
                Label {
                    text: qsTr("VPS verwenden:")
                    font.pointSize: Style.pointSizeStandard
                    opacity: useVps.enabled ? 1.0 : 0.5
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                CheckBox {
                    id: useVps
                    checked: searchTimer.useVps
                    enabled: useSearchTimer.checked
                    Layout.topMargin: topAbstand
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    onToggled: searchTimer.useVps = checked
                }

                Label {
                    text: qsTr("automatisch löschen:")
                    font.pointSize: Style.pointSizeStandard
                    //                opacity: useVps.enabled ? 1.0 : 0.5
                    wrapMode: Text.WordWrap
                    Layout.topMargin: topAbstand
                    //                Layout.preferredWidth: ausschusslistenLabel.width
                    enabled: useSearchTimer.checked
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }
                MyControls.ComboBoxAuto {
                    id: delMode
                    model: [qsTr("nein"),qsTr("Anzahl Aufnahmen"),qsTr("Anzahl Tage")]
                    Layout.topMargin: topAbstand
                    Layout.preferredWidth: width
                    Layout.alignment: Qt.AlignTop
                    enabled: useSearchTimer.checked
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                    currentIndex: searchTimer.deleteMode
                    onActivated: searchTimer.deleteMode = currentIndex
                }
                Label {
                    text: " "
                    font.pointSize: Style.pointSizeStandard
                    visible: action.currentIndex === 0 || action.currentIndex === 5
                }

                RowLayout {
                    spacing: 10
                    visible: delMode.currentIndex == 1 && (action.currentIndex === 0 || action.currentIndex === 5)

                    Label {
                        text: qsTr("nach")
                        font.pointSize: Style.pointSizeStandard
                        enabled: delMode.enabled

                    }
                    MyControls.SpinBox {
                        id: delAfterCountRecs
                        value: searchTimer.deleteAfterCounts
                        from: 0
                        to: 999
                        editable: true
                        enabled: delMode.enabled
                        onValueChanged: searchTimer.deleteAfterCounts = value
                    }
                    Label {
                        text: qsTr("Aufnahmen")
                        font.pointSize: Style.pointSizeStandard
                        enabled: delMode.enabled
                    }
                }
                RowLayout {
                    spacing: 10
                    visible: delMode.currentIndex == 2 && (action.currentIndex === 0 || action.currentIndex === 5)

                    Label {
                        text: qsTr("nach")
                        font.pointSize: Style.pointSizeStandard
                        enabled: delMode.enabled
                    }
                    MyControls.SpinBox {
                        id: delAfterDaysOfFirstRecs
                        from: 0
                        to: 999
                        editable: true
                        value: searchTimer.deleteAfterDays
                        enabled: delMode.enabled
                        onValueChanged: searchTimer.deleteAfterDays = value
                    }
                    Label {
                        text: qsTr("Tagen nach erster Aufnahme")
                        font.pointSize: Style.pointSizeStandard
                        enabled: delMode.enabled
                    }
                }

                // Label {
                //     text: "  "
                //     font.pointSize: Style.pointSizeStandard
                //     Layout.columnSpan: 2
                // }
            }//GridLayout
        }//Column
    }//ScrollView

    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel {
                MyControls.CommandButton {
                    id: saveButton
                    iconCharacter: Style.iconSave
                    description: "Speichern"
                    enabled: searchTimer.search.length > 0
                    opacity: enabled ? 1.0 : 0.5
                    onCommandButtonClicked: saveSearchTimer()
                }
            }
        }
    }
}

