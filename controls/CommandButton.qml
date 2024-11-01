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

    //Breite wird nur mit background berechnet, ohne wird implicitWidth aus T.ToolButton (40 bzw. 48)genommen
    background: Rectangle {
        id: bkg
        color: "transparent"
        states: [
            State {
                when: toolButton.highlighted
                PropertyChanges {
                    target: bkg
                    color: Qt.darker(Style.colorPrimary, 1.2)
                }
            },
            State {
                when: toolButton.down
                PropertyChanges {
                    target: bkg
                    color: Qt.lighter(Style.colorPrimary, 1.2)
                }
            },
            State {
                when: toolButton.checked
                PropertyChanges {
                    target: bkg
                    color: Qt.darker(Style.colorPrimary, 1.2)
                }
            }
        ]
    }

    signal commandButtonClicked()

    contentItem: ColumnLayout {
        implicitWidth: Math.max(textIcon.implicitWidth, textLabel.implicitWidth)
        Label {
            id: textIcon
            text: "Icon"
            font {
                family: toolButton.fontSolid ? Style.faSolid : Style.faRegular
                pointSize: Style.pointSizeLarge
            }
            Layout.alignment: Qt.AlignHCenter
        }
        Label {
            id: textLabel
            text: "Button"
            Layout.alignment: Qt.AlignHCenter
            font.pointSize: Style.pointSizeSmall
        }
    }
    onClicked: commandButtonClicked()
}
