import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import dialogs 1.0
import assets 1.0

GroupBox {
    property int userdefined // bei wert = 2
    property  int from //unixtime
    property int til

    property date fromDate: (from === 0) ? new Date() : new Date(from * 1000)
    property date tilDate: (til === 0) ? new Date() : new Date(til * 1000)

    font.pointSize: Style.pointSizeStandard
    label: CheckBox {
        id: gbLabel
        checked: userdefined === 2
        text: qsTr("Aktives Zeitfenster:")
        onCheckedChanged: {
            checked ? userdefined = 2 : userdefined = 1
        }
    }

    GridLayout {
        enabled: gbLabel.checked
        columns: 3
        columnSpacing: 20
        rowSpacing: 20
        opacity: gbLabel.checked ? 1.0 : 0.5

        Label {
            text: qsTr("Erster Tag:")
            font.pointSize: Style.pointSizeStandard
        }
        Label {
            id: fromText
            text: Qt.formatDate(fromDate,"dd.MM.yyyy")
            font.pointSize: Style.pointSizeStandard
        }
        Label {
            horizontalAlignment: Qt.AlignRight
            text: Style.iconCalender
            font.pointSize: Style.pointSizeDialogIcon
            font.family: Style.faRegular
            MouseArea {
                anchors.fill: parent
                onClicked: calFrom.open()
            }

        }

        Label {
            text: qsTr("Letzter Tag:")
            font.pointSize: Style.pointSizeStandard
        }
        Label {
            text: Qt.formatDate(tilDate,"dd.MM.yyyy")
            font.pointSize: Style.pointSizeStandard
        }
        Label {
            text: Style.iconCalender
            font.pointSize: Style.pointSizeDialogIcon
            font.family: Style.faRegular
            horizontalAlignment: Qt.AlignRight
            MouseArea {
                anchors.fill: parent
                onClicked: calTo.open()
            }
        }
    }

    CalendarDlg {
        id: calFrom
        parent: Overlay.overlay
        datum: fromDate
        onAccepted: from = datum.getTime() / 1000
    }

    CalendarDlg {
        id: calTo
        parent: Overlay.overlay
        datum: tilDate
        onAccepted: til = datum.getTime() / 1000
    }

}

