import QtQuick
import controls

Item {
    property alias channelModel: cba.model
    property string selectedChannel: "" //channel_id: S19.2E

    onSelectedChannelChanged: {
       console.log("ChannelComboBox onSelectedChannelChanged selectedChannel", selectedChannel)
        if (selectedChannel !== "") cba.currentIndex = cba.indexOfValue(selectedChannel)
    }

    implicitHeight: cba.height

    ComboBoxAuto {
        id: cba
        textRole: "channelnrname"
        width: parent.width
        valueRole: "id"
        // onCurrentIndexChanged: console.log("ChannelComboBox onCurrentIndexChanged","currentIndex",currentIndex,"currentValue",currentValue)
        // onCurrentValueChanged: console.log("ChannelComboBox onCurrentValueChanged","currentIndex",currentIndex,"currentValue",currentValue)
        onActivated: { if (selectedChannel !== currentValue) selectedChannel = currentValue }
        Component.onCompleted: {
            console.log("ChannelComboBox onCompleted currentValue",currentValue,"currentIndex",currentIndex,"selectedChannel",selectedChannel)
            if (selectedChannel === "") {
                selectedChannel = valueAt(0)
            }
            else {
                currentIndex = indexOfValue(selectedChannel)
            }
        }
    }
}
