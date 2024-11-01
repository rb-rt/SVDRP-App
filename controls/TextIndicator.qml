import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0

Popup {
    id: indicator
    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.NoAutoClose

    property alias text: label.text

    RowLayout {
        spacing: 10
        BusyIndicator {
            id: bi
            Layout.alignment: Qt.AlignVCenter
            running: false
        }
        Label {
            id: label
            font.pointSize: Style.pointSizeStandard
            Layout.alignment: Qt.AlignVCenter
        }
    }

    onOpened: bi.running = true
    onClosed: bi.running = false

}

