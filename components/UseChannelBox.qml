import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import assets 1.0
import components 1.0
import controls 1.0 as MyControls
import vdr.models 1.0

GroupBox {

    id: root

    required property ChannelModel channelModel
    property alias channelGroups: channelGroupBox.model

    property int useChannel
    property alias fromChannel: fromChannelBox.selectedChannel
    property alias toChannel: toChannelBox.selectedChannel
    property string channels


    onChannelsChanged: {
        // console.log("UseChannelBox onChannelsChanged", channels,"count",channelGroupBox.count)
        if (channelGroupBox.count <= 0) return
        var index = channelGroupBox.find(channels)
        if (index === channelGroupBox.currentIndex) return
        if (index !== -1) {
            channelGroupBox.currentIndex = index
        }
        else {
            channelGroupBox.currentIndex = 0
            channels = channelGroupBox.textAt(0)
        }
    }

    font.pointSize: Style.pointSizeStandard

    label: CheckBox {
        id: gbLabel
        checked: useChannel > 0
        text: qsTr("Verwende Kanal")
        onCheckedChanged: {
            if (checked && useChannel === 0) {
                rb1.checked = true
            }
            else if (!checked) {
                useChannel = 0
            }
        }
    }

    ColumnLayout {
        id: columnChannels
        enabled: gbLabel.checked
        spacing: 10
        anchors.left: parent.left
        anchors.right: parent.right

        ButtonGroup {
            id: buttonGroup
        }

        RadioButton {
            id: rb1
            text: qsTr("Kanalbereich")
            font.pointSize: Style.pointSizeStandard
            checked: useChannel === 1
            ButtonGroup.group: buttonGroup
            onCheckedChanged: {
                if (checked) {
                    useChannel = 1
                    fromChannel = fromChannelBox.selectedChannel
                    toChannel = toChannelBox.selectedChannel
                }
            }
        }
        RowLayout {

            Label {
                id: fromLabel
                text: qsTr("von Kanal:")
                font.pointSize: Style.pointSizeStandard
                Layout.preferredWidth: rb2.width
                opacity: gbLabel.checked && rb1.checked ? 1.0 : 0.2
                leftPadding: 30
            }
            ChannelComboBox {
                id: fromChannelBox
                channelModel: root.channelModel
                enabled: rb1.checked
                Layout.fillWidth: true
                onSelectedChannelChanged: {
                    var from = channelModel.getChannelNumber(selectedChannel)
                    var to = channelModel.getChannelNumber(toChannelBox.selectedChannel)
                    if (from > to) toChannelBox.selectedChannel = selectedChannel
                }
            }
        }

        RowLayout {
            Label {
                text: qsTr("bis Kanal:")
                font.pointSize: Style.pointSizeStandard
                Layout.preferredWidth: rb2.width
                leftPadding: fromLabel.leftPadding
                opacity: fromLabel.opacity
            }
            ChannelComboBox {
                id: toChannelBox
                channelModel: root.channelModel
                enabled: rb1.checked
                Layout.fillWidth: true
                onSelectedChannelChanged: {
                    var from = channelModel.getChannelNumber(fromChannelBox.selectedChannel)
                    var to = channelModel.getChannelNumber(selectedChannel)
                    if (to < from) fromChannelBox.selectedChannel = selectedChannel
                }
            }
        }

        RowLayout {
            RadioButton {
                id: rb2
                text: qsTr("Kanalgruppe")
                checked: useChannel === 2
                enabled: channelGroupBox.count > 0
                ButtonGroup.group: buttonGroup
                onCheckedChanged: {
                    // console.log("onCheckedChanged Kanalgruppe checked", checked, channelGroupBox.currentIndex)
                    if (checked) useChannel = 2
                }
            }
            MyControls.ComboBoxAuto {
                id: channelGroupBox
                enabled: rb2.checked && channelGroupBox.count > 0
                displayText: currentIndex === -1 ? "Keine Liste..." : currentText
                Layout.preferredWidth: width
                onActivated: {
                    // console.log("onCurrentIndexChanged Kanalgruppe", "currentIndex",currentIndex)
                    channels = model[currentIndex]
                }
                Component.onCompleted: {
                    // console.log("channelGroupBox onCompleted", "channels",channels, "count",count)
                    channelsChanged()
                    // if ( (count > 0) && (channels.length === 0) ) channels = textAt(currentIndex)
                    }
                }
            }        

        RadioButton {
            id: rb3
            text: qsTr("ohne PayTV")
            font.pointSize: Style.pointSizeStandard
            checked: useChannel === 3
            ButtonGroup.group: buttonGroup
            onCheckedChanged: {
                if (checked) useChannel = 3
            }
        }
    }
}


