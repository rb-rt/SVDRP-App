import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import controls 1.0 as MyControls
// import "subs"

DynamicDialog {

    id: root

    property alias datum: cal.selectedDate

    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.NoAutoClose

    titleText: cal.selectedDate.toLocaleDateString(locale,"ddd, dd.MM.yyyy")
    headerIcon: Style.iconCalender
    fontSolid: false

    contentItem: MyControls.Kalender {
        id: cal
    }

    standardButtons: Dialog.Apply | Dialog.Cancel
    onApplied: close()
}
