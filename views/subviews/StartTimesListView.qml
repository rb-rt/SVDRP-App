import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import assets 1.0
import dialogs 1.0
import "../icons"
import "../labels"
Item {

    ListView {
        id: listViewStartTimes
        model: startTimes
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        delegate: Rectangle {
            id: rowRec
            width: ListView.view.width
            gradient: Style.gradientList
            height: rowLayout.height

            RowLayout {
                id: rowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard
                anchors.leftMargin: Style.pointSizeStandard / 2
                implicitHeight: Style.listMinHeight

                LabelTitle {
                    id: timeText
                    text: model.display
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    Layout.fillWidth: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            timeTumbler.time = timeText.text
                            timeTumbler.open()
                        }
                    }
                }
                EditIcon {
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        timeTumbler.time = timeText.text
                        timeTumbler.open()
                    }
                }
                DeleteIcon {
                    Layout.preferredHeight: parent.height
                    onIconClicked: startTimes.delTime(model.index)
                }

            }
            TimeTumblerDlg {
                id: timeTumbler
                parent: Overlay.overlay
                onAccepted: {
                    timeText.text = time
                    model.edit = timeText.text
                }
            }
        }
    }

    Button {
        text: "Neue Zeit"
        font.pointSize: Style.pointSizeStandard
        anchors {
            top: listViewStartTimes.bottom
            topMargin: 20
            left: parent.left
            leftMargin: 20
            right: parent.right
            rightMargin: 20
        }
        onClicked: {
            var t = Date.fromLocaleTimeString(locale,"00:00","hh:mm")
            newTimeTumbler.time = t
            newTimeTumbler.open()
        }
    }


    TimeTumblerDlg {
        id: newTimeTumbler
        onAccepted: {
            var h = newTimeTumbler.time.getHours()
            var m = newTimeTumbler.time.getMinutes()
            if (h < 10) h = "0" + h
            if (m < 10) m = "0" + m
            var t = h + ":" + m
            startTimes.addTime(t)
        }
    }
}
