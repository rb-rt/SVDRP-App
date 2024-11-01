import QtQuick 2.15
import QtQuick.Layouts 1.15

import assets 1.0

Rectangle {

    property date datum //: new Date()

//    onDatumChanged: console.log("DateTimeTumbler.qml onDatumChanged",datum)

    color: "transparent"
    implicitHeight: rowLayout.height + 2
    implicitWidth: rowLayout.width + 2
    border.color: Style.colorPrimary
    border.width: 1

    function setDate() {
        datum = new Date(yearTumbler.year, monthTumbler.month, dayTumbler.day+1, hourTumbler.hour, minuteTumbler.minute)
    }

    RowLayout {
        id: rowLayout
        spacing: 1
        anchors.centerIn: parent

        DayTumbler {
            id:dayTumbler
            day: datum.getDate() - 1
            month: monthTumbler.month
            year: yearTumbler.year
            onDayChanged: {
                if (day !== datum.getDate()-1) setDate()
            }
        }

        MonthTumbler {
            id:monthTumbler
            month: datum.getMonth()
            onMonthChanged: if (month !== datum.getMonth()) setDate()
        }

        YearTumbler {
            id: yearTumbler
            year: datum.getFullYear()
            onYearChanged: if (year !== datum.getFullYear()) setDate()
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 3
            color: "transparent"
        }

        HourTumbler {
            id:hourTumbler
            hour: datum.getHours()
            onHourChanged: if (hour !== datum.getHours()) setDate()
        }

        MinuteTumbler {
            id:minuteTumbler
            minute: datum.getMinutes()
            onMinuteChanged: if (minute !== datum.getMinutes()) setDate()
        }
    }
}
