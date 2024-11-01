import QtQuick 2.15
import QtQuick.Controls 2.15
import assets 1.0

Label {
    id: icon

    property var record

    text: Style.iconVideoFile
    font.pointSize: Style.pointSizeListIcon
    font.family: Style.faRegular
    verticalAlignment: Qt.AlignVCenter
    horizontalAlignment: Qt.AlignHCenter
    color: Style.colorForeground
    property bool showError: false
    leftPadding: Style.listIconPadding
    rightPadding: Style.listIconPadding
    states: [
        State {
            when: record.faulty && showError
            PropertyChanges {
                target: icon
                text: Style.iconVideoFile
                color: Style.colorRecordingFaulty
            }
        },
        State {
            when: record.instant
            PropertyChanges {
                target: icon
                text: Style.iconVideoFile
                color: Style.colorRecordingInstant
            }
        },
        State {
            when: record.new && record.cut
            PropertyChanges {
                target: icon
                text: Style.iconCut
                font.family: Style.faSolid
                color: Style.colorRecordingNew
            }
        },
        State {
            when: record.new
            PropertyChanges {
                target: icon
                text: Style.iconVideoFile
                color: Style.colorRecordingNew
            }
        },
        State {
            when: record.cut
            PropertyChanges {
                target: icon
                text: Style.iconCut
                font.family: Style.faSolid
            }
        }
    ]
}
