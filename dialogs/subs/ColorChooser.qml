import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import assets

Item {
    id: root

    property color defaultColor: "#123456"

    property alias hue: hueSlider.value
    property alias alpha: alphaSlider.value

    property real saturation: defaultColor.hsvSaturation
    property real colorValue: defaultColor.hsvValue

    function getColor() : color {
        return Qt.hsva(hueSlider.value, saturation, colorValue, alphaSlider.value)
    }

    function compColor(hue:real) : color {
        var h =  hue + 0.5
        if (h > 1) h = h - 1
        return Qt.hsva(h, 1, 1, 1)
    }
    function compTextColor(c : color) : color {
        var a = c.a
        console.log("Alpha",a)
        var  d = Qt.rgba (1-a, 1-a, 1-a, 1)
        console.log("TextColor",d)
        return d
        // if (c.a < 0.5) return d; else return Qt.hsva(a, a, a, 1)
    }

    function realCompColor() : color {
        var c = getColor()
        return Qt.rgba(1-c.r, 1-c.g, 1-c.b, 1)
    }

    GridLayout {
        id: grid
        columns: 2
        anchors.fill: parent
        rowSpacing: 20
        columnSpacing: 20

        property bool quer: width > height

        ColumnLayout {
            Layout.columnSpan: grid.quer ? 1 : 2
            Layout.rowSpan: grid.quer ? 2 : 1
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignTop
            spacing: 10

            Loader {
                id: hueLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: width
                Layout.maximumHeight: width
                sourceComponent: hueComponentAnalog

                states: State {
                    name: "discret"
                    when: discretCheckBox.checked
                    PropertyChanges {
                        target: hueLoader
                        sourceComponent: hueComponentDiscret
                    }
                }
            }

            Slider {
                id: hueSlider
                Layout.fillWidth: true
                value: defaultColor.hsvHue

                background: Rectangle {
                    id: bg
                    implicitHeight: 32
                    width: hueSlider.availableWidth
                    x: hueSlider.leftPadding
                    y: hueSlider.topPadding + hueSlider.availableHeight / 2 - height / 2


                    gradient: Gradient {
                        id: gradient
                        orientation: hueSlider.orientation
                        GradientStop { position: 0.0;  color: "#FF0000" }
                        GradientStop { position: 60/360; color: "#FFFF00" }
                        GradientStop { position: 120/360; color: "#00FF00" }
                        GradientStop { position: 180/360;  color: "#00FFFF" }
                        GradientStop { position: 240/360; color: "#0000FF" }
                        GradientStop { position: 300/360; color: "#FF00FF" }
                        GradientStop { position: 1.0;  color: "#FF0000" }
                    }
                }

                handle: Rectangle {
                    x: hueSlider.leftPadding + hueSlider.visualPosition * (hueSlider.availableWidth - width)
                    y: hueSlider.topPadding + hueSlider.availableHeight / 2 - height / 2
                    width: bg.height / 2 // alphaSlider.height / 2
                    height: bg.height + 2
                    radius: width / 4
                    border.color: "dimgrey"
                    border.width: 2
                    color: hueSlider.pressed ? "#f0f0f0" : "#f6f6f6"
                    opacity: 0.7
                }
            }

            Slider {
                id: alphaSlider
                Layout.fillWidth: true
                value: defaultColor.a

                background: Rectangle {
                    id: background
                    x: alphaSlider.leftPadding
                    y: alphaSlider.topPadding + alphaSlider.availableHeight / 2 - height / 2
                    implicitHeight: 32
                    width: alphaSlider.availableWidth
                    radius: 2
                    color: "transparent"

                    Row {
                        anchors.fill: parent
                        clip: true
                        Repeater {
                            model: (parent.width / parent.height)
                            delegate: Grid {
                                columns: 2
                                width: parent.height
                                height: parent.height
                                Rectangle {width: height; height: parent.height / 2; color: "white" }
                                Rectangle {width: height; height: parent.height / 2; color: "gray" }
                                Rectangle {width: height; height: parent.height / 2; color: "gray" }
                                Rectangle {width: height; height: parent.height / 2; color: "white" }
                            }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            orientation: alphaSlider.orientation
                            GradientStop { position: 0.0;  color: "#00000000" }
                            GradientStop { position: 1.0;  color: "#FF000000" }
                        }
                    }
                }

                handle: Rectangle {
                    x: alphaSlider.leftPadding + alphaSlider.visualPosition * (alphaSlider.availableWidth - width)
                    y: alphaSlider.topPadding + alphaSlider.availableHeight / 2 - height / 2
                    width: background.height / 2 // alphaSlider.height / 2
                    height: background.height + 2
                    radius: width / 4
                    color: alphaSlider.pressed ? "#f0f0f0" : "#f6f6f6"
                    border.color: "dimgrey"
                    border.width: 2
                    opacity: 0.8
                }

            }

            RowLayout {
                Layout.topMargin: 20
                CheckBox {
                    id: discretCheckBox
                    text: "Farbraster"
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: "Farbe:"
                    font.pointSize: Style.pointSizeStandard
                }
                TextField {
                    id: inputHexColor
                    text: getColor()
                    maximumLength: 9
                    font.pointSize: Style.pointSizeStandard
                    Layout.preferredWidth: implicitWidth * 2
                    validator: RegularExpressionValidator {
                        regularExpression: /^#([A-Fa-f0-9]{8}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
                    }
                    onEditingFinished: {
                        console.log("onEditingFinished",text, acceptableInput)
                        var c  = Qt.color(text)
                        hue = c.hsvHue
                        saturation = c.hsvSaturation
                        colorValue = c.hsvValue
                        alpha = c.a
                    }
                    onActiveFocusChanged: {
                        if (!acceptableInput) focus = true
                        console.log("onActiveFocusChanged",activeFocus,acceptableInput)
                    }

                    states: [
                        State {
                            when: !inputHexColor.acceptableInput
                            PropertyChanges {
                                target: inputHexColor
                                color: "red"
                            }
                        }
                    ]
                }
                Label {
                    text: "ungültig"
                    visible: !inputHexColor.acceptableInput
                    font.pointSize: Style.pointSizeStandard
                }
            }
        }

        //Farbboxen
        ColumnLayout {

            Layout.preferredWidth: parent.width / 2
            Layout.row: grid.quer ? 0 : 1
            Layout.column: grid.quer ? 1 : 0
            Layout.alignment: Qt.AlignTop
            // spacing: 0

            Rectangle {
                color: defaultColor
                Layout.fillWidth: true
                Layout.preferredHeight: refLabel.height * 3 //  childrenRect.height * 3
                border.width: 2
                border.color: color.hsvSaturation < 0.5 ? Qt.darker(color, 1.5) : Qt.lighter(color, 1.5)
                Label {
                    id: refLabel
                    text: "Aktuelle Farbe"
                    anchors.centerIn: parent
                    color: defaultColor.a < 0.5 ? Style.colorForeground : compColor(defaultColor.hsvHue)
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        hue = defaultColor.hsvHue
                        saturation = defaultColor.hsvSaturation
                        colorValue = defaultColor.hsvValue
                        alpha = defaultColor.a
                    }
                }
            }
            Rectangle {
                color: getColor()
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height * 3
                border.width: 2
                border.color: color.hsvSaturation < 0.5 ? Qt.darker(color, 1.5) : Qt.lighter(color, 1.5)
                Label {
                    text: "Neue Farbe"
                    // color: alphaSlider.value < 0.5 ? Style.colorForeground : Style.colorBackground //compColor(hueSlider.value)
                    color: compColor(hueSlider.value)
                    // color: compTextColor(parent.color)
                    anchors.centerIn: parent
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                color: "transparent"

                Label {
                    text: "Klick auf \"Aktuelle Farbe\" setzt die Werte zurück"
                    font.pointSize: Style.pointSizeSmall
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
            Rectangle {
                color: getColor()
                Layout.fillWidth: true
                Layout.preferredHeight: childrenRect.height * 3
                border.width: 2
                border.color: color.hsvSaturation < 0.5 ? Qt.darker(color, 1.5) : Qt.lighter(color, 1.5)
                Label {
                    text: "Komplementärfarbe"
                    // color: alphaSlider.value < 0.5 ? Style.colorForeground : compColor(hueSlider.value)
                    color: realCompColor()
                    anchors.centerIn: parent
                }
            }
        }

        //Textboxen
        Rectangle {
            id: textRectangle
            Layout.fillHeight: true
            color: "transparent"
            Layout.preferredWidth: parent.width / 2
            Layout.row: 1
            Layout.column: 1
            Layout.alignment: Qt.AlignTop
            Layout.minimumHeight: childrenRect.height


            property color c: getColor()

            function setColor(c:color) {
                hue = c.hsvHue
                saturation = c.hsvSaturation
                colorValue = c.hsvValue
                alpha = c.a
            }

            GridLayout {
                columns: 2

                Label {
                    // id: colorLabel
                    Layout.columnSpan: 2
                    text: "Farbe: " + textRectangle.c
                    font.bold: true
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: "Rot:"
                    font.pointSize: Style.pointSizeStandard
                }
                ColorField {
                    font.pointSize: Style.pointSizeStandard
                    text: (textRectangle.c.r * 255).toFixed(0)
                    onEditingFinished: {
                        console.log("ColorField onEditingFinished",text, acceptableInput)
                        var rgba  = Qt.rgba(text/255, textRectangle.c.g, textRectangle.c.b, textRectangle.c.a)
                        console.log("Farbe:",rgba)
                        textRectangle.setColor(rgba)
                    }
                }
                Label {
                    text: "Grün:"
                    font.pointSize: Style.pointSizeStandard
                }
                ColorField {
                    font.pointSize: Style.pointSizeStandard
                    text: (textRectangle.c.g * 255).toFixed(0)
                    onEditingFinished: textRectangle.setColor(Qt.rgba(textRectangle.c.r, text/255, textRectangle.c.b, textRectangle.c.a))
                }
                Label {
                    text: "Blau:"
                    font.pointSize: Style.pointSizeStandard
                }
                ColorField {
                    font.pointSize: Style.pointSizeStandard
                    text: (textRectangle.c.b * 255).toFixed(0)
                    onEditingFinished: textRectangle.setColor(Qt.rgba(textRectangle.c.r, textRectangle.c.g, text/255, textRectangle.c.a))
                }
                Label {
                    text: "Alpha:"
                    font.pointSize: Style.pointSizeStandard
                }
                RowLayout {
                    ColorField {
                        font.pointSize: Style.pointSizeStandard
                        text: (textRectangle.c.a * 100).toFixed(0) // + " (" + (textRectangle.c.a * 100).toFixed(0) + " %)"
                        onEditingFinished: textRectangle.setColor(Qt.rgba(textRectangle.c.r, textRectangle.c.g, textRectangle.c.b, text/100))
                        validator: IntValidator {
                            bottom: 0
                            top: 100
                        }
                    }
                    Label {
                        text: "%"
                        font.pointSize: Style.pointSizeStandard
                    }
                }
                Label {
                    text: "Farbton:"
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: (textRectangle.c.hsvHue).toFixed(2) + " (" + (textRectangle.c.hsvHue * 360).toFixed(0) + " Grad)"
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: "Sättigung:"
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: (textRectangle.c.hsvSaturation).toFixed(2)
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: "Helligkeit:"
                    font.pointSize: Style.pointSizeStandard
                }
                Label {
                    text: (textRectangle.c.hsvValue).toFixed(2)
                    font.pointSize: Style.pointSizeStandard
                }
            }
        }

        Component {
            id: hueComponentAnalog
            Rectangle {
                anchors.fill: parent
                // color: "yellow"

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        orientation: Qt.Horizontal
                        GradientStop { position: 0.0; color: "#FFFFFFFF" }
                        GradientStop { position: 1.0; color: Qt.hsva(hueSlider.value, 1, 1.0, 1) } // "#FFFF0000" }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 1.0; color: "#FF000000" }
                    }
                    border.width: 1
                    border.color: Style.colorForeground
                }

                Rectangle {
                    id: cursor
                    width: 24
                    height: 24
                    color: "transparent"
                    border.width: 2
                    border.color: compColor(hueSlider.value)
                    radius: 12

                    Rectangle {
                        // anchors.fill: parent
                        anchors.centerIn: parent
                        color: compColor(hueSlider.value)
                        width: 3
                        height: 3

                    }

                    x: saturation * parent.width - radius
                    y: (1 - colorValue) * parent.height - radius
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.CrossCursor
                    onPositionChanged: mouse => handleMouse(mouse)
                    onClicked: mouse => handleMouse(mouse)
                    function handleMouse(mouse) {
                        // console.log("handleMouse",mouseY,height)
                        if (mouseX < 0) { saturation = 0 }
                        else if (mouseX > width) { saturation = 1 }
                        else { saturation = mouseX / width }

                        if (mouseY < 0) { colorValue = 1 }
                        else if (mouseY > height) { colorValue = 0 }
                        else { colorValue = 1 - (mouseY / height) }

                        // console.log("Farbe",Qt.hsva(hueSlider.value, saturation, colorValue, 1.0))
                    }
                }
            }

        }


        Component {
            id: hueComponentDiscret
            Rectangle {
                anchors.fill: parent
                color: "transparent"

                Grid {
                    id: grid

                    anchors.fill: parent

                    property int rectangles: columns * columns
                    property int minWidth: 64 //Minimale Breite einer Farbbox
                    property int recWidth: { return (width - (columns-1)*spacing) / columns }
                    property int recHeight: { return (height - (columns-1)*spacing) / columns }

                    spacing: 6

                    onWidthChanged: {
                        var x = Math.floor(parent.width / minWidth)
                        if ((x % 2) === 1) x = x - 1
                        if ( x < 4) x = 4
                        if ( x > 8) x = 8
                        if (columns !== x) {
                            console.log("onWidthChanged ändere columns columns",columns,"x:",x)
                            columns = x
                        }
                    }

                    Repeater {
                        id: upperRepeater
                        model: grid.rectangles / 2
                        ColorRectangle {
                            width: grid.recWidth
                            height: grid.recHeight
                            color: Qt.hsva(hueSlider.value,index/upperRepeater.count, 1)
                            border.color: Qt.darker(color, 1.5)
                        }
                    }
                    Repeater {
                        id: lowerRepeater
                        model: grid.rectangles / 2
                        ColorRectangle {
                            width: grid.recWidth
                            height: grid.recHeight
                            color: Qt.hsva(hueSlider.value, 1, 1 - index/lowerRepeater.count,1)
                            border.color: Qt.lighter(color, 1.5)
                        }
                    }
                }
            }
        }


        component ColorRectangle: Rectangle {
            id: colorRectangle
            border.width: 1
            states: [
                State {
                    name: "selected"
                    when: Qt.colorEqual(color, getColor())
                    PropertyChanges {
                        target: colorRectangle
                        border.width: 3
                        border.color: compColor(hueSlider.value)
                    }
                }
            ]
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Farbe:",parent.color)
                    saturation = parent.color.hsvSaturation
                    colorValue = parent.color.hsvValue
                    alpha = parent.color.a
                }
            }
        }


    }//GridLayout
}
