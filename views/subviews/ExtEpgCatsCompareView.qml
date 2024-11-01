import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import assets 1.0
import components 1.0
import controls 1.0 as MyControls

Page {

    id: root
    property alias defaultExtEpgCats: listView.model

    property alias headerLabel: headerLabel.text
    property int compareCategories: 0 //bitweise codiertes Feld abhängig vom Index (compare_categories in epgsearch)

    signal categoriesSaved()

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }
        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {}

            Label {
                text: Style.iconGripH
                font.pointSize: Style.pointSizeHeaderIcon
                font.weight: Font.Bold
                font.family: Style.faSolid
                Layout.alignment: Qt.AlignCenter
                Layout.leftMargin: 10
                Layout.rightMargin: 10
            }
            Label {
                id: headerLabel
                text: "Erweiterte EPG Info"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}

        delegate: Rectangle {
            width: ListView.view.width
            height: childrenRect.height
            gradient: Style.gradientList

            CheckDelegate {
                text: modelData.name
                font.pointSize: Style.pointSizeStandard
                LayoutMirroring.enabled: true
                checked: (Math.pow(2, index) & compareCategories) === Math.pow(2, index)
                onToggled: checked ? compareCategories = compareCategories | Math.pow(2, index) : compareCategories = compareCategories &~ Math.pow(2, index)
            }
        }
    }


    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel {
                MyControls.CommandButton {
                    iconCharacter: Style.iconUndo
                    description:qsTr("Alle Werte löschen")
                    onCommandButtonClicked: compareCategories = 0
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconSave
                    description:qsTr("Übernehmen")
                    onCommandButtonClicked: categoriesSaved()
                }
            }
        }
    }
}


