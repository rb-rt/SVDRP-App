import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import vdr.models 1.0
import assets 1.0
import dialogs 1.0
import "../icons"

Item {

    property VdrModel vdrModel

    // HostEditView {
    //     id: hostEditView
    //     visible: false
    //     onSaveHostEntry: {
    //         console.log("VDRListView.qml onSaveHostEntry")
    //         for (var p in vdr) console.log("p",p,"vdr[p]",vdr[p])
    //         var v = {host:hostEditView.host, port:hostEditView.port, streamPort: hostEditView.streamPort }
    //         if (vdrModel.update(vdr)) {
    //             pageStack.pop()
    //             //Automatisch umschalten bei nur einem Eintrag
    //             if (vdrModel.rowCount() === 1) {
    //                 vdrModel.currentIndex = 0
    //             }
    //         }
    //         else {
    //             messageDialog.titleText = "Fehler beim Speichern"
    //             messageDialog.text = "Konnte " + hostEditView.host + " nicht speichern."
    //             messageDialog.open()
    //         }
    //     }
    // }
    property HostEditView hostEditView
    Connections {
        target: hostEditView
        function onSaveHostEntry() {
            console.log("VDRListView.qml onSaveHostEntry")
            if (vdrModel.update(hostEditView.vdr)) {
                pageStack.pop()
                //Automatisch umschalten bei nur einem Eintrag
                if (vdrModel.rowCount() === 1) {
                    vdrModel.currentIndex = 0
                }
            }
            else {
                messageDialog.titleText = "Fehler beim Speichern"
                messageDialog.text = "Konnte " + hostEditView.vdr.host + " nicht speichern."
                messageDialog.open()
            }
        }
    }


    ListView {
        id: listViewVdr
        model: vdrModel
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        height: childrenRect.height

        delegate: Rectangle {
            width: ListView.view.width
            height: rowLayout.height
            gradient: Style.gradientList

            RowLayout {
                id: rowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard
                anchors.leftMargin: Style.pointSizeStandard / 2
                implicitHeight: Style.listMinHeight

                Label {
                    id: labelVdr
                    text: model.host
                    font.pointSize: Style.pointSizeStandard
                    font.bold: true
                    verticalAlignment: Qt.AlignVCenter
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }
                Label {
                    text:  " : " + model.port
                    font.pointSize: Style.pointSizeStandard
                    verticalAlignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                }


                //Icons
                EditIcon {
                    id: editIcon
                    color: model.index === vdrModel.currentIndex ? Style.colorListIconActive : Style.colorListIconEdit
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        var vdr = {
                            index: model.index,
                            host: model.host,
                            port: model.port,
                            streamport: model.streamport
                        }
                        // pageStack.push(hostEditView, { vdr: vdr } )
                        hostEditView = pageStack.push("qrc:/views/subviews/HostEditView.qml", { vdr: vdr })
                    }
                }

                Label {
                    id: switchIcon
                    text: Style.iconSwitch
                    Layout.preferredHeight: parent.height
                    color: Style.colorListIconVdrSwitch
                    font {
                        family: Style.faSolid
                        pointSize: Style.pointSizeListIcon
                    }
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    background: Rectangle {gradient: Style.gradientList}
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: switchIcon.background.gradient = Style.gradientListHover
                        onExited: switchIcon.background.gradient = Style.gradientList
                        onClicked: {
                            console.log("vdrModel.currentIndex",vdrModel.currentIndex, "Modelindex", model.index)
                            vdrModel.currentIndex = model.index
                        }
                    }
                }
                DeleteIcon {
                    enabled: model.index !== vdrModel.currentIndex
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        deleteMsgBox.index = model.index
                        deleteMsgBox.text = model.host + " löschen?"
                        deleteMsgBox.open()
                    }
                }
            }
        }
    }

    Button {
        id: newVDRButton
        //            anchors.bottom: parent.bottom
        anchors {
            top: listViewVdr.bottom
            topMargin: 20
            left: parent.left
            leftMargin: 20
            right: parent.right
            rightMargin: 20
        }

        text: "Neuer VDR"
        font.pointSize: Style.pointSizeStandard
        onClicked: {
            var vdr = {
                index: -1,
                host: "",
                port: 6419,
                streamport: 0
            }
            hostEditView = pageStack.push("qrc:/views/subviews/HostEditView.qml", { vdr: vdr })
        }
    }


    MyMessageDialog {
        id: messageDialog
        onAccepted: close()
    }

    MyMessageDialog {
        id: deleteMsgBox
        property int index: -1
        titleText: "VDR löschen"
        onAccepted: {
            vdrModel.remove(index)
        }
    }


}
