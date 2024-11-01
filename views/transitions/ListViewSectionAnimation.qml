import QtQuick 2.15


ParallelAnimation {
    id: animation
    property QtObject target
    PropertyAction { target: animation.target; property: "transformOrigin"; value: Item.Left }
    NumberAnimation { target: animation.target; property: "opacity"; from: 0; to: 1.0; duration: 400 }
    NumberAnimation { target: animation.target; property: "scale"; from: 0; to: 1.0; duration: 400 }
    // onStarted: console.log("Section Animation started")
    // onRunningChanged: console.log("Section Animation running",running)
}
