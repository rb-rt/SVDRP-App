pragma Singleton
import QtQuick
import QtQuick.Controls.Universal

import vdr.settings

Item {

    property bool showChannelLogos: false
    property bool showChannelLogosComboBox: false
    property bool showChannelTitle: true
    property bool showEventSubtitle: false
    property bool showFilename: false
    property int marginStart: 2
    property int marginStop: 10
    property int toChannel: 0
    property int recordingsView: 0
    property int priority: 50
    property int lifetime: 99
    property bool showIndicatorIcon: false
    property bool showEventDescription: false
    property bool showInfo: false
    property color colorMainTime
    property bool showMainTime: false
    property date mainTimeFrom
    property date mainTimeTo
    property bool showTimerGap: false
    property color colorTimerGap
    property bool showRecordError: false
    property bool showEpgAtNow: true
    property int favoritesHours: 24
    property int firstView: 4 //Startansicht: 0=Programm, 1=Timer, Reihenfolge wie im Drawer im main.qml

    property alias faSolid: fontSolid.name
    FontLoader {
        id: fontSolid
        source: "qrc:/assets/fa-solid.ttf"
    }
    property alias faRegular: fontRegular.name
    FontLoader {
        id: fontRegular
        source: "qrc:/assets/fa-regular.ttf"
    }

    /* ---------- Schriftgrößen --------------- */

    property real pointSizeStandard: 0 //Ausgangsgröße, davon wird alles andere berechnet, bei 0 wird die Systemgröße benutzt
    readonly property real pointSizeSmall: pointSizeStandard * 0.8
    readonly property real pointSizeLarge: pointSizeStandard * 1.2
    readonly property real pointSizeListIcon: pointSizeStandard * 1.4 //Icongröße in Listen

    /* Header */
    readonly property real pointSizeHeader: pointSizeStandard * 1.1
    readonly property real pointSizeHeaderIcon: pointSizeHeader
    readonly property real pointSizeHeaderSmall: pointSizeStandard * 0.8
    readonly property int fontweightHeader: Font.DemiBold

    readonly property real pointSizeDialogIcon: pointSizeStandard * 1.6 //Für Icons in Dialogen (TimerEditView, Search etc)
    readonly property real listIconPadding: 5 //Abstand der Icons in Listen links (leftPadding:) und rechts

    readonly property int listMinHeight: 40 //Höhe bei einzeiligen Listen wie z.B. die Kanalliste

    /* -------------- Referenzwindow -------------------- */
    readonly property real widthWindow: 640
    readonly property real heightWindow: 1080

    /* ------------ Colors --------------- */
    readonly property color colorListIconStandard: "#85795B" // "#85827B" //"grey"
    readonly property color colorListIconActive: Universal.color(Universal.Green)
    readonly property color colorListIconInactive: Universal.color(Universal.Red)
    readonly property color colorListIconEdit: Universal.color(Universal.Orange)
    readonly property color colorListIconDelete: Universal.color(Universal.Red)
    readonly property color colorListIconSearch: Universal.color(Universal.Teal)
    readonly property color colorListIconMove: Universal.color(Universal.Olive)
    readonly property color colorListIconAction: Universal.color(Universal.Amber)
    readonly property color colorListIconVdrSwitch: Universal.color(Universal.Lime)
    readonly property color colorListIconPlay: Universal.color(Universal.Cyan)
    readonly property color colorListIconPlayLocal: Universal.color(Universal.Amber)
    readonly property color colorListIconPlayVdr: Universal.color(Universal.Lime)
    readonly property color colorListIconRecording: Universal.color(Universal.Magenta)

    readonly property color colorDelete: Universal.color(Universal.Red)
    readonly property color colorRecordingNew: colorAccent
    readonly property color colorRecordingInstant: "#00E000" // "green"
    readonly property color colorRecordingFaulty: "red"
    readonly property color colorWarning: Universal.color(Universal.Yellow)

    readonly property color colorConflictTimer: "yellow"
    readonly property color colorCommandBarBackground: colorPrimary
    readonly property color colorCommandBarFont: Qt.darker(colorForeground, 1.20)



    /* --------- Icons ---------*/
    readonly property string iconBars: "\uf0c9" //Bars (Solid) "\uf065" //
    readonly property string iconChevron: "\uf053" // Solid Backspace alternative
    readonly property string iconChevronRight: "\uf054" // Solid
    readonly property string iconChevronRightCircle: "\uf138" // Solid
    readonly property string iconCheck: "\uf00c" //(Solid)
    readonly property string iconCheckCircle: "\uf058" //(Regular+Solid)
    readonly property string iconCircle: "\uf111" //(Regular+Solid)
    readonly property string iconCircleDot: "\uf192" //(Regular+Solid)
    readonly property string iconClock: "\uf017" //Uhr (Regular+Solid)
    readonly property string iconTimer: "\uf0f3" //Bell (Regular+Solid)
    readonly property string iconTimerSlash: "\uf1f6" //Bell durchgestrichen (Regular+Solid)
    readonly property string iconCalender: "\uf133" //Kalender (Regular+Solid)
    readonly property string iconCalenderAlt: "\uf073" //Kalender mit Rechtecken (Regular+Solid)
    readonly property string iconCalenderCheck: "\uf274" //Kalender mit Haken (Regular+Solid)
    readonly property string iconCalenderDay: "\uf783" //Kalender mit einem kleinen Rechteck (Solid)
    readonly property string iconCalenderPlus: "\uf271" //Kalender mit Pluszeichen (Regular+Solid)
    readonly property string iconCalenderDelete: "\uf273" //Kalender mit Kreuz (Regular+Solid)
    readonly property string iconEdit: "\uf044"
    readonly property string iconSave: "\uf0c7" //Floppydisk (Regular+Solid)
    readonly property string iconSearch: "\uf002" //Lupe (Solid)
    readonly property string iconDeleteCircle: "\uf057" //(Solid+Regular)
    readonly property string iconTrash: "\uf2ed" //(Solid+Regular)
    readonly property string iconTimes: "\uf00d" //Solid "Kreuz (Löschen)
    readonly property string iconHome: "\uf015" //(Solid)
    //    readonly property string iconBackspace: "\uf55a" //(Solid)
    readonly property string iconDatabase: "\uf1c0" //Solid
    readonly property string iconSettings: "\uf013" //Solid
    readonly property string iconSwitch: "\uf074" //Solid
    readonly property string iconFolder: "\uf07b" //Solid+Regular
    readonly property string iconVideoFile: "\uf1c8" //Solid+Regular
    readonly property string iconSort: "\uf550" //Solid
    readonly property string iconSortNumUp: "\uf163" //Solid
    readonly property string iconSortNumUpAlt: "\uf887" //Solid
    readonly property string iconSortNumDown: "\uf162" //Solid
    readonly property string iconSortNumDownAlt: "\uf886" //Solid
    readonly property string iconSortAlphaIncrease: "\uf15d" //Solid
    readonly property string iconSortAlphaDecrease: "\uf881" //Solid
    readonly property string iconUndo: "\uf0e2" //Solid
    readonly property string iconRedo: "\uf01e" //Solid wie Undo mit Pfeil in andere Richtung
    readonly property string iconCut: "\uf0c4" //Solid
    readonly property string iconWifi: "\uf1eb" //Solid
    readonly property string iconEllipsisV: "\uf142" //Solid
    readonly property string iconLevelUp: "\uf062" //Solid
    readonly property string iconChannel: "\uf7c0" //Solid Satellitenantenne
    readonly property string iconMusic: "\uf001" //Solid
    readonly property string iconVideo: "\uf03d" //Solid
    readonly property string iconSubtitle: "\uf7a4" //Solid (zwei Linien)
    readonly property string iconKey: "\uf084" //Solid
    readonly property string iconGripH: "\uf58d" //Solid
    readonly property string iconRename: "\uf246" //Solid
    readonly property string iconCancel: "\uf00d" //Solid
    readonly property string iconSquareMinus: "\uf146" //Solid+Regular
    readonly property string iconList: "\uf0ca" //Solid
    readonly property string iconArrowsUpDown: "\uf338" //Solid
    readonly property string iconMobile: "\uf3cf" //Solid
    readonly property string iconFolderOpen: "\uf07c" //Solid+Regular
    readonly property string iconFolderMinus: "\uf65d" //Solid
    readonly property string iconFolderTree: "\uf802" //Solid
    readonly property string iconFilter: "\uf0b0" //Solid
    readonly property string iconExclamation: "\uf071" //Solid
    readonly property string iconQuestion: "\uf059" //Solid+Regular

    /* Icons Fernbedienung */
    readonly property string iconPower: "\uf011" //Solid
    readonly property string iconLeft: "\uf0d9" //Solid
    readonly property string iconRight: "\uf0da" //Solid
    readonly property string iconUp: "\uf0d8" //Solid
    readonly property string iconDown: "\uf0d7" //Solid
    readonly property string iconBackward: "\uf04a" //Solid
    readonly property string iconFastBackward: "\uf049" //Solid
    readonly property string iconForward: "\uf04e" //Solid
    readonly property string iconFastForward: "\uf050" //Solid
    readonly property string iconPause: "\uf04c" //Solid
    readonly property string iconPlay: "\uf04b" //Solid
    readonly property string iconStop: "\uf04d" //Solid
    readonly property string iconPrev: "\uf048" //Solid
    readonly property string iconNext: "\uf051" //Solid
    readonly property string iconRecord: "\uf111" //Solid + Regular
    readonly property string iconVolUp: "\uf028" //Solid
    readonly property string iconVolDn: "\uf027" //Solid
    readonly property string iconVolMute: "\uf6a9" //Solid
    readonly property string iconChannelUp: "\uf077" //Solid
    readonly property string iconChannelDn: "\uf078" //Solid


    /* Hintergrund Header Views bzw. Pages (background:) */
    readonly property Component headerBackground: Component {
        Rectangle {
            color: Style.colorPrimary
            Rectangle {
                width: parent.width
                height: 1
                anchors.top: parent.bottom
                color: Qt.lighter(parent.color)
            }
        }
    }

    /* Hintergrund Footer Views bzw. Pages (background:) */
    readonly property Component footerBackground: Component {
        Rectangle {
            color: Style.colorPrimary
            Rectangle {
                width: parent.width
                height: 1
                anchors.top: parent.top
                color: Qt.lighter(parent.color)
            }
        }
    }



    /* Hintergrund Tumbler */
    readonly property Gradient gradientTumbler: Gradient {
        GradientStop {
            position: 0.00;
            color: Qt.darker(colorPrimary)
        }
        GradientStop {
            position: 0.50;
            color: colorPrimary
        }
        GradientStop {
            position: 1.00;
            color: Qt.darker(colorPrimary)
        }
    }
    // Hintergrund (Background) für Tumbler
    readonly property Gradient gradientTumblerBackground: Gradient {
        GradientStop {
            position: 0.0
            color: Qt.darker("dimgrey")
        }
        GradientStop {
            position: 0.1
            color: Qt.darker("darkgrey")
        }
        GradientStop {
            position: 0.4
            color: Qt.darker("white")
        }
        GradientStop {
            position: 0.6
            color: Qt.darker("white")
        }
        GradientStop {
            position: 0.9
            color: Qt.darker("darkgrey")
        }
        GradientStop {
            position: 1.0
            color: Qt.darker("dimgrey")
        }
    }

    readonly property color colorTumblerLine: Qt.lighter(colorPrimary)


    /* Hintergrund Listen/Rectangles */

    /* --- Tageswechsel ---*/
    readonly property Gradient gradientTageswechsel: Gradient {
        GradientStop {
            position: 0.00;
            color: Universal.theme === Universal.Dark ? colorAccent : colorPrimary
        }
        GradientStop {
            position: 1.00;
            color: Universal.theme === Universal.Dark ? Qt.darker(colorAccent) : Qt.darker(colorPrimary, 1.2)
        }
    }

    // readonly property alias gradientList: gradientList
    readonly property color backgroundListColor1: Universal.theme === Universal.Dark ? Qt.lighter(Style.colorBackground, 1.6) : Qt.lighter(Style.colorBackground, 1.2)
    readonly property color backgroundListColor2: Universal.theme === Universal.Dark ? Style.colorBackground : Qt.darker(Style.colorBackground, 1.1)


    readonly property Gradient gradientList: Gradient {
        GradientStop {
            position: 0.00;
            color: backgroundListColor1
        }
        GradientStop {
            position: 1.00;
            color: backgroundListColor2
        }
    }

    // property color tintColor: Qt.alpha(Style.colorBackground,0.25)

    readonly property Gradient gradientListHover: Gradient {
        GradientStop {
            position: 0.00;
            color: Universal.theme === Universal.Dark ? Qt.lighter(Style.colorBackground,2.0) : Qt.darker(Style.colorBackground, 1.1)
            // color: Qt.tint(backgroundListColor1,tintColor)
        }
        GradientStop {
            position: 1.00;
            color: Universal.theme === Universal.Dark ? Qt.lighter(Style.colorBackground,1.5) : Qt.darker(Style.colorBackground, 1.3)
        }
    }

    readonly property Gradient gradientListToolButton: Gradient {
        GradientStop {
            position: 0.00;
            color: Style.colorAccent
        }
        GradientStop {
            position: 1.00;
            color: Qt.darker(Style.colorAccent,1.5)
        }
    }

    readonly property Gradient gradientListMainTime: Gradient {
        GradientStop {
            position: 0.00;
            color: Qt.tint(backgroundListColor1, Style.colorMainTime)
        }
        GradientStop {
            position: 1.00;
            color: Qt.tint(backgroundListColor2, Style.colorMainTime)        }
    }

    Settings {
        id: settings
    }

    property color colorBackground
    property color colorPrimary
    property color colorForeground
    property color colorAccent


    //    Screen {
    //        id: screen
    //    }

    property date jetzt
    property font f

    Component.onCompleted: {

        console.log("Style.qml onCompleted Application.font",Qt.application.font)
        console.log("Style.qml onCompleted Application.font.pixelSize",Qt.application.font.pixelSize)
        console.log("Style.qml onCompleted Application.font.pointSize",Qt.application.font.pointSize)
        console.log("Style.qml onCompleted settings FontSize",settings.fontSize)
        console.log("Qt.local",Qt.locale(),Qt.locale().dateFormat(Locale.ShortFormat),Qt.locale().dateFormat(Locale.LongFormat))
        // console.log("Style.qml onCompleted FontFamilien",Qt.fontFamilies())

        console.log("Style.qml onCompleted font",f,"weights",f.weight,f.styleName)
        // for(var p in f) console.log("f properties",p,f[p])

        jetzt = new Date
        console.log("Jetzt",jetzt.toLocaleDateString(Qt.locale(), "ddd"))

        //        Universal.theme = Universal.Light
               // Universal.theme = Universal.Dark

        pointSizeStandard = settings.fontSize
        showChannelLogos = settings.showLogos
        showChannelLogosComboBox = settings.showLogosInLists
        showChannelTitle = settings.showChannelTitle;
        showEventSubtitle = settings.showEventSubtitle
        showFilename = settings.showFilename
        marginStart = settings.marginStart
        marginStop = settings.marginStop
        toChannel = settings.toChannel
        recordingsView = settings.recordingsView
        priority = settings.priority
        lifetime= settings.lifetime
        showIndicatorIcon = settings.showIndicatorIcon
        showEventDescription = settings.showEventDescription
        colorMainTime = settings.colorMainTime
        showMainTime = settings.showMainTime
        mainTimeFrom = new Date(settings.mainTimeFrom)
        mainTimeTo =  new Date(settings.mainTimeTo)
        showInfo = settings.showInfo
        showTimerGap = settings.showTimerGap
        colorTimerGap = settings.timerGapColor
        showRecordError = settings.showRecordError
        showEpgAtNow = settings.showEpgAtNow
        favoritesHours = settings.favoritesHours
        firstView = settings.firstView

        console.log("Universal.background:", Universal.background);
        console.log("Universal.foreground:", Universal.foreground);
        console.log("Universal.accent:", Universal.accent);
        console.log("Universal.theme:", Universal.theme);

        //        console.log("Universal.baseLowColor:", Universal.baseLowColor);
        //        console.log("Universal.baseMediumLowColor:", Universal.baseMediumLowColor);
        //        console.log("Universal.baseMediumColor:", Universal.baseMediumColor);

        //        console.log("Universal.theme:", Universal.theme);
        //        console.log("Universal.background lighter:", Qt.lighter(Universal.background, 1.6));
        //        console.log("Universal.background darker:", Qt.darker(Universal.background));

        colorPrimary = "#426473"
        colorBackground = Universal.background
        colorAccent = Universal.accent
        colorForeground = Universal.foreground

        console.log("colorBackGround:",colorBackground)
        console.log("colorForeground:",colorForeground)
        console.log("colorAccent:",colorAccent)
        console.log("colorPrimary:",colorPrimary)

        console.log("Screen: desktopAvailableHeight",Screen.desktopAvailableHeight)
        console.log("Screen: desktopAvailableWidth",Screen.desktopAvailableWidth)
        console.log("Screen: devicePixelRatio",Screen.devicePixelRatio)
        console.log("Screen: height",Screen.height)
        console.log("Screen: width",Screen.width)
        //        console.log("Screen: manufacturer",Screen.manufacturer)
        //        console.log("Screen: model",Screen.model)
        //        console.log("Screen: name",Screen.name)
        //        console.log("Screen: orientation",Screen.orientation)
        //        console.log("Screen: orientationUpdateMask",Screen.orientationUpdateMask)
        //        console.log("Screen: pixelDensity",Screen.pixelDensity)
        //        console.log("Screen: primaryOrientation",Screen.primaryOrientation)
        //        console.log("Screen: serialNumber",Screen.serialNumber)
        //        console.log("Screen: virtualX",Screen.virtualX)
        //        console.log("Screen: virtualY",Screen.virtualY)

        //        console.log("fixedDialogHeightHeader:", fixedDialogHeightHeader)
        //        Universal.foreground = "yellow"

    }
}
