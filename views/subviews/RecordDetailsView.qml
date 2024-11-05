import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import components 1.0
import controls 1.0
Page {


    property var recordEvent

//    onRecordEventChanged: {
//        for(var p in recordEvent) console.log("P",p,"RecordEvent",recordEvent[p])
//    }

    property date startDate: recordEvent.startDateTime

    header: ToolBar {
        anchors.left: parent.left
        anchors.right: parent.right

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            ToolButtonHeader {
            }

            Label {
                font.pointSize: Style.pointSizeHeaderIcon
                text: Style.iconDatabase
                font.family: Style.faSolid
                Layout.leftMargin: 10
                Layout.rightMargin: 10
            }
            Label {
                id: title
                text: recordEvent.title
                font.pointSize: Style.pointSizeStandard
                font.weight: Font.Bold
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {

        color: Style.colorBackground
        anchors.fill: parent
        anchors.margins: 10

        GridLayout {
            id: col
            width: parent.width
            columns: 2

            Label {
                font.pointSize: Style.pointSizeStandard
                text: "Kanal:"
            }
            Label {
                id: channelName
                text: recordEvent.channelname
                Layout.fillWidth: true
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                id: leftLabel
                font.pointSize: Style.pointSizeStandard
                text: "Datum:"
            }
            Label {
                id: date
                // text: Qt.formatDateTime(recordEvent.startDateTime, "ddd, dd.MM.yyyy  hh:mm")
                text: startDate.toLocaleString(locale,"dddd, dd.MM.yyyy  hh:mm")
                Layout.fillWidth: true
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                text: "Titel:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
            }
            Label {
                id: eventTitle
                text: recordEvent.title
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                Layout.fillWidth: true
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }
            Label {
                text: "Untertitel"
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                id: eventSubtitle
                text: recordEvent.subtitle === "" ? "<i>nicht vorhanden</i>" :recordEvent.subtitle
                Layout.fillWidth: true
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                wrapMode: Text.WordWrap
            }
//            Label {
//                text: "Aufnahmedauer:"
//                font.pointSize: Style.pixelSizeStandard
//                Layout.alignment: Qt.AlignTop
//            }
//            Label {
//                id: recordingDuration
//                Layout.fillWidth: true
//                font.pointSize: Style.pixelSizeStandardSmall
//                Layout.maximumWidth: scrollView.width - leftLabel.width
//                Layout.preferredWidth: scrollView.width - leftLabel.width
//                wrapMode: Text.WordWrap
//            }
//            Label {
//                text: "Sendedauer:"
//                font.pointSize: Style.pixelSizeStandard
//                Layout.alignment: Qt.AlignTop
//            }
//            Label {
//                id: eventDuration
//                Layout.fillWidth: true
//                font.pointSize: Style.pixelSizeStandardSmall
//                Layout.maximumWidth: scrollView.width - leftLabel.width
//                Layout.preferredWidth: scrollView.width - leftLabel.width
//                wrapMode: Text.WordWrap
//            }
            Label {
                text: "Pfad:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
            }
            Label {
                id: fileName
                text: recordEvent.name
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            Label {
                text: "Dauer:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
            }
            Label {
                text: Qt.formatTime(recordEvent.durationTime, "h:mm")
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            Label {
                text: "Priorität:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
            }
            Label {
                text: recordEvent.priority
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            Label {
                text: "Lebendauer:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
            }
            Label {
                text: recordEvent.lifetime
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                Layout.fillWidth: true
            }
            Label {
                text: "Frames:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
            }
            Label {
                text: recordEvent.frames
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                Layout.fillWidth: true
            }
            Label {
                text: "Fehler:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
            }
            Label {
                text: recordEvent.errors
                font.pointSize: Style.pointSizeStandard
                Layout.maximumWidth: scrollView.width - leftLabel.width
                Layout.preferredWidth: scrollView.width - leftLabel.width
                Layout.fillWidth: true
            }
        }

        ScrollView {
            id: scrollView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: col.bottom
            anchors.bottom: componentsListView.top
            anchors.bottomMargin: 12
            anchors.topMargin: 12
            clip: true
            contentWidth: availableWidth

            Label {
                id: recordingDescription
                text: recordEvent.description
                width: scrollView.width - 20
                wrapMode: Text.WordWrap
                font.pointSize: Style.pointSizeStandard
            }
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
//            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        }

        ComponentsListView {
            id: componentsListView
            model: recordEvent["components"]
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 5
        }

    }

}
