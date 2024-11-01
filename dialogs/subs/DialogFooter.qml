import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0

DialogButtonBox {

    font.pointSize: Style.pointSizeStandard
//        standardButtons: Dialog.Ok //Funktioniert mit einem Button nicht
    alignment: Qt.AlignHCenter | Qt.AlignVCenter

    background: Rectangle {
        color: Qt.darker(Style.colorPrimary, 1.5)
    }

}
