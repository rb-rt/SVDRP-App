import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import assets 1.0

ToolButton {
    id: button

    property int channelKind: 0 //Alle, FreeTV, PayTV
    property int channelType: 0 //Alle, TV, Radio

    signal drawerClicked()

    readonly property var channelKinds: ["Alle","Free TV","Pay TV"]
    readonly property var channelTypes: ["Alle Kanäle","Fernsehkanäle","Radiokanäle"]

    contentItem: RowLayout {
        Label {
            id: iconLabel
            text: Style.iconChannel
            font.family: Style.faSolid
            font.pointSize: Style.pointSizeStandard
        }
        Label {
            id: textLabel
            text: channelTypes[channelType] + " (" + channelKinds[channelKind] + ")"
            font.pointSize: Style.pointSizeStandard
        }
    }
    opacity: 0.7
    background: Rectangle {
        id: bkg
        anchors.fill: parent
        radius: 4
        border.width: 2
        gradient: Style.gradientListToolButton
        border.color: Qt.lighter(Style.colorPrimary)
        states: State {
            when: button.down
            PropertyChanges {
                target: bkg
                border.color: Qt.darker(Style.colorPrimary, 1.2)
                gradient: Style.gradientList
            }
        }
    }

    states: [
        State {
            when: channelType === 2
            PropertyChanges {
                target: iconLabel
                text: Style.iconMusic
            }
        },
        State {
            when: channelType === 1
            PropertyChanges {
                target: iconLabel
                text: Style.iconVideo
            }
        }
    ]

    onClicked: drawerSelect.open()

    Drawer {
        id: drawerSelect
        edge: Qt.RightEdge

        ColumnLayout {

            RowLayout {

                GroupBox {
                    title: "Kanalauswahl"
                    Layout.margins: 10
                    font.pointSize: Style.pointSizeStandard

                    ColumnLayout {
                        RadioButton {
                            text: channelTypes[0]    /*qsTr("Alle Kanäle")*/
                            font.pointSize: Style.pointSizeStandard
                            checked: channelType === 0
                            onToggled: if (checked) channelType = 0
                        }
                        RadioButton {
                            text: channelTypes[1]
                            font.pointSize: Style.pointSizeStandard
                            checked: channelType === 1
                            onToggled: if (checked) channelType = 1
                        }
                        RadioButton {
                            text: channelTypes[2]
                            font.pointSize: Style.pointSizeStandard
                            checked: channelType === 2
                            onToggled: if (checked) channelType = 2
                        }
                    }
                }
                GroupBox {
                    title: " "
                    Layout.margins: 10
                    ColumnLayout {
                        RadioButton {
                            text: channelKinds[0]
                            font.pointSize: Style.pointSizeStandard
                            checked: channelKind == 0
                            onToggled: if (checked) channelKind = 0
                        }
                        RadioButton {
                            text: channelKinds[1]
                            font.pointSize: Style.pointSizeStandard
                            checked: channelKind == 1
                            onToggled: if (checked) channelKind = 1
                        }
                        RadioButton {
                            text: channelKinds[2]
                            font.pointSize: Style.pointSizeStandard
                            checked: channelKind == 2
                            onToggled: if (checked) channelKind = 2
                        }
                    }
                }
            }

            RowLayout {

                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignHCenter

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Übernehmen"
                    onClicked: {
                        drawerSelect.close()
                        drawerClicked()
                    }
                }
                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Abbruch"
                    onClicked: {
                        drawerSelect.close()
                        button.canceled()
                    }
                }
            }
        }
    }
}
