import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import assets
import "subs"

Dialog {
    id: dlg
    modal: true
    anchors.centerIn: Overlay.overlay

    property alias titleText: titleLabel.text
    property alias contentComponent: contentLoader.sourceComponent

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

            DialogCloseIcon {
                Layout.fillHeight: true
                Layout.preferredWidth: parent.height
                Layout.bottomMargin: 1
                visible: dialogButtonBox.count <= 1
            }
        }

    }

    onContentWidthChanged: console.log("contentWidth",contentWidth)
    onContentHeightChanged: console.log("contentHeight",contentHeight)
    onHeightChanged: console.log("height",height)
    onImplicitBackgroundHeightChanged: console.log("onImplicitBackgroundHeightChanged",implicitBackgroundHeight)
    onImplicitContentHeightChanged: console.log("onImplicitContentHeightChanged",implicitContentHeight)

    contentItem: Loader {
        id: contentLoader
    }


    footer: DialogButtonBox {
        id: dialogButtonBox
        font.pointSize: Style.pointSizeStandard
        alignment: Qt.AlignHCenter

        onHeightChanged: console.log("Footer onHeightChanged",height)
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

