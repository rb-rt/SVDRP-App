import QtQuick 2.15
import QtQuick.Controls 2.15
import assets 1.0

Dialog {

    property alias errorText: errorLabel.text
    modal: true
    anchors.centerIn: parent

    title: qsTr("Fehler aufgetreten")
    standardButtons: Dialog.Ok

    Label {
        id: errorLabel
        font.pointSize: Style.pointSizeStandard
        width: parent.width
        wrapMode: Text.WordWrap
    }
}
