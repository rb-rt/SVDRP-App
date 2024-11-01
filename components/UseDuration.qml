import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import controls 1.0 as MyControls

GroupBox {

    property alias useDuration: gbLabel.checked
    property alias durationMin: minValue.value //Werte in Minuten
    property alias durationMax: maxValue.value

    width: parent.width
    font.pointSize: Style.pointSizeStandard
    label: CheckBox {
        id: gbLabel
        checked: false
        text: qsTr("Verwende Dauer:")
    }

    GridLayout {
        columns: 3
        enabled: gbLabel.checked
        width: parent.width
        rowSpacing: 10

        Label {
            text: qsTr("Min. Dauer:")
            font.pointSize: Style.pointSizeStandard
        }
        MyControls.SpinBox {
            id: minValue
            value: 0
            from: 0
            to: 359
            stepSize: 1
            editable: true
            Layout.preferredWidth: Math.max(minValue.width,maxValue.width)
            onValueChanged: {
                if (minValue.value >= maxValue.value) minValue.value = maxValue.value-stepSize
            }
        }
        Label { text: "min."; font.pointSize: Style.pointSizeStandard }

        Label {
            id: name
            text: qsTr("Max. Dauer:")
            font.pointSize: Style.pointSizeStandard
        }
        MyControls.SpinBox {
            id: maxValue
            value: 90
            from: 1
            to: 360
            stepSize: 1
            editable: true
            Layout.preferredWidth: Math.max(minValue.width,maxValue.width)
            onValueChanged: {
                if (maxValue.value <= minValue.value) maxValue.value = minValue.value+stepSize
            }
        }
        Label { text: "min."; font.pointSize: Style.pointSizeStandard }
    }

}

