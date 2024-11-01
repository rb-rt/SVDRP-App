import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import controls 1.0 as MyControls

Page {
    id: root

    property alias logs: listView.model

    property bool keepOpen: false //true setzen, wenn das Fesnter nicht geschlossen wird

    signal canceled()

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent
            MyControls.ToolButtonHeader{}
            Label {
                text: "Protokoll"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        spacing: 20
        Label {
            text: "Programmstart um " + Qt.formatTime(new Date(), "hh:mm:ss.zzz")
            font.pointSize: Style.pointSizeLarge
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "transparent"

            ListView {
                id: listView
                anchors.fill: parent
                clip: true
                delegate: Label {
                    text: model.time + ": " + model.message
                    font.pointSize: Style.pointSizeStandard

                    ListView.onAdd: {
                        // console.log("onAdd",index,listView.count)
                        listView.positionViewAtEnd()
                        // listView.positionViewAtIndex(index, ListView.End)
                    }
                }
            }
        }
        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            running: !root.keepOpen
            onRunningChanged: if (root.keepOpen) listView.positionViewAtEnd()
        }

        Button {
            text: "Abbruch"
            Layout.topMargin: 20
            Layout.bottomMargin: 20
            Layout.alignment: Qt.AlignHCenter
            enabled: !root.keepOpen
            onClicked: root.canceled()
        }
    }

}


