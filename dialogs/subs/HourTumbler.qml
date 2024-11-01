import QtQuick 2.15
import QtQuick.Controls 2.15
import assets 1.0

Tumbler {
    id: tumbler

    property alias hour: tumbler.currentIndex

    model: 24
    font.pointSize: Style.pointSizeStandard
//    visibleItemCount: 3

    property int itemCount: Math.floor(visibleItemCount / 2)
    property real itemHeight: 1 / visibleItemCount

    background: Rectangle {
        anchors.fill: parent
        color: "lightgreen"
        //            opacity: 0.3
        gradient: Style.gradientTumbler
    }

    Rectangle {
        id: rec1
        anchors.horizontalCenter: tumbler.horizontalCenter
        y: tumbler.height * tumbler.itemHeight * tumbler.itemCount
        width: parent.width * 0.8
        height: 1
        color: Style.colorTumblerLine
    }
    Rectangle {
        anchors.horizontalCenter: tumbler.horizontalCenter
        y: tumbler.height * (tumbler.itemCount + 1) * tumbler.itemHeight
        width: parent.width * 0.8
        height: 1
        color: Style.colorTumblerLine
    }

    delegate: Label {
        text: ("00" + (modelData)).slice(-2)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: tumbler.font.pointSize
        opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler.visibleItemCount / 2)
    }
}
