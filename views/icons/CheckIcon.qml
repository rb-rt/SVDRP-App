import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

Label {
    id: icon

    //Icon für die TimerListPage und SearchtimerListPage

    property bool isSearchtimer: false

    signal iconClicked()

    text: isSearchtimer ? Style.iconCalenderCheck : Style.iconCheck
    leftPadding: Style.listIconPadding
    rightPadding: Style.listIconPadding

    font {
        family: isSearchtimer ? Style.faRegular : Style.faSolid
        pointSize: Style.pointSizeListIcon
    }
    color: Style.colorListIconStandard
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignHCenter
    background: Rectangle {
        id: rec
        gradient: Style.gradientList
    }

    states: [
        State {
            name: "inactive"
            PropertyChanges {
                target: icon
                //                color: Style.colorListIconStandard
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
        },
        State {
            name: "recording"
            PropertyChanges {
                target: icon
                color: Style.colorListIconRecording
            }
        }
    ]
/*
    transitions:
        Transition {
        from: "*"
            to: "recording"
            onRunningChanged: console.log("CheckIcon.qml Transition",running)
            PropertyAnimation {
                target: icon
                property: "color"
                from: "white"
                to: "black"
                duration: 1000
                onStarted: console.log("CheckIcon.qml Transition onStarted")
            }
        }*/

/*
    SequentialAnimation on color {
        loops: Animation.Infinite
        running: icon.state === "recording"

        ParallelAnimation {
            ColorAnimation {
                from: Style.colorListIconStandard
                to: Style.colorListIconRecording
                duration: 1000
            }
            NumberAnimation {
                target: icon
                property: "scale"
                from: 1.0
                to: 1.1
//                property: "font.pointSize"
//                from: Style.pointSizeListIcon
//                to: Style.pointSizeListIcon * 1.2
                duration: 1000
            }
        }
        ParallelAnimation {
            ColorAnimation {
                from: Style.colorListIconRecording
                to: Style.colorListIconStandard
                duration: 1000
            }
            NumberAnimation {
                target: icon
                property: "scale"
                from: 1.1
                to: 1.0
//                property: "font.pointSize"
//                from: Style.pointSizeListIcon * 1.2
//                to: Style.pointSizeListIcon
                duration: 1000
            }
        }
    }

    onStateChanged: {
        console.log("CheckIcon.qml on StateChanged",state)
    }
*/
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: rec.gradient = Style.gradientListHover
        onExited: rec.gradient = Style.gradientList
        onClicked: iconClicked()
    }
}
