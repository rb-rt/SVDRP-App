import QtQuick 2.15
import QtQuick.Controls 2.15
import assets 1.0

Rectangle {
    id: button
    property alias text: label.text
    property alias fontFamily: label.font.family
    property alias color: label.color
    signal clicked()

    gradient: Style.gradientList
    border.width: 1
    border.color: Style.colorPrimary    

    states: [
        State {
            name: "hover"
            PropertyChanges {
                target: button
                gradient: Style.gradientListHover
            }
        }
    ]

    Label {
        id: label
        anchors.fill: parent
        font.pointSize: Style.pointSizeStandard
        fontSizeMode: Text.HorizontalFit
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: button.state = "hover"
        onExited: button.state = ""
        onClicked: button.clicked()
    }
}
