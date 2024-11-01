import QtQuick 2.15
import QtQuick.Controls 2.15
import models 1.0
import assets 1.0

Tumbler {
    id: tumbler

    property alias month: tumbler.currentIndex //month 0..11

    onCurrentIndexChanged: {
        console.log("MonthTumbler onCurrentIndexChanged",currentIndex)
        // var m = currentIndex + 1
        // if (month !== m) month = m
    }

    font.pointSize: Style.pointSizeStandard

    model: MonthModel {}

    background: Rectangle {
        anchors.fill: parent
        gradient: Style.gradientTumbler
    }

    Rectangle {
        anchors.horizontalCenter: tumbler.horizontalCenter
        y: tumbler.height * 0.4
        width: parent.width * 0.8
        height: 1
        color: Style.colorTumblerLine
    }
    Rectangle {
        anchors.horizontalCenter: tumbler.horizontalCenter
        y: tumbler.height * 0.6
        width: parent.width * 0.8
        height: 1
        color: Style.colorTumblerLine
    }

    delegate: Label {
        text: month_short
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: tumbler.font.pointSize
        opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler.visibleItemCount / 2)
    }

}
