import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import assets 1.0
import components 1.0
import dialogs 1.0
import vdr.remote 1.0
import controls 1.0

Page {
    id: root

    Remote {
        id: remote
        url: channelModel.url
        onSvdrpError: {
            errorDialog.errorText = error
            errorDialog.open()
        }
        Component.onCompleted: {
            remote.send("REMO")
        }
    }


    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent
            ToolButtonHeader { }

            Label {
                text: Style.iconWifi
                font.pointSize: Style.pointSizeHeaderIcon
                font.weight: Font.Bold
                font.family: Style.faSolid
            }
            Label {
                text: channelModel.url.toString().substr(7)
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                elide: Text.ElideRight
                //                Layout.fillWidth: true
                Layout.leftMargin: 5
            }
            ToolButton {
                id: switchButton
                text: remote.status ? "An" : "Aus"
                font.pointSize: Style.pointSizeStandard
                Layout.leftMargin: 10
                background: Rectangle {
                    id: bkg
                    anchors.fill: parent
                    radius: 4
                    border.width: 2
                    gradient: Style.gradientListToolButton
                    border.color: Qt.lighter(Style.colorPrimary)
                    states: State {
                        when: switchButton.down
                        PropertyChanges {
                            target: bkg
                            border.color: Qt.darker(Style.colorPrimary, 1.2)
                            gradient: Style.gradientList
                        }
                    }
                }
                onClicked: {
                    if (remote.status) remoteSwitched.open()
                    remote.status = !remote.status
                }
            }
            ToolButton {
                id: volumeButton
                text: Style.iconVolUp
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                Layout.preferredHeight: switchButton.height
                Layout.preferredWidth: switchButton.height
                Layout.leftMargin: 10
                background: Rectangle {
                    id: bkg2
                    anchors.fill: parent
                    radius: 4
                    border.width: 2
                    gradient: Style.gradientListToolButton
                    border.color: Qt.lighter(Style.colorPrimary)
                    states: State {
                        when: volumeButton.down
                        PropertyChanges {
                            target: bkg2
                            border.color: Qt.darker(Style.colorPrimary, 1.2)
                            gradient: Style.gradientList
                        }
                    }
                }
                onClicked: {
                    volumePopup.open()
                }
            }
            Rectangle {
                Layout.preferredHeight: parent.height
                Layout.fillWidth: true
                color: "transparent"
            }
            Rectangle {
                Layout.preferredHeight: parent.height - 4
                Layout.preferredWidth: height
                Layout.rightMargin: 20
                color: "transparent"
                border.width: 2
                border.color: Qt.darker(Style.colorForeground)
                radius: height / 2
                gradient: Style.gradientList
                Label {
                    id: powerlabel
                    anchors.fill: parent
                    text: Style.iconPower
                    font.family: Style.faSolid
                    font.pointSize: Style.pointSizeLarge
                    color: "red"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    states: [
                        State {
                            name: "hover"
                            PropertyChanges {
                                target: powerlabel
                                font.pointSize: Style.pointSizeLarge * 1.2
                            }
                        }
                    ]
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: powerlabel.state = "hover"
                        onExited: powerlabel.state = ""
                        onClicked: powerOffDlg.open()
                    }
                }
            }
        }
    }

    property bool quer: width > height//

    onWidthChanged: calculate()
    onHeightChanged: calculate()

    readonly property color borderColor: Style.colorPrimary
    readonly property int columnSpacing: 20 //Abstand zwischen den Columns
    readonly property int gridSpacing:5 //Abstand der Buttons zueinander
    readonly property int margins: 10 //Abstand zu Rändern

    property int colWidth: 0
    property int refButtonWidth: 0
    property int refButtonHeight: 0

    onRefButtonWidthChanged: refButtonHeight = calcButtonHeight()

    function calcButtonHeight() {
        var buttonHeight = refButtonWidth * 0.66

        //Manchmal 0 ??
        if (implicitHeaderHeight === 0 || implicitFooterHeight === 0) {
            var colHeight = root.height - 2*48 - 2*root.margins
        }
        else {
            colHeight = root.height - implicitHeaderHeight - implicitFooterHeight - 2*root.margins
        }

        if (width > height) {
            var allHeight = 7*buttonHeight + 5*root.gridSpacing + root.columnSpacing
        }
        else {
            allHeight = 9*buttonHeight + 6*root.gridSpacing + 2*root.columnSpacing
        }

        if (allHeight > colHeight) {
            if (width > height) {
                var n = (colHeight - root.columnSpacing - 5*root.gridSpacing) / 7
            }
            else {
                n = (colHeight - 2*root.columnSpacing - 6*root.gridSpacing) / 9
            }

            buttonHeight = n
        }
        return buttonHeight
    }

    function calculate() {
        if (width > height) {
            root.colWidth = (root.width - 2*root.margins - 2*root.columnSpacing) / 3
        }
        else {
            root.colWidth = (root.width - 2*root.margins - root.columnSpacing) / 2
        }
    }

    SwipeView {
        id: swipeView

        anchors.fill: parent

        Loader {
            sourceComponent: quer ? landscapePage1 : portraitPage1
        }
        //        Loader {
        //            sourceComponent: portraitPage2
        //        }
    }
    /*
    PageIndicator {
        id: pi
        count: swipeView.count
        currentIndex: swipeView.currentIndex
        anchors.bottom: swipeView.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        delegate: Rectangle {
               implicitWidth: 16
               implicitHeight: implicitWidth

               radius: height / 2
               color: Style.colorAccent
               border.width: 1
               border.color: Qt.lighter(color)

               opacity: index === pi.currentIndex ? 1 : 0.5

               Behavior on opacity {
                   OpacityAnimator {
                       duration: 250
                   }
               }
           }
    }
*/
    //Hochformat
    Component {
        id: portraitPage1
        RowLayout {

            //            anchors {
            //                fill: parent
            //                leftMargin: root.margins
            //                topMargin: root.margins
            //                bottomMargin: root.margins
            //                rightMargin: root.margins
            //            }

            spacing: root.columnSpacing

            ColumnLayout {
                spacing: root.columnSpacing
                Layout.preferredWidth: root.colWidth
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: root.margins
                Layout.topMargin: root.margins
                Layout.bottomMargin: root.margins

                Loader {
                    Layout.fillWidth: true
                    sourceComponent: numPad
                }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: steuerKreuz
                }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: volume
                }
            }

            ColumnLayout {
                spacing: root.columnSpacing
                Layout.preferredWidth: root.colWidth
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                Layout.rightMargin: root.margins
                Layout.topMargin: root.margins
                Layout.bottomMargin: root.margins
                //                            Rectangle {
                //                                Layout.fillWidth: true
                //                                height: 30
                //                            }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: play
                }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: menu
                }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: setup
                }

            }

        }
    }

    Component {
        id: portraitPage2

        ColumnLayout {
            anchors {
                fill: parent
                leftMargin: root.margins
                topMargin: root.margins
                bottomMargin: root.margins
                rightMargin: root.margins
            }

            //            spacing: root.columnSpacing

            Rectangle {
                Layout.preferredWidth: grid.width
                Layout.preferredHeight: root.refButtonHeight
                Layout.alignment: Qt.AlignTop
                color: "transparent"
                border.width: 1
                border.color: borderColor
                Label {
                    id: commandsLabel
                    text: "Befehle"
                    width: parent.width
                    height: parent.height
                    font.pointSize: Style.pointSizeLarge
                    fontSizeMode: Text.HorizontalFit
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    background: Rectangle {
                        width: parent.width -2
                        height: parent.height - 2
                        anchors.centerIn: parent
                        gradient: Style.gradientList
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: commandsLabel.background.gradient = Style.gradientListHover
                    onExited: commandsLabel.background.gradient = Style.gradientList
                    onClicked: remote.send("Commands")
                }
            }

            Label {
                text: "Benutzerdefinierte Befehle"
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: grid.width
                font.pointSize: Style.pointSizeLarge
                Layout.alignment: Qt.AlignTop
                font.weight: Font.Bold
                wrapMode: Text.Wrap
            }

            GridLayout {
                id: grid
                columns: 2
                property int buttonWidth: (parent.width - columnSpacing) / 4
                Layout.alignment: Qt.AlignTop

                Repeater {
                    model: 10
                    Rectangle {
                        Layout.preferredWidth: grid.buttonWidth
                        Layout.preferredHeight: root.refButtonHeight
                        color: "transparent"
                        border.width: 1
                        border.color: borderColor

                        Label {
                            id: userLabel
                            text: "User" + model.index
                            width: parent.width
                            height: parent.height
                            font.pointSize: Style.pointSizeLarge
                            fontSizeMode: Text.HorizontalFit
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            background: Rectangle {
                                width: parent.width -2
                                height: parent.height - 2
                                anchors.centerIn: parent
                                gradient: Style.gradientList
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: userLabel.background.gradient = Style.gradientListHover
                            onExited: userLabel.background.gradient = Style.gradientList
                            onClicked: remote.send("User" + model.index)
                        }
                    }
                }
            }
        }
    }

    //Querformat
    Component {
        id: landscapePage1

        RowLayout {
            id: rowLayout
            //            anchors {
            //                fill: parent
            //                leftMargin: root.margins
            //                topMargin: root.margins
            //                bottomMargin: root.margins
            //                rightMargin: root.margins
            //            }

            spacing: root.columnSpacing
            //            visible: quer

            ColumnLayout {
                spacing: root.columnSpacing
                Layout.preferredWidth: root.colWidth
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: root.margins
                Layout.topMargin: root.margins
                Layout.bottomMargin: root.margins

                //            onWidthChanged: {
                //                console.log("Querformat RowLayout ColumnLayout onWidthChanged root.width", root.width, "width", width)
                //            }

                //            Rectangle {
                //                Layout.fillWidth: true
                //                Layout.fillHeight: true
                //                height: 33
                //                color: "yellow"
                //            }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: numPad
                }
                //            Rectangle {
                //                Layout.fillWidth: true
                //                Layout.fillHeight: true
                //                height: 33
                //                color: "green"
                //            }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: steuerKreuz
                }
            }

            ColumnLayout {
                spacing: root.columnSpacing
                Layout.preferredWidth: root.colWidth
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: root.margins
                Layout.bottomMargin: root.margins

                //            Rectangle {
                //                Layout.fillWidth: true
                //                height: 30
                //            }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: menu
                }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: volume
                }

            }

            ColumnLayout {
                spacing: root.columnSpacing
                Layout.preferredWidth: root.colWidth
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: root.margins
                Layout.bottomMargin: root.margins
                Layout.rightMargin: root.margins

                //            Rectangle {
                //                Layout.fillWidth: true
                //                height: 25
                //                color: "lightsteelblue"
                //            }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: play
                }
                Loader {
                    Layout.fillWidth: true
                    sourceComponent: setup
                }
            }

        }
    }


    //Ab hier die einzelnen Komponenten

    Component {
        id: numPad
        GridLayout {
            id: grid
            columns: 3

            columnSpacing: root.gridSpacing
            rowSpacing: root.gridSpacing

            property int buttonWidth: (parent.width - 2*columnSpacing) / 3

            onButtonWidthChanged: root.refButtonWidth = buttonWidth

            Repeater {
                model: 9
                RemoteButton {
                    Layout.preferredWidth:  buttonWidth
                    Layout.preferredHeight: refButtonHeight
                    text: model.index + 1
                    onClicked: {
                        var key = (model.index+1).toString()
                        remote.send(key)
                    }
                }
            }
            RemoteButton {
                Layout.preferredWidth:  buttonWidth
                Layout.preferredHeight: refButtonHeight
                Layout.row: 3
                Layout.column: 1
                text: "0"
                onClicked: remote.send("0")
            }
        }
    }


    Component {
        id: steuerKreuz
        GridLayout {
            id: grid
            columns: 3
            rows: 3
            columnSpacing: root.gridSpacing
            rowSpacing: root.gridSpacing

            property int buttonWidth: (parent.width - 2*columnSpacing) / 3
            property int buttonHeight: root.refButtonHeight

            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: buttonHeight
                Layout.column: 1
                Layout.row: 0
                text: Style.iconUp
                fontFamily: Style.faSolid
                onClicked: remote.send("Up")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: buttonHeight
                Layout.column: 0
                Layout.row: 1
                text: Style.iconLeft
                fontFamily: Style.faSolid
                onClicked: remote.send("Left")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: buttonHeight
                Layout.column: 1
                Layout.row: 1
                text: "Ok"
                onClicked: remote.send("Ok")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: buttonHeight
                Layout.column: 2
                Layout.row: 1
                text: Style.iconRight
                fontFamily: Style.faSolid
                onClicked: remote.send("Right")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: buttonHeight
                Layout.column: 1
                Layout.row: 2
                text: Style.iconDown
                fontFamily: Style.faSolid
                onClicked: remote.send("Down")
            }
        }
    }


    Component {
        id: volume
        GridLayout {
            id: grid
            columns: 3
            rows: 2
            columnSpacing: root.gridSpacing
            rowSpacing: root.gridSpacing

            property int buttonWidth: (parent.width - 2*columnSpacing) / 3

            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: root.refButtonHeight
                text: Style.iconVolUp
                fontFamily: Style.faSolid
                onClicked: remote.send("Volume+")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: root.refButtonHeight
                Layout.rowSpan: 2
                text: Style.iconVolMute
                fontFamily: Style.faSolid
                onClicked: remote.send("Mute")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: root.refButtonHeight
                text: Style.iconChannelUp
                fontFamily: Style.faSolid
                onClicked: remote.send("Channel+")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: root.refButtonHeight
                text: Style.iconVolDn
                fontFamily: Style.faSolid
                onClicked: remote.send("Volume-")
            }
            RemoteButton {
                Layout.preferredWidth: buttonWidth
                Layout.preferredHeight: root.refButtonHeight
                text: Style.iconChannelDn
                fontFamily: Style.faSolid
                onClicked: remote.send("Channel-")
            }
        }
    }

    Component {
        id: menu
        GridLayout {
            id: grid
            columns: 2
            columnSpacing: root.gridSpacing
            rowSpacing: root.gridSpacing

            property int buttonWidth: (parent.width - columnSpacing) / 2

            ListModel {
                id: settings
                ListElement { text: "Menü"; command: "Menu"; icon: "" }
                ListElement { text: "Zurück"; command: "Back"; icon: "" }
                ListElement { text: "Kanäle"; command: "Channels"; icon: "" }
                ListElement { text: "Programm"; command: "Schedule"; icon: "" }
                ListElement { text: "Timer"; command: "Timers"; icon: "" }
                ListElement { text: "Aufnahmen"; command: "Recordings"; icon: "" }

                Component.onCompleted: {
                    setProperty(3,"icon", Style.iconClock)
                    setProperty(4,"icon", Style.iconTimer)
                    setProperty(5,"icon", Style.iconDatabase)
                }
            }

            Repeater {
                model: settings
                RemoteButton {
                    Layout.preferredWidth: buttonWidth
                    Layout.preferredHeight: root.refButtonHeight
                    text: model.text
                    onClicked: remote.send(model.command)
                }
            }
        }
    }

    Component {
        id: setup
        GridLayout {
            id: grid
            columns: 2
            columnSpacing: root.gridSpacing
            rowSpacing: root.gridSpacing

            property int buttonWidth: (parent.width - columnSpacing) / 2

            ListModel {
                id: model
                ListElement { text: "Setup"; command: "Setup" }
                ListElement { text: "Info"; command: "Info" }
                ListElement { text: "Audio"; command: "Audio" }
                ListElement { text: "Untertitel"; command: "Subtitles" }
            }

            Repeater {
                model: model
                RemoteButton {
                    Layout.preferredWidth: buttonWidth
                    Layout.preferredHeight: root.refButtonHeight
                    text: model.text
                    onClicked: remote.send(model.command)
                }
            }
        }
    }

    Component {
        id: play
        GridLayout {
            id: grid
            columns: 2
            columnSpacing: root.gridSpacing
            rowSpacing: root.gridSpacing

            property int buttonWidth: (parent.width - columnSpacing) / 2

            ListModel {
                id: model
                ListElement { text: "Prev"; command: "Prev"; icon: "" }
                ListElement { text: "Next"; command: "Next"; icon: ""  }
                ListElement { text: "FR"; command: "FastRew"; icon: ""  }
                ListElement { text: "FF"; command: "FastFwd"; icon: ""  }
                ListElement { text: "Rec"; command: "Record"; icon: ""  }
                ListElement { text: "Play"; command: "Play"; icon: ""  }
                ListElement { text: "Pause"; command: "Pause"; icon: ""  }
                ListElement { text: "Stop"; command: "Stop"; icon: ""  }

                Component.onCompleted: {
                    model.setProperty(0,"icon", Style.iconPrev)
                    model.setProperty(1,"icon", Style.iconNext)
                    model.setProperty(2,"icon", Style.iconFastBackward)
                    model.setProperty(3,"icon", Style.iconFastForward)
                    model.setProperty(4,"icon", Style.iconRecord)
                    model.setProperty(5,"icon", Style.iconPlay)
                    model.setProperty(6,"icon", Style.iconPause)
                    model.setProperty(7,"icon", Style.iconStop)
                }
            }

            Repeater {
                model: model
                RemoteButton {
                    Layout.preferredWidth: buttonWidth
                    Layout.preferredHeight: root.refButtonHeight
                    text: model.icon
                    fontFamily: Style.faSolid
                    color: model.index === 4 ? "red" : Style.colorForeground
                    onClicked: remote.send(model.command)
                }
            }
        }
    }

    footer: ToolBar {
        id: toolBar
        GridLayout {
            anchors.fill: parent
            anchors.leftMargin: root.margins
            anchors.rightMargin: root.margins
            rows: 1
            Repeater {
                model: ["red","green","yellow","blue"]
                Rectangle {
                    id: colorButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modelData
                    border.width: 2
                    border.color: Qt.darker(modelData)
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: colorButton.color = Qt.darker(modelData)
                        onExited: colorButton.color = modelData
                        onClicked: {
                            console.log("klick",model.index)
                            switch(model.index) {
                            case 0: remote.send("Red"); break;
                            case 1: remote.send("Green"); break;
                            case 2: remote.send("Yellow"); break;
                            case 3: remote.send("Blue"); break;
                            }
                        }
                    }
                }
            }
        }
    }

    ErrorDialog {
        id: errorDialog
    }

    SimpleMessageDialog {
        id: powerOffDlg
        titleText: "VDR auschalten"
        text: "VDR herunterfahren?"
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: remote.send("Power")
    }

    SimpleMessageDialog {
        id: remoteSwitched
        titleText: "Fernbedienung"
        text: "Kontrolle über Fernbedienung ausgeschaltet!"
        standardButtons: Dialog.Close
    }

    Popup {
        id: volumePopup
        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: parent.width / 2
        height: width

        ColumnLayout{
            anchors.fill: parent

            Label {
                id: label
                text: "Laustärke"
                // anchors.horizontalCenter: parent.horizontalCenter
                Layout.alignment: Qt.AlignHCenter
            }

            Dial {
                id: dial
                // anchors.centerIn: parent
                // anchors.fill: parent
                // anchors.top: label.bottom
                // anchors.bottom: valueLabel.top
                // anchors.left: parent.left
                // anchors.right: parent.right
                // width: height
                // height: parent.height - valueLabel.height - label.height
                // Layout.fillHeight: true
                // Layout.fillWidth: true
                Layout.preferredWidth: Math.min(parent.width, parent.height -label.height - valueLabel.height)
                Layout.preferredHeight: width
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignCenter
                from: 0
                to: 255
                stepSize: 1
                value: remote.volume
                onMoved: {
                    remote.volume = value
                }
            }
            Label {
                id: valueLabel
                text: remote.volume
                Layout.alignment: Qt.AlignHCenter
                // anchors.horizontalCenter: parent.horizontalCenter
                // anchors.bottom: parent.bottom
            }
        }
        onAboutToShow: {
            console.log("onAboutToShow")
            console.log("Sende VOLU")
            remote.send("VOLU")
        }
    }
}
