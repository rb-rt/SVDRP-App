import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0

ToolBar {

    property alias icon: icon.text
    property alias text: label.text

    background: Rectangle {
        color: Style.colorPrimary

        Rectangle {
            width: parent.width
            height: 1
            anchors.bottom: parent.bottom
            color: Qt.lighter(parent.color)
        }
    }

    RowLayout {
        width: parent.width

        Label {
            id: icon
            font.family: Style.faRegular
            font.pointSize: Style.pointSizeLarge
            Layout.leftMargin: 10
            Layout.topMargin: 10
            Layout.bottomMargin: 10
        }
        Label {
            id: label
            font.pointSize: Style.pointSizeStandard
            Layout.fillWidth: true
            Layout.leftMargin: 10
        }
        DialogCloseIcon {
            Layout.fillHeight: true
            Layout.bottomMargin: 1
            Layout.preferredWidth: parent.height
        }
    }
}
