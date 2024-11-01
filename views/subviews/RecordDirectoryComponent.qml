import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import assets 1.0

// RowLayout {
//     anchors.left: parent.left
//     anchors.right: parent.right
//     anchors.rightMargin: Style.pointSizeStandard
    Label {
        id: lbl
        // anchors.fill: parent

        text: display
        font.pointSize: Style.pointSizeLarge
        elide: Text.ElideRight
        // Layout.fillWidth: true
        // Layout.topMargin: 10
        // Layout.bottomMargin: 10
        verticalAlignment: Qt.AlignVCenter
        MouseArea {
            anchors.fill: parent
            onClicked: {
                dir = lbl.text
            }
        }
    }
// }
