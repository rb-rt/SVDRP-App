import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15
//import QtQuick.Dialogs

import assets 1.0
import components 1.0
import controls 1.0 as MyControls
import vdr.models 1.0
import vdr.epgsearch 1.0

Page {
    id:root

    property var blacklist

    signal saveBlacklist()

    property alias headerTitle: headerLabel.text
    property ChannelModel channelModel
    property EPGSearch epgsearch

    header: ToolBar {

        background: Rectangle {
            implicitHeight: parent.height
            color: Style.colorPrimary

            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "transparent"
                border.color: Qt.darker(parent.color)
            }

        }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {}
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

        clip: true

        // contentWidth: parent.width - 20
        contentWidth: availableWidth

        SearchViewCommon {
            id: searchViewCommon
            // width: parent.width
            anchors.fill: parent
            anchors.leftMargin: 1
            anchors.rightMargin: 15
            searchTimer: blacklist
            channelModel: root.channelModel
            epgsearch: root.epgsearch
            isBlacklist: true
            onEmptySearch: function(empty) { saveButton.enabled = !empty}
        }
    }//Scrollview

    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel {
                MyControls.CommandButton {
                    id: saveButton
                    iconCharacter: Style.iconSave
                    description: "Speichern"
                    enabled: root.blacklist.search.length > 0
                    opacity: enabled ? 1.0 : 0.5
                    onCommandButtonClicked: saveBlacklist()
                }
            }
        }
    }
}
