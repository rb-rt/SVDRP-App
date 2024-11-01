import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQml.Models 2.15
import assets 1.0
import components 1.0
import models 1.0
import controls 1.0 as MyControls

Page {

    id: root
    property string contentDescriptors: "" //"id1id2id3..."
    property alias headerLabel: headerLabel.text

    signal contentDescriptorsSaved()

    onContentDescriptorsChanged: {
        console.log("ContentDescriptorsView.qml onContentDescriptorsChanged",contentDescriptors)
        if (contentDescriptors.length === 0) {
            contentModel.reset()
        }
        else {
            for(var i=0; i < contentDescriptors.length; i+=2) {
                var id = contentDescriptors.substr(i, 2)
                for(var k=0; k < contentModel.count; k++){
                    var c = contentModel.get(k).contentid.toString(16) //Liefert id als hex
                    if (c === id) {
                        contentModel.setProperty(k, "selected", true)
                    }
                }
            }
        }
    }

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
                text: "Content Descriptors"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignVCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }


    ContentDescriptorModel {
        id: contentModel
    }


    ListView {
        id: listView
        model: contentModel
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}

        delegate: Rectangle {
            width: ListView.view.width
            height: checkDelegate.implicitHeight
            gradient: Style.gradientList

            CheckDelegate {
                id: checkDelegate
                text: model.text
                checked: model.selected
                font.pointSize: Style.pointSizeStandard
                LayoutMirroring.enabled: true
                leftPadding: (model.contentid & 0xf0) !== model.contentid ? 2*Style.pointSizeStandard : 0
                onCheckedChanged: model.selected = checked
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
                    onCommandButtonClicked: contentModel.reset()
                }
                MyControls.CommandButton {
                    iconCharacter: Style.iconSave
                    description:qsTr("Übernehmen")
                    onCommandButtonClicked: {
                        console.log("descriptors",contentDescriptors)
                        console.log("contentModel.descriptors" ,contentModel.descriptor() )
                        contentDescriptors = contentModel.descriptor()
                        contentDescriptorsSaved()
                    }
                }
            }
        }
    }
}


