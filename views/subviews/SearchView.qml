import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

import assets 1.0
import components 1.0
import dialogs 1.0
import controls 1.0 as MyControls
import vdr.models 1.0
import vdr.epgsearch 1.0

Page {
    id: root
    /*identischer Aufbau zu searchTimerEditView ohne Suchtimerbereich */

    property var search //Teilbereich eines searchtimer!

    property alias headerTitle: headerLabel.text

    property ChannelModel channelModel
    property EPGSearch epgsearch
    property TimerModel timerModel

   // width: parent.width

    onSearchChanged: {
        console.log("SearchView.qml onSearchChanged",search)
    }

    Connections {
        target: epgsearch
        function onSearchAdded() {
            searchTimerCreatedBox.open()
        }
    }

    Connections {
        target: epgsearch
        function onSvdrpError(e) {
            errorMsgDlg.errorText = e
            errorMsgDlg.open()
        }
    }


    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {
            }
            Label {
                text: Style.iconSearch
                font.pointSize: Style.pointSizeHeaderIcon
                font.family: Style.faSolid
            }
            Label {
                id: headerLabel
                font.pointSize: Style.pointSizeHeader
                Layout.fillWidth: true
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
            }
        }
    }

    readonly property int topAbstand: 30

    ScrollView {
        id: scrollView
        //        clip: true
        anchors.fill: parent
        anchors {
            leftMargin: 10
            rightMargin: 0
            topMargin: 5
            bottomMargin: 5
        }
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        //        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

//        contentWidth: parent.width - 25
        // contentWidth: availableWidth

        SearchViewCommon {
            id: searchViewCommon
//            width: parent.width
            anchors.fill: parent
            anchors.rightMargin: 15
            anchors.leftMargin: 1
            searchTimer: root.search
            channelModel: root.channelModel
            epgsearch: root.epgsearch
            onEmptySearch: function (empty) { searchButton.enabled = !empty }
        }
    }


    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel {
                MyControls.CommandHButton {
                    iconCharacter: Style.iconUndo
                    description: "Standardwerte"
                    onCommandButtonClicked: {
                        headerLabel.text = "Suche nach..."
                        search = JSON.parse(JSON.stringify(epgsearch.getSearch()))
                    }
                }
                MyControls.CommandHButton {
                    iconCharacter: Style.iconCalenderPlus
                    description: "Als Suchtimer speichern"
                    fontSolid: false
                    enabled: searchButton.enabled
                    opacity: searchButton.opacity
                    onCommandButtonClicked: {
                        console.log("SearchView Suchtimer speichern",search)
                        //                for (var prop in search) console.log("prop:",prop,":",search[prop])
                        epgsearch.createSearch(search)
                    }
                }
                MyControls.CommandHButton {
                    id: searchButton
                    iconCharacter: Style.iconSearch
                    description: qsTr("Suchen")
                    enabled: search.search.length > 0
                    opacity: enabled > 0 ? 1.0 : 0.5
                    onCommandButtonClicked: {
                        // for(var p in search) console.log("p",p,"Wert",search[p])
                        root.epgsearch.writeSearch(search)
                        pageStack.push("qrc:/views/EpgSearchQueryPage.qml",
                                       {searchTimer: search,
                                           channelModel: root.channelModel,
                                           epgsearch: root.epgsearch,
                                           timerModel: root.timerModel,
                                           headerLabel: "Suchergebnisse von <i>" + search.search + "</i>" ,
                                           // isSearch: true
                                       })
                    }
                }
            }
        }
    }

    ErrorDialog {
        id: errorMsgDlg
    }

    MyMessageDialog {
        id: searchTimerCreatedBox
        simple: true
        titleText: "Suchtimer"
        text: "<i>" + search.search + "</i> erfolgreich angelegt."
    }

}
