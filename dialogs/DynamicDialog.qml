import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import assets
import "subs"

Dialog {
    id: root

    property alias titleText: titleLabel.text
    property alias headerIcon: labelIcon.text
    property bool fontSolid: true
    property bool showCloseIcon: false
    property alias contentComponent: contentLoader.sourceComponent //verhindert binding loop für implicitHeight

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
                id: labelIcon
                Layout.fillHeight: true
                Layout.preferredWidth: parent.height
                Layout.bottomMargin: 1
                leftPadding: 10
                rightPadding: 10
                verticalAlignment: Qt.AlignVCenter
                visible: text.length > 0
                font.family: root.fontSolid ? Style.faSolid : Style.faRegular
                font.pointSize: Style.pointSizeLarge
            }

            Label {
                id: titleLabel
                text: "Header fehlt"
                font.pointSize: Style.pointSizeStandard
                leftPadding: labelIcon.visible ? 0 : 10
                rightPadding: 10
                elide: Text.ElideRight
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.fillWidth: true
            }
            DialogCloseIcon {
                Layout.fillHeight: true
                Layout.bottomMargin: 1
                Layout.preferredWidth: parent.height
                visible: root.showCloseIcon
            }
        }
    }

    contentItem: Loader {
        id: contentLoader
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

