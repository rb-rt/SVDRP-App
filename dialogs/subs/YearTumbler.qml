import QtQuick 2.15
import QtQuick.Controls 2.15
import assets 1.0

Tumbler {
    id: tumbler

    property int year

    font.pointSize: Style.pointSizeStandard

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

    model: []

    delegate: Label {
        text: modelData
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pointSize: tumbler.font.pointSize
        opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler.visibleItemCount / 2)
    }

    currentIndex: 1

    onCurrentIndexChanged: {
        console.log("YearTumbler currentitem",currentItem.text)
        year = tumbler.currentItem.text
    }

    Component.onCompleted: {
        var years =[]
        var y = new Date().getFullYear()
        for(var i =- 1; i < 3; i++) years.push(y+i)
        model = years
        // currentIndex = 1
    }

}
