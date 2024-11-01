import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0

Drawer {
    id: drawerChannels

    property alias channelModel: listView.model
    property string selectedChannel: "" //channel_id: S19.2E

    onSelectedChannelChanged: {
        console.log("ChannelsDrawer onSelectedChannelChanged selectedChannel", selectedChannel)
        if (selectedChannel === "") {
            listView.currentIndex = -1
            return
        }
        var nr = channelModel.getChannelNumber(selectedChannel)
        if (nr !== -1) {
            listView.currentIndex = nr-1
        }
    }

    focus: true
    height: parent.height
    // width: Math.min(listView.implicitWidth, parent.width / 2)
    width: Math.max(parent.width / 4, implicitWidth)
    implicitWidth: 200
    edge: Qt.RightEdge

    ListView {
        id: listView
        anchors.fill: parent
        delegate: ItemDelegate {
            width: ListView.view.width
            highlighted: ListView.isCurrentItem

            contentItem: RowLayout {
                spacing: 10
                Label {
                    id: cLabel
                    text: model.channel.isFTA ? " " : Style.iconKey
                    font.pointSize: Style.pointSizeSmall
                    font.family: Style.faSolid
                }
                Label {
                    text: model.channelnrname
                    font.pointSize: Style.pointSizeStandard
                    Layout.fillWidth: true
                    elide: Text.ElideRight
//                    width: parent.width - cLabel.width
                }
            }
            onClicked: {
                drawerChannels.close()
                var id = model.id
                if (id !== selectedChannel) selectedChannel = id
            }
        }

        ScrollBar.vertical: ScrollBar { }
        onModelChanged: {
            // implicitWidth = calcMaxWidth() * tm.advanceWidth
            // currentIndex =-1
        }
    }
/*
    function calcMaxWidth() {
        var rows = channelModel.rowCount()
        var maxWidth = 0
        for(var nr = 1; nr <= rows; nr++){
            var ch = channelModel.getChannel(nr)
            var s = ch.number + " - " + ch.name
            maxWidth = Math.max(maxWidth, s.length)
        }
        return maxWidth
    }
*/
}
