import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import components 1.0
import controls 1.0 as MyControls

Page {
    property var channel //QVariantMap
    signal saveChannel

    id: root

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {

            }

            Label {
                text: Style.iconChannel
                font.pointSize: Style.pointSizeHeaderIcon
                font.family: Style.faSolid
            }
            Label {
                id: headerLabel
                text: "Kanal <i>" + channel.name + "</i> bearbeiten"
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
            rightMargin: 10
            topMargin: 5
            bottomMargin: 5
        }
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        //        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        clip: true

        GridLayout {
            width: scrollView.width - 20 //ScrollBar abziehen
            columns: 2

            Label {
                text: qsTr("Kanalnummer:")
                font.pointSize: Style.pointSizeLarge
                topPadding: Style.listIconPadding
                bottomPadding: Style.listIconPadding
            }
            Label {
                font.pointSize: Style.pointSizeStandard
                text: channel.number
            }
            Label {
                text: qsTr("ID:")
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                font.pointSize: Style.pointSizeStandard
                text: channel.id
            }
            Label {
                text: qsTr("Name:")
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                font.pointSize: Style.pointSizeStandard
                text: channel.name
                Layout.fillWidth: true
                onTextChanged: channel.name = text
            }
            Label {
                text: qsTr("Kurzname:")
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                font.pointSize: Style.pointSizeStandard
                text: channel.shortname
                Layout.fillWidth: true
                onTextChanged: channel.shortname = text
            }
            Label {
                text: qsTr("Bouquet:")
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                font.pointSize: Style.pointSizeStandard
                text: channel.bouquet
                Layout.fillWidth: true
                onTextChanged: channel.bouquet = text
            }

            Label {
                text: qsTr("Quelle:")
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                text: channel.source
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                onTextChanged: channel.source = text
            }
            Label {
                text: "Frequenz:"
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                font.pointSize: Style.pointSizeStandard
                text: channel.frequency
                Layout.fillWidth: true
                inputMethodHints: Qt.ImhDigitsOnly
                onTextChanged: channel.frequency = text
            }
            Label {
                font.pointSize: Style.pointSizeStandard
                text: "VPID:"
            }
            TextField {
                font.pointSize: Style.pointSizeStandard
                text: channel.vpid
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: Style.pointSizeStandard
                text: "APID:"
            }
            TextField {
                text: channel.apid
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
            }
            Label {
                font.pointSize: Style.pointSizeStandard
                text: "TPID:"
            }
            TextField {
                text: channel.tpid
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
            }
            Label {
                text: "CA:"
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                text: channel.caid
                Layout.fillWidth: true
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                text: "SID:"
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                text: channel.sid
                Layout.fillWidth: true
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                text: "NID:"
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                text: channel.nid
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
            }
            Label {
                text: "TID:"
                font.pointSize: Style.pointSizeStandard
            }
            TextField {
                text: channel.tid
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
            }


        }
    }

    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
        commandList: ObjectModel {
            MyControls.CommandButton {
                iconCharacter: Style.iconSave
                description: qsTr("Speichern")
                onCommandButtonClicked:{
                                   // for (var p in channel) console.log("p:",p,channel[p])
                    saveChannel()
                }
            }
        }
    }
    }
}
