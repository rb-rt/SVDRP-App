import QtQuick
import QtQuick.Controls

import assets
import dialogs
import controls as MyControls

Item {
    id: root

    property string time //20:15

    // onTimeChanged: console.log("TimeSpinBox onTimeChanged",time)

    implicitWidth: spinBox.width + rec.width + rec.anchors.leftMargin
    implicitHeight: spinBox.height

    MyControls.SpinBox {
        id: spinBox

        from: 0
        to: timeToInt("23:59", locale)   // 1439 //23h * 60m + 59m
        value: timeToInt(time, locale)        

        // editable: true
        inputMethodHints: Qt.ImhTime

        textFromValue: function(value) {
            // console.log("textFromValue",value, intToTime(value))
            return intToTime(value)
        }
        valueFromText: function(text, locale) {
            // console.log("valueFromText",text, timeToInt(text, locale))
            return timeToInt(text, locale)
        }

        function timeToInt(time, locale) {
            // console.log("timeToInt",time)
            if (time.length === 0) return 0
            var d = Date.fromLocaleTimeString(locale, time, "hh:mm")
            var h = d.getHours();
            var m = d. getMinutes()
            return h * 60 + m
        }
        function intToTime(i) {
            // console.log("intToTime",i)
            var h = Math.floor(value / 60)
            if (h < 10) h = "0" + h
            var m = value % 60
            if (m < 10) m = "0" + m
            return  h + ":" + m
        }

        onValueChanged: {
            // console.log("onValueChanged",value)
            time = intToTime(value)
        }

        onActiveFocusChanged: {
            console.log("onActiveFocusChanged SpinBox", activeFocus)
            if (activeFocus) rec.focus = true
        }
    }
    Rectangle {
        id: rec
        height: spinBox.height
        width: height
        anchors.left: spinBox.right
        anchors.leftMargin: 12
        color: "transparent"
        border.width: 2
        border.color: spinBox.enabled ? spinBox.Universal.chromeDisabledLowColor: spinBox.Universal.baseLowColor
        states: State {
            name: "hover"
            PropertyChanges {
                target: rec
                border.color: spinBox.Universal.baseMediumColor
            }
        }
        Label {
            id: startIcon
            anchors.fill: parent
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: Style.iconClock
            font.pointSize: Style.pointSizeDialogIcon
            font.family: Style.faRegular
            color: spinBox.Universal.baseMediumColor
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: root.enabled
            onEntered: rec.state = "hover"
            onExited: rec.state = ""
            onClicked: {
                tumbler.open()
            }
        }
        // onWidthChanged: console.log("rec",width,anchors.leftMargin)
    }

    TimeTumblerDlg {
        id: tumbler
        time: root.time
        parent: Overlay.overlay
        onAccepted: root.time = time
    }

    //Stellt das Bindung wieder her bei tumbler.onAccepted
    Binding {
        target: tumbler
        property: "time"
        value: root.time
    }
}
