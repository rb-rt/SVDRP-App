import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0
import models 1.0

Tumbler {
    id: tumbler

    property alias day: tumbler.currentIndex ////0..28,29,30 (
    property int month //0..11
    property int year

    property int daysInMonth: monthModel.getDays(month,year)

    model: daysInMonth

    implicitWidth: 72

//    TextMetrics {
//        id: textMetrics
//        text: "Do. 99"
//        font: tumbler.font
//    }

//    Text {
//        id: ref
//        text: qsTr("Mo.  99")
//        visible: false
//        font: tumbler.font
//    }

    onDaysInMonthChanged: {
        var i = currentIndex
        tumbler.model = daysInMonth
        currentIndex = Math.min(i, daysInMonth - 1)
    }

    MonthModel {
        id: monthModel
    }

    font.pointSize: Style.pointSizeStandard

    background: Rectangle {
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

    delegate: RowLayout {
        opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler.visibleItemCount / 2)
        Label {
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 6
            text: weekDay
//            horizontalAlignment: Text.AlignHCenter
//            verticalAlignment: Text.AlignVCenter
            font.pointSize: tumbler.font.pointSize
//            opacity: 1.0 - Math.abs(Tumbler.displacement) / (tumbler.visibleItemCount / 2)
            property string weekDay: {
                var d = new Date(tumbler.year, tumbler.month, modelData+1).getDay()
                return Qt.locale("de_DE").dayName(d,Locale.ShortFormat)
            }
        }
        Label {
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 6
            text: ("00" + (modelData+1)).slice(-2)
            font.pointSize: tumbler.font.pointSize
        }
    }
}
