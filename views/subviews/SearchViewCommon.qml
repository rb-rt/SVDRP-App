import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import controls 1.0 as MyControls
import components 1.0
import assets 1.0
import dialogs 1.0
import vdr.models 1.0
import vdr.epgsearch 1.0

Item {
    id: root

    property var searchTimer //Search, Searchtimer oder Blacklist

    required property ChannelModel channelModel
    required property EPGSearch epgsearch

    property bool isBlacklist: false //bei Blacklist fehlt ContentDescriptor und BlackListView
    signal emptySearch(bool empty) //Wird nach jedem Tastendruck verschickt, true wenn das Suchfeld leer ist

    implicitHeight: gridlayout.height

    property bool showBlacklistView: isBlacklist ?  false : searchTimer.blacklistMode === 1

    //    Rectangle {
    //        width: parent.width
    //        height: parent.height
    //        color: "lightsteelblue"
    //        opacity: 0.5
    //    }

    onSearchTimerChanged: {
        console.log("SearchViewCommon.qml onSearchTimerChanged",searchTimer)
        // useChannelBox.useChannel = searchTimer.useChannel
        // useChannelBox.fromChannel = searchTimer.channelMin
        // useChannelBox.toChannel = searchTimer.channelMax
        // useChannelBox.channels = searchTimer.channels
        emptySearch(searchTimer.search.length === 0)
        // useClock.useTime = searchTimer.useTime
        // useClock.start = searchTimer.startTime
        // useClock.stop = searchTimer.stopTime
    }

    Component.onCompleted: {
        console.log("SearchViewCommon.qml onCompleted","channels",searchTimer.channels)
        // console.log("SearchViewCommon.qml onCompleted","epgsearch directories",epgsearch.directories)
    }

    ContentDescriptorsView {
        id: contentDescriptorsView
        visible: false
        contentDescriptors: isBlacklist ? "" : searchTimer.contentDescriptors //fehlt bei Blacklists
        onContentDescriptorsSaved: {
            console.log("SearchViewCommon.qml ContentDescriptorsView onContentDescriptorsSaved:", contentDescriptors)
            searchTimer.contentDescriptors = contentDescriptors
            pageStack.pop()
        }
    }

    property ExtEpgCatsView extEpgCatsPage
    Connections {
        target: extEpgCatsPage
        function onCategoriesSaved() {
            console.log("SerchViewCommon onCategoriesSaved values", extEpgModel.values)
            searchTimer.extEpgCats = extEpgModel.values
            pageStack.pop()
        }
    }

    ExtendedEpgCatModel {
        id: extEpgModel
        defaultValues: root.epgsearch.extEpgCats
        values: searchTimer.extEpgCats
        onEmptyValuesChanged: console.log("ExtEpgCatsModel onEmptyValuesChanged",emptyValues)
    }

    GridLayout {
        id: gridlayout

        width: parent.width
        columns: 2

        Label {
            id: textLabel
            text: qsTr("Suche:")
            font.pointSize: Style.pointSizeStandard
        }
        MyControls.LineInput {
            id: searchField
            text: searchTimer.search
            placeholderText: "..."
            Layout.fillWidth: true
            onTextChanged: {
                console.log("onTextEdited",text)
                searchTimer.search = text
                emptySearch(text.length === 0)
            }
        }

        Label {
            text: qsTr("Suchmodus:")
            font.pointSize: Style.pointSizeStandard
        }
        MyControls.ComboBoxAuto {
            id: searchModeBox
            model: [qsTr("Ausdruck"), qsTr("Alle Worte"), qsTr("Ein Wort") ,qsTr("Exakt"),
                qsTr("Regulärer Ausdruck"), qsTr("Unscharf")]
            currentIndex: searchTimer.mode
            Layout.preferredWidth: width
            onActivated: searchTimer.mode = currentIndex
        }
        Label {
            text: qsTr("Toleranz:")
            visible: searchModeBox.currentIndex === 5
            font.pointSize: Style.pointSizeStandard
        }
        MyControls.SpinBox {
            id: tolerance
            value: searchTimer.tolerance
            from: 1
            to: 9
            stepSize: 1
            editable: true
            visible: searchModeBox.currentIndex === 5
            onValueChanged: searchTimer.tolerance = value
        }

        Label {
            text: qsTr("Groß/Klein")
            font.pointSize: Style.pointSizeStandard
        }
        CheckBox {
            id: matchCaseBox
            checked: searchTimer.matchCase
            onToggled: searchTimer.matchCase = checked
        }

        Label {
            text: qsTr("Suche in:")
            font.pointSize: Style.pointSizeStandard
            Layout.alignment: Qt.AlignTop
        }
        Flow {
            Layout.fillWidth: true
            CheckBox {
                id: titleBox
                text: qsTr("Titel")
                font.pointSize: Style.pointSizeStandard
                checked: searchTimer.useTitle
                onToggled: {
                    if (checkedError()) {
                        messageBox.open()
                        toggle()
                    }
                    else {
                        searchTimer.useTitle = checked
                    }
                }
            }
            CheckBox {
                id: subTitleBox
                text: qsTr("Untertitel")
                font.pointSize: Style.pointSizeStandard
                checked: searchTimer.useSubtitle
                onToggled: {
                    if (checkedError()) {
                        messageBox.open()
                        toggle()
                    }
                    else {
                        searchTimer.useSubtitle = checked
                    }
                }
            }
            CheckBox {
                id: descriptionBox
                text: qsTr("Beschreibung")
                font.pointSize: Style.pointSizeStandard
                checked: searchTimer.useDescription
                onToggled: {
                    if (checkedError()) {
                        messageBox.open()
                        toggle()
                    }
                    else {
                        searchTimer.useDescription = checked
                    }
                }
            }
        }

        Loader {
            active: !isBlacklist
            Layout.columnSpan: 2
            Layout.topMargin: topAbstand
            sourceComponent: contentDescriptorRow
            Layout.fillWidth: true
        }

        Loader {
            active: epgsearch.extEpgCats.length > 0
            Layout.columnSpan: 2
            Layout.topMargin: topAbstand
            sourceComponent: extEpgRow
        }

        UseChannelBox {
            id: useChannelBox
            channelModel: root.channelModel
            channelGroups: root.epgsearch.channelGroupNames
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.topMargin: topAbstand
            useChannel: searchTimer.useChannel
            fromChannel: searchTimer.channelMin
            toChannel: searchTimer.channelMax
            channels: searchTimer.channels
            onUseChannelChanged: searchTimer.useChannel = useChannel
            onFromChannelChanged: searchTimer.channelMin = fromChannel
            onToChannelChanged: searchTimer.channelMax = toChannel
            onChannelsChanged: searchTimer.channels = channels
            Binding { target: useChannelBox; property: "useChannel"; value: searchTimer.useChannel }
            Binding { target: useChannelBox; property: "fromChannel"; value: searchTimer.channelMin }
            Binding { target: useChannelBox; property: "toChannel"; value:  searchTimer.channelMax}
            Binding { target: useChannelBox; property: "channels"; value: searchTimer.channels }
        }

        UseClock {
            id: useClock
            Layout.topMargin: topAbstand
            Layout.columnSpan: 2
            onUseTimeChanged: searchTimer.useTime = useTime
            onStartChanged: searchTimer.startTime = start
            onStopChanged: searchTimer.stopTime = stop
            Binding { target: useClock; property: "useTime"; value: searchTimer.useTime }
            Binding { target: useClock; property: "stop"; value: searchTimer.stopTime }
            Binding { target: useClock; property: "start"; value: searchTimer.startTime }
        }

        UseDuration {
            id: useDuration
            useDuration: searchTimer.useDuration
            durationMin: searchTimer.durationMin
            durationMax: searchTimer.durationMax
            Layout.topMargin: topAbstand
            Layout.columnSpan: 2
            onUseDurationChanged: searchTimer.useDuration = useDuration.useDuration
            onDurationMinChanged: searchTimer.durationMin = durationMin
            onDurationMaxChanged: searchTimer.durationMax = durationMax
        }

        UseWeekday {
            id: useWeekday
            useWeekday: searchTimer.useDayOfWeek
            weekdays: searchTimer.dayOfWeek
            Layout.columnSpan: 2
            Layout.topMargin: topAbstand
            Layout.fillWidth: true
            onUseWeekdayChanged: searchTimer.useDayOfWeek = useWeekday.useWeekday
            onWeekdaysChanged: searchTimer.dayOfWeek = weekdays
        }

        Loader {
            active: isBlacklist
            Layout.topMargin: topAbstand
            Layout.columnSpan: 2
            sourceComponent:
                CheckBox {
                text: "Global verwenden"
                font.pointSize: Style.pointSizeStandard
                checked: searchTimer.isGlobal
                onToggled: searchTimer.isGlobal = checked
            }
        }

        // Auswahl Ausschlußlisten
        Label {
            id: ausschusslistenLabel
            text: qsTr("Ausschlusslisten:")
            font.pointSize: Style.pointSizeStandard
            visible: !isBlacklist
        }

        Loader {
            active: !isBlacklist
            sourceComponent: MyControls.ComboBoxAuto {
                id: blacklistMode
                model: [ qsTr("nur globale"), qsTr("Auswahl"), qsTr("alle"), qsTr("keine") ]
                currentIndex: searchTimer.blacklistMode
                Layout.preferredWidth: width
                onActivated: {
                    searchTimer.blacklistMode = currentIndex
                    root.showBlacklistView = currentIndex === 1
                }
            }
        }
        Loader {
            active: root.showBlacklistView
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.preferredHeight: active ? item.contentHeight : 0

            sourceComponent: ListView {
                id: blacklistView
                model: epgsearch.blacklists

                property var blacklistIDs: searchTimer.blacklists

                clip: true
                ScrollBar.vertical: ScrollBar{
                    policy: blacklistView.count > 5 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }
                delegate: CheckBox {
                    text: modelData.search
                    font.pointSize: Style.pointSizeStandard
                    checked: isBlacklist ? false : blacklistView.blacklistIDs.indexOf(modelData.id) !== -1
                    onToggled: {
                        let index = blacklistView.blacklistIDs.indexOf(modelData.id)
                        if (checked) {
                            if (index === -1) blacklistView.blacklistIDs.push(modelData.id)
                        }
                        else {
                            if (index !== -1) {
                                blacklistView.blacklistIDs.splice(index,1)
                            }
                        }
                        blacklistView.blacklistIDs.sort(function(a, b){return a - b})
                        searchTimer.blacklists = blacklistView.blacklistIDs
                    }
                }
            }
        }

        Label {
            text: "  "
            font.pointSize: Style.pointSizeStandard
            Layout.columnSpan: 2
        }

    }//GridLayout

    function checkedError() {
        if (!titleBox.checked && !subTitleBox.checked && !descriptionBox.checked) {
            return true
        }
        return false
    }

    Component {
        id: contentDescriptorRow
        ColumnLayout {
            width: parent.width
            RowLayout {

                Label {
                    text: qsTr("Verwende Kennung für Inhalt")
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: Style.iconEdit
                    font {
                        family: Style.faSolid
                        pointSize: Style.pointSizeDialogIcon
                    }
                    Layout.leftMargin: 10
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var header = "Kennung für Inhalte von <i>" + searchTimer.search + "</i>"
                            pageStack.push(contentDescriptorsView, { headerLabel: header, contentDescriptors: searchTimer.contentDescriptors })
                        }
                    }
                }
                Label {
                    text: " (leer)"
                    font.pointSize: Style.pointSizeStandard
                    visible: contentDescriptorsView.contentDescriptors.length === 0
                }
            }
            Label {
                text: qsTr("Achtung: Gesetzte Werte können über die App nicht mehr entfernt werden. Eine komplette Löschung muß direkt am VDR erfolgen, z.B. über das OSD.")
                font.pointSize: Style.pointSizeSmall
                wrapMode: Text.Wrap
                Layout.preferredWidth: parent.width
            }
        }
    }

    Component {
        id: extEpgRow
        GroupBox {

            label: CheckBox {
                id: useExtEpgInfo
                text: qsTr("Verwende Erweiterte EPG Info")
                font.pointSize: Style.pointSizeStandard
                checked: searchTimer.useExtEpgCats
                onToggled: checked ? searchTimer.useExtEpgCats = true : searchTimer.useExtEpgCats = false
            }
            ColumnLayout {
                spacing: 10
                RowLayout {
                    Label {
                        id: extEpgIcon
                        text:Style.iconEdit
                        font {
                            family: Style.faSolid
                            pointSize: Style.pointSizeDialogIcon
                        }
                        enabled: useExtEpgInfo.checked
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                extEpgCatsPage = pageStack.push("qrc:/views/subviews/ExtEpgCatsView.qml",
                                                                { extEpgModel,
                                                                    headerLabel: "EPG Kategorien von <i>" +  searchTimer.search + "</i>"
                                                                })
                            }
                        }
                    }
                    Label {
                        id: extEpgLabel
                        text: "Kategorien ausgewählt"
                        font.pointSize: Style.pointSizeStandard
                        enabled: useExtEpgInfo.checked
                        states: [
                            State {
                                when: extEpgModel.emptyValues && extEpgLabel.enabled
                                PropertyChanges {
                                    target: extEpgLabel
                                    text: "Keine Kategorien ausgewählt"
                                    color: Style.colorWarning
                                }
                                PropertyChanges {
                                    target: extEpgIcon
                                    color: Style.colorWarning
                                }
                            }
                        ]
                    }
                }
                CheckBox {
                    text: "Ignoriere fehlende Kategorie"
                    font.pointSize: Style.pointSizeStandard
                    Layout.columnSpan: 2
                    checked: searchTimer.ignoreMissingEpgCats
                    enabled: useExtEpgInfo.checked
                    onToggled: searchTimer.ignoreMissingEpgCats = checked
                }
            }
        }
    }



    MyMessageDialog {
        id: messageBox
        titleText: "Ungültige Suchabfrage"
        text: "Titel, Untertitel oder Beschreibung sind nicht gesetzt.\nBitte mindestens eine Kategorie auswählen."
        simple: true
    }

}

