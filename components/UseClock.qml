import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import assets 1.0
import controls

GroupBox {
    property alias useTime: gbLabel.checked
    property string start //z.B. 20:15
    property string stop

    onStartChanged: {
        console.log("UseClock.qml onStartChanged",start, "SpinBox", timeSpinBoxStart.time)
        if (start.length === 0) start = "00:00"
        if (start !== timeSpinBoxStart.time) timeSpinBoxStart.time = start
    }
    onStopChanged: {
        //        console.log("UseClock.qml onStopChanged",stop)
        if (stop.length === 0) stop = "23:59"
        if (stop !== timeSpinBoxStop.time) timeSpinBoxStop.time = stop
    }

    width: parent.width

    font.pointSize: Style.pointSizeStandard
    label: CheckBox {
        id: gbLabel
        text: qsTr("Verwende Uhrzeit:")
    }

    GridLayout {
        columns: 2
        columnSpacing: 20
        rowSpacing: 10
        enabled: gbLabel.checked
        // verticalItemAlignment: Grid.AlignVCenter

        Label {
            text: qsTr("Start nach:")
            font.pointSize: Style.pointSizeStandard
        }
        TimeSpinBox {
            id: timeSpinBoxStart
            time: start
            onTimeChanged: {
                console.log("UseClock Start onTimeChanged", time, "start",start)
                start = time
            }
        }


        Label {
            text: qsTr("Start vor:")
            font.pointSize: Style.pointSizeStandard
        }
        TimeSpinBox {
            id: timeSpinBoxStop
            time: stop
            onTimeChanged: {
                console.log("UseClock Stop onTimeChanged", time)
                stop = time
            }
        }
    }
}

