import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0
import controls 1.0
import QtQuick.Controls.Universal 2.15

Page {
    id: root

    property date start
    Component.onCompleted: {
        start = new Date()
        console.log("TestPage onCompleted",start)
    }
    StackView.onActivating:{
        var d = new Date()
        console.log("TestPage onActivating", d.getTime() - start.getTime())
    }
    StackView.onActivated: {
        var d = new Date()
        console.log("TestPage onActivated",d.getTime() - start.getTime())
    }


    header: ToolBar {
        //        contentHeight: toolButton.implicitHeight

        background: Loader { sourceComponent: Style.headerBackground }

        ToolButtonHeader {  }
    }

//    background: Rectangle {
//        anchors.fill: parent
//        color: "lightsteelblue"
//    }

    ColumnLayout {
        Label  { text: "theme " + root.Universal.theme }

        RowLayout {
            Label { text: "accent " + root.Universal.accent
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.accent
            }
        }
        RowLayout {
            Label {
                text: "foreground " + root.Universal.foreground
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.foreground
            }
        }
        RowLayout {
            Label {
                text: "background " + root.Universal.background
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.background
            }
        }
        RowLayout {
            Label {
                text: "altHighColor " + root.Universal.altHighColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.altHighColor
            }
        }
        RowLayout {
            Label {
                text: "altLowColor " + root.Universal.altLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.altLowColor
            }
        }
        RowLayout {
            Label {
                text: "altMediumColor " + root.Universal.altMediumColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.altMediumColor
            }
        }
        RowLayout {
            Label {
                text: "altMediumHighColor " + root.Universal.altMediumHighColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.altMediumHighColor
            }
        }
        RowLayout {
            Label {
                text: "altMediumLowColor " + root.Universal.altMediumLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.altMediumLowColor
            }
        }
        RowLayout {
            Label {
                text: "baseHighColor " + root.Universal.baseHighColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.baseHighColor
            }
        }
        RowLayout {
            Label {
                text: "baseLowColor " + root.Universal.baseLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.baseLowColor
            }
        }
        RowLayout {
            Label {
                text: "baseMediumColor " + root.Universal.baseMediumColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.baseMediumColor
            }
        }
        RowLayout {
            Label {
                text: "baseMediumHighColor " + root.Universal.baseMediumHighColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.baseMediumHighColor
            }
        }
        RowLayout {
            Label {
                text: "baseMediumLowColor " + root.Universal.baseMediumLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.baseMediumLowColor
            }
        }
        RowLayout {
            Label {
                text: "chromeAltLowColor " + root.Universal.chromeAltLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeAltLowColor
            }
        }
        RowLayout {
            Label {
                text: "chromeBlackHighColor " + root.Universal.chromeBlackHighColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeBlackHighColor
            }
        }
        RowLayout {
            Label {
                text: "chromeBlackLowColor " + root.Universal.chromeBlackLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeBlackLowColor
            }
        }
        RowLayout {
            Label {
                text: "chromeBlackMediumLowColor " + root.Universal.chromeBlackMediumLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeBlackMediumLowColor
            }
        }
        RowLayout {
            Label {
                text: "chromeBlackMediumColor " + root.Universal.chromeBlackMediumColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeBlackMediumColor
            }
        }
        RowLayout {
            Label {
                text: "chromeDisabledHighColor " + root.Universal.chromeDisabledHighColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeDisabledHighColor
            }
        }
        RowLayout {
            Label {
                text: "chromeDisabledLowColor " + root.Universal.chromeDisabledLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeDisabledLowColor
            }
        }
        RowLayout {
            Label {
                text: "chromeHighColor " + root.Universal.chromeHighColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeHighColor
            }
        }
        RowLayout {
            Label {
                text: "chromeLowColor " + root.Universal.chromeLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeLowColor
            }
        }
        RowLayout {
            Label {
                text: "chromeMediumColor " + root.Universal.chromeMediumColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeMediumColor
            }
        }
        RowLayout {
            Label {
                text: "chromeMediumLowColor " + root.Universal.chromeMediumLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeMediumLowColor
            }
        }
        RowLayout {
            Label {
                text: "chromeWhiteColor " + root.Universal.chromeWhiteColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.chromeWhiteColor
            }
        }
        RowLayout {
            Label {
                text: "listLowColor " + root.Universal.listLowColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.listLowColor
            }
        }
        RowLayout {
            Label {
                text: "listMediumColor " + root.Universal.listMediumColor
                font.pointSize: Style.pointSizeStandard
            }
            Rectangle {
                width: 100
                height: Style.pointSizeStandard
                color: root.Universal.listMediumColor
            }
        }

        /*
        Label { text: ""; type: "QVariant" }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        Label { text: ""; type: "QColor"; isReadonly: true }
        */
    }


    footer: ToolBar {
        height: 40
        background: Loader { sourceComponent: Style.headerBackground }

    }

}
