import QtQuick
import QtQuick.Controls

TextField {
    id: textField
    horizontalAlignment: TextField.AlignRight
    maximumLength: 3
    validator: IntValidator {
        bottom: 0
        top: 255
    }
    onActiveFocusChanged: if (!acceptableInput) focus = true
    states: [
        State {
            when: !acceptableInput
            PropertyChanges {
                target: textField
                color: "red"
            }
        }
    ]
}
