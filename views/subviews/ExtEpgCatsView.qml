import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQml.Models 2.15

import assets 1.0
import components 1.0
import controls 1.0 as MyControls
import vdr.models 1.0

Page {
    id: root

    //    property alias extEpgCats: extEpgModel.values // array[id#werte] die EPG Kategorien vom Suchtimer, kann leer sein

    //Array der Form [ExtEpgCat, ExtEpgCat, ...]
    //    property alias defaultExtEpgCats: extEpgModel.defaultValues

    property alias extEpgModel: listView.model

    property alias headerLabel: labelHeader.text

    signal categoriesSaved()

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


    property int lastIndex: -1

    property ExtEpgCatsViewSelect extPage
    Connections {
        target: extPage
        function onValuesSaved() {
            if (lastIndex !== -1) {
                console.log("ExtEpgCatsView.qml extPage onValuesSaved()", extPage.values)
                extEpgModel.setData( extEpgModel.index(lastIndex,0), extPage.values, ExtendedEpgCatModel.ValuesAsListRole )
                lastIndex = -1
            }
            pageStack.pop()
        }
    }

    ListView {
        id: listView
        //        model: extEpgModel
        anchors.fill: parent
        ScrollBar.vertical: ScrollBar{}

        //        Label {
        //            anchors.fill: parent
        //            horizontalAlignment: Qt.AlignHCenter
        //            verticalAlignment: Qt.AlignVCenter
        //            visible: parent.count == 0
        //            text: qsTr("Keine erweiterten EPG Kategorien vorhanden")
        //        }

        property int labelMaxWidth: 0
        property int labelCompareWidth: 0


        delegate: Rectangle {
            width: ListView.view.width
            height: rowLayout.height
            gradient: Style.gradientList

            RowLayout {
                id: rowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 20
                Label {
                    id: label
                    text: model.name
                    font.pointSize: Style.pointSizeStandard
                    Layout.preferredWidth: listView.labelMaxWidth
                    onWidthChanged: if (width > listView.labelMaxWidth) listView.labelMaxWidth = width
                }
                MyControls.LineInput {
                    id: textField
                    text: model.values
                    placeholderText: "..."
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    Layout.leftMargin: 10
                    //                    text: edit // "edit" role of the model, to break the binding loop
                    //                    onTextChanged: {
                    //                        console.log("onTextChanged",model.index)
                    //                        model.edit = text
                    //                    }
                    onTextChanged: if (model.values !== text) model.values = text

                    //bei Focusverlust
                    //                    onEditingFinished: {
                    //                        console.log("onEditingFinished",model.values)
                    //                        extEpgModel.set(model.index, text)
                    //                    }
                }
                Label {
                    id: iconEdit
                    text: Style.iconEdit
                    font {
                        family: Style.faSolid
                        pointSize: Style.pointSizeDialogIcon
                    }
                    enabled: model.defaults.length === 0 ? false : true
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            lastIndex = model.index
                            extPage = pageStack.push("qrc:/views/subviews/ExtEpgCatsViewSelect.qml",
                                                     {headerLabel: "EPG Kategorien <i>" +  "</i>",
                                                         values: model.list,
                                                         defaultValues: model.defaults
                                                     })
                        }
                    }
                }

                Label {
                    text: "Vergleich: " + model.searchmode
                    font.pointSize: Style.pointSizeStandard
                    Layout.preferredWidth: listView.labelCompareWidth
                    onWidthChanged: if (width > listView.labelCompareWidth) listView.labelCompareWidth = width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: compareInfo.open()
                    }
                }
            }
        }
    }

    Popup {
        id: compareInfo
        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        ColumnLayout {
            Label {
                text: "aus epgsearchcat.conf"
                font.pointSize: Style.pointSizeLarge
                Layout.bottomMargin: 10
            }
            Repeater {
                model: compareModel
                delegate: Label {
                    text: model.nr + ": " +  model.name
                    font.pointSize: Style.pointSizeStandard
                }
            }
        }
    }

    ListModel {
        id: compareModel
        ListElement { nr: 0; name: "Ausdruck" }
        ListElement { nr: 1; name: "Alle Worte (Standard)" }
        ListElement { nr: 2; name: "Mindestestens ein Wort" }
        ListElement { nr: 3; name: "Exakte Übereinstimmung" }
        ListElement { nr: 4; name: "Regular Expression" }
        ListElement { nr: 10; name: "<" }
        ListElement { nr: 11; name: "<=" }
        ListElement { nr: 12; name: ">" }
        ListElement { nr: 13; name: ">=" }
        ListElement { nr: 14; name: "==" }
        ListElement { nr: 15; name: "!=" }
        function getText(nr) {
            if (nr < 5) {
                return get(nr).name
            }
            else {
                return get(nr-5).name
            }
        }
    }


    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel{
                MyControls.CommandButton {
                    iconCharacter: Style.iconSave
                    description: "Übernehmen"
                    onCommandButtonClicked: {
                        categoriesSaved()
                    }
                }
            }
        }
    }
}





