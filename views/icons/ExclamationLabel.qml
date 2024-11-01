import QtQuick
import QtQuick.Controls

import assets 1.0

Label {

    signal iconClicked()

    text: Style.iconExclamation
    color: Style.colorTimerGap
    leftPadding: Style.listIconPadding
    rightPadding: Style.listIconPadding
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignHCenter
    font {
        family: Style.faSolid
        pointSize: Style.pointSizeStandard
    }
    background: Rectangle {
        id: bkg
        gradient: Style.gradientList
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: bkg.gradient = Style.gradientListHover
        onExited: bkg.gradient = Style.gradientList
        onClicked: iconClicked()
    }
}
