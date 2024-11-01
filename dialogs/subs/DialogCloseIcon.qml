import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0

Rectangle {
    id: deleteRec
    height: parent.height
    width: parent.height
    color: Style.colorDelete
    opacity: 0.8

    states: [
        State {
            name: "hover"
            PropertyChanges {
                target: deleteRec
                opacity: 1.0
            }
            PropertyChanges {
                target: deleteLabel
                font.pointSize: Style.pointSizeLarge * 1.2
            }
        }
    ]

    Label {
        id: deleteLabel
        anchors.centerIn: parent
        text: Style.iconTimes
        font.family: Style.faSolid
        font.pointSize: Style.pointSizeLarge
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: deleteRec.state = "hover"
        onExited: deleteRec.state = ""
        onClicked: reject()
    }
}
