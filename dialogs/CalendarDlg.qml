import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import controls 1.0 as MyControls
import "subs"

Dialog {

    id: root

    property alias datum: cal.selectedDate
   // onDatumChanged: console.log("CalendarDlg onDatumChanged",datum)

    anchors.centerIn: parent
    modal: true
    closePolicy: Popup.NoAutoClose

    header: DialogHeaderToolBar {
        icon: Style.iconCalender
        text: cal.selectedDate.toLocaleDateString(locale,"ddd, dd.MM.yyyy")
    }

    contentItem: MyControls.Kalender {
        id: cal
    }

    footer: DialogFooterToolBar {
        onOkClicked: accept()
    }

}
