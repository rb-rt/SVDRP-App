import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import controls 1.0 as MyControls

Page {
    id: root

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent
            MyControls.ToolButtonHeader{}
            Label {
                text: "Farbe auswählen"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    // height: 666

    Rectangle {
        // opacity: 0.2
        anchors.fill: parent
        color: "bisque"
    }

    property bool quer: width > height

    onHeightChanged: {
        console.log("onHeightChanged parent.height",height)
        console.log("onHeightChanged grid.height",grid.height)
        console.log("onHeightChanged firstColumn.height",firstColumn.height)
        console.log("onHeightChanged slider.height",slider.height)
        // console.log("onHeightChanged quadrat.height",quadrat.height)
        // console.log("onHeightChanged quadrat.width",quadrat.width)
    }

    GridLayout {
        id: grid
        columns: 2
        anchors.fill: parent
        anchors.margins: 10
        rowSpacing: 10
        columnSpacing: 10

        onHeightChanged: {
            console.log("Grid onHeightChanged",height)
            // maxGridHeight = height - rectangleBoxes.height
        }

        // property real minGridHeight: quer ? (height - 2 * slider.height - rowSpacing - firstColumn.spacing - 10) : (height - rectangleBoxes.height - 2 * slider.height - rowSpacing - firstColumn.spacing - 10)
        // property real minGridHeight: height - slider.height - rowSpacing - firstColumn.spacing - 10 - (quer ?  0 : textBoxes.height)
        // onMinGridHeightChanged: {
        //     console.log("onMinGridHeightChanged",minGridHeight)
        // }

        ColumnLayout {
            id: firstColumn
            // Layout.columnSpan: quer ? 1 : 2
            // Layout.rowSpan: quer ? 2 : 1
            Layout.preferredWidth: parent.width / grid.columns
            Layout.fillWidth: true
            // Layout.alignment: Qt.AlignTop

            onHeightChanged: console.log("firstColiumn onheightChanged",height)
            property int buttonWidth: width / 3

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                Repeater {
                    model: 9
                    Rectangle {
                        // implicitWidth: 100
                        Layout.preferredWidth: firstColumn.buttonWidth
                        Layout.preferredHeight: 10
                    }
                }
            }

            Rectangle {
                id: quadrat
                color: "crimson"
                Layout.fillWidth: true
                Layout.preferredHeight: width
                Layout.maximumHeight: grid.minGridHeight
            }

            Slider {
                id: slider
                Layout.fillWidth: true
                // Layout.preferredHeight: 100
                // Layout.fillHeight: true
                // Layout.preferredWidth: 100
            }
        }
        /*
        ColumnLayout {
            id: rectangleBoxes

            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignTop

            Layout.row: quer ? 0 : 1
            Layout.column: quer ? 1 : 0

            Rectangle {
                color: "green"
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                // Layout.fillHeight: true
                // Layout.preferredWidth: parent.width / 2
                // opacity: 0.5
            }
            Rectangle {
                color: "lightgreen"
                Layout.fillWidth: true
                height: childrenRect.height
                Label {
                    height: 2 * implicitHeight
                    width: parent.width
                    text: "Hier steht etwas"
                    color: "black"
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                }
            }
            Rectangle {
                color: "steelblue"
                Layout.fillWidth: true
                // Layout.preferredHeight: parent.height - red.height
                // Layout.fillHeight: true
                height: 100
            }
        }
*/


        ColumnLayout {
            id: textBoxes
            // Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width / grid.columns
            Layout.alignment: Qt.AlignTop

            // Layout.row: quer ? 0 : 1
            // Layout.column: quer ? 1 : 0

            Rectangle {
                id: defaultRectangle
                color: "green"
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                gradient: Style.gradientList
                border.width: 1
                border.color: Qt.darker(Style.colorForeground)
                Label {
                    text: "Ohne Farbüberlagerung"
                    width: parent.width
                    height: implicitHeight * 2
                    font.pointSize: Style.pointSizeStandard
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
            Rectangle {
                Layout.preferredHeight: defaultRectangle.height
                Layout.fillWidth: true
                gradient: Style.gradientListMainTime
                border.width: 1
                border.color: Qt.darker(Style.colorForeground)
                Label {
                    text: "Aktuelle Farbe"
                    width: parent.width
                    height: parent.height
                    font.pointSize: Style.pointSizeStandard
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width / grid.columns
            // Layout.row: 1
            // Layout.column: 1
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Button {
                text: "toggle"
                onClicked: grid.state === "" ? grid.state = "quer" : grid.state = ""
            }
        }

        states: [
            State {
                name: "quer"
                when: quer
                PropertyChanges {
                    target: grid
                    columns: 3
                }
            }
        ]

        /*
        GridLayout {
            id: textBoxes
            // Layout.preferredWidth: parent.width / 2
            Layout.columnSpan: quer ? 1 : 2
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true

            columns: 2
            Label {
                id: refLabel
                text: "Text"
                color: "black"
            }
            Rectangle {
                Layout.preferredWidth: 2 * height
                Layout.preferredHeight: refLabel.height
                color: "black"
            }
            Label {
                color: "black"
                text: "Text"
            }
            Rectangle {
                Layout.preferredWidth: 2 * height
                Layout.preferredHeight: refLabel.height
                color: "blue"
            }
            Rectangle {
                Layout.fillHeight: true
            }
        }
        */
    }




    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }

        MyControls.CommandBar {
            anchors.right: parent.right
            MyControls.CommandButton {
                id: saveButton
                iconCharacter: Style.iconSave
                description:qsTr("Übernehmen")
                onCommandButtonClicked: mainColorChanged()
            }
        }
    }
}


