import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0
import controls 1.0

Page {
    id: root


    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent
            ToolButtonHeader { }

        }
    }

    Label {
        text: "+Test RemoteÜage.qml"
    }

}
