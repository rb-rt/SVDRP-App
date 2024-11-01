import QtQuick

Transition {
    NumberAnimation { properties: "x,y"; duration: 600; easing.type: Easing.OutBack }
    onRunningChanged: console.log("ListViewRemoveDisplaced")
}
