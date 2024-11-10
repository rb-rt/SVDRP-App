import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models

import assets 1.0
import components 1.0
import dialogs 1.0
import vdr.models 1.0
import controls 1.0 as MyControls
import vdr.vdrinfo 1.0
import vdr.streamdev 1.0
import vdr.epgsearch
import models 1.0
import "labels"
import "icons"
import "subviews"
import "transitions"

Page {

    id: root

    property url url
    property url streamUrl
    property EPGSearch epgsearch

    enum ViewType { TreeView, ListView }
    property int viewType: Style.recordingsView
    // property int viewType: -1

    onViewTypeChanged: {
        console.log("RecordListPage.qml onViewTypeChanged viewType:",viewType)
    }

    property var jniPlayer
    Component.onCompleted: {
        console.log("RecordListPage.qml Component.onCompleted")
        console.log("RecordListPage JNI_SUPPORT",JNI_SUPPORT)
        if (JNI_SUPPORT) {
            jniPlayer = Qt.createQmlObject('
                        import vdr.jniplayer 1.0;

                        JniPlayer {
                            id: jniPlayer
                            onJniError: {
                                messageDlg.text = error
                            }
                        }', root, "JniPlayer")
        }
    }

    property Page deletePage
    Connections {
        target: deletePage

        function onPageRemoved() {
            recordSelectedModel.filterSelectedRecords = false
        }
        function onDeleteRecords() {
            recordListModel.deleteRecords()
            //            pageStack.pop()
        }
        function onClearRecords() {
            recordListModel.clearSelection()
        }
        function onRequestEvent(id) {
            recordListModel.getEvent(id)
        }
    }

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {

            spacing: 0

            MyControls.ToolButtonHeader { }

            ToolButton {
                id:upButton
                visible: (treeProxyModel.level > 0) && (viewType === RecordListPage.ViewType.TreeView)
                text: Style.iconLevelUp
                font.family: Style.faSolid
                onClicked: treeProxyModel.levelUp()
                Layout.rightMargin: 10

                background: Rectangle {
                    id: bkg
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: height / 2
                    border.width: 2
                    gradient: Style.gradientListToolButton
                    border.color: Qt.lighter(Style.colorPrimary)
                    states: State {
                        when: upButton.down
                        PropertyChanges {
                            target: bkg
                            border.color: Qt.darker(Style.colorPrimary, 1.2)
                            gradient: Style.gradientList
                        }
                        PropertyChanges {
                            target: upButton
                            scale: 1.5
                        }
                    }
                }
            }

            ColumnLayout {

                Layout.topMargin: 5
                Layout.bottomMargin: 5
                spacing: 0

                RowLayout {

                    Layout.leftMargin: 5

                    Label {
                        text: Style.iconDatabase
                        font.pointSize: Style.pointSizeHeaderIcon
                        font.family: Style.faSolid
                    }
                    Label {
                        id: headerLabel
                        text: qsTr("Aufnahmen")
                        font.pointSize: Style.pointSizeHeader
                        font.weight: Style.fontweightHeader
                        elide: Text.ElideRight
                    }
                    MyControls.ComboBoxAuto {
                        Layout.leftMargin: 20
                        model: ["Baum", "Liste"]
                        // Layout.preferredWidth: width
                        onActivated: {
                            console.log("onActivated")
                            currentIndex === 0 ? viewType = RecordListPage.ViewType.TreeView : viewType = RecordListPage.ViewType.ListView                        }

                        // onCurrentIndexChanged: currentIndex === 0 ? viewType = RecordListPage.ViewType.TreeView : viewType = RecordListPage.ViewType.ListView
                        Component.onCompleted: {
                            currentIndex = Style.recordingsView
                            // viewType = Style.recordingsView
                        }
                    }
                    ToolButton {
                        id: updrButton
                        text: "UPDR"
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
                        onClicked: updrDlg.open()
                    }
                }

                RowLayout {

                    // CheckBox {
                    //     id: checkBoxLastDir
                    //     font.pointSize: Style.pointSizeHeaderSmall
                    //     text: Style.iconFolder
                    //     font.family: Style.faSolid
                    //     visible: viewType === RecordListPage.ViewType.ListView
                    // }
                    CheckBox {
                        id: checkBoxFilename
                        font.pointSize: Style.pointSizeHeaderSmall
                        text: "Dateiname"
                        checked: Style.showFilename
                    }
                    CheckBox {
                        id: checkBoxShowError
                        font.pointSize: Style.pointSizeHeaderSmall
                        text: "Fehler anzeigen"
                        checked: Style.showRecordError
                    }
                }

                Loader {
                    Layout.bottomMargin: 5
                    active: Style.showInfo
                    sourceComponent: Label {
                        font.pointSize: Style.pointSizeHeaderSmall
                        font.italic: true
                        text: vdrInfo.statistics.usedPercent + " % belegt. Noch " +
                              vdrInfo.statistics.freeSpace + " GB frei von " + vdrInfo.statistics.totalSpace + " GB"
                    }
                    onLoaded: vdrInfo.svdrpStat()
                }
            } //ColumnLayout
        }
    }

    VdrInfo {
        id: vdrInfo
        url: root.url
    }

    property bool streamingAvailable: streamUrl.toString() !== ""

    Streamdev {
        id: streamdev
        url: root.streamUrl
        onStreamUrlFinished: function(url) {
            console.log("streamurl",url)
            jniPlayer.playVideo(url)
        }
        onRecordingsFinished: {
            busyIndicator.close()
        }
        onError: {
            busyIndicator.close()
            streamingAvailable = false
            errorDialog.title = "Fehler Streamdev"
            errorDialog.errorText = error
            errorDialog.open()
        }
    }

    //Das Basismodel. Alle Befehle laufen über dieses Model
    RecordListModel {
        id: recordListModel
        url: root.url
        onError: function(error) {
            busyIndicator.close()
            errorDialog.errorText = error
            errorDialog.open()
        }
        onRecordsFinished: {
            console.log("RecordListPage.qml ListModel onRecordsfinished")
            busyIndicator.close()
        }
        // onRecordDeleted: console.log("Record gelöscht", record)
        onRecordsUpdated: {
            updrDlg.text = "Befehl abgesetzt.\nDie Liste in der App wird nicht neu eingelesen!\nZur Aktualisierung die Seite nochmals aufrufen."
            updrDlg.simple = true
            updrDlg.open()
        }
        onRecordPlayed: function(record) {
            console.log("RecordListPage.qml onRecordPlayed")
            playDlg.text = "Es läuft <i>" + record.lastName + "</i>"
            playDlg.open()
        }
        onRecordEdited: function(record) {
            editDlg.text = "Befehl abgesetzt.\n Eine weitere Rückmeldung erfolgt nicht."
            editDlg.simple = true;
            editDlg.open()
        }

        Component.onCompleted: {
            console.log("RecordListPage.qml RecordListModel Component.onCompleted")
            busyIndicator.open()
            getRecords();
        }
    }
    Connections {
        id: eventConnection
        target: recordListModel
        function onEventFinished(event) {
            console.log("RecordListPage.qml onEventFinished")
            pageStack.push("qrc:/views/subviews/RecordDetailsView.qml", { recordEvent: event } )
        }
    }


    RecordSelectedProxyModel {
        id: recordSelectedModel
        sourceModel: recordListModel
    }

    RecordFilterTextModel {
        id: recordFilterTextModel
        sourceModel: recordSelectedModel
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    RecordListSFProxyModel {
        id: listProxyModel
        sourceModel: recordFilterTextModel
        sortRole: RecordListModel.SortDateRole
        sortCaseSensitivity: Qt.CaseInsensitive
    }

    RecordTreeModel {
        id: treeProxyModel
        sourceModel: recordFilterTextModel
        sortCaseSensitivity: Qt.CaseInsensitive
    }

    Loader {
        id: listViewLoader
        active: viewType === RecordListPage.ViewType.ListView
        anchors.fill: parent
        sourceComponent:
            ListView {
            anchors.fill: parent
            id: listViewList
            ScrollBar.vertical: ScrollBar{}
            model:  listProxyModel
            delegate: listDelegate
            section.property: (listProxyModel.sortRole === RecordListModel.SortDateRole) ? sectionProperty : "name"
            section.criteria: (listProxyModel.sortRole === RecordListModel.SortDateRole) ? ViewSection.FullString : ViewSection.FirstCharacter
            section.delegate: (listProxyModel.sortRole === RecordListModel.SortDateRole) ? sectionHeadingDate : sectionHeadingTitle
            section.labelPositioning: (listProxyModel.sortRole === RecordListModel.SortDateRole) ? ViewSection.InlineLabels : ViewSection.InlineLabels // ViewSection.CurrentLabelAtStart
            MyControls.EmptyListLabel {
                text: "Keine Aufnahmen vorhanden"
                visible: parent.count === 0
            }
            populate: ListViewPopulate{}
            displaced: ListViewDisplaced{}
        }
    }

    Loader {
        id: treeViewLoader
        active: viewType === RecordListPage.ViewType.TreeView
        anchors.fill: parent
        sourceComponent: ListView {
            anchors.fill: parent
            ScrollBar.vertical: ScrollBar{}
            model:  treeProxyModel
            delegate: treeDelegate
            headerPositioning: ListView.OverlayHeader
            header: RowLayout {
                Repeater {
                    model: treeProxyModel.tree
                    delegate: Label {
                        text: "> " + modelData
                        font.pointSize: Style.pointSizeStandard
                        font.italic: true
                        topPadding: 5
                        bottomPadding: 5
                        elide: Text.ElideLeft
                    }
                }
            }
            MyControls.EmptyListLabel {
                text: "Keine Aufnahmen vorhanden"
                visible: parent.count === 0
            }
            populate: ListViewPopulate{}
            displaced: ListViewDisplaced{}
        }
    }

    // property int margin: (Style.showChannelTitle || checkBoxFilename.checked || checkBoxLastDir.checked) ? 5 : 10

    Component {
        id: treeDelegate

        Rectangle {
            width: ListView.view.width
            height: treeRowLayout.height
            gradient: Style.gradientList

            RowLayout {
                id: treeRowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard

                //Verzeichnis
                Loader {
                    active: model.isDir
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    sourceComponent: Label {
                        text: display
                        font.pointSize: Style.pointSizeLarge
                        elide: Text.ElideRight
                        verticalAlignment: Qt.AlignVCenter
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                dir = display
                            }
                        }
                    }
                }
                //Aufnahme
                Loader {
                    active: !model.isDir
                    Layout.fillWidth: true
                    sourceComponent: RecordFileComponent {}
                }
            }
        }
    }

    Component {
        id:listDelegate

        Rectangle {
            width: ListView.view.width
            height: recordFileLoader.height
            gradient: Style.gradientList

            Loader {
                id: recordFileLoader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard
                sourceComponent: RecordFileComponent {}
            }
        }
    }

    property string sectionProperty: "month"

    Component {
        id: sectionHeadingDate

        Rectangle {
            id: sectionRec
            width: ListView.view.width
            height: childrenRect.height
            gradient: Style.gradientTageswechsel

            required property string section
            onSectionChanged: sectionAnimation.start()

            Label {
                text: parent.section
                font.pointSize: Style.pointSizeSmall
                padding: 5
                leftPadding: 10
            }
            MouseArea {
                anchors.fill: parent
                onClicked: sectionProperty === "month" ? sectionProperty = "year" : sectionProperty = "month"
            }
            ListViewSectionAnimation {
                id: sectionAnimation
                target: sectionRec
            }
        }
    }

    Component {
        id: sectionHeadingTitle
        Rectangle {
            id: sectionRec
            width: ListView.view.width
            height: childrenRect.height
            gradient: Style.gradientTageswechsel

            required property string section
            onSectionChanged: sectionAnimation.start()

            Label {
                text: parent.section
                font.pointSize: Style.pointSizeSmall
                padding: 5
                leftPadding: 10
            }
            ListViewSectionAnimation {
                id: sectionAnimation
                target: sectionRec
            }
        }
    }

    Menu {
        id: playContextMenu
        rightMargin: parent.width

        property var record

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

        MyControls.ContextMenuItem {
            isLabel: true
            description: playContextMenu.record ? playContextMenu.record.lastName : ""
        }
        MyControls.ContextMenuItem {
            enabled: streamingAvailable
            description: qsTr("Lokale Wiedergabe")
            iconCharacter: Style.iconMobile
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayLocal
            onMenuItemClicked: {
                streamdev.streamRecord(playContextMenu.record)
            }
        }
        MyControls.ContextMenuItem {
            description: "Wiedergabe auf VDR"
            iconCharacter: Style.iconSwitch
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayVdr
            onMenuItemClicked: {
                playRecordDlg.record = playContextMenu.record
                playRecordDlg.open()
            }

        }
        MyControls.ContextMenuItem {
            description: "Aufnahme schneiden"
            iconCharacter: Style.iconCut
            iconFont: Style.faSolid
            iconColor: Style.colorListIconEdit
            onMenuItemClicked: {
                editDlg.text = playContextMenu.record.lastName
                editDlg.id = playContextMenu.record.id
                editDlg.open()
            }
        }
    }

    Menu {
        id: contextMenu
        rightMargin: Style.pointSizeStandard

        property var record

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

        MyControls.ContextMenuItem {
            isLabel: true
            description: contextMenu.record ?  contextMenu.record.lastName : ""
        }
        MyControls.ContextMenuItem {
            iconCharacter: Style.iconArrowsUpDown
            iconColor: Style.colorListIconMove
            iconFont: Style.faSolid
            description: qsTr("Verschieben")
            onMenuItemClicked: pageStack.push(moveRecordView, { record: contextMenu.record })
        }
        MyControls.ContextMenuItem {
            enabled: streamingAvailable
            description: qsTr("Lokale Wiedergabe")
            iconCharacter: Style.iconMobile
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayLocal
            onMenuItemClicked: streamdev.streamUrl(contextMenu.record.id)
        }
        MyControls.ContextMenuItem {
            description: qsTr("Wiedergabe auf VDR")
            iconCharacter: Style.iconSwitch
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayVdr
            onMenuItemClicked: {
                console.log("Record",contextMenu.record)
                // recordListModel.playRecord(contextMenu.record.id)
                playRecordDlg.record = contextMenu.record
                playRecordDlg.open()
            }
        }
        MyControls.ContextMenuItem {
            description: "Aufnahme schneiden"
            iconCharacter: Style.iconCut
            iconFont: Style.faSolid
            iconColor: Style.colorListIconEdit
            onMenuItemClicked: {
                editDlg.text = contextMenu.record.lastName
                editDlg.id = contextMenu.record.id
                editDlg.open()
            }
        }
        MyControls.ContextMenuItem {
            iconCharacter: Style.iconTrash
            iconColor: Style.colorListIconDelete
            iconFont: Style.faRegular
            description: qsTr("Löschen")
            onMenuItemClicked: {
                deleteRecordDlg.id = contextMenu.record.id
                deleteRecordDlg.text = contextMenu.record.lastName
                deleteRecordDlg.open()
            }
        }
    }

    footer: ToolBar {
        height: swipeView.height

        background: Loader { sourceComponent: Style.footerBackground }

        SwipeView {
            id: swipeView
            anchors.fill: parent
            Loader {
                sourceComponent: {
                    switch (viewType) {
                    case RecordListPage.ViewType.ListView: footerComponentListView
                        break
                    case RecordListPage.ViewType.TreeView: footerComponentTreeView
                        break
                    default: footerComponentListView
                    }
                }
            }

            Loader {
                sourceComponent: componentSecondListRow
            }
        }

        PageIndicator {
            count: swipeView.count
            currentIndex: swipeView.currentIndex
            anchors.left: swipeView.left
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    component RecordFileComponent: RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        RecordIcon {
            record: model.record
            showError: checkBoxShowError.checked
        }

        //Eventspalte
        Rectangle {
            Layout.fillWidth: true
            color: "transparent"
            Layout.preferredHeight: columnEvent.height
            ColumnLayout {
                id: columnEvent
                anchors.left: parent.left
                anchors.right: parent.right
                EventColumn {
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    recordListModel.getEvent(model.record.id)
                }
            }
        }
        CheckBox {
            id: deleteCheckBox
            opacity: 0.66
            checked: model.select
            onToggled: model.select = checked
            onCheckedChanged: console.log("onCheckedChanged",checked)
        }
        MoveIcon {
            id: moveIcon
            visible: !Style.showIndicatorIcon
            Layout.preferredHeight: columnEvent.height
            Layout.preferredWidth: deleteIcon.width
            onIconClicked: pageStack.push(moveRecordView, { record:model.record })
        }
        PlayIcon {
            id: playIcon
            visible: moveIcon.visible
            Layout.preferredHeight: columnEvent.height
            onIconClicked: {
                console.log("Record",model.record)
                playContextMenu.record = model.record
                playContextMenu.popup(playIcon)
            }
        }
        DeleteIcon {
            id: deleteIcon
            visible: moveIcon.visible && !root.selectedRecords
            Layout.preferredHeight: columnEvent.height
            onIconClicked:{
                deleteRecordDlg.id = model.record.id
                deleteRecordDlg.text = model.record.lastName
                deleteRecordDlg.open()
            }
        }
        IndicatorIcon {
            id: indicatorIcon
            visible: Style.showIndicatorIcon
            Layout.preferredHeight: columnEvent.height
            onIconClicked: {
                contextMenu.record = model.record
                contextMenu.popup(indicatorIcon)
            }
        }
    }

    component EventColumn: ColumnLayout {
        spacing: 2
        width: parent.width

        LabelSubtitle {
            text: model.time
            Layout.preferredWidth: parent.width
            visible: Style.showChannelTitle
        }
        LabelTitle {
            text: model.display
            Layout.preferredWidth: parent.width
        }
        LabelDescription {
            text: model.record.name
            visible: checkBoxFilename.checked
            Layout.preferredWidth: parent.width
        }
    }

    Component {
        id: footerComponentListView

        RowLayout {
            Label {
                text: Style.iconSort
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                opacity: 0.7
                Layout.leftMargin: 20
            }
            Switch {
                id: sortComboBox
                text: checked ? "Titel" : "Datum" //false = Sortierung nach Datum (Standard)
                font.pointSize: Style.pointSizeStandard
                Layout.leftMargin: 10
                onCheckedChanged: checked ? listProxyModel.sortRole = RecordListModel.SortNameRole :
                                            listProxyModel.sortRole = RecordListModel.SortDateRole
            }
            Switch {
                text: sortComboBox.checked ? (checked ? Style.iconSortAlphaIncrease : Style.iconSortAlphaDecrease) :
                                             (checked ?  Style.iconSortNumDown : Style.iconSortNumDownAlt)
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                checked: false
                onClicked: {
                    checked ? listProxyModel.sortOrder = Qt.AscendingOrder :
                              listProxyModel.sortOrder = Qt.DescendingOrder
                }
            }
            CheckBox {
                text: checked ? "ABab" : "AaBb"
                checked: false
                enabled: sortComboBox.checked
                anchors.leftMargin: 10
                font.pointSize: Style.pointSizeStandard
                onToggled: checked ? listProxyModel.sortCaseSensitivity = Qt.CaseSensitive :
                                     listProxyModel.sortCaseSensitivity = Qt.CaseInsensitive
            }
            MyControls.CommandHButton {
                description: "Liste"
                iconCharacter: Style.iconList
                enabled: recordListModel.hasSelection
                onEnabledChanged: enabled ? opacity = 1.0 : opacity = 0.5
                onCommandButtonClicked: {
                    recordSelectedModel.filterSelectedRecords = true
                    deletePage = pageStack.push("qrc:/views/RecordDeletePage.qml", { deleteModel: listProxyModel }) // /*, showError: checkBoxShowError.checked*/ })
                }
            }
            Label {
                Layout.fillWidth: true
            }
        }
    }


    Component {
        id: footerComponentTreeView
        RowLayout {
            Label {
                text: Style.iconSort
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                opacity: 0.7
                Layout.leftMargin: 20
            }
            Switch {
                id: sortTreeSwitch
                text: checked ? "Datum" : "Titel"
                font.pointSize: Style.pointSizeStandard
                Layout.leftMargin: 10
                checked: false
                onCheckedChanged: checked ? treeProxyModel.sortRole = RecordListModel.SortDateRole :
                                            treeProxyModel.sortRole = Qt.DisplayRole
            }

            Switch {
                text: sortTreeSwitch.checked ? (checked ? Style.iconSortNumDownAlt : Style.iconSortNumDown) :
                                               (checked ? Style.iconSortAlphaDecrease : Style.iconSortAlphaIncrease)
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                checked: false
                onCheckedChanged: {
                    checked ? treeProxyModel.sortOrder = Qt.DescendingOrder :
                              treeProxyModel.sortOrder = Qt.AscendingOrder
                }
            }
            CheckBox {
                text: checked ? "ABab" : "AaBb"
                enabled: !sortTreeSwitch.checked
                font.pointSize: Style.pointSizeStandard
                onToggled: checked ? treeProxyModel.sortCaseSensitivity = Qt.CaseSensitive :
                                     treeProxyModel.sortCaseSensitivity = Qt.CaseInsensitive
            }
            MyControls.CommandHButton {
                description: "Liste"
                iconCharacter: Style.iconList
                enabled: recordListModel.hasSelection
                onEnabledChanged: enabled ? opacity = 1.0 : opacity = 0.5
                onCommandButtonClicked: {
                    recordSelectedModel.filterSelectedRecords = true
                    deletePage = pageStack.push("qrc:/views/RecordDeletePage.qml", { deleteModel: listProxyModel }) // /*, showError: checkBoxShowError.checked*/ })
                }
            }
            Label {
                Layout.fillWidth: true
            }
        }
    }

    Component {
        id: componentSecondListRow
        RowLayout {
            Label {
                text: Style.iconFilter
                font.pointSize: Style.pointSizeStandard
                font.family: Style.faSolid
                Layout.leftMargin: 20
                opacity: 0.7
            }
            CheckBox {
                id: filterCaseSensitivityCheckBox
                text: checked ? "aa" : "Aa"
                font.pointSize: Style.pointSizeStandard
                Layout.leftMargin: 10
                enabled: recordFilterTextModel.filterText.length > 0
                onToggled: checked ? recordFilterTextModel.filterCaseSensitivity = Qt.CaseSensitive :
                                     recordFilterTextModel.filterCaseSensitivity = Qt.CaseInsensitive
            }
            MyControls.LineInput {
                Layout.fillWidth: true
                placeholderText: "Textfilter..."
                text: recordFilterTextModel.filterText
                onTextChanged: recordFilterTextModel.filterText = text
            }
            Switch {
                text: checked ? "Suche in Pfad" : "Suche in Titel"
                font.pointSize: Style.pointSizeStandard
                Layout.rightMargin: 10
                onToggled: recordFilterTextModel.filterPath = checked
            }
        }
    }

    ErrorDialog {
        id: errorDialog
    }

    MoveRecordView {
        id: moveRecordView
        directories: epgsearch.directories
        recordsModel: recordListModel
        visible: false

        StackView.onActivating: eventConnection.enabled = false
        StackView.onDeactivated: eventConnection.enabled = true

        onNewName: function(filename) {
            console.log("MoveRecordView onNewName",filename)
            recordListModel.moveRecord(moveRecordView.record.id, filename)
        }
    }

    DynamicDialog {
        id: playRecordDlg
        property var record
        property int play: 0 //0 = von begin, 1 = letzter Wiedergabeposition, 2 = Zeitangabe
        property alias time: timeSpinBox.time
        titleText: "Wiedergabe auf dem VDR"

        anchors.centerIn: parent
        modal: true
        closePolicy: Popup.NoAutoClose

        standardButtons: Dialog.Apply | Dialog.Cancel

        contentItem: ColumnLayout {

            ButtonGroup {
                id: buttonGroup
            }

            Label {
                text: playRecordDlg.record ? playRecordDlg.record.lastName : ""
                font.pointSize: Style.pointSizeStandard
                font.bold: true
            }

            RadioButton {
                text: "ab Anfang"
                ButtonGroup.group: buttonGroup
                checked: playRecordDlg.play === 0
                onToggled: if (checked) playRecordDlg.play = 0
                font.pointSize: Style.pointSizeStandard
            }
            RadioButton {
                text: "letzte Wiedergabeposition"
                ButtonGroup.group: buttonGroup
                checked: playRecordDlg.play === 1
                onToggled: if (checked) playRecordDlg.play = 1
                font.pointSize: Style.pointSizeStandard
            }
            RowLayout {
                RadioButton {
                    text: "ab "
                    ButtonGroup.group: buttonGroup
                    checked: playRecordDlg.play === 2
                    onToggled: if (checked) playRecordDlg.play = 2
                    font.pointSize: Style.pointSizeStandard
                }
                MyControls.TimeSpinBox {
                    id: timeSpinBox
                    time: "00:00"
                    enabled: playRecordDlg.play === 2
                }
                Label {
                    text: " Format hh:mm"
                    font.pointSize: Style.pointSizeStandard
                    enabled: timeSpinBox.enabled
                }
            }
        }
        onApplied: {
            var t = time + ":00"
            console.log("onAccept",play,time,t)
            recordListModel.playRecord(playRecordDlg.record.id, playRecordDlg.play,t)
            close()
        }
    }

    SimpleMessageDialog {
        id: deleteRecordDlg
        titleText: "Aufnahme löschen?"
        property int id
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: recordListModel.deleteRecord(id)
    }
    SimpleMessageDialog {
        id: updrDlg
        titleText: "Aufnahmen akutalisieren"
        text: "Aufnahmen auf dem VDR neu einlesen?"
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: recordListModel.updateRecords()
    }
    SimpleMessageDialog {
        id: playDlg
        standardButtons: Dialog.Close
        titleText: "Aufnahme abspielen"
    }
    SimpleMessageDialog {
        id: editDlg
        titleText: "Aufnahme auf dem VDR schneiden?"
        property int id
        standardButtons: Dialog.Yes | Dialog.No
        onAccepted: recordListModel.editRecord(id)
    }

    MyControls.BusyIndicatorPopup {
        id: busyIndicator
    }

}
