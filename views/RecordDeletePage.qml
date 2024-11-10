import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import assets 1.0
import dialogs 1.0
import controls 1.0 as MyControls
import models 1.0
import "labels"
import "icons"

Page {

    id: root
    property alias deleteModel: listView.model

    signal pageRemoved()
    signal deleteRecords()
    signal clearRecords()
    signal requestEvent(int id)

    StackView.onRemoved: {
        console.log("RecordDeletePage.qml onRemoved")
        pageRemoved()
    }

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {

            spacing: 0

            MyControls.ToolButtonHeader { }
            Label {
                text: "Ausgewählte Aufnahmen"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.fillWidth: true
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}
        MyControls.EmptyListLabel {
            text: "Keine Aufnahmen ausgewählt"
            visible: parent.count === 0
        }
        delegate: Rectangle {
            width: ListView.view.width
            height: listRowLayout.height
            gradient: Style.gradientList

            RowLayout {
                id: listRowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard

                //Icon
                RecordIcon {
                    id: iconStatus
                    record: model.record
                    showError: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    color: "transparent"
                    Layout.preferredHeight: colTitle.height

                    ColumnLayout {
                        id: colTitle
                        spacing: 0
                        anchors.left: parent.left
                        anchors.right: parent.right

                        LabelSubtitle {
                            id: dateLabel
                            // text: Qt.formatDateTime(model.record.starttime, "ddd, dd.MM.yyyy  hh:mm ") + "(" + model.duration + ")"
                            text: model.time
                            Layout.preferredWidth: parent.width
                            Layout.topMargin: 10
                        }
                        LabelTitle {
                            text: model.record.lastName
                            Layout.preferredWidth: parent.width
                        }
                        LabelDescription {
                            text: model.record.name
                            Layout.preferredWidth: parent.width
                        }
                        Rectangle {
                            Layout.preferredWidth: parent.width
                            Layout.bottomMargin: 10
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: requestEvent(model.record.id)
                    }
                }
                CheckBox {
                    id: deleteCheckBox
                    opacity: 0.66
                    checked: model.select
                    onToggled: model.select = checked
                }
            }
        }
    }

    footer: ToolBar {

        background: Loader { sourceComponent: Style.footerBackground }

        RowLayout {
            Label {
                text: ""
                Layout.fillWidth: true
            }
            MyControls.CommandHButton {
                iconCharacter: Style.iconUndo
                description:qsTr("Liste leeren")
                enabled: listView.count > 0
                onEnabledChanged: enabled ? opacity = 1.0 : opacity = 0.5
                onCommandButtonClicked: clearRecords()
            }
            MyControls.CommandHButton {
                description: "Aufnahmen endgültig löschen"
                iconCharacter: Style.iconTrash
                enabled: listView.count > 0
                onEnabledChanged: enabled ? opacity = 1.0 : opacity = 0.5
                onCommandButtonClicked: {
                    deleteCheckedRecordDlg.open()
                }
            }
        }
    }

    ErrorDialog {
        id: errorDialog
    }


    SimpleMessageDialog {
        id: deleteCheckedRecordDlg
        titleText: "Aufnahmen löschen"
        text: "Alle ausgewählten Aufnahmen löschen?"
        onAccepted: deleteRecords()
    }
}
