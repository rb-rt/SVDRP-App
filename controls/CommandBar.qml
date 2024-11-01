import QtQuick 2.15
import QtQuick.Layouts 1.15

RowLayout {
    property alias commandList: commandRepeater.model
    //        spacing: 0
    Repeater {
        id: commandRepeater
        delegate: CommandButton {
            iconCharacter: commandRepeater.model.iconCharakter
            description: commandRepeater.model.description
        }
    }
}

