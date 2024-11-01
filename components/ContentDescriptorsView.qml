import QtQuick 2.15
import QtQuick.Controls 2.15

Item {

    property alias contentDescriptorsModel: listView.model

    ListView {
        id: listView
        anchors.fill: parent

        delegate: CheckDelegate {
                text: modelData.name
                LayoutMirroring.enabled: true
        }
    }
}
