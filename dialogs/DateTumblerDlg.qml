import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
//import QtQuick.Extras 1.4

import assets 1.0
import components 1.0

Dialog {
    id: root
    property date datum
//    property alias datum: dateTumbler.datum

    onDatumChanged: {
        console.log("DateTumblerDlg.qml onDatumChanged",datum)
//        dateTumbler.datum = datum
    }

    anchors.centerIn: parent

    background: Rectangle {
        color: Style.colorBackground
    }

    modal: true

    header: ToolBar {

        padding: 1
        height: Style.fixedDialogHeightHeader

        background: Rectangle {
            height: parent.height
            color: Style.colorPrimary
//            color: "red"

            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
                color: "transparent"
                border.color: Qt.darker(parent.color)
            }
        }

        RowLayout {
            anchors.fill: parent

            Label {
                id: icon
                text: Style.iconClock
                font.family: Style.faRegular
                font.pointSize: Style.pointSizeHeader
                Layout.leftMargin: 10
                Layout.rightMargin: 10
            }
            Label {
                text: Qt.formatDate(dateTumbler.datum, "ddd. dd.MM.yyyy")
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
            }
            Rectangle {
                id: deleteRec
                Layout.preferredWidth: parent.height
                Layout.preferredHeight: parent.height
                Layout.alignment: Qt.AlignRight
                color: "transparent"
//                                color: "crimson"
                Layout.bottomMargin: 1
                Layout.fillHeight: true
                Label {
                    anchors.centerIn: parent
                    text: Style.iconTimes
                    font.family: Style.faSolid
                    font.pointSize: Style.pointSizeHeader
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: deleteRec.color = Style.colorDelete
                    onExited: deleteRec.color = "transparent"
                    onClicked: reject()
                }
            }
        }
    }

    contentItem: DateTumbler {
                id: dateTumbler
                datum: root.datum
//                onDatumChanged: root.datum = datum
            }        


    standardButtons: Dialog.Ok
    footer: DialogButtonBox {
        id: footer
        font.pointSize: Style.pointSizeStandard
        alignment: Qt.AlignBottom | Qt.AlignHCenter
    }

    onAccepted: {
        console.log("DateTumblerDlg.qml onAccepted")
        datum = dateTumbler.datum
    }
    onRejected: {
        console.log("DateTumblerDlg.qml onRejected datetumbler.datum:",dateTumbler.datum,"datum",datum)
        dateTumbler.datum = root.datum
    }
}
