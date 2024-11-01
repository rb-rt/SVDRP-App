import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models

import assets
import components
import controls as MyControls
import vdr.models

import "../icons"
import "../transitions"

Page {
    id:root

    property alias channels: channelSelectProxyModel.channels //  [] //die ausgewählten Kanäle
    property alias headerTitle: headerLabel.text
    property alias channelModel: channelSFProxyModel.sourceModel

    signal channelGroupsSaved()

    ChannelSFProxyModel {
        id: channelSFProxyModel
    }

    ChannelSelectProxyModel {
        id: channelSelectProxyModel
        channels: []
        sourceModel: channelSFProxyModel
    }

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        GridLayout {
            anchors.fill: parent
            width: parent.width
            columns: 2

            MyControls.ToolButtonHeader {
                Layout.rowSpan: 2
                Layout.column: 0
            }
            Label {
                id: headerLabel
                font.pointSize: Style.pointSizeHeader
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.topMargin: 5
            }

            RowLayout {
                Layout.bottomMargin: 5
                spacing: 10
                CheckBox {
                    text: "Ausgewählt"
                    onCheckedChanged: channelSelectProxyModel.filtered = checked
                    font.pointSize: Style.pointSizeStandard
                    Layout.fillWidth: true
                }
                ChannelTypeDrawer {
                    Layout.rightMargin: 10
                    channelKind: channelSFProxyModel.ca
                    channelType: channelSFProxyModel.channelType
                    onDrawerClicked: {
                        channelSFProxyModel.ca = channelKind
                        channelSFProxyModel.channelType = channelType
                    }
                }
            }
        }
    }

    property int channelIconWidth: Math.floor( Math.log10(channelModel.rowCount()) + 2) * Style.pointSizeStandard

    ListView {
        anchors.fill: parent
        model: channelSelectProxyModel
        ScrollBar.vertical: ScrollBar{}
        delegate: Rectangle {
            width: ListView.view.width
            height: rowLayout.height
            gradient: Style.gradientList

            RowLayout {
                id: rowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard
                //                implicitHeight: Style.listMinHeight

                ChannelIcon {
                    Layout.preferredWidth: root.channelIconWidth
                    Layout.preferredHeight: parent.height
                    text: model.channel.number
                }
                Label {
                    id: keyLabel
                    text: model.channel.isFTA ? "" : Style.iconKey
                    font.family: Style.faSolid
                    font.pointSize: Style.pointSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    Layout.minimumWidth: height
                }
                Label {
                    id: musicLabel
                    text: model.channel.isRadio ? Style.iconMusic : ""
                    font.family: Style.faSolid
                    font.pointSize: Style.pointSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    Layout.minimumWidth: height
                }

                CheckDelegate {
                    id: checkDelegate
                    text: model.display
                    font.pointSize: Style.pointSizeStandard
                    LayoutMirroring.enabled: true
                    checked: model.select
                    onToggled: model.select = checked
                }
                Label {
                    text: ""
                    Layout.fillWidth: true
                }
            }
        }

        MyControls.EmptyListLabel {
            text: "Keine Kanäle"
            visible: parent.count === 0
        }

        populate: ListViewPopulate{}
    }

    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel {
                MyControls.CommandButton {
                    iconCharacter: Style.iconQuestion
                    description: "Hilfe"
                    fontSolid: false
                    onCommandButtonClicked: helpPopup.open()
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconCheckCircle
                    description: "Alle"
                    onCommandButtonClicked: channelSelectProxyModel.selectAll()
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconCircle
                    fontSolid: false
                    description: "Keine"
                    onCommandButtonClicked: channelSelectProxyModel.selectNone()
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconCircleDot
                    fontSolid: false
                    description: "Umkehren"
                    onCommandButtonClicked: channelSelectProxyModel.selectInvert()
                }
                MyControls.CommandButton {
                    iconCharacter: "[ ]"
                    description: "Bereich"
                    onCommandButtonClicked: dialogIntervall.open()
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconSave
                    description: "Speichern"
                    onCommandButtonClicked: channelGroupsSaved()
                }
            }
        }
    }

    Dialog {
        id: dialogIntervall
        modal: true
        anchors.centerIn: parent

        header: ToolBar {

            Label {
                text: "Bereich auswählen"
                font.pointSize: Style.pointSizeStandard
                font.bold: true
                leftPadding: 10
                rightPadding: 10
                verticalAlignment: Qt.AlignVCenter
                height: parent.height
            }

            background: Rectangle {
                color: Style.colorPrimary
                implicitHeight: 48 //s. DialogInputText.qml
            }
        }
        ColumnLayout {
            spacing: 10
            RowLayout {
                Label {
                    text: "Von Kanal"
                    font.pointSize: Style.pointSizeStandard
                    Layout.rightMargin: 5
                }
                MyControls.SpinBox {
                    id: fromBox
                    from: 1
                    to: channelModel.rowCount()
                    editable: true
                    value: 1
                    onValueChanged: if (value > toBox.value) toBox.value = value
                }
                Label {
                    text: "bis"
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                }
                MyControls.SpinBox {
                    id: toBox
                    from: 1
                    to: channelModel.rowCount()
                    editable: true
                    value: channelModel.rowCount()
                    onValueChanged: if (value < fromBox.value) fromBox.value = value
                }
            }
            Label {
                text: "Die Angaben beziehen sich hier auf die gesamte Liste und nicht auf die gerade ausgewählten Kanäle."
                font.pointSize: Style.pointSizeStandard
                Layout.preferredWidth: parent.width
                wrapMode: Text.WordWrap
            }
        }
        footer: DialogButtonBox {
            standardButtons: Dialog.Cancel | Dialog.Apply
            font.pointSize: Style.pointSizeStandard
        }
        onApplied: {
            channelSelectProxyModel.selectIntervall(fromBox.value,toBox.value)
            close()
        }
    }

    ChannelHelpPopup {
        id: helpPopup
    }
}


