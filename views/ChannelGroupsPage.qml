import QtQuick 2.15
import QtQuick.Layouts 1.15
//import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.15
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
                text: "Kanalgruppen"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    property string lastChannelGroup: "" //Die zuletzt aufgerufene Kanalgruppe
    property bool newChannelGroup: false //true für eine neue Kanalgruppe

    Connections {
        target: epgsearch
        function onSvdrpError(error) {
            console.log("ChannelGroupsPage.qml onError",error)
            httpErrorMsg.text = error
            httpErrorMsg.open()
        }        
    }

    property ChannelGroupsEditView editView
    Connections {
        target: editView
        function onChannelGroupsSaved() {
            // epgsearch.editChannelGroup(lastChannelGroup,editView.channels)
            pageStack.pop()
            if (newChannelGroup) {
                newChannelGroup = false
                channelGroupsModel.newChannelGroup(lastChannelGroup, editView.channels)
            }
            else {
                channelGroupsModel.editChannelGroup(lastChannelGroup, editView.channels)
            }
        }
    }

    ChannelGroupsModel {
        id: channelGroupsModel
        epgsearch: root.epgsearch
        Component.onCompleted: channelGroupsModel.getChannelGroups()
    }

    ListView {
        // model: root.epgsearch.channelGroupNames
        model: channelGroupsModel
        anchors.fill: parent
        delegate: delegateListView
        ScrollBar.vertical: ScrollBar{}

        EmptyListLabel {
            text: "Keine Kanalgruppe vorhanden."
            visible: parent.count === 0
        }
    }

    Component {
        id: delegateListView

        Rectangle {
            width: ListView.view.width
            height: rowLayout.height
            gradient: Style.gradientList

//            onHeightChanged: console.log("Rectange height",height)

            RowLayout {
                id: rowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard
                anchors.leftMargin: Style.pointSizeStandard
                implicitHeight: Style.listMinHeight

                LabelTitle {
                    text: model.display
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }

                //Icons
                Label {
                    id: renameIcon
                    text: Style.iconRename
                    visible: !Style.showIndicatorIcon
                    font {
                        family: Style.faSolid
                        pointSize: Style.pointSizeListIcon
                    }
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: deleteIcon.width
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Style.colorListIconStandard
                    background: Rectangle {gradient: Style.gradientList}
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: renameIcon.background.gradient = Style.gradientListHover
                        onExited: renameIcon.background.gradient = Style.gradientList
                        onClicked: {
                            lastChannelGroup = model.display
                            renameChannelName.title = "Kanalgruppe <i>" + lastChannelGroup + "</i> umbenennen"
                            renameChannelName.open()
                        }
                    }
                }
                EditIcon {
                    id: editIcon
                    visible: renameIcon.visible
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        console.log("onIconClicked", model.display, model.channels)
                        lastChannelGroup = model.display
                        var header = "Kanalliste <i>" + lastChannelGroup  + "</i> bearbeiten"
                        editView = pageStack.push("qrc:/views/subviews/ChannelGroupsEditView.qml", {
                                                      channels: model.channels,
                                                      headerTitle: header,
                                                      channelModel: root.channelModel
                                                  })
                    }
                }

                DeleteIcon {
                    id: deleteIcon
                    visible: renameIcon.visible
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        confirmDeleteMsgBox.text = model.display + " löschen?"
                        confirmDeleteMsgBox.open()
                    }
                }
                IndicatorIcon {
                    id: indicatorIcon
                    visible: Style.showIndicatorIcon
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        lastChannelGroup = model.display
                        contextMenu.channels = model.channels
                        contextMenu.popup(indicatorIcon)
                    }
                }
            }
        }
    }

    Menu {
        id: contextMenu

        property var channels

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
            description: lastChannelGroup
        }

        ContextMenuItem {
            iconCharacter: Style.iconRename
            iconColor: Style.colorListIconStandard
            iconFont: Style.faSolid
            description: qsTr("Umbenennen")
            onMenuItemClicked: {
                contextMenu.close()
                renameChannelName.title = "Kanalgruppe <i>" + lastChannelGroup + "</i> umbenennen"
                renameChannelName.open()
            }
        }

        ContextMenuItem {
            iconCharacter: Style.iconEdit
            iconColor: Style.colorListIconEdit
            iconFont: Style.faSolid
            description: qsTr("Bearbeiten")
            onMenuItemClicked: {
                contextMenu.close()
                var header = "Kanalliste <i>" + lastChannelGroup  + "</i> bearbeiten"
                // var channels = root.epgsearch.channelsFromGroup(lastChannelGroup)
                editView = pageStack.push("qrc:/views/subviews/ChannelGroupsEditView.qml", {
                                              channels: contextMenu.channels,
                                              headerTitle: header,
                                              channelModel: root.channelModel
                                          })
            }
        }

        ContextMenuItem {
            iconCharacter: Style.iconTrash
            iconColor: Style.colorListIconDelete
            iconFont: Style.faRegular
            description: qsTr("Löschen")
            onMenuItemClicked: {
                contextMenu.close()
                // confirmDeleteMsgBox.groupName = lastChannelGroup
                confirmDeleteMsgBox.text = lastChannelGroup + " löschen?"
                confirmDeleteMsgBox.open()
            }
        }
    }

    footer: ToolBar {

        background: Loader { sourceComponent: Style.footerBackground }

        CommandBar {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.rightMargin: 10
            commandList: ObjectModel {
                CommandButton {
                    iconCharacter: Style.iconCalenderPlus
                    description: "Neu"
                    onCommandButtonClicked: newChannelGroupDlg.open()
                }
            }
        }
    }


    SimpleMessageDialog {
        id: confirmDeleteMsgBox
        titleText: "Kanalgruppe löschen"
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: channelGroupsModel.deleteChannelGroup(groupName)
    }

    DialogInputText {
        id: renameChannelName
        title: "Kanalgruppe umbenennen"
        placeholderText: "neuer Kanalname"
        onAccepted: channelGroupsModel.renameChannelGroup(lastChannelGroup, newText)
    }

    DialogInputText {
        id: newChannelGroupDlg
        title: "Neue Kanalgruppe anlegen"
        onAccepted: {
            newChannelGroup = true
            lastChannelGroup = newText
            editView = pageStack.push("qrc:/views/subviews/ChannelGroupsEditView.qml", {
                                          channels: [],
                                          headerTitle: "Neue Kanalgruppe <i>" + newText + "</i>",
                                          channelModel: root.channelModel
                                      })
        }
    }

    SimpleMessageDialog {
        id: httpErrorMsg
        titleText: qsTr("Fehler aufgetreten")
        standardButtons: Dialog.Close
    }

}
