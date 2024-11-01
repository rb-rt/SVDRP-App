import QtQuick 2.15
import QtQuick.Controls 2.15
import assets 1.0

Dialog {

    property alias titleText: titleLabel.text
    property alias text: label.text
    property bool simple: false //True setzen bei nur einem Button (Close)

    modal: true
    anchors.centerIn: parent
    //    width: parent.width  * 0.66
    parent: Overlay.overlay

    header: ToolBar {

        background: Rectangle {
            color: Style.colorPrimary
            implicitHeight: 48 //aus Universal Template, notwendig!?

            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "transparent"
                border.color: Qt.darker(parent.color)
            }
        }

        Label {
            id: titleLabel
            text: "Header fehlt"
            font.pointSize: Style.pointSizeStandard
            verticalAlignment: Qt.AlignVCenter
            leftPadding: 10
            elide: Text.ElideRight
            height: parent.height
        }
    }

    Label {
        id: label
        font.pointSize: Style.pointSizeStandard
        width: parent.width
        wrapMode: Text.WordWrap
    }

    footer: DialogButtonBox {
        standardButtons: simple ? Dialog.Close : Dialog.Yes | Dialog.Cancel
        font.pointSize: Style.pointSizeStandard
        verticalPadding: 0
        implicitHeight: 72
        // alignment: simple ? Qt.AlignBottom | Qt.AlignHCenter : Qt.AlignCenter | Qt.AlignBottom
        alignment: Qt.AlignCenter | Qt.AlignBottom

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
