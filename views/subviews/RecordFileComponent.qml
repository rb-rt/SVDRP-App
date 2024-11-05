import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import assets 1.0
import "../labels"
import "../icons"

RowLayout {

    anchors.left: parent.left
    anchors.right: parent.right

    RecordIcon {
        record: model.record
        showError: checkBoxShowError.checked
    }

    //Eventspalte
    Rectangle {
        Layout.fillWidth: true
        color: "transparent"
        Layout.preferredHeight: columnEvent.height

        ColumnLayout {
            id: columnEvent
            anchors.left: parent.left
            anchors.right: parent.right

            EventColumn {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
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
        Layout.preferredHeight: columnEvent.height
        Layout.preferredWidth: deleteIcon.width
        onIconClicked: pageStack.push(moveRecordView, { record:model.record })
    }
    PlayIcon {
        id: playIcon
        visible: moveIcon.visible
        Layout.preferredHeight: columnEvent.height
        onIconClicked: {
            console.log("Record",model.record)
            playContextMenu.record = model.record
            playContextMenu.popup(playIcon)
        }
    }
    DeleteIcon {
        id: deleteIcon
        visible: moveIcon.visible && !root.selectedRecords
        Layout.preferredHeight: columnEvent.height
        onIconClicked:{
            deleteRecordDlg.id = model.record.id
            deleteRecordDlg.text = model.record.lastName
            deleteRecordDlg.open()
        }
    }
    IndicatorIcon {
        id: indicatorIcon
        visible: Style.showIndicatorIcon
        Layout.preferredHeight: columnEvent.height
        onIconClicked: {
            contextMenu.record = model.record
            contextMenu.popup(indicatorIcon)
        }
    }

    component EventColumn: ColumnLayout {
        spacing: 2
        width: parent.width

        LabelSubtitle {
            text: model.time
            Layout.preferredWidth: parent.width
            visible: Style.showChannelTitle
        }
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
}

