import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0

ToolBar {
    id: toolBar

    signal okClicked()

    implicitHeight: 48

    background: Rectangle {
        color: Qt.darker(Style.colorPrimary, 1.5)
        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.top
            color: Qt.lighter(parent.color)
        }
    }

    Button {
        anchors.centerIn: parent
        text: qsTr("Ok")
        font.pointSize: Style.pointSizeStandard
        width: (parent.width / 4) > implicitWidth ? parent.width / 4 : implicitWidth
        implicitWidth: 64
        onClicked: toolBar.okClicked()
    }
}


