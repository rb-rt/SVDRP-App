import QtQuick 2.15
import QtQuick.Controls 2.15

Slider {
    id: control

    //value entspricht dem Farbwert laut HSV-Farbmodel (0 - 1)

    background: Rectangle {
        id: background
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitHeight: 32
        width: control.availableWidth
        radius: 2

        gradient: Gradient {
            orientation: control.orientation
            GradientStop { position: 0.0;  color: "#FF0000" }
            GradientStop { position: 60/360; color: "#FFFF00" }
            GradientStop { position: 120/360; color: "#00FF00" }
            GradientStop { position: 180/360;  color: "#00FFFF" }
            GradientStop { position: 240/360; color: "#0000FF" }
            GradientStop { position: 300/360; color: "#FF00FF" }
            GradientStop { position: 1.0;  color: "#FF0000" }
        }
    }

    handle: Rectangle {
        id: handle
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: background.height / 2
        height: background.height + width
        radius: width / 4
        color: control.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbebf"
        border.width: 1
        opacity: 0.8
    }
}
