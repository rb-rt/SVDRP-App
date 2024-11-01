import QtQuick 2.15
import QtQuick.Layouts 1.15

import assets 1.0

Rectangle {
    id: root

    property date datum //: new Date()

    onDatumChanged: {
        console.log("DateTumbler.qml onDatumChanged",datum)
        if (datum.getDate() !== dayTumbler.day) dayTumbler.day = datum.getDate()
        if (datum.getMonth()+1 !== monthTumbler.month) monthTumbler.month = datum.getMonth() + 1
        if (datum.getFullYear() !== yearTumbler.year) yearTumbler.year = datum.getFullYear()
    }

//    property int day: datum.getDate()
//    property int month: datum.getMonth()
//    property int year: datum.getFullYear()

//    onDayChanged: {
//        console.log("DateTumbler onDayChanged",day)
//        if (dayTumbler.day !== day) dayTumbler.day = day
//    }
//    onMonthChanged: {
//        console.log("DateTumbler onMonthChanged",month)
//        if (month !== monthTumbler.month-1) monthTumbler.month = month + 1
//    }
//    onYearChanged: console.log("onYearChanged",year)

    color: "transparent"
    implicitHeight: rowLayout.height + 2
    implicitWidth: rowLayout.width + 2
    border.color: Style.colorPrimary
    border.width: 1

    function setDate() {
        datum = new Date(yearTumbler.year, monthTumbler.month-1, dayTumbler.day, 0,0)
    }

    RowLayout {
        id: rowLayout
        spacing: 1
        anchors.centerIn: parent

        DayTumbler {
            id:dayTumbler
//            day: datum.getDate()
            month: monthTumbler.month
            year: yearTumbler.year
            onDayChanged: {
                if (day !== datum.getDate()) setDate()
            }
        }

        MonthTumbler {
            id:monthTumbler
//            month: datum.getMonth() + 1
            onMonthChanged: if (month !== (datum.getMonth() + 1)) setDate()
        }

        YearTumbler {
            id: yearTumbler
//            year: datum.getFullYear()
            onYearChanged: if (year !== datum.getFullYear()) setDate()
        }
    }
}
