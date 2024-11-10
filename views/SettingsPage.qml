import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal 2.15
import assets 1.0
// import components 1.0
import controls 1.0 as MyControls
import vdr.settings 1.0
import dialogs 1.0
import vdr.vdrinfo 1.0
import vdr.models 1.0

import "subviews"

Page {

    id: root

    property ChannelModel channelModel
    property VdrModel vdrModel

    // onWidthChanged: console.log("Settingspage onWidthChanged",width)

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {

            }

            Label {
                text: Style.iconSettings
                font.family: Style.faSolid
                font.pointSize: Style.pointSizeHeader
                Layout.alignment: Qt.AlignCenter
                //                Layout.leftMargin: 10
                Layout.rightMargin: 10
            }
            Label {
                id: headerLabel
                text: "Einstellungen"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }


    VdrInfo {
        id: vdrInfo
        url: channelModel ? channelModel.url : ""
        onStatisticsChanged: getPlugins()
    }

    TabBar {
        id: bar
        width: parent.width

        TabButton {
            text: "VDRs"
            font.pointSize: Style.pointSizeStandard
            font.bold: true
            width: implicitWidth
        }
        TabButton {
            text: "Vorgaben"
            font.pointSize: Style.pointSizeStandard
            font.bold: true
            width: implicitWidth
        }
        TabButton {
            text: "Startzeiten"
            font.pointSize: Style.pointSizeStandard
            font.bold: true
            width: implicitWidth
        }
        TabButton {
            text: "Informationen"
            font.pointSize: Style.pointSizeStandard
            font.bold: true
            width: implicitWidth
        }
    }

    StackLayout {
        id: stackLayout
        currentIndex: bar.currentIndex
        anchors {
            top: bar.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        VDRListView {
            id: vdrListView
            vdrModel: root.vdrModel
        }

        //Vorgaben
        ScrollView {
            // clip: true
            contentWidth: parent.width

            ColumnLayout {

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                // anchors.top: parent.top
                // anchors.topMargin: 50
                // anchors.bottom: parent.bottom
                // anchors.bottomMargin: 100

                GroupBox {

                    label: Label {
                        text: "Schriftgröße einstellen"
                        font.pointSize: Style.pointSizeStandard
                    }

                    ColumnLayout {

                        Label {
                            id: demoText
                            text: "Beispieltext"
                            font.pointSize: slider.value
                        }

                        RowLayout {
                            Label {
                                text: "Schriftgröße:"
                                font.pointSize: Style.pointSizeStandard
                            }
                            Slider {
                                id: slider
                                from: 10
                                to: 24
                                stepSize: 1.0
                                snapMode: Slider.SnapAlways
                                // live: false
                                value: Style.pointSizeStandard
                                onValueChanged: saveButton.enabled = value !== Style.pointSizeStandard
                                // onMoved: Style.pointSizeStandard = value
                            }
                            Label {
                                font.pointSize: Style.pointSizeStandard
                                text: slider.value
                            }
                        }
                        Label {
                            font.pointSize: Style.pointSizeStandard
                            text: "Standard System: " + Qt.application.font.pointSize
                        }

                        RowLayout {
                            Button {
                                id: saveButton
                                text: "Speichern"
                                font.pointSize: Style.pointSizeStandard
                                enabled: false
                                onClicked: {
                                    settings.fontSize = slider.value
                                    enabled = false
                                }
                            }
                            Label {
                                text: "Schriftgröße geändert"
                                font.pointSize: Style.pointSizeStandard
                                Layout.leftMargin: 10
                                visible: saveButton.enabled
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.topMargin: Style.pointSizeStandard
                    Label {
                        text: "Ansicht Programmstart:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    MyControls.ComboBoxAuto {
                        model: ["Programm","Timer","Suchtimer","Aufnahmen","Fernbedienung","Kanäle","Protokoll"]
                        currentIndex: Style.firstView
                        onActivated: settings.firstView = currentIndex
                    }
                }

                CheckBox {
                    text: "Zeige immer Kanal- und Zeitinformationen"
                    font.pointSize: Style.pointSizeStandard
                    checked: Style.showChannelTitle
                    onCheckedChanged: settings.showChannelTitle = checked
                    Layout.topMargin: Style.pointSizeStandard
                }
                CheckBox {
                    id: checkBoxSubtitle
                    text: "Zeige immer Untertitel (Programm und Timer)"
                    font.pointSize: Style.pointSizeStandard
                    checked: Style.showEventSubtitle
                    onCheckedChanged: settings.showEventSubtitle = checked
                }
                CheckBox {
                    id: checkBoxFilename
                    text: "Zeige immer Dateinamen (Timer und Aufnahmen)"
                    font.pointSize: Style.pointSizeStandard
                    checked: Style.showFilename
                    onCheckedChanged: settings.showFilename = checked
                }


                GridLayout {
                    columns: 2
                    Layout.topMargin: Style.pointSizeStandard
                    Label {
                        text: "Suchtimer Vorlauf:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    MyControls.SpinBox {
                        id: spinBoxMarginStart
                        from: 0
                        to: 999
                        value: Style.marginStart
                        editable: true
                        onValueChanged: settings.marginStart = value
                        Layout.preferredWidth: Math.max(spinBoxMarginStart.width,spinBoxMarginStop.width)
                    }
                    // Label {
                    //     text: "Minuten [VDR: " + epgsearch.options["DefMarginStart"] +"]"
                    //     font.pointSize: Style.pointSizeStandard
                    //     Layout.leftMargin: 10
                    // }
                    Label {
                        text: "Suchtimer Nachlauf:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    MyControls.SpinBox {
                        id: spinBoxMarginStop
                        from: 0
                        to: 999
                        editable: true
                        value: Style.marginStop
                        onValueChanged: settings.marginStop = value
                        Layout.preferredWidth: Math.max(spinBoxMarginStart.width,spinBoxMarginStop.width)
                    }
                    // Label {
                    //     text: "Minuten [VDR: " + epgsearch.options["DefMarginStop"] +"]"
                    //     font.pointSize: Style.pointSizeStandard
                    //     Layout.leftMargin: 10
                    // }

                    Label {
                        text: "Priorität"
                        font.pointSize: Style.pointSizeStandard
                    }
                    RowLayout {
                        MyControls.SpinBox {
                            from:0
                            to: 99
                            editable: true
                            value: Style.priority
                            onValueChanged: settings.priority = value
                        }
                        // Label {
                        //     text: "[VDR: " + epgsearch.options["DefPriority"] +"]"
                        //     font.pointSize: Style.pointSizeStandard
                        //     Layout.leftMargin: 10
                        // }
                    }

                    Label {
                        text: "Lebensdauer"
                        font.pointSize: Style.pointSizeStandard
                    }
                    RowLayout {
                        MyControls.SpinBox {
                            from:0
                            to: 99
                            editable: true
                            value: Style.lifetime
                            onValueChanged: settings.lifetime = value
                        }
                        // Label {
                        //     text: "[VDR: " + epgsearch.options["DefLifetime"] +"]"
                        //     font.pointSize: Style.pointSizeStandard
                        //     Layout.leftMargin: 10
                        // }
                    }
                    Label {
                        text: "EPG-Anzeige bis Kanal:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    RowLayout {
                        MyControls.SpinBox {
                            id: spinBoxChannels
                            from: 0
                            to: 9999
                            value: Style.toChannel
                            editable: true
                            onValueChanged: settings.toChannel = value
                            Layout.preferredWidth: Math.max(spinBoxMarginStart.width,spinBoxMarginStop.width)
                        }
                        Label {
                            text: "0 = alle Kanäle"
                            font.pointSize: Style.pointSizeStandard
                            Layout.leftMargin: 10
                        }
                    }
                    Label {
                        text: "Favoritensuche:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    RowLayout {
                        MyControls.SpinBox {
                            from: 0
                            to: 999
                            value: Style.favoritesHours
                            editable: true
                            onValueChanged: settings.favoritesHours = value
                            // Layout.preferredWidth: Math.max(spinBoxMarginStart.width,spinBoxMarginStop.width)
                        }
                        Label {
                            text: "Stunden"
                            font.pointSize: Style.pointSizeStandard
                            Layout.leftMargin: 10
                        }
                    }
                    Label {
                        text: "Startansicht Aufnahmen:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    MyControls.ComboBoxAuto {
                        id: comboBoxRecordings
                        model: ["Baumansicht","Listenansicht"]
                        currentIndex: Style.recordingsView
                        onActivated: settings.recordingsView = currentIndex
                    }
                }

                ColumnLayout {
                    Layout.topMargin: Style.pointSizeStandard
                    CheckBox {
                        text: "Icon bei fehlerhaften Aufnahmen einfärben?"
                        checked: Style.showRecordError
                        font.pointSize: Style.pointSizeStandard
                        onCheckedChanged: settings.showRecordError = checked
                    }
                    Label {
                        text:"Zeigt über das Icon an, ob eine Aufnahme fehlerhaft ist. Voreinstellung für die CheckBox <i>Fehler anzeigen</i> bei den Aufnahmen."
                        font.pointSize: Style.pointSizeSmall
                        Layout.preferredWidth: parent.width
                        wrapMode: Text.Wrap
                    }
                }

                ColumnLayout {
                    Layout.topMargin: Style.pointSizeStandard
                    RowLayout {
                        CheckBox {
                            id: checkBoxStatusIcons
                            text: "Zeige Icons einzeln anstatt dem Kontextmenüicon "
                            font.pointSize: Style.pointSizeStandard
                            checked: !Style.showIndicatorIcon
                            onCheckedChanged: settings.showIndicatorIcon = !checked
                        }
                        Label {
                            text: Style.iconEllipsisV
                            font.pointSize: Style.pointSizeDialogIcon
                            font.family: Style.faSolid
                        }
                    }
                    Label {
                        text:"Für breitere Bildschirme oder Querformat, um direkten Zugriff auf die einzelnen Icons (Timer, Suchen, Bearbeiten, etc.) zu erhalten"
                        font.pointSize: Style.pointSizeSmall
                        Layout.preferredWidth: parent.width
                        wrapMode: Text.Wrap
                    }
                }
                CheckBox {
                    Layout.topMargin: Style.pointSizeStandard
                    text: "Zeige EPG erst ab aktueller Zeit"
                    font.pointSize: Style.pointSizeStandard
                    checked: Style.showEpgAtNow
                    onCheckedChanged: settings.showEpgAtNow = checked
                }
                Label {
                    text: "Zeigt das EPG bei einer Kanalauswahl nur ab der aktuellen Zeit. Der VDR liefert hier noch ältere Einträge. Wird auch in der Programmübersicht angezeigt (<i>EPG ab jetzt</i>)."
                    Layout.preferredWidth: parent.width
                    font.pointSize: Style.pointSizeSmall
                    wrapMode: Text.Wrap
                }

                CheckBox {
                    id: checkBoxEventDescription
                    Layout.topMargin: Style.pointSizeStandard
                    Layout.preferredWidth: parent.width
                    text: "Zeige in der Programmübersicht zusätzlich die Beschreibung an"
                    font.pointSize: Style.pointSizeStandard
                    checked: Style.showEventDescription
                    onCheckedChanged: settings.showEventDescription = checked
                }
                Label {
                    text: "Blendet in der Programmübersicht die erweiterten EPG-Informationen ein. Wird auch in der Programmübersicht angezeigt (<i>Details</i>)."
                    Layout.preferredWidth: parent.width
                    font.pointSize: Style.pointSizeSmall
                    wrapMode: Text.Wrap
                }

                CheckBox {
                    id: checkBoxShowInfo
                    text: "Zeige Speicherplatzbelegung bei den Aufnahmen an"
                    font.pointSize: Style.pointSizeStandard
                    Layout.topMargin: Style.pointSizeStandard
                    checked: Style.showInfo
                    onCheckedChanged: settings.showInfo = checked
                }

                CheckBox {
                    id: checkBoxMainTime
                    text: "Hauptzeit in der Programmansicht färben"
                    font.pointSize: Style.pointSizeStandard
                    Layout.topMargin: Style.pointSizeStandard
                    checked: Style.showMainTime
                    onCheckedChanged: settings.showMainTime = checked
                }
                Label {
                    text: "Färbt in der Programmübersicht den Hintergrund farblich ein. Wird nur auf Listen mit Tagesansichten eingesetzt, wie z.B. Was läuft gerade auf Kanal 1. Ausschlaggebend ist der Beginn der Sendung. Er muss sich innerhalb der Hauptzeit befinden."
                    Layout.preferredWidth: parent.width
                    font.pointSize: Style.pointSizeSmall
                    wrapMode: Text.Wrap
                }

                GridLayout {
                    columns: 2
                    rowSpacing: Style.pointSizeStandard
                    Layout.topMargin: Style.pointSizeStandard / 2
                    Label {
                        text: "Anfang:"
                        font.pointSize: Style.pointSizeStandard
                        //                        Layout.topMargin: 20
                    }
                    MyControls.TimeSpinBox {
                        time: Qt.formatTime(settings.mainTimeFrom, "hh:mm")
                        onTimeChanged: settings.mainTimeFrom = Date.fromLocaleTimeString(locale, time, "hh:mm")
                    }
                    Label {
                        text: "Ende:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    MyControls.TimeSpinBox {
                        time: Qt.formatTime(settings.mainTimeTo, "hh:mm")
                        // Layout.columnSpan: 3
                        onTimeChanged: settings.mainTimeTo = Date.fromLocaleTimeString(locale, time, "hh:mm")
                    }

                    Label {
                        text: "Farbe aktuell:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    Rectangle {
                        id: colorRectangle
                        Layout.preferredWidth: height * 3
                        implicitHeight: 32
                        gradient: Style.gradientListMainTime
                        border.color: Qt.darker(Style.colorForeground)
                        border.width: 1
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                colorChooser = pageStack.push("qrc:/dialogs/ColorChooserView.qml", { selectedColor: Style.colorMainTime })
                            }
                        }
                    }
                    Label {
                        text: "Standardfarbe 1"
                        font.pointSize: Style.pointSizeStandard
                    }
                    Rectangle {
                        Layout.preferredWidth: colorRectangle.width
                        implicitHeight: 32
                        color: "#3383b546"
                        border.width: 1
                        border.color: Qt.darker(Style.colorForeground)
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                colorDlg.clr = "#3383b546"
                                colorDlg.open()
                            }
                        }
                    }
                    Label {
                        text: "Standardfarbe 2"
                        font.pointSize: Style.pointSizeStandard
                    }
                    Rectangle {
                        Layout.preferredWidth: colorRectangle.width
                        implicitHeight: 32
                        color: "#33D268C2"
                        border.width: 1
                        border.color: Qt.darker(Style.colorForeground)
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                colorDlg.clr = "#33D268C2"
                                colorDlg.open()
                            }
                        }
                    }
                }

                CheckBox {
                    text: "Unterschied zwischen Timer- und Ereigniszeit hervorheben"
                    font.pointSize: Style.pointSizeStandard
                    Layout.topMargin: Style.pointSizeStandard
                    checked: Style.showTimerGap
                    onCheckedChanged: settings.showTimerGap = checked
                    Layout.fillWidth: true
                }
                Label {
                    text: "Stimmen Anfangszeit von Timer (inkl. Berücksichtigung der Vorlaufzeit) und dazugehörigen Ereignis nicht überein, wird die Beschriftung bei der Timerliste farblich anders dargestellt.\nTimer Vorlaufzeit in der App und auf dem VDR müssen dafür übereinstimmen."
                    Layout.preferredWidth: parent.width
                    font.pointSize: Style.pointSizeSmall
                    wrapMode: Text.Wrap
                }
                RowLayout {
                    Label {
                        text: "Farbe:"
                        font.pointSize: Style.pointSizeStandard
                    }
                    Rectangle {
                        Layout.preferredWidth: colorRectangle.width
                        implicitHeight: 32
                        color: Style.colorTimerGap
                        border.color: Qt.darker(Style.colorForeground)
                        border.width: 1
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                colorChooserTimer = pageStack.push("qrc:/dialogs/ColorChooserView.qml", { selectedColor: Style.colorTimerGap })
                            }
                        }
                    }
                }

                //Dummy für unteren Abstand
                Label {
                    text: " "
                    font.pointSize: Style.pointSizeStandard
                    Layout.columnSpan: 2
                    Layout.bottomMargin: 100
                }

                Settings {
                    id: settings
                    onFontSizeChanged: Style.pointSizeStandard = fontSize
                    onShowMainTimeChanged: Style.showMainTime = showMainTime
                    onColorMainTimeChanged: Style.colorMainTime = colorMainTime
                    onMainTimeFromChanged: Style.mainTimeFrom = mainTimeFrom
                    onMainTimeToChanged: Style.mainTimeTo = mainTimeTo
                    onShowInfoChanged: Style.showInfo = showInfo
                    onToChannelChanged: Style.toChannel = toChannel
                    onShowChannelTitleChanged: Style.showChannelTitle = showChannelTitle
                    onShowEventSubtitleChanged: Style.showEventSubtitle = showEventSubtitle
                    onShowEventDescriptionChanged: Style.showEventDescription = showEventDescription
                    onShowFilenameChanged: Style.showFilename = showFilename
                    onRecordingsViewChanged: Style.recordingsView = recordingsView
                    onPriorityChanged: Style.priority = priority
                    onLifetimeChanged: Style.lifetime = lifetime
                    onShowIndicatorIconChanged: Style.showIndicatorIcon = showIndicatorIcon
                    onMarginStartChanged: Style.marginStart = marginStart
                    onMarginStopChanged: Style.marginStop = marginStop
                    onShowTimerGapChanged: Style.showTimerGap = showTimerGap
                    onTimerGapColorChanged: Style.colorTimerGap = timerGapColor
                    onShowRecordErrorChanged: Style.showRecordError = showRecordError
                    onShowEpgAtNowChanged: Style.showEpgAtNow = showEpgAtNow
                    onFavoritesHoursChanged: Style.favoritesHours = favoritesHours
                    onFirstViewChanged: Style.firstView = firstView
                    Component.onCompleted: {
                        //                        checkBoxChannelLogos.checked = settings.showLogos
                        //                    checkBoxLogosInCombobox.checked = settings.showLogosInLists
                    }
                }
            }
        }

        StartTimesListView {
            onWidthChanged: console.log("StartTimesListView onWidthChanged",width)
        }

        Loader {
            sourceComponent: Style.showInfo ? informationTab : informationTabEmpty
            onLoaded: {
                if (Style.showInfo) {
                    vdrInfo.svdrpStat()
                    //                    vdrInfo.getPlugins() //zu schnell, Überschreibt den ersten Befehl
                }
            }
        }
    } //StackLayout

    Component {
        id: informationTabEmpty
        ColumnLayout {
            Label {
                horizontalAlignment: Qt.AlignHCenter
                textFormat: Text.StyledText
                text: "<p>Hier stehen ein paar Informationen über den VDR.</p><br><p>Zum Anzeigen das Häkchen setzen.<p><p>Auch unter <b>Vorgaben</b> aufgeführt.</p>"
                font.pointSize: Style.pointSizeStandard
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
            CheckBox {
                text: "Zeige Speicherplatzbelegung bei den Aufnahmen an"
                font.pointSize: Style.pointSizeStandard
                checked: Style.showInfo
                onCheckedChanged: settings.showInfo = checked
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                Layout.fillHeight: true
            }
        }
    }

    Component {
        id: informationTab
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            color: Style.colorBackground

            ColumnLayout {
                id: colInfo
                anchors.left: parent.left
                anchors.right: parent.right

                Label {
                    id: vdrVersion
                    text: "VDR Version: " + vdrInfo.statistics.version
                    font.pointSize: Style.pointSizeStandard
                    font.weight: Font.DemiBold
                }

                Label {
                    text: "Aufnahmeverzeichnis:"
                    font.pointSize: Style.pointSizeStandard
                    font.weight: Font.DemiBold
                    Layout.topMargin: 10
                }
                Label {
                    text: vdrInfo.statistics.totalSpace + " GB Speicherplatz"
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    id: labelFreeSpace
                    font.pointSize: Style.pointSizeStandard
                    text: vdrInfo.statistics.freeSpace + " GB frei"
                }
                Label {
                    text: vdrInfo.statistics.usedPercent + " % belegt"
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    id: labelPlugin
                    text: "Plugins:"
                    font.pointSize: Style.pointSizeStandard
                    font.weight: Font.DemiBold
                    Layout.topMargin: 10
                }
            }

            ListView {
                anchors.top: colInfo.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                model: vdrInfo.plugins
                clip: true
                ScrollBar.vertical: ScrollBar{}

                delegate:
                    Label {
                    text: model.modelData
                    font.pointSize: Style.pointSizeStandard
                    height: implicitHeight
                    bottomPadding: 5
                    topPadding: 5
                }
            }
        }
    }


    property ColorChooserView colorChooser
    Connections {
        target: colorChooser
        function onSelectedColorChanged() {
            settings.colorMainTime = colorChooser.selectedColor
            pageStack.pop()
        }
    }
    property ColorChooserView colorChooserTimer
    Connections {
        target: colorChooserTimer
        function onSelectedColorChanged() {
            settings.timerGapColor = colorChooserTimer.selectedColor
            pageStack.pop()
        }
    }

    SimpleMessageDialog {
        id: colorDlg
        titleText: "Farbauswahl"
        text: "Farbe übernehmen?"
        property color clr
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: settings.colorMainTime = clr
    }

    Component.onCompleted: {
        console.log("Settingspage.qml onCompleted")
    }

}
