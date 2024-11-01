import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts 1.15
import assets 1.0
import controls 1.0 as MyControls

ColumnLayout {
    id: root

    property date selectedDate: new Date()

    // onSelectedDateChanged: {
    //     console.log("Kalender onSelectedDateChanged",selectedDate)
    // }


/*
    //Ohne Rectangle: Binding loop detected for property "implicitHeight" (!?)
    Rectangle {
        //            color: "green"
        Layout.fillWidth: true
        //            height: 3
    }
*/
    RowLayout {
        width: parent.width

        MyControls.SpinBox {
            id: monthBox
            Layout.fillWidth: true
            font: monthGrid.font
            from: 0
            to: 11
            value: selectedDate.getMonth()
            contentItem: Label {
                text: monthGrid.locale.monthName(monthBox.value,Locale.ShortFormat)
                horizontalAlignment: Qt.AlignHCenter
            }
            onValueChanged: selectedDate.setMonth(value)
        }
        MyControls.SpinBox {
            id: yearBox
            Layout.fillWidth: true
            font: monthGrid.font
            value: selectedDate.getFullYear()
            from: value - 1
            to: value + 1
            onValueChanged: selectedDate.setFullYear(value)
            contentItem: Label {
                text: yearBox.value
                horizontalAlignment: Qt.AlignHCenter
                font: monthGrid.font
            }
        }
    }

    DayOfWeekRow {
        id: dayOfWeek
        locale: monthGrid.locale

        font: monthGrid.font
        Layout.fillWidth: true
        Layout.topMargin: 20
        delegate: Label {
            text: model.shortName
        }
    }


    MonthGrid {
        id: monthGrid
        month: monthBox.value
        year: yearBox.value

        locale: Qt.locale("de_DE")
        //                locale: Qt.locale("en_EN")

        Layout.fillWidth: true
        Layout.fillHeight: true

        spacing: 0
        font.pointSize: Style.pointSizeStandard

        delegate: Label {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: model.month === monthGrid.month ? 1 : 0.3
            text: model.day
            font: monthGrid.font
            padding: Style.pointSizeSmall

            required property var model

            background: Rectangle {
                id: background
                anchors.fill: parent
                border.width: 1
                border.color: Style.colorPrimary
                gradient: Style.gradientList
                states: [
                    State {
                        when: model.day === selectedDate.getDate()
                        PropertyChanges {
                            target: background
                            gradient: Style.gradientTageswechsel
                        }
                    },
                    State {
                        when: model.today
                        PropertyChanges {
                            target: background
                            border.color: Style.colorAccent
                            border.width: 2
                            // color: Qt.lighter(Style.colorBackground, 2.0)
                            // gradient: undefined
                        }
                    }
                ]
            }
        }

        onClicked: function (date) {
            console.log("MonthGrid onClicked",date)
            selectedDate = date
        }
    }

    Button {
        text: "Heute"
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20

        font.pointSize: Style.pointSizeStandard
        onClicked: selectedDate = new Date()
    }
}

