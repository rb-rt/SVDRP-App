import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

Label {
    id: icon

    signal iconClicked()

    text: Style.iconArrowsUpDown
    leftPadding: Style.listIconPadding
    rightPadding: Style.listIconPadding

    font {
        family: Style.faSolid
        pointSize: Style.pointSizeListIcon
    }
    color: Style.colorListIconMove
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignHCenter
    background: Rectangle {
        id: rec
        gradient: Style.gradientList
    }

    states: [
        State {
            name: "hover"
            PropertyChanges {
                target: rec
                gradient: Style.gradientListHover
            }
        }
    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: icon.state = "hover"
        onExited: icon.state = ""
        onClicked: iconClicked()
    }
}
