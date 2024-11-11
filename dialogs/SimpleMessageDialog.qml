import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import assets

Dialog {

    property alias titleText: titleLabel.text
    property alias text: label.text

    modal: true
    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.NoAutoClose

    header: ToolBar {

        background: Rectangle {
            anchors.fill: parent
            color: Style.colorPrimary
            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                border.color: Qt.darker(parent.color)
            }
        }

        RowLayout {

            anchors.fill: parent

            Label {
                id: titleLabel
                text: "Header fehlt"
                font.pointSize: Style.pointSizeStandard
                leftPadding: 10
                rightPadding: 10
                elide: Text.ElideRight
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.fillWidth: true
            }

        }
    }

    contentItem: Label {
        id: label
        font.pointSize: Style.pointSizeStandard
    }

    footer: DialogButtonBox {
        font.pointSize: Style.pointSizeStandard
        alignment: Qt.AlignHCenter
        topPadding: 6
        bottomPadding: 6

        background: Rectangle {
            color: Qt.darker(Style.colorPrimary, 1.5)
            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.top
                color: Qt.lighter(parent.color)
            }
        }
    }

}
