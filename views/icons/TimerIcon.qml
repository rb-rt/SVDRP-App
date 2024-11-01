import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

Label {
    id: icon

    //Timericon "Glocke" für die Programmlisten

    property bool mainTime: false
    property bool exists: false
    property int flags: 0

    signal iconClicked()

    text: Style.iconTimer

    leftPadding: Style.listIconPadding
    rightPadding: Style.listIconPadding
    font {
        family: icon.exists ? Style.faSolid : Style.faRegular
        pointSize: Style.pointSizeListIcon
    }
    color: Style.colorListIconStandard
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignHCenter
    background: Rectangle {
        id: rec
        gradient: Style.gradientList
        states: [
            State {
                name: "hover"
                PropertyChanges {
                    target: rec
                    gradient: Style.gradientListHover
                }
            },
            State {
                when: mainTime
                name: "maintime"
                PropertyChanges {
                    target: rec
                    gradient: Style.gradientListMainTime
                }
            }
        ]
    }

    states: [
        State {
            when: flags == 0
            name: "inactive"
            PropertyChanges {
                target: icon
                color: Style.colorListIconInactive
            }
        },
        State {
            when: flags == 1
            name: "active"
            PropertyChanges {
                target: icon
                color: Style.colorListIconActive
            }
        },
        State {
            when: flags == 2
            name: "instant"
            PropertyChanges {
                target: icon
                color: Style.colorListIconAction
            }
        },
        State {
            when: flags == 9
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
        to: "recording"
        onRunningChanged: console.log("TimerIcon.qml Transition",running)
        SequentialAnimation {
            loops: Animation.Infinite
            ColorAnimation {
                duration: 1000
            }
            ColorAnimation {
                duration: 1000
                to: Style.colorListIconStandard
            }
        }
        //        PropertyAnimation {
        //            target: icon
        //            property: "color"
        //            from: "white"
        //            to: "black"
        //            duration: 1000
        //            onStarted: console.log("CheckIcon.qml Transition onStarted")
        //        }
    }*/

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: rec.state = "hover"
        onExited: mainTime ? rec.state = "maintime" : rec.state = ""
        onClicked: iconClicked()
    }
}
