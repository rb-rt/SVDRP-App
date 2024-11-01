import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Controls.Universal
import assets

Controls.SpinBox {
    id: control

    Universal.theme: Universal.Dark //Ändert sich im Original bei Focuswechsel!

    // Note: the width of the indicators are calculated into the padding
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             up.implicitIndicatorHeight, down.implicitIndicatorHeight)

    spacing: 4
    topPadding: 8
    bottomPadding: 8
    leftPadding: control.mirrored ? (up.indicator ? up.indicator.width : 0) : (down.indicator ? down.indicator.width : 0)
    rightPadding: control.mirrored ? (down.indicator ? down.indicator.width : 0) : (up.indicator ? up.indicator.width : 0)

    validator: IntValidator {
        locale: control.locale.name
        bottom: Math.min(control.from, control.to)
        top: Math.max(control.from, control.to)
    }

    contentItem: TextInput {
        text: control.displayText
        // font: control.font
        font.pointSize: Style.pointSizeStandard
        color: !enabled ? control.Universal.chromeDisabledLowColor : control.Universal.foreground
        selectionColor: control.Universal.accent
        selectedTextColor: control.Universal.chromeWhiteColor
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints
        clip: width < implicitWidth        
    }

    up.indicator: Item {
        x: control.mirrored ? 0 : control.width - width
        // implicitWidth: 36
        // implicitHeight: 36
        implicitWidth: 32
        implicitHeight: 32
        height: control.height
        width: height

        Rectangle {
            x: control.spacing
            y: control.spacing
            width: parent.width - 2 * control.spacing
            height: parent.height - 2 * control.spacing
            color: control.activeFocus ? control.Universal.chromeHighColor :
                   control.up.pressed ? control.Universal.baseMediumLowColor :
                   control.up.hovered ? control.Universal.baseLowColor : "transparent"
        }

        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: Math.min(parent.width / 3, parent.height / 3)
            height: 2
            color: !enabled ? control.Universal.chromeDisabledLowColor : control.Universal.baseHighColor
        }
        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: 2
            height: Math.min(parent.width / 3, parent.height / 3)
            color: !enabled ? control.Universal.chromeDisabledLowColor : control.Universal.baseHighColor
        }
    }

    down.indicator: Item {
        x: control.mirrored ? control.width - width : 0
        // implicitHeight: 36
        // implicitWidth: 36
        implicitHeight: 32
        implicitWidth: 32

        height: control.height
        width: height

        Rectangle {
            x: control.spacing
            y: control.spacing
            width: parent.width - 2 * control.spacing
            height: parent.height - 2 * control.spacing
            color: control.activeFocus ? control.Universal.chromeHighColor :
                   control.down.pressed ? control.Universal.baseMediumLowColor :
                   control.down.hovered ? control.Universal.baseLowColor : "transparent"
        }

        Rectangle {
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            width: parent.width / 3
            height: 2
            color: !enabled ? control.Universal.chromeDisabledLowColor : control.Universal.baseHighColor
        }
    }

    background: Rectangle {
        // implicitWidth: 140
        // implicitHeight: 36
        implicitWidth: 88
        implicitHeight: 32
        border.width: 2
        border.color: !control.enabled ? control.Universal.baseLowColor :
                       control.activeFocus ? control.Universal.accent :
                       control.hovered ? control.Universal.baseMediumColor : control.Universal.chromeDisabledLowColor
        color: control.enabled ? control.Universal.background : control.Universal.baseLowColor
    }

}
