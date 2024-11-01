import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

Label {
    id: icon

    property bool mainTime: false

    signal iconClicked()

    text: Style.iconSearch

    leftPadding: Style.listIconPadding
    rightPadding: Style.listIconPadding

    font {
        family: Style.faSolid
        pointSize: Style.pointSizeListIcon
    }
    color: Style.colorListIconSearch
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignHCenter
    background: Rectangle {
        id: rec
        gradient: Style.gradientList
    }
    state: mainTime ? "maintime" : ""

    states: [
        State {
            name: "hover"
            PropertyChanges {
                target: rec
                gradient: Style.gradientListHover
            }
        },
        State {
            name: "maintime"
            PropertyChanges {
                target: rec
                gradient: Style.gradientListMainTime
            }
        }
    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: icon.state = "hover"
        onExited: mainTime ? icon.state = "maintime" : icon.state = ""
        onClicked: iconClicked()
    }
}
