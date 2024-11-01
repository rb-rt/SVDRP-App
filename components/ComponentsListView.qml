import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import models 1.0

ListView {
    id: componentsListView

    StreamModel {
        id: streamModel
    }

    TextMetrics {
        id: textMetrics
        font.pointSize: Style.pointSizeSmall
    }

    implicitHeight: childrenRect.height

    property int maxWidth: 0

    delegate:
        GridLayout {
        id: grid
        columns: 4
//        width: parent.width
        width: ListView.view.width

        Label {
            text: switch(modelData.content) {
                  case 1: Style.iconVideo; break;
                  case 2: Style.iconMusic; break;
                  case 3: Style.iconSubtitle; break;
                  case 4: Style.iconMusic; break;
                  case 5: Style.iconVideo; break;
                  case 6: Style.iconMusic; break;
                  case 7: Style.iconMusic; break;
                  case 8: " "; break;
                  case 9: Style.iconVideo; break;
                  case 10: " "; break;
                  case 11: " "; break;
                  default: " "
                  }
            font.pointSize: Style.pointSizeSmall
            font.family: Style.faSolid
            Layout.rightMargin: 5
        }

        Label {
//            text: streams.getComponent(modelData.content, modelData.type)
            text: streamModel.getStream(modelData.content, modelData.type)
            font.pointSize: Style.pointSizeSmall
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
        Label {
            text:  modelData.language
            font.pointSize: Style.pointSizeSmall
            Layout.rightMargin: 5
            Layout.leftMargin: 5
        }
        Label {
            text: modelData.description
            font.pointSize: Style.pointSizeSmall
            Layout.preferredWidth: textMetrics.width
            onTextChanged: function() {
                if (text.length > componentsListView.maxWidth) {
                    componentsListView.maxWidth = text.length
                    textMetrics.text = text
                }
            }
        }                
    }
}
