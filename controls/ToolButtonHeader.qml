import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

ToolButton {
    text: stackView.depth > 1 ? Style.iconChevron : Style.iconBars
    font.family: Style.faSolid
    // font.pointSize: Style.pointSizeHeader
    onClicked: stackView.depth > 1 ? stackView.pop() : drawer.open()
}
