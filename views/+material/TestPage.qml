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

    Label {
        text: "+material/TestPage.qml"
    }



    footer: ToolBar {
        height: 40
        background: Loader { sourceComponent: Style.headerBackground }

    }

}
