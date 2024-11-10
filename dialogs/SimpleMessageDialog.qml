import QtQuick
import QtQuick.Controls
import assets

DynamicDialog {

    property alias text: label.text

    modal: true
    anchors.centerIn: Overlay.overlay

    contentItem: Label {
        id: label
        font.pointSize: Style.pointSizeStandard
    }

}
