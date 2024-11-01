import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import controls 1.0 as MyControls
import "subs"

Page {
    id: root

    property color selectedColor

    function compareColor (c:color) {
        var a = Qt.color(selectedColor)
        var b = Qt.color(c)
        saveButton.enabled = !Qt.colorEqual(a,b)
    }

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

    ColorChooser {
        id: colorChooser
        defaultColor: selectedColor
        anchors.fill: parent
        anchors.margins: 10
        onHueChanged: compareColor(getColor())
        onSaturationChanged: compareColor(getColor())
        onColorValueChanged: compareColor(getColor())
        onAlphaChanged: compareColor(getColor())
    }


    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }

        MyControls.CommandBar {
            anchors.right: parent.right
            MyControls.CommandButton {
                id: saveButton
                iconCharacter: Style.iconSave
                description:qsTr("Übernehmen")
                onCommandButtonClicked: {
                    selectedColor = colorChooser.getColor()
                }
            }
        }
    }
}


