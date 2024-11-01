import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import assets
import controls
import "subs"

Dialog {

    property var record

    property int play: 0 //0 = von begin, 1 = letzter Wiedergabeposition, 2 = Zeitangabe
    property alias time: timeSpinBox.time

    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.NoAutoClose

    header: DialogHeaderToolBar {
        icon: Style.iconClock
        text: "Wiedergabe auf dem VDR"
    }


    contentItem:
        ColumnLayout {

        ButtonGroup {
            id: buttonGroup
        }

        Label {
            text: record ? record.lastName : ""
            font.pointSize: Style.pointSizeStandard
            font.bold: true
        }

        RadioButton {
            text: "ab Anfang"
            ButtonGroup.group: buttonGroup
            checked: play === 0
            onToggled: if (checked) play = 0
            font.pointSize: Style.pointSizeStandard
        }
        RadioButton {
            text: "letzte Wiedergabeposition"
            ButtonGroup.group: buttonGroup
            checked: play === 1
            onToggled: if (checked) play = 1
            font.pointSize: Style.pointSizeStandard
        }
        RowLayout {
            RadioButton {
                text: "ab "
                ButtonGroup.group: buttonGroup
                checked: play === 2
                onToggled: if (checked) play = 2
                font.pointSize: Style.pointSizeStandard
            }
            TimeSpinBox {
                id: timeSpinBox
                time: "00:00"
                enabled: play === 2
            }
            Label {
             text: " Format hh:mm"
             font.pointSize: Style.pointSizeStandard
             enabled: timeSpinBox.enabled
            }
        }
    }

    footer: DialogFooterToolBar {
        onOkClicked: {
            accept()
        }
    }


}
