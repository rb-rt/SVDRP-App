import QtQuick 2.15
import QtQuick.Layouts 1.15

import components 1.0
import assets 1.0

Rectangle {

    property alias hours: hourTumbler.hour
    property alias minutes: minuteTumbler.minute


    implicitHeight: row.height + 2
    implicitWidth: row.width + 2

    border.color: Style.colorPrimary
    border.width: 1

    gradient: Style.gradientTumblerBackground

//    Rectangle {
//        width: parent.width
//        height: parent.height
//        color: "yellow"
//    }

    RowLayout {
        id: row
        spacing: 1
        anchors.centerIn: parent

        HourTumbler {
            id:hourTumbler
        }

        MinuteTumbler {
            id:minuteTumbler
        }
    }
}
