import QtQuick 2.15
import QtQuick.Controls 2.15

Popup {
    id: busyIndicator
    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.NoAutoClose
    BusyIndicator { }
}
