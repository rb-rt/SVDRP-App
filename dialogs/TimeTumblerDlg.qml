import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import components 1.0
import assets 1.0
import "subs"

Dialog {

    property string time //20:15

    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.NoAutoClose

    header: DialogHeaderToolBar {
        icon: Style.iconClock
        text: time
    }

    function formatTime(h,m) {
        if (m < 10) m = "0" + m
        if (h < 10) h = "0" + h
        return h + ":" + m
    }

    contentItem:
        ColumnLayout {
            TimeTumbler {
                id: timeTumbler
                Layout.alignment: Qt.AlignHCenter
            }
    }

    footer: DialogFooterToolBar {
        onOkClicked: {
            time = formatTime(timeTumbler.hours, timeTumbler.minutes)
            accept()
        }
    }

    onTimeChanged: {
        var d = Date.fromLocaleTimeString(locale, time, "hh:mm")
        timeTumbler.hours = d.getHours()
        timeTumbler.minutes = d.getMinutes()
    }

}
