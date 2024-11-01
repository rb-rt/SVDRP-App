import QtQuick 2.15
import QtQml.Models 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0
import components 1.0
import vdr.models
import controls 1.0 as MyControls

Page {

    id: root
    //    width: parent.width

    property alias headerTitle: headerLabel.text
    property alias directories: dirBox.model
    property var record
    signal newName(var filename)

    StackView.onActivating: {
        console.log("MoveRecordView.qml StackView.onActivating")
        console.log("MoveRecordView.qml StackView.onActivating record.name",record.name)
        splitFilename(record.name)
        recordsModel.getEvent(record.id)
    }

    property RecordListModel recordsModel
    Connections {
        target: recordsModel
        function onEventFinished(event) {
            console.log("MoveRecordView onEventFinished")
            eventTitle.text = event.title
            if (event.subtitle === "") {
                eventSubtitle.text = "<i>nicht vorhanden</i>"
                buttonSubtitle.enabled = false
            }
            else {
                eventSubtitle.text = event.subtitle
                buttonSubtitle.enabled = true
            }
        }
    }

    function splitFilename(filename) {
        console.log("MoveRecordView.qml splitFilename",filename)
        var arr = filename.split("~")
        var dir = ""
        var file = ""

        if (arr.length === 1) {
            file = filename
            dir = ""
        }
        else {
            file = arr.pop()
            dir = arr.join("~")
        }
        titleInput.text = file
        dirBox.setDirectory(dir)

    }

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader {

            }

            Label {
                text: Style.iconDatabase
                font.pointSize: Style.pointSizeHeaderIcon
                font.family: Style.faRegular
            }
            Label {
                id: headerLabel
                text: "Verschieben/Umbenennen"
                font.pointSize: Style.pointSizeHeader
                Layout.alignment: Qt.AlignCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.leftMargin: 10
            }
        }
    }

    GridLayout {
        id: grid
        columns: 2
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 10
            rightMargin: 10
            topMargin: 10
            bottomMargin: 5
        }
        Label {
            text: "Verschiebt die Aufnahme und/oder benennt sie um. Sind im Titel Trennzeichen (Tilde ~) vorhanden, werden gegebenenfalls neue Verzeichnisse angelegt."
            font.pointSize: Style.pointSizeStandard
            Layout.topMargin: 10
            Layout.columnSpan: 2
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            Layout.bottomMargin: 10
        }

        Label {
            text: "Titel:"
            font.pointSize: Style.pointSizeStandard
            Layout.topMargin: 20
        }
        //siehe auch SearchTimerEditView.qml
        MyControls.LineInput {
            id: titleInput
            placeholderText: "..."
            Layout.topMargin: 20
            onTextChanged: {
                console.log("onTextChanged",text)
                let index = text.indexOf("~")
                if ( index === 0) {
                    text = text.slice(1)
                    textInput.cursorPosition = 0
                }
            }
            Layout.fillWidth: true
        }

        Label {
            text: "Verzeichnis:"
            font.pointSize: Style.pointSizeStandard
        }
        MyControls.ComboBoxAuto {
            id: dirBox
            Layout.fillWidth: true
            function setDirectory(dir) {
                var i = find(dir, Qt.MatchStartsWith | Qt.MatchCaseSensitive)
                if (i !== dirBox.currentIndex) dirBox.currentIndex = i
            }
        }
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: grid.bottom
            leftMargin: 10
            rightMargin: 10
            topMargin: 20
            bottomMargin: 5
        }
        spacing: 10
        RowLayout {
            Layout.topMargin: 20
            Label {
                text: "Ereignis Titel:"
                font.pointSize: Style.pointSizeStandard
                font.weight: Font.DemiBold
                Layout.alignment: Qt.AlignTop
            }
            Label {
                id: eventTitle
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }
        Button {
            text: "Damit das Feld Titel ersetzen"
            font.pointSize: Style.pointSizeStandard
            onClicked: titleInput.text = eventTitle.text
            enabled: eventTitle.text.length > 0
        }
        RowLayout {
            Layout.topMargin: 20
            Label {
                text: "Ereignis Untertitel:"
                font.pointSize: Style.pointSizeStandard
                Layout.alignment: Qt.AlignTop
                font.weight: Font.DemiBold
            }
            Label {
                id: eventSubtitle
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
        }
        Button {
            id: buttonSubtitle
            text: "Damit das Feld Titel ersetzen"
            font.pointSize: Style.pointSizeStandard
            onClicked: titleInput.text = eventSubtitle.text
        }

        Label {
            text: "Original Dateiname:"
            font.pointSize: Style.pointSizeStandard
            Layout.topMargin: 20
        }
        Label {
            font.pointSize: Style.pointSizeStandard
            text: record ? record.name : ""
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        Label {
            text: "Neuer Dateiname:"
            font.pointSize: Style.pointSizeStandard
            Layout.topMargin: 20
        }
        Label {
            id: filenameLabel
            font.pointSize: Style.pointSizeStandard
            text: dirBox.currentIndex === 0 ? titleInput.text : dirBox.currentText + "~" + titleInput.text
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        Button {
            text: "Zurücksetzen"
            onClicked: splitFilename(record.name)
        }

    }

    footer: ToolBar {
        background: Loader { sourceComponent: Style.footerBackground }
        MyControls.CommandBar {
            anchors.right: parent.right
            commandList: ObjectModel {
                MyControls.CommandButton {
                    id: saveButton
                    iconCharacter: Style.iconSave
                    enabled: titleInput.text.length > 0
                    description: "Speichern"
                    onCommandButtonClicked: {
                        var newFilename = filenameLabel.text
                        console.log("MoveRecordView saveButton",newFilename)
                        newName(newFilename)
                        pageStack.pop()
                    }
                }
            }
        }
    }
}

