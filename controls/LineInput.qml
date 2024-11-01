import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15

import assets 1.0

FocusScope {
    id: wrapper

    property alias placeholderText: hint.text
    property alias text: input.text
    property alias textInput: input

//    implicitHeight: 40
    implicitWidth: 200
    implicitHeight: Math.max(input.implicitHeight, 32) //32 wie in SpinBox

    Rectangle {
        id: rec

        anchors.fill: parent
        border.color: !wrapper.enabled ? wrapper.Universal.baseLowColor :
                       wrapper.activeFocus ? wrapper.Universal.accent :
                       wrapper.hovered ? wrapper.Universal.baseMediumColor : wrapper.Universal.chromeDisabledLowColor
        border.width: 2
        color: Style.colorBackground

        Label {
            id: hint
            anchors.fill: input
            verticalAlignment: Text.AlignVCenter
            font.pointSize: input.font.pointSize
            opacity: 0.5
            visible: input.displayText.length === 0 && !input.activeFocus
        }

        //s. auch ComboBoxAuto.qml
        TextInput {
            id: input
            focus: false

            anchors {
                left: rec.left
                right: image.left
//                top:parent.top
//                bottom: parent.bottom
                leftMargin: 12
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            topPadding: 5
            bottomPadding: 7

            enabled: wrapper.enabled
            opacity: enabled ? 1.0 : 0.5
            color: Style.colorForeground
            font.pointSize: Style.pointSizeStandard
            clip: true // contentWidth > width

            //Workaround für Android -> signal textChanged wird sonst nicht ausgelöst, erst bei Enter
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
        }

        //Deletekreuz
        Rectangle {
            id: image
            width: parent.height
            height: parent.height
            anchors.right: rec.right
            color: "transparent"
            anchors.verticalCenter: input.verticalCenter

            states: [
                State {
                    name: "hover"
                    PropertyChanges {
                        target: deleteLabel
                        font.pointSize: Style.pointSizeLarge
                    }
                }
            ]

            Label {
                id: deleteLabel
                text: Style.iconTimes
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                color: Style.colorDelete
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: image.state = "hover"
                onExited: image.state = ""
                onClicked: {
                    input.clear()
                    wrapper.focus = true
                }
            }
        }
    }
}
