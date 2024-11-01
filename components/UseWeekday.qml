import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0


GroupBox {

    property alias useWeekday: gbLabel.checked
    property int weekdays

    font.pointSize: Style.pointSizeStandard //Wird durchgereicht
    label: CheckBox {
        id: gbLabel
        checked: false
        text: qsTr("Verwende Wochentag:")
    }
    width: parent.width

    Flow {
        width: parent.width
        spacing: 10

        enabled: gbLabel.checked
        CheckBox {
            id: monday
            text: qsTr("Montag")
            checked: weekdays & 2
            onCheckedChanged: checked ? weekdays = weekdays | 2 : weekdays = weekdays & ~ 2
        }
        CheckBox {
            id: tuesday
            text: qsTr("Dienstag")
            checked: weekdays & 4
            onCheckedChanged: checked ? weekdays = weekdays | 4 : weekdays = weekdays & ~ 4
        }
        CheckBox {
            id: wednesday
            text: qsTr("Mittwoch")
            checked: weekdays & 8
            onCheckedChanged: checked ? weekdays = weekdays | 8 : weekdays = weekdays & ~ 8
        }
        CheckBox {
            id: thursday
            text: qsTr("Donnerstag")
            checked: weekdays & 16
            onCheckedChanged: checked ? weekdays = weekdays | 16 : weekdays = weekdays & ~ 16
        }
        CheckBox {
            id: friday
            text: qsTr("Freitag")
            checked: weekdays & 32
            onCheckedChanged: checked ? weekdays = weekdays | 32 : weekdays = weekdays & ~ 32
        }
        CheckBox {
            id: saturday
            text: qsTr("Samstag")
            checked: weekdays & 64
            onCheckedChanged: checked ? weekdays = weekdays | 64 : weekdays = weekdays & ~ 64
        }
        CheckBox {
            id: sunday
            text: qsTr("Sonntag")
            checked: weekdays & 1
            onCheckedChanged: checked ? weekdays = weekdays | 1 : weekdays = weekdays & ~ 1
        }
    }
}

