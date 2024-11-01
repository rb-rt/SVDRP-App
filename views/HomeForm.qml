import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import assets 1.0
import components 1.0
import controls 1.0 as MyControls
import dialogs 1.0
Page {
    id: root

    property string text: "HomePage"

    header: ToolBar {
        //        contentHeight: toolButton.implicitHeight

        background: Loader { sourceComponent: Style.headerBackground }

        MyControls.ToolButtonHeader {

        }
    }

    //    property date datum: new Date()
    //    property date datum: new Date(2022,2,3)
    //    onDatumChanged: console.log("HomeForm.qml onDatumChanged",datum)


    //    Rectangle {

    //        x: 20
    //        y: 25
    //        anchors.fill: parent

    //        color: "lightgreen"
    //        implicitWidth: childrenRect.width + 2
    //        implicitHeight: childrenRect.height + 2
    //        implicitWidth: row.width + 2
    //        implicitHeight: row.height + 2
    //        gradient: Style.gradientTumblerBackground


    //        border.color: Style.colorPrimary
    //        border.width: 1



    ColumnLayout {
        //        width: root.width
        //        width: 500
        //        anchors.left: parent.left
        //        anchors.right: parent.right
        //        anchors.horizontalCenter: parent.Center
        //        anchors.leftMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        Button {

            text: "Kalender"
            onClicked: {
                dynamicDialog.d = "Neuer Text"
                dynamicDialog.open()
//                dialog.open()
                //                cal.datum = new Date(2023,7,7)
//                                cal.open()
            }
        }

        //        MyControls.Kalender {
        //            id: kalender
        //            selectedDate: new Date()
        //            //        Layout.preferredWidth: parent.width
        ////                    Layout.fillWidth: true
        //            //        Layout.fillHeight: true
        //            onSelectedDateChanged: console.log("HomeForm.qml onSelectedDateChanged",selectedDate)
        //        }

    }
//    CalendarDlg {
//        id: cal
//        onAccepted: console.log("Dialog onAccepted")
//        onRejected: console.log("Dialog onRejected")
//    }
/*
    DynamicTestDialog {
        id: dynamicDialog

        property alias d: contentid.text

//        contentComponent: Label {
//            id: contentid
//            text: "Label"
//            font.pointSize: 40
//        }

        contentItem: Label {
            id: contentid
            text: "Label"
            font.pointSize: 40
        }

//        contentComponent: MyControls.Kalender {
//            id: cal2
////            selectedDate: d
//        }
    }*/


    Dialog {
        id: dialog

        property alias contentComponent: contentLoader.sourceComponent

        modal: true
        anchors.centerIn: parent

        //        title: "Dialog"
        header: ToolBar {

            background: Rectangle {
                color: Style.colorPrimary

                Rectangle {
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                    color: "yellow" // "transparent"
                }

            }

            RowLayout {

//                anchors {
//                    top: parent.top
//                    left: parent.left
//                    bottom: parent.bottom
//                    topMargin: 10
//                    leftMargin: 10
//                    bottomMargin: 10
//                }

                Label {
                    text: "Dialog"
                    font.pointSize: 60
                    Layout.leftMargin: 10
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }
                Label {
                    text: "Dialog 2"
                    font.pointSize: 60
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
//                    Layout.topMargin: 10
//                    Layout.bottomMargin: 10
                }
            }

        }

        onWidthChanged: {
//            console.log ("Dialog onWidthChanged",width, "implicitWidth",implicitWidth,"contentWidth",contentWidth)
//            console.log ("Dialog Header implicitWidth",implicitHeaderWidth)
//            console.log ("Dialog Footer implicitWidth",implicitFooterWidth)
        }
        onHeightChanged: {
//            console.log("Dialog onHeightChanged",height,"implicitHeight",implicitHeight,"contentHeight",contentHeight)
//            console.log ("Dialog implicitHeaderHeight",implicitHeaderHeight)
//            console.log ("Dialog implicitFooterHeight",implicitFooterHeight)
        }

//        contentItem: Label {
//            text: "Label"
//            font.pointSize: 40
//        }

        contentItem: Loader {
            id: contentLoader
        }

        footer: DialogButtonBox {
            standardButtons: Dialog.Ok | Dialog.Cancel
//            font.pointSize: 40

//            topPadding: 20

            background: Rectangle {
                color: Style.colorPrimary
                Rectangle {
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.top
                    color: "yellow" // "transparent"
                }

            }

        }
    }

}
