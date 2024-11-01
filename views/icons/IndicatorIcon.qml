import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

Label {
    id: icon

    property bool mainTime: false

    signal iconClicked()

    text: Style.iconEllipsisV
    color: Style.colorListIconStandard
    leftPadding: Style.listIconPadding
    rightPadding: Style.listIconPadding
    font {
        family: Style.faSolid
        pointSize: Style.pointSizeListIcon
    }
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignHCenter
    background: Rectangle {
        id: rec
        gradient: mainTime ? rec.gradient = Style.gradientListMainTime : rec.gradient = Style.gradientList
    }

    states: [
        State {
            name: "inactive"
            PropertyChanges {
                target: icon
                color: Style.colorListIconInactive
            }
        },
        State {
            name: "active"
            PropertyChanges {
                target: icon
                color: Style.colorListIconActive
            }
        },
        State {
            name: "action"
            PropertyChanges {
                target: icon
                color: Style.colorListIconAction
            }
        }
    ]

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: rec.gradient = Style.gradientListHover
        onExited: mainTime ? rec.gradient = Style.gradientListMainTime : rec.gradient = Style.gradientList
        onClicked: iconClicked()
    }
}
