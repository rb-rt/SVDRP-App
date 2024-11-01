import QtQuick 2.15
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models

import assets 1.0
import components 1.0
import dialogs 1.0
import vdr.models 1.0
import vdr.epgsearch 1.0
import controls 1.0
import "labels"
import "icons"
import "subviews"
import "transitions"

Page {
    id: root

    property ChannelModel channelModel
    property EPGSearch epgsearch
    property TimerModel timerModel

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            ToolButtonHeader { }

            Label {
                text: Style.iconCalenderAlt
                font.pointSize: Style.pointSizeHeaderIcon
                font.family: Style.faRegular
                Layout.alignment: Qt.AlignCenter
                Layout.leftMargin: 5
                Layout.rightMargin: 10
            }
            Label {
                id: headerLabel
                text: "Suchtimer"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                Layout.alignment: Qt.AlignCenter
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            CheckBox {
                id: checkBoxFavorites
                text: "Nur Favoriten"
            }
            ToolButton {
                id: updrButton
                text: "Update"
                font.pointSize: Style.pointSizeStandard
                opacity: 0.7
                Layout.leftMargin: 10
                background: Rectangle {
                    id: bkg2
                    anchors.fill: parent
                    radius: 4
                    border.width: 2
                    gradient: Style.gradientListToolButton
                    border.color: Qt.lighter(Style.colorPrimary)
                    states: State {
                        when: updrButton.down
                        PropertyChanges {
                            target: bkg2
                            border.color: Qt.darker(Style.colorPrimary, 1.2)
                            gradient: Style.gradientList
                        }
                    }
                }
                onClicked: {
                    updateSearchtimersDlg.text = "Suchtimer auf dem VDR aktualisieren?"
                    updateSearchtimersDlg.simple = false
                    updateSearchtimersDlg.open()
                }
            }

            Rectangle {
                Layout.preferredHeight: parent.height - 12
                Layout.preferredWidth: useLabel.implicitWidth * 2
                Layout.rightMargin: 20
                border.width: 2
                border.color: Qt.darker(color)
                radius: 4
                opacity: 0.75
                color: epgsearch.options["UseSearchTimers"] === "1" ? "green" : "crimson"
                Label {
                    id: useLabel
                    text: epgsearch.options["UseSearchTimers"] === "1" ? "Ein" : "Aus"
                    font.pointSize: Style.pointSizeStandard
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    height: parent.height
                    width: parent.width
                }
            }
        }
    }

    SearchtimerSFProxyModel {
        id: searchtimerSFProxyModel
        sourceModel: searchtimerModel
        sortCaseSensitivity: caseBox.checked ? Qt.CaseSensitive : Qt.CaseInsensitive
        sortOrder: sortSwitch.checked ? Qt.DescendingOrder : Qt.AscendingOrder
        favorites: checkBoxFavorites.checked
    }

    Connections {
        target: epgsearch
        function onUpdateFinished() {
            updateSearchtimersDlg.text = "Befehl erfolgreich abgsetzt.\n Eine weitere Rückmeldung erfolgt nicht."
            updateSearchtimersDlg.simple = true
            updateSearchtimersDlg.open()
        }
    }

    SearchtimerModel {
        id: searchtimerModel
        channelModel: root.channelModel
        epgsearch: root.epgsearch
        //        onError: {
        //            console.log("SearchtimerListPage.qml SearchtimerModel onError")
        //            errorMsgDlg.title = "Suchtimer Fehler"
        //            errorMsgDlg .text = error
        //            errorMsgDlg.open()
        //        }
        Component.onCompleted: {
            console.log("SearchtimerListPage.qml SearchtimerModel onCompleted")
            getSearchTimers()
        }
        onModelAboutToBeReset: busyIndicator.open()
        onModelReset: busyIndicator.close()
    }

    //Darstellung erfolgt so schneller
    SearchTimerEditView {
        id: searchTimerEditView
        visible: false
        channelModel: root.channelModel
        epgsearch: root.epgsearch
        headerTitle: "Suchtimer bearbeiten"
        searchTimer: searchtimerModel.getSearchtimer()
        onSaveSearchTimer: {
            console.log("SearchtimerListPage.qml SearchtimerModel onSaveSearchTimer")
            searchtimerModel.setSearchTimer(searchTimerEditView.searchTimer)
            pageStack.pop()
        }
    }

    //    property SearchTimerEditView searchTimerEditView
    //    Connections {
    //        target: searchTimerEditView
    //        function onSaveSearchTimer() {
    //            searchtimerModel.setSearchTimer(searchTimerEditView.searchTimer)
    //            pageStack.pop()
    //        }
    //    }

    //Enthält für eine Abfrage mit QRYS die ids
    property var searchtimerIds: []
    onSearchtimerIdsChanged: console.log("onSearchtimerIdsChanged")

    ListView {
        id: timerListView
        model: searchtimerSFProxyModel
        anchors.fill: parent
        delegate: searchtimerDelegate
        ScrollBar.vertical: ScrollBar{}

        EmptyListLabel {
            text: "Keine Suchtimer vorhanden."
            visible: parent.count === 0
        }

        add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 400 } }
        addDisplaced: Transition { NumberAnimation { properties: "x,y"; duration: 600; easing.type: Easing.OutBack } }

        populate: ListViewPopulate{}
        removeDisplaced: ListViewRemoveDisplaced {}
    }

    Component {
        id: searchtimerDelegate

        Rectangle {
            width: ListView.view.width
            height: Math.max(col.height, checkDelegate.height)
            gradient: Style.gradientList

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard
                anchors.leftMargin: Style.listIconPadding

                Rectangle {
                    Layout.fillWidth: true
                    color: "transparent"
                    Layout.preferredHeight: col.height

                    ColumnLayout {
                        id: col
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 2

                        LabelTitle {
                            text: model.display ? model.display : "" //manchmal undefined?
                            Layout.preferredWidth: parent.width
                            Layout.topMargin: 5
                        }
                        LabelSubtitle {
                            text: "Kanäle: " + model.channels + " " + model.time + " " + model.weekday
                            Layout.preferredWidth: parent.width
                            Layout.bottomMargin: 5
                        }
                    }
                }

                CheckDelegate {
                    id: checkDelegate
                    visible: !checkBoxFavorites.checked
                    opacity: 0.75
                    onToggled: {
                        console.log("TOGGLED: id",model.id)
                        let index = root.searchtimerIds.indexOf(model.id)
                        if (checked) {
                            if (index === -1) root.searchtimerIds.push(model.id)
                        }
                        else {
                            if (index !== -1) {
                                root.searchtimerIds.splice(index,1)
                            }
                        }
                        searchtimerIdsChanged() //! Funktioniert !
                    }
                }

                //Icons
                CheckIcon {
                    id: checkIcon
                    visible: !Style.showIndicatorIcon
                    Layout.preferredHeight: col.height
                    color: Style.colorListIconStandard
                    state: {
                        //console.log(model.display, "active",model.active, "action",model.action)
                        //model.active und model.action sind manchmal "undefined" -> unable to assign [undefined]
                        if (typeof model.active === "undefined" || typeof model.action === "undefined" ) return 0
                        var s = ""
                        if (model.active)  {
                            switch(model.action) {
                            case 0: s = "active"; break;
                            case 5: s = "inactive"; break;
                            case 1:
                            case 2:
                            case 3:
                            case 4: s = "action"; break;
                            default: s = "";
                            }
                        }
                        return s
                    }
                    onIconClicked: {
                        //                            var timer = JSON.parse(JSON.stringify(model.searchtimer))
                        console.log("Searchtimer",model.searchtimer)
                        searchtimerModel.toggleSearchTimer(model.id)
                    }
                }
                EditIcon {
                    id: editIcon
                    visible: checkIcon.visible
                    Layout.preferredHeight: col.height
                    onIconClicked: {
                        console.log("Editicon onIconclicked")
                        var timer = JSON.parse(JSON.stringify(model.searchtimer))
                        var header = "Suchtimer <i>" + timer.search  + "</i> bearbeiten"
                        console.log("Editicon onIconclicked vor push")
                        //                        editViewLoader.active = true
                        //                        searchTimerEditView = pageStack.push("qrc:/views/subviews/SearchTimerEditView.qml", {
                        //                                                                 searchTimer:timer,
                        //                                                                 headerTitle: header,
                        //                                                                 channelModel: root.channelModel,
                        //                                                                 epgsearch: root.epgsearch
                        //                                                             })
                        pageStack.push(searchTimerEditView, {
                                           searchTimer:timer,
                                           headerTitle: header
                                       })

                        console.log("Editicon onIconclicked nach push")
                    }
                }
                SearchIcon {
                    id: searchIcon
                    visible: checkIcon.visible
                    Layout.preferredHeight: col.height
                    onIconClicked: {
                        var timer = JSON.parse(JSON.stringify(model.searchtimer))
                        pageStack.push("qrc:/views/EpgSearchQueryPage.qml",
                                       {/*searchTimer: timer,*/
                                           ids:[timer.id],
                                           headerLabel: "Suchergebnisse von <i>" + timer.search + "</i>" ,
                                           channelModel: root.channelModel,
                                           epgsearch: root.epgsearch,
                                           timerModel: root.timerModel
                                       })
                    }
                }
                DeleteIcon {
                    id: deleteIcon
                    visible: checkIcon.visible
                    Layout.preferredHeight: col.height
                    onIconClicked: {
                        var s = model.searchtimer
                        confirmDeleteMsgBox.searchTimer = s
                        confirmDeleteMsgBox.text = s.search
                        confirmDeleteMsgBox.open()
                    }
                }
                IndicatorIcon {
                    id: indicatorIcon
                    visible: Style.showIndicatorIcon
                    Layout.preferredHeight: col.height
                    state: {
                        //model.active und model.action sind manchmal "undefined" -> unable to assign [undefined]
                        if (typeof model.active === "undefined" || typeof model.action === "undefined" ) return 0
                        var s = ""
                        if (model.active)  {
                            switch(model.action) {
                            case 0: s = "active"; break;
                            case 5: s = "inactive"; break;
                            case 1:
                            case 2:
                            case 3:
                            case 4: s = "action"; break;
                            default: s = "";
                            }
                        }
                        return s
                    }
                    onIconClicked: {
                        contextMenu.searchTimer = model.searchtimer
                        contextMenu.popup(indicatorIcon)
                    }
                }
            }
        }
    }

    Menu {
        id: contextMenu

        property var searchTimer: 0

        rightMargin: parent.width

        width: {
            var result = 0;
            var padding = 0;
            for (var i = 0; i < count; ++i) {
                var item = itemAt(i);
                result = Math.max(item.contentItem.implicitWidth, result);
                padding = Math.max(item.padding, padding);
            }
            return result + padding * 2;
        }

        ContextMenuItem {
            isLabel: true
            description: contextMenu.searchTimer ?  contextMenu.searchTimer.search : ""
        }

        ContextMenuItem {
            iconCharacter: Style.iconCheck
            iconColor: contextMenu.searchTimer.useAsSearchtimer === 0 ? Style.colorListIconActive : Style.colorListIconStandard
            iconFont: Style.faSolid
            description: contextMenu.searchTimer.useAsSearchtimer ? "Deaktivieren" : "Aktivieren"
            onMenuItemClicked: {
                if (contextMenu.searchTimer) {
                    contextMenu.close()
                    searchtimerModel.toggleSearchTimer(contextMenu.searchTimer.id)
                }
            }
        }

        ContextMenuItem {
            iconCharacter: Style.iconEdit
            iconColor: Style.colorListIconEdit
            iconFont: Style.faSolid
            description: qsTr("Bearbeiten")
            onMenuItemClicked: {
                if (contextMenu.searchTimer) {
                    contextMenu.close()
                    var timer = JSON.parse(JSON.stringify(contextMenu.searchTimer))
                    var header = "Timer bearbeiten"
                    if (contextMenu.searchTimer.id > 0) {
                        header = "Timer <i>" + contextMenu.searchTimer.search + "</i> bearbeiten"
                    }
                    //                    searchTimerEditView = pageStack.push("qrc:/views/subviews/SearchTimerEditView.qml", {
                    //                                                             searchTimer:timer,
                    //                                                             headerTitle: header,
                    //                                                             channelModel: root.channelModel,
                    //                                                             epgsearch: root.epgsearch
                    //                                                         })
                    pageStack.push(searchTimerEditView, { searchTimer:timer, headerTitle: header })
                }
            }
        }

        ContextMenuItem {
            iconCharacter: Style.iconSearch
            iconColor: Style.colorListIconSearch
            iconFont: Style.faSolid
            description: qsTr("Suchen")
            onMenuItemClicked: {
                if (contextMenu.searchTimer) {
                    var timer = JSON.parse(JSON.stringify(contextMenu.searchTimer))
                    pageStack.push("qrc:/views/EpgSearchQueryPage.qml",
                                   {searchTimer: timer,
                                       headerLabel: "Suchergebnisse von <i>" + timer.search + "</i>" ,
                                       channelModel: root.channelModel,
                                       epgsearch: root.epgsearch,
                                       timerModel: root.timerModel
                                   })
                }
            }
        }

        ContextMenuItem {
            iconCharacter: Style.iconTrash
            iconColor: Style.colorListIconDelete
            iconFont: Style.faRegular
            description: qsTr("Löschen")
            onMenuItemClicked: {
                if (contextMenu.searchTimer) {
                    contextMenu.close()
                    confirmDeleteMsgBox.searchTimer = contextMenu.searchTimer
                    confirmDeleteMsgBox.text = contextMenu.searchTimer.search
                    confirmDeleteMsgBox.open()
                }
            }
        }
    }

    footer: ToolBar {

        background: Rectangle {
            color: Style.colorPrimary

            Rectangle {
                width: parent.width
                height: 1
                anchors.top: parent.top
                color: Qt.lighter(parent.color)
            }
        }

        height: commandBar.height

        RowLayout{

            width: parent.width

            Label {
                text: "Sortierung:"
                font.pointSize: Style.pointSizeStandard
                Layout.leftMargin: 10
            }
            Switch {
                id: sortSwitch
                text: checked ? Style.iconSortAlphaDecrease : Style.iconSortAlphaIncrease
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                checked: false
            }
            CheckBox {
                id: caseBox
                text: checked ? "ABab" : "AaBb"
                checked: false
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
            }

            //        Label {
            //            id: conflictlabel
            //            color: Style.colorConflictTimer
            //            font.pointSize: Style.pixelSizeStandard
            //            height: parent.height
            //            verticalAlignment: Qt.AlignVCenter
            //        }

            CommandBar {
                id: commandBar
                Layout.rightMargin: 10
                Layout.topMargin: 1

                commandList: ObjectModel {
                    CommandButton{
                        visible: checkBoxFavorites.checked && timerListView.count > 0
                        iconCharacter: Style.iconSearch
                        description: "Favoritensuche"
                        onCommandButtonClicked: {
                            pageStack.push("qrc:/views/EpgSearchQueryPage.qml", {
                                               channelModel:channelModel,
                                               epgsearch: epgsearch,
                                               timerModel: timerModel,
                                               isFavoritesSearch: true
                                           })
                        }
                    }
                    CommandButton {
                        id: commandSearchBtn
                        visible: !checkBoxFavorites.checked
                        enabled: searchtimerIds.length > 0
                        iconCharacter: Style.iconSearch
                        description: "Suchen"
                        onCommandButtonClicked: {
                            pageStack.push("qrc:/views/EpgSearchQueryPage.qml",
                                           {ids: searchtimerIds,
                                               headerLabel: "Suchergebnisse (verschiedene)" ,
                                               channelModel: root.channelModel,
                                               epgsearch: root.epgsearch,
                                               timerModel: root.timerModel
                                           })
                        }
                    }
                    CommandButton {
                        iconCharacter: Style.iconCalenderPlus
                        description: "Neu"
                        onCommandButtonClicked: {
                            var s = JSON.parse(JSON.stringify(searchtimerModel.getSearchtimer()))
                            pageStack.push(searchTimerEditView, { searchTimer:s, headerTitle: "Neuen Suchtimer anlegen" })
                            //                            searchTimerEditView = pageStack.push("qrc:/views/subviews/SearchTimerEditView.qml", {
                            //                                                                     searchTimer: s,
                            //                                                                     headerTitle: "Neuen Suchtimer anlegen",
                            //                                                                     channelModel: root.channelModel,
                            //                                                                     epgsearch: root.epgsearch
                            //                                                                 })
                        }
                    }
                }
            }
        }
    }

    MyMessageDialog {
        id: confirmDeleteMsgBox
        property var searchTimer
        titleText: "Suchtimer löschen?"
        onAccepted: {
            if (searchTimer) {
                searchtimerModel.deleteSearchTimer(searchTimer.id)
            }
            else {
                console.log("Timer nicht vorhanden")
            }
        }
    }
    MyMessageDialog {
        id: updateSearchtimersDlg
        titleText: "Suchtimer aktualisieren"
        text: "Suchtimer auf dem VDR aktualisieren?"
        onAccepted: epgsearch.svdrpUpdate()
    }

    ErrorDialog {
        id: errorMsgDlg
        title: "Fehler bei der Abfrage"
    }
    BusyIndicatorPopup {
        id: busyIndicator
    }

    Component.onCompleted:{
        console.log("SearchtimerListpage.qml onCompleted")
        //        searchtimerModel.getExtendedEpgCategories()
        //       searchtimerModel.getSearchTimers()

        //        searchtimerModel.getSearchTimers()
    }
}
