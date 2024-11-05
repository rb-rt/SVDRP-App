import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import components 1.0
import controls 1.0
import models 1.0

Page {
    
    property var event

    //    onEventChanged: {
    //        console.log("Event",event)
    ////        console.log("Event",event.startDateTime)
    ////        console.log("locale",locale)
    ////        console.log("FormatTime", Qt.formatDateTime(event.startDateTime, "dddd, dd.MM.yyyy  hh:mm"))
    //    }

    //    StreamModel {
    //        id: streamModel
    //    }

    property date startDate: event.startDateTime
    property date endDate: event.endDateTime

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            ToolButtonHeader {
                id: toolButton
            }
            Label {
                id: channelName
                text: event.title
                font.pointSize: Style.pointSizeStandard
                font.weight: Font.Bold
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.fillWidth: true
            }
        }
    }

    ContentDescriptorModel{
        id: contentModel
    }

    Rectangle {
        color: Style.colorBackground
        anchors.fill: parent
        anchors.margins: 10

        GridLayout {
            id: col
            //            spacing: 0
            width: parent.width
            columns: 2

            Label {
                font.pointSize: Style.pointSizeStandard
                text: "Kanal:"
            }
            Label {
                text: event.channelname
                font.pointSize: Style.pointSizeStandard
            }

            Label {
                font.pointSize: Style.pointSizeStandard
                text: "Datum:"
            }
            Label {
                id: eventDatum
                text: startDate.toLocaleString(locale,"dddd, dd.MM.yyyy  hh:mm") + endDate.toLocaleTimeString(locale," - hh:mm")
                font.pointSize: Style.pointSizeStandard
            }

            Label {
                font.pointSize: Style.pointSizeStandard
                text: "Titel:"
                Layout.alignment: Qt.AlignTop
            }
            Label {
                id: eventTitle
                text: event.title
                font.pointSize: Style.pointSizeStandard
                font.weight: Font.Bold
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            Label {
                font.pointSize: Style.pointSizeStandard
                text: "Untertitel:"
                Layout.alignment: Qt.AlignTop
            }
            Label {
                text: event.subtitle === "" ? "<i>nicht vorhanden</i>" : event.subtitle
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            Label {
                font.pointSize: Style.pointSizeStandard
                text: "Mindestalter:"
                Layout.alignment: Qt.AlignTop
            }
            Label {
                text: event.parentalRating === 0 ? "<i>nicht vorhanden</i>" : event.parentalRating
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            Label {
                font.pointSize: Style.pointSizeStandard
                text: event.genres.length > 1 ? "Genres:" : "Genre:"
                Layout.alignment: Qt.AlignTop
            }
            ListView {
                model: event.genres
                Layout.preferredHeight: contentHeight
                Layout.fillWidth: true

                EmptyListLabel {
                    visible: parent.count === 0
                    text: "nicht vorhanden"
                    font.pointSize: Style.pointSizeStandard
                    font.italic: true
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                }

                delegate: Label {
                    id: delegateLabel
                    width: ListView.view.width
                    text: contentModel.getText(event.genres[index]) + " [" + event.genres[index] + "]"
                    font.pointSize: Style.pointSizeStandard
                }
            }
        }

        ScrollView {
            id: scrollView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: col.bottom
            anchors.topMargin: 12
            //            anchors.bottom: parent.bottom
            anchors.bottom: componentsListView.top
            anchors.bottomMargin: 12
            clip: true
            contentWidth: availableWidth

            Label {
                id: eventDescription
                text: event.description
                width: scrollView.width - 20
                //                    anchors.fill: parent
                wrapMode: TextEdit.WordWrap
                font.pointSize: Style.pointSizeStandard
            }
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            //            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        }

        ComponentsListView {
            id: componentsListView
            //            model: event["components"]
            model: event.components
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 5
        }

        Component {
            id: componentRepeater
            Repeater {
                model: event.genres
                ColumnLayout {
                    Label {
                        text: contentModel.getText(event.genres[index]) + "[" + event.genres[index] + "]"
                        font.pointSize: Style.pointSizeStandard
                        // Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
}
