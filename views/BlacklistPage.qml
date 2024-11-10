import QtQuick 2.15
import QtQuick.Layouts 1.5
import QtQuick.Controls 2.15
//import QtQuick.Dialogs 1.2
import QtQml.Models 2.15

import assets 1.0
import components 1.0
import dialogs 1.0
import controls 1.0
import vdr.epgsearch 1.0
import vdr.models 1.0
import "labels"
import "icons"
import "subviews"

Page {

    id: root

    property ChannelModel channelModel
    property EPGSearch epgsearch
    property TimerModel timerModel

    header: ToolBar {
        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            ToolButtonHeader {
            }

            Label {
                text: Style.iconCalenderAlt
                font.pointSize: Style.pointSizeHeaderIcon
                font.family: Style.faRegular
                Layout.alignment: Qt.AlignCenter
                Layout.leftMargin: 5
                Layout.rightMargin: 10
            }
            Label {
                id: headerLabel
                text: "Ausschlußlisten"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    property BlacklistEditView editView
    Connections {
        target: editView
        function onSaveBlacklist() {
            blacklistModel.setBlacklist(editView.blacklist)
            pageStack.pop()
        }
    }

    BlacklistModel {
        id: blacklistModel
        channelModel: root.channelModel
        epgsearch: root.epgsearch
        //        onError: {
        //            errorDialog.text = error
        //            errorDialog.open()
        //        }
        //        onEpgsearchChanged: console.log("BlacklistPage.qml onEpgsearchChanged")
        Component.onCompleted: {
            console.log("BlacklistPage.qml BlacklistModel onCompleted")
            getBlacklists()
        }
    }

    ListView {
        model: blacklistModel
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}

        EmptyListLabel {
            text: "Kein Ausschluß vorhanden."
            visible: parent.count === 0
        }

        delegate: Rectangle {
            width: ListView.view.width
            height: col.height //childrenRect.height
            //            height: 40
            gradient: Style.gradientList

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard

                //Global?
                Rectangle {
                    id: globalRectangle
                    Layout.preferredHeight: col.height
                    Layout.preferredWidth: col.height
                    gradient: Style.gradientList

                    Label {
                        anchors.centerIn: parent
                        text: "G"
                        font.pointSize: Style.pointSizeStandard
                        font.weight: Font.Black
                        enabled: model.blacklist.isGlobal
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    color: "transparent"
                    Layout.preferredHeight: col.height

                    ColumnLayout {
                        id: col
                        anchors.left: parent.left
                        anchors.right: parent.right

                        LabelTitle {
                            text: model.display
                            Layout.preferredWidth: parent.width
                            Layout.topMargin: 5
                        }
                        LabelSubtitle {
                            text: "Kanäle: " + model.channels + " " + model.time + " " + model.duration + " " + model.weekday
                            Layout.preferredWidth: parent.width
                            Layout.bottomMargin: 5
                        }
                    }
                }

                //Icons
                EditIcon {
                    id: editIcon
                    visible: !Style.showIndicatorIcon
                    Layout.preferredHeight: col.height
                    onIconClicked: {
                        var bl = JSON.parse(JSON.stringify(model.blacklist))//.toVariantMap()
                        var header = "Ausschlußliste <i>" + bl.search  + "</i> bearbeiten"
                        editView = pageStack.push("qrc:/views/subviews/BlacklistEditView.qml", {
                                                      blacklist: bl,
                                                      headerTitle: header,
                                                      channelModel:root.channelModel,
                                                      epgsearch: root.epgsearch
                                                  })
                    }
                }
                SearchIcon {
                    id: searchIcon
                    visible: editIcon.visible
                    Layout.preferredHeight: col.height
                    onIconClicked: {
                        var b = JSON.parse(JSON.stringify(model.blacklist))
                        pageStack.push("qrc:/views/EpgSearchQueryPage.qml",
                                       {searchTimer: b,
                                           ids: [],
                                           headerLabel: "Suchergebnisse von <i>" + b.search + "</i>" ,
                                           timerModel: root.timerModel,
                                           channelModel: root.channelModel,
                                           epgsearch:root.epgsearch
                                       })
                    }
                }
                DeleteIcon {
                    id: deleteIcon
                    visible: editIcon.visible
                    Layout.preferredHeight: col.height
                    onIconClicked: {
                        var bl = model.blacklist
                        confirmDeleteMsgBox.blacklist = bl
                        confirmDeleteMsgBox.text = bl.search
                        confirmDeleteMsgBox.open()
                    }
                }
                IndicatorIcon {
                    id: indicatorIcon
                    visible: Style.showIndicatorIcon
                    Layout.preferredHeight: col.height
                    onIconClicked: {
                        contextMenu.blacklist = model.blacklist
                        contextMenu.popup(indicatorIcon)
                    }
                }
            }
        }
    }

    Menu {
        id: contextMenu

        property var blacklist: 0 //als Timer

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

        ContextMenuItem {
            isLabel: true
            description: contextMenu.blacklist ? contextMenu.blacklist.search : ""
        }

        ContextMenuItem {
            iconCharacter: Style.iconEdit
            iconFont: Style.faSolid
            iconColor: Style.colorListIconEdit
            description: qsTr("Bearbeiten")
            onMenuItemClicked: {
                if (contextMenu.blacklist) {
                    contextMenu.close()
                    var bl =  JSON.parse(JSON.stringify(contextMenu.blacklist))
                    var header = "Ausschlußliste bearbeiten"
                    if (contextMenu.blacklist.id > 0) {
                        header = "Ausschlußliste <i>" + contextMenu.blacklist.search + "</i> bearbeiten"
                    }
                    editView = pageStack.push("qrc:/views/subviews/BlacklistEditView.qml", {
                                                  blacklist: bl,
                                                  headerTitle: header,
                                                  channelModel:root.channelModel,
                                                  epgsearch: root.epgsearch
                                              })
                }
            }
        }

        ContextMenuItem {
            iconCharacter: Style.iconSearch
            iconFont: Style.faSolid
            iconColor: Style.colorListIconSearch
            description: qsTr("Suchen")
            onMenuItemClicked: {
                if (contextMenu.blacklist) {
                    contextMenu.close()
                    var bl = JSON.parse(JSON.stringify(contextMenu.blacklist))
                    pageStack.push("qrc:/views/EpgSearchQueryPage.qml",
                                   {searchTimer: bl,
                                       ids: [],
                                       headerLabel: "Suchergebnisse von <i>" + bl.search + "</i>" ,
                                       timerModel: root.timerModel,
                                       channelModel: root.channelModel,
                                       epgsearch:root.epgsearch
                                   })
                }
            }
        }

        ContextMenuItem {
            iconCharacter: Style.iconTrash
            iconColor: Style.colorListIconDelete
            iconFont: Style.faRegular
            description: qsTr("Löschen")
            onMenuItemClicked: {
                if (contextMenu.blacklist) {
                    contextMenu.close()
                    confirmDeleteMsgBox.blacklist = contextMenu.blacklist
                    confirmDeleteMsgBox.text = contextMenu.blacklist.search
                    confirmDeleteMsgBox.open()
                }
            }
        }
    }

    footer: ToolBar {

        background: Loader { sourceComponent: Style.footerBackground }

        CommandBar {
            anchors {
                right: parent.right
                top: parent.top
                topMargin: 1
                rightMargin: 10
            }

            commandList: ObjectModel {
                CommandButton {
                    iconCharacter: Style.iconCalenderPlus
                    description: "Neu"
                    onCommandButtonClicked: {
                        var header = "Neue Ausschlußliste"
                        var bl = JSON.parse(JSON.stringify(blacklistModel.getBlacklist()))
                        editView = pageStack.push("qrc:/views/subviews/BlacklistEditView.qml", {
                                                      blacklist: bl,
                                                      headerTitle: header,
                                                      channelModel:root.channelModel,
                                                      epgsearch: root.epgsearch
                                                  })
                    }
                }
            }
        }
    }

    SimpleMessageDialog {
        id: confirmDeleteMsgBox
        titleText: "Ausschlußliste löschen?"
        property var blacklist
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: {
            if (blacklist) {
                blacklistModel.deleteBlacklist(blacklist.id)
            }
        }
    }

    ErrorDialog {
        id: errorDialog
        title: "Fehler bei der Abfrage"
    }

}
