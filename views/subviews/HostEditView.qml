import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import assets 1.0
import components 1.0
import controls 1.0
Page {

    property var vdr

    signal saveHostEntry()

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            ToolButtonHeader {
            }

            Label {
                id: headerLabel
                text: vdr.index !== -1 ? "VDR <i>" + vdr.host + "<i> bearbeiten" : "Neuen VDR anlegen"
                font.pointSize: Style.pointSizeHeader
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.fillWidth: true
            }
        }
    }

    ScrollView {
        id: scrollView
        //        anchors.fill: parent
        anchors {
            left: parent.left
            right: parent.right
//            top: headerLabel.bottom
            //            bottom: buttonBox.top
        }
        padding: 10
        height: parent.height - 10
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
//        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        ColumnLayout {
            id: col
            width: scrollView.availableWidth
            spacing: 20

            Label {
                text: "Hostname oder IP-Adresse vom VDR."
                wrapMode: Text.Wrap
                Layout.preferredWidth: parent.width
                Layout.topMargin: 20
                font.pointSize: Style.pointSizeStandard
            }
            Label {
                text: "Hostname oder IP-Adresse sind eindeutig. Ein vorhandener Eintrag wird überschrieben."
                wrapMode: Text.Wrap
                Layout.preferredWidth: parent.width
//                Layout.topMargin: 20
                font.pointSize: Style.pointSizeSmall
            }

            RowLayout {
                Label {
                    text: "Host:"
                    font.pointSize: Style.pointSizeStandard
                }
//                LineInput {
//                    id: hostTextfield
//                    placeholderText: "..."
//                    Layout.preferredWidth: 200
//                    Layout.leftMargin: 10
//                }

                TextField {
                    id: hostTextfield
                    text: vdr.host
                    placeholderText: "..."
                    Layout.preferredWidth: 200
                    Layout.leftMargin: 10
                    font.pointSize: Style.pointSizeStandard
                    inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    onTextChanged: vdr.host = text
                }
            }

            Label {
                text: "Als Port für SVDRP wird üblicherweise 6419 verwendet."
                wrapMode: Text.Wrap
                Layout.topMargin: 20
                font.pointSize: Style.pointSizeSmall
                Layout.preferredWidth: parent.width
            }
            RowLayout {
                Label {
                    text: "Port:"
                    font.pointSize: Style.pointSizeStandard
                }
                TextField {
                    id: portTextfield
                    placeholderText: "Standard: 6419"
                    text: vdr.port
                    inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    validator: IntValidator { bottom: 0; top: 65635 }
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 10
                    Layout.preferredWidth: 200
                    onTextChanged: vdr.port = text
                }
            }

            Label {
                text: "Der Port vom Streamdev-Server. Nur notwendig zur lokalen Wiedergabe von Live TV oder Aufnahmen auf dem Gerät. Eine 0 deaktivert die Abfrage."
                wrapMode: Text.Wrap
                Layout.topMargin: 20
                font.pointSize: Style.pointSizeSmall
                Layout.preferredWidth: parent.width
            }
            RowLayout {
                Label {
                    text: "Port:"
                    font.pointSize: Style.pointSizeStandard
                }
                TextField {
                    id: streamportTextfield
                    placeholderText: "Standard: 3000"
                    text: vdr.streamport
                    inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText | Qt.ImhSensitiveData
                    validator: IntValidator { bottom: 0; top: 65635 }
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 10
                    Layout.preferredWidth: 200
                    onTextChanged: vdr.streamport = text
                }
            }

            Label {
                text: "Die zusammengesetzte Adresse"
                wrapMode: Text.Wrap
                Layout.topMargin: 10
                font.pointSize: Style.pointSizeSmall
            }
            Label {
                text: hostTextfield.text + ":" + portTextfield.text
                font.pointSize: Style.pointSizeStandard
            }

        }
    }

    footer: DialogButtonBox {
        id: buttonBox
        standardButtons: Dialog.Save
        alignment: Qt.AlignCenter
        enabled: hostTextfield.text.length > 0 && portTextfield.text.length > 0
        onAccepted: {
            saveHostEntry()
        }
    }
}


