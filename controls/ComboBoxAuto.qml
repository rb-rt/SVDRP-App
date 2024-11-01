import QtQuick
import QtQuick.Controls
import assets 1.0

//Paßt die Höhe automatisch an (Schriftgröße) im Gegensatz zum Original

ComboBox {
    id: comboBox
    font.pointSize: Style.pointSizeStandard
    implicitHeight: Math.max(32, contentItem.contentHeight + contentItem.bottomPadding + contentItem.topPadding) //32 aus SpinBox
    popup.font: comboBox.font
    implicitContentWidthPolicy: ComboBox.WidestTextWhenCompleted
}

