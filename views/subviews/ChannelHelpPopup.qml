import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import assets
import dialogs

DynamicDialog {
        modal: true
        anchors.centerIn: Overlay.overlay
        width: parent.width / 2

        titleText: "Hinweis zu den Auswahlmöglichkeiten"

        standardButtons: Dialog.Close

        contentComponent:
        ColumnLayout {
            width: parent.width //- parent.leftPadding - parent.rightPadding
            Label {
                text: "Alle / Keine / Umkehren"
                font.pointSize: Style.pointSizeStandard
                font.bold: true
                Layout.fillWidth: true
                Layout.topMargin: 10
            }
            Label {
                text: "Die Auswahl bezieht sich immer auf die aktuell sichtbare Liste. Bereits ausgewählte, nicht sichtbare Kanäle, bleiben unberührt."
                font.pointSize: Style.pointSizeStandard
                wrapMode: Label.WordWrap
                Layout.fillWidth: true
            }
            Label {
                text: "Bereich"
                font.pointSize: Style.pointSizeStandard
                font.bold: true
                Layout.fillWidth: true
                Layout.topMargin: 10
            }
            Label {
                text: "Hier wird immer die gesamte Kanalliste herangezogen, unabhängig von der aktuellen Auswahl."
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
                wrapMode: Label.WordWrap
            }
        }
    }
