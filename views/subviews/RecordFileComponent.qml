import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import assets 1.0
import "../labels"
import "../icons"

RowLayout {

    RecordIcon {
        record: model.record
        showError: checkBoxShowError.checked
    }

    Rectangle {
        Layout.fillWidth: true
        color: "transparent"
        Layout.preferredHeight: colTitle.height

        ColumnLayout {
            id: colTitle
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 2

            LabelSubtitle {
                // text: Qt.formatDateTime(model.record.starttime, "ddd, dd.MM.yyyy  hh:mm  ") + "(" + model.duration + ")"
                text: model.time
                Layout.preferredWidth: parent.width
                visible: Style.showChannelTitle
            }
            // LabelDescription {
            //     text: model.lastDir === "" ? "(.)" : "(" + model.lastDir +")"
            //     Layout.preferredWidth: parent.width
            //     font.weight: Font.Light
            //     visible: checkBoxLastDir.checked
            // }
            LabelTitle {
                text: model.display
                Layout.preferredWidth: parent.width
            }
            LabelDescription {
                text: model.record.name
                visible: checkBoxFilename.checked
                Layout.preferredWidth: parent.width
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                recordListModel.getEvent(model.record.id)
            }
        }
    }

    CheckBox {
        id: deleteCheckBox
        opacity: 0.66
        checked: model.select
        onToggled: model.select = checked
        onCheckedChanged: console.log("onCheckedChanged",checked)
    }

    MoveIcon {
        id: moveIcon
        visible: !Style.showIndicatorIcon
        Layout.preferredHeight: colTitle.height
        Layout.preferredWidth: deleteIcon.width
        onIconClicked: pageStack.push(moveRecordView, { record:model.record })
    }
    PlayIcon {
        id: playIcon
        visible: moveIcon.visible
        Layout.preferredHeight: colTitle.height
        onIconClicked: {
            console.log("Record",model.record)
            playContextMenu.record = model.record
            playContextMenu.popup(playIcon)
        }
    }
    DeleteIcon {
        id: deleteIcon
        visible: moveIcon.visible && !root.selectedRecords
        Layout.preferredHeight: colTitle.height
        onIconClicked:{
            deleteRecordDlg.id = model.record.id
            deleteRecordDlg.text = model.record.lastName
            deleteRecordDlg.open()
        }
    }
    IndicatorIcon {
        id: indicatorIcon
        visible: Style.showIndicatorIcon
        Layout.preferredHeight: colTitle.height
        onIconClicked: {
            contextMenu.record = model.record
            contextMenu.popup(indicatorIcon)
        }
    }
}

