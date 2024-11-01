import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0

MenuItem {
    id: menuItem
    property alias iconCharacter: labelIcon.text
    property alias iconColor: labelIcon.color
    property alias iconFont: labelIcon.font.family
    property alias description: labelText.text
    property bool isLabel: false

    signal menuItemClicked()

    indicator: Label {
        id: labelIcon
        visible: !isLabel
        font.pointSize: Style.pointSizeDialogIcon
        anchors.verticalCenter: parent.verticalCenter
        leftPadding: parent.leftPadding
    }

    contentItem: Label {
            id: labelText
            font.pointSize: Style.pointSizeStandard
            font.bold: isLabel ? true : false
            leftPadding: menuItem.indicator.width
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

    background: Rectangle {
        color: isLabel ? Qt.darker(Style.colorCommandBarBackground,1.2) : (menuItem.highlighted ? Qt.darker(Style.colorCommandBarBackground) : Style.colorCommandBarBackground)
    }

    onTriggered: if (!isLabel) menuItemClicked()
}
