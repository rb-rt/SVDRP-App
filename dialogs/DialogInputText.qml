import QtQuick 2.15
import QtQuick.Controls 2.15

import assets 1.0
import controls 1.0


Dialog {

    property alias placeholderText: input.placeholderText
    property alias newText: input.text

    modal: true
    anchors.centerIn: parent

    header: ToolBar {
        id: header

        Label {
            id: titleLabel
            text: title
            font.pointSize: Style.pointSizeStandard
            font.bold: true
            elide: Text.ElideRight
            height: parent.height
            verticalAlignment: Qt.AlignVCenter
            leftPadding: 10
            rightPadding: 10
        }

        background: Rectangle {
            color: Style.colorPrimary
            implicitHeight: 48 //aus Universal Template, notwendig!?
        }

    }

    contentItem: LineInput {
        id: input
        width: parent.width
        placeholderText: "..."
        focus: true        
        onTextChanged: buttonBox.standardButton(DialogButtonBox.Save).enabled = (text !== "")
    }

    footer: DialogButtonBox {
        id: buttonBox
        standardButtons: DialogButtonBox.Save | DialogButtonBox.Cancel
        font.pointSize: Style.pointSizeStandard
    }

    onAboutToShow: buttonBox.standardButton(DialogButtonBox.Save).enabled = false

}
