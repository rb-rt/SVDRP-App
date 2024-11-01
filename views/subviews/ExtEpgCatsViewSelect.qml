import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

import assets 1.0
import controls 1.0 as MyControls

Page {
    id: root

    property var values: []
    property alias headerLabel: labelHeader.text
    property alias defaultValues: listView.model //ein array[]

    signal valuesSaved()

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {
                id: toolButton
            }
            Label {
                id: labelHeader
                text: "Erweiterte EPGs"
                font.pointSize: Style.pointSizeStandard
                font.weight: Font.Bold
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.fillWidth: true
            }
        }
    }

    ListView {
        id: listView
//        model: 12 // defaultValues
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}


//        Label {
//               anchors.fill: parent
//               horizontalAlignment: Qt.AlignHCenter
//               verticalAlignment: Qt.AlignVCenter
//               visible: parent.count == 0
//               text: qsTr("Keine erweiterten EPG Kategorien vorhanden")
//        }

        delegate: Rectangle {
            width: ListView.view.width
            height: rowLayout.height
            gradient: Style.gradientList

            RowLayout {
                id: rowLayout
                CheckDelegate {
                    id: label
                    text: modelData
                    font.pointSize: Style.pointSizeStandard
                    LayoutMirroring.enabled: true
                    checked: root.values.includes(modelData)
                    onToggled: checked ? values.push(modelData) : listView.removeValue(modelData)
                }
            }
        }

        function removeValue(value) {
            let index = root.values.indexOf(value)
            if (index !== -1) root.values.splice(index,1)
        }
    }



    footer: ToolBar {
        background: Loader {
            sourceComponent: Style.footerBackground
        }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel{
                MyControls.CommandButton {
                    iconCharacter: Style.iconSave
                    description: "Übernehmen"
                    onCommandButtonClicked: {
                        valuesSaved()
                    }
                }
            }
}
        }
    }





