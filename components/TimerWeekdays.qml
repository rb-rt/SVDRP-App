import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

Flow {

    property string weekdays: "-------"

    width: parent.width
    spacing: 10


    CheckBox {
        id: montag
        text: qsTr("Montag")
        font.pointSize: Style.pointSizeStandard
        checked: weekdays[0] === "M"
//        onCheckedChanged: setWeekday(0, checked) //Binding Loop!
        onClicked: setWeekday(0, checked)
    }

    CheckBox {
        id: dienstag
        text: qsTr("Dienstag")
        font.pointSize: Style.pointSizeStandard
        checked: weekdays[1] === "T"
        onClicked: setWeekday(1, checked)
    }
    CheckBox {
        id: mittwoch
        text: qsTr("Mittwoch")
        font.pointSize: Style.pointSizeStandard
        checked: weekdays[2] === "W"
        onClicked: setWeekday(2, checked)
    }

    CheckBox {
        id: donnerstag
        text: qsTr("Donnerstag")
        font.pointSize: Style.pointSizeStandard
        checked: weekdays[3] === "T"
        onClicked: setWeekday(3, checked)
    }
    CheckBox {
        id: freitag
        text: qsTr("Freitag")
        font.pointSize: Style.pointSizeStandard
        checked: weekdays[4] === "F"
        onClicked: setWeekday(4, checked)
    }
    CheckBox {
        id: samstag
        text: qsTr("Samstag")
        font.pointSize: Style.pointSizeStandard
        checked: weekdays[5] === "S"
        onClicked: setWeekday(5, checked)
    }
    CheckBox {
        id: sonntag
        text: qsTr("Sonntag")
        font.pointSize: Style.pointSizeStandard
        checked: weekdays[6] === "S"
        onClicked: setWeekday(6, checked)
    }


    function setWeekday(index, checked) {
        if (index === 0) {
            var str2 = weekdays.substring(index+1)
            var str1 = "-"
            if (checked) str1 = "M"
            weekdays = str1 + str2
        }
        else if (index === 6) {
            str1 = weekdays.substring(0,index)
            str2 = "-"
            if (checked) str2 = "S"
            weekdays = str1 + str2

        }
        else {
            str1 = weekdays.substring(0,index)
            str2 = weekdays.substring(index+1)
            var str = "-"
            if (checked) str = getWeekday(index)
            weekdays = str1 + str + str2
        }
    }

    function getWeekday(index) {
        var day = "-"
        switch (index) {
        case 0 : day = "M";
            break;
        case 1 : day = "T"
            break;
        case 2: day = "W"
            break;
        case 3: day = "T"
            break;
        case 4: day = "F"
            break;
        case 5: day = "S"
            break;
        case 6: day = "S"
        }
        return day;
    }
}
