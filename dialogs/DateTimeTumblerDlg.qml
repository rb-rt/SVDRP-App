import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import components 1.0
import "subs"

Dialog {
    id: root

    property date datum

    anchors.centerIn: parent

//    background: Rectangle {
//        color: Style.colorBackground
//    }

    modal: true
    closePolicy: Popup.NoAutoClose

    header: DialogHeaderToolBar {
        icon: Style.iconClock
        text: qsTr("Zeige Sendungen ab")
    }

    /*
    header: ToolBar {

        background: Rectangle {
            color: Style.colorPrimary

            Rectangle {
                width: parent.width
                height: 1
                anchors.bottom: parent.bottom
//                color: "yellow"
                color: Qt.lighter(parent.color)
            }
        }

        RowLayout {
            width: parent.width

            Label {
                id: icon
                text: Style.iconClock
                font.family: Style.faRegular
                font.pointSize: Style.pixelSizeLarge
                Layout.leftMargin: 10
                Layout.topMargin: 10
                Layout.bottomMargin: 10
            }
            Label {
                text: qsTr("Zeige Sendungen ab")
                font.pointSize: Style.pixelSizeStandard
                Layout.fillWidth: true
            }
            DialogCloseIcon {
                Layout.fillHeight: true
                Layout.bottomMargin: 1
                Layout.preferredWidth: parent.height
            }
        }
    }*/

//    padding: 0

    contentItem:
        ColumnLayout {
//            width: parent.width

//        implicitHeight: 100
//            onHeightChanged: console.log("DateTimeTumblerDlg.qml onHeightChanged",height,"implicitHeight:",implicitHeight)

            DateTimeTumbler {
                id: dateTimeTumbler
                Layout.alignment: Qt.AlignHCenter
                datum: root.datum
            }
            CheckBox {
                id: checkBox
                text: qsTr("Zeit in Auswahlliste übernehmen?")
                font.pointSize: Style.pointSizeStandard
                width: parent.width
            }
        }

    footer: DialogFooterToolBar {
        onOkClicked: {
            root.datum = dateTimeTumbler.datum
            if (checkBox.checked) {
                var t = Qt.formatTime(dateTimeTumbler.datum,"hh:mm")
                startTimes.addTime(t)
            }
            accept()
        }
    }


/*
    footer: DialogButtonBox {
        background: Rectangle {
            color: "#707070"
            border.width: 1.0
            border.color: "#000000"
        }
        Button {
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            contentItem: Text {
                text: qsTr("Ok")
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10
            }
            background: Rectangle {
                color: "#8fbc8f"
                radius: 10
                border.width: 1.0
                border.color: "#006400"
            }
        }
        Button {
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
            contentItem: Text {
                text: qsTr("Cancel")
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 10
            }
            background: Rectangle {
                color: "#cd5c5c"
                radius: 10
                border.width: 1.0
                border.color: "#8b0000"
            }
        }
    }*/


}
