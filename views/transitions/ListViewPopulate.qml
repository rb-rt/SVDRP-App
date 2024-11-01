import QtQuick 2.15

Transition {
    NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.InQuad }
    // onRunningChanged: console.log("ListViewPopulate")
}
