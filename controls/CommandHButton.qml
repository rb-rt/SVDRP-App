import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0

ToolButton {
    id: toolButton

    property alias iconCharacter: textIcon.text
    property alias description: textLabel.text
//    property alias textColor: textLabel.color
    property bool fontSolid: true

    signal commandButtonClicked()

    contentItem: RowLayout {
        Label {
            id: textIcon
            text: "Icon"
            font {
                family: toolButton.fontSolid ? Style.faSolid : Style.faRegular
                pointSize: Style.pointSizeStandard
            }
//            color: textLabel.color
            Layout.alignment: Qt.AlignVCenter
            Layout.topMargin: 5
            Layout.bottomMargin: 5
        }
        Label {
            id: textLabel
            text: "Button"
            Layout.alignment: Qt.AlignVCenter
            font.pointSize: Style.pointSizeStandard
            Layout.topMargin: 5
            Layout.bottomMargin: 5
        }
    }
    onClicked: commandButtonClicked()
}
