import QtQuick 2.15
import QtQuick.Controls 2.15
import assets 1.0

Label {
    id: icon

    text: "?"
    property bool mainTime: false
    property bool active: false
    signal iconClicked()

    font.pointSize: Style.pointSizeStandard
    font.weight: Font.Bold
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignRight
    leftPadding: 2 * Style.listIconPadding
    rightPadding: 2 * Style.listIconPadding

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
        enabled: icon.active
        onEntered: icon.state = "hover"
        onExited: mainTime ? icon.state = "maintime" : icon.state = ""
        onClicked: if (icon.active) iconClicked()
    }
}
