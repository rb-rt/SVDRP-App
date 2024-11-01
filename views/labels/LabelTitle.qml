import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

Label {
    id: label
    elide: Text.ElideRight
    font.pointSize: Style.pointSizeStandard
    font.weight: Font.Medium
    states: [
        State {
            name: "ohneEpg"
            PropertyChanges {
                target: label
                font.weight: Font.Thin
                font.pointSize: Style.pointSizeSmall
            }
        }
    ]
    // Component.onCompleted: console.log("LabelTitle.qml Weight",font.weight)
}
