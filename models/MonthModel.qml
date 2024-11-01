import QtQuick 2.15

ListModel {
    id: monthModel
    ListElement { month: "Januar"; month_short: "Jan"; days: 31 }
    ListElement { month: "Februar"; month_short: "Feb"; days: 28 }
    ListElement { month: "März"; month_short: "Mrz"; days: 31 }
    ListElement { month: "April"; month_short: "Apr"; days: 30 }
    ListElement { month: "Mai"; month_short: "Mai"; days: 31 }
    ListElement { month: "Juni"; month_short: "Jun"; days: 30 }
    ListElement { month: "Juli"; month_short: "Jul"; days: 31 }
    ListElement { month: "August"; month_short: "Aug"; days: 31 }
    ListElement { month: "September"; month_short: "Sep"; days: 30 }
    ListElement { month: "Oktober"; month_short: "Okt"; days: 31 }
    ListElement { month: "November"; month_short: "Nov"; days: 30 }
    ListElement { month: "Dezember"; month_short: "Dez"; days: 31 }

    //Monat Januar = 0
    function getDays(month,year) {
        var isLeapYear = ((year % 4 == 0 && year % 100 != 0)) || (year % 400 == 0)
        if ( (month === 1) && (isLeapYear) ) return 29
        if (month < 0) return 31
        return monthModel.get(month).days
    }
}
