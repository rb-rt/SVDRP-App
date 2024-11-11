import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import "subs"

DynamicDialog {
    id: root

    property date datum

    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.NoAutoClose

    titleText: qsTr("Zeige Sendungen ab")
    headerIcon: Style.iconClock
    fontSolid: false
    showCloseIcon: true

    contentItem:
        ColumnLayout {
        DateTimeTumbler {
            id: dateTimeTumbler
            Layout.alignment: Qt.AlignHCenter
            datum: root.datum
        }
        CheckBox {
            id: checkBox
            text: qsTr("Zeit in Auswahlliste übernehmen?")
            font.pointSize: Style.pointSizeStandard
            width: parent.width
        }
    }

    standardButtons: Dialog.Ok
    onAccepted: {
        root.datum = dateTimeTumbler.datum
        if (checkBox.checked) {
            var t = Qt.formatTime(dateTimeTumbler.datum,"hh:mm")
            startTimes.addTime(t)
        }
    }
}
