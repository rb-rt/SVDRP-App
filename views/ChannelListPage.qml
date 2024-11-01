import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import QtQuick.Dialogs

import vdr.models 1.0
import vdr.epgsearch 1.0
import assets 1.0
import components 1.0
import dialogs 1.0
import controls 1.0 as MyControls
import "labels"
import "icons"
import "subviews"
import "transitions"

Page {

    id: root

    property ChannelModel channelModel
    property TimerModel timerModel
    property EPGSearch epgsearch

    property url streamUrl
    property bool streamingAvailable: streamUrl.toString() !== ""

    property var jniPlayer
    Component.onCompleted: {
        console.log("JNI_SUPPORT",JNI_SUPPORT)
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

    header: ToolBar {

        background: Loader { sourceComponent: Style.headerBackground }

        RowLayout {
            anchors.fill: parent

            MyControls.ToolButtonHeader { }

            Label {
                id: headerLabel
                text: "Kanalliste"
                font.pointSize: Style.pointSizeHeader
                font.weight: Style.fontweightHeader
                elide: Text.ElideRight
                // Layout.fillWidth: true
                // Layout.leftMargin: 10
            }

            CheckBox {
                text: "Ausgewählt"
                onCheckedChanged: channelSelectProxyModel.filtered = checked
                font.pointSize: Style.pointSizeStandard
                Layout.fillWidth: true
                Layout.leftMargin: 10
            }

            ChannelTypeDrawer {
                Layout.rightMargin: 10
                channelKind: channelSFProxyModel.ca
                channelType: channelSFProxyModel.channelType
                onDrawerClicked: {
                    channelSFProxyModel.ca = channelKind
                    channelSFProxyModel.channelType = channelType
                }
                onCanceled: {
                    channelKind = channelSFProxyModel.ca
                    channelType = channelSFProxyModel.channelType
                }
            }
        }
    }

    ChannelSFProxyModel {
        id: channelSFProxyModel
        sourceModel: channelModel
        filterCaseSensitivity: filterCaseSensitivityCheckBox.checked ? Qt.CaseSensitive : Qt.CaseInsensitive
    }

    ChannelSelectProxyModel {
        id: channelSelectProxyModel
        sourceModel: channelSFProxyModel
    }

    property ChannelEditView channelEditView
    Connections {
        target: channelEditView
        function onSaveChannel() {
            channelModel.updateChannel(channelEditView.channel)
            pageStack.pop()
        }
    }
    Connections {
        target: channelModel
        function onError(error) {
            channelSelectProxyModel.channels = []
            errorDlg.errorText = "Fehler beim Löschen der Kanäle: " + error + "\nKanalliste sollte unbedingt aktualisiert werden."
            errorDlg.open()
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        model: channelSelectProxyModel
        ScrollBar.vertical: ScrollBar{ }
        delegate: channelDelegate

        MyControls.EmptyListLabel {
            visible: parent.count === 0
            text: "Keine Kanäle gefunden."
        }

        property bool showFrequency: channelSFProxyModel.sortRole === ChannelModel.SortRoleFrequency
        section.property: channelSFProxyModel.sortNumber ? "group" : "frequency"
        section.criteria: ViewSection.FullString
        section.delegate: channelSFProxyModel.sortNumber ? sectionGroup : sectionFrequency

        populate: ListViewPopulate{}
        displaced: Transition { NumberAnimation { properties: "x,y"; duration: 400; easing.type: Easing.OutBounce } }
    }

    Component {
        id: sectionGroup
        Rectangle {
            id: sectionGroupRec
            width: ListView.view.width
            height: childrenRect.height
            gradient: Style.gradientTageswechsel

            required property string section
            onSectionChanged: sectionAnimation.start()

            Label {
                text: channelModel.getGroupName(parent.section)
                font.pointSize: Style.pointSizeSmall
                padding: 5
                leftPadding: 10
            }
            ListViewSectionAnimation {
                id: sectionAnimation
                target: sectionGroupRec
            }
        }
    }

    Component {
        id: sectionFrequency
        Rectangle {
            id: sectionFrequencyRec
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
                target: sectionFrequencyRec
            }
        }
    }

    property int channelIconWidth: Math.ceil(tm.advanceWidth) * Math.floor( Math.log10(channelModel.rowCount()) + 2)
    TextMetrics {
        id: tm
        font.pointSize: Style.pointSizeStandard
        font.bold: true
        text: "7"
    }

    Component {
        id: channelDelegate

        Rectangle {
            id: recChannel
            width: ListView.view.width
            height: rowLayout.height
            gradient: Style.gradientList

            required property var model
            property var channel: model.channel //zum unterdrücken von "cannot read property of undefined..."

            RowLayout {
                id: rowLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.pointSizeStandard
                implicitHeight: Style.listMinHeight

                //Kanallogo
                ChannelIcon {
                    Layout.preferredWidth: channelIconWidth
                    Layout.preferredHeight: parent.height
                    text: channel ? channel.number : "0"
                    active: true
                    onIconClicked: {
                        pageStack.replace("qrc:/views/EventListPage.qml", {
                                              channelModel:channelModel,
                                              timerModel: timerModel,
                                              epgsearch: epgsearch,
                                              channelID: model.channel.id
                                          })
                    }
                }

                ColumnLayout {
                    Layout.preferredWidth: deleteIcon.width
                    Layout.maximumWidth: deleteIcon.width
                    Label {
                        id: keyLabel
                        text: channel ? (channel.isFTA ? "" : Style.iconKey) : ""
                        font.family: Style.faSolid
                        font.pointSize: Style.pointSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                        visible: channel ? !model.channel.isFTA : false
                        Layout.fillWidth: true
                    }
                    Label {
                        id: musicLabel
                        text: channel ? (channel.isRadio ? Style.iconMusic : "") : ""
                        font.family: Style.faSolid
                        font.pointSize: Style.pointSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                        visible: channel ? channel.isRadio : false
                        Layout.fillWidth: true
                    }
                }

                LabelTitle {
                    id: channelLabel
                    text: channel ? model.display : ""
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                }

                CheckDelegate {
                    opacity: 0.66
                    checked: model.select
                    onToggled: model.select = checked
                    Layout.preferredWidth: deleteIcon.width
                }

                //Icons
                MoveIcon {
                    visible: !Style.showIndicatorIcon
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: deleteIcon.width
                    onIconClicked: {
                        moveDialog.title = qsTr("Kanal ") + model.channel.number + " (" + model.channel.name + ") " + qsTr("verschieben an Position")
                        moveDialog.fromChannel = model.id
                        moveDialog.open()
                    }
                }

                EditIcon {
                    visible: !Style.showIndicatorIcon
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        var ch = JSON.parse(JSON.stringify(model.channel))
                        channelEditView = pageStack.push("qrc:/views/subviews/ChannelEditView.qml", { channel: ch })
                    }
                }

                PlayIcon {
                    id: playIcon
                    visible: !Style.showIndicatorIcon
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        playContextMenu.channel = model.channel
                        playContextMenu.popup(playIcon)
                    }
                }

                DeleteIcon {
                    id: deleteIcon
                    visible: !Style.showIndicatorIcon
                    Layout.preferredHeight: parent.height
                    onIconClicked: {
                        deleteDialog.text = model.channelnrname
                        deleteDialog.channelIds = model.id
                        deleteDialog.open()
                    }
                }

                IndicatorIcon {
                    id: contextMenuIcon
                    visible: Style.showIndicatorIcon
                    Layout.preferredHeight: recChannel.height
                    onIconClicked: {
                        contextMenu.channel = model.channel
                        contextMenu.popup(contextMenuIcon)
                    }
                }
            }
        }
    }

    footer: ToolBar {
        id: footer
        background: Loader { sourceComponent: Style.footerBackground }

        height: lineInput.height + 20

        SwipeView {
            id: swipeView
            anchors.fill: parent
            //[0]
            RowLayout {
                Label {
                    text: Style.iconSort
                    font.pointSize: Style.pointSizeStandard
                    font.family: Style.faSolid
                    opacity: 0.7
                    Layout.leftMargin: 20
                }
                Switch {
                    id: sortSwitch
                    text: checked ? "Frequenz" : "Nummer"
                    font.pointSize: Style.pointSizeStandard
                    onToggled: channelSFProxyModel.sortNumber = !checked
                }
                Switch {
                    text: checked ? Style.iconSortNumDownAlt : Style.iconSortNumDown
                    font.pointSize: Style.pointSizeStandard
                    font.family: Style.faSolid
                    checked: false
                    onClicked: checked ?  channelSFProxyModel.sortOrder = Qt.DescendingOrder :
                                         channelSFProxyModel.sortOrder = Qt.AscendingOrder
                }
                Label {
                    Layout.fillWidth: true
                }
                MyControls.CommandBar {
                    commandList: ObjectModel {
                        Loader { sourceComponent: deleteCommandButton }
                        MyControls.CommandButton {
                            iconCharacter: Style.iconRedo
                            description: "Aktualisieren"
                            onCommandButtonClicked: channelModel.getChannels()
                        }
                    }
                }
            }
            //[1]
            RowLayout {
                Label {
                    text: "Filter:"
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 20
                }
                CheckBox {
                    id: filterCaseSensitivityCheckBox
                    text: checked ? "aa" : "Aa"
                    enabled: channelSFProxyModel.filterText.length > 0
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 10
                }
                CheckBox {
                    text: checked ? "\"text\"" : ".text."
                    font.pointSize: Style.pointSizeStandard
                    enabled: channelSFProxyModel.filterText.length > 0
                    onToggled: channelSFProxyModel.wordOnly = checked
                }
                MyControls.LineInput {
                    id: lineInput
                    placeholderText: "Textfilter..."
                    onTextChanged: channelSFProxyModel.filterText = text
                    Layout.fillWidth: true
                }
                Loader { sourceComponent: deleteCommandButton }
            }
            //[2]
            RowLayout {
                MyControls.CommandBar {
                    Layout.alignment: Qt.AlignRight
                    commandList: ObjectModel {
                        MyControls.CommandButton {
                            iconCharacter: Style.iconQuestion
                            description: "Hilfe"
                            fontSolid: false
                            onCommandButtonClicked: helpPopup.open()
                        }
                        MyControls.CommandButton {
                            iconCharacter: Style.iconCheckCircle
                            description: "Alle"
                            fontSolid: false
                            onCommandButtonClicked: channelSelectProxyModel.selectAll()
                        }
                        MyControls.CommandButton {
                            iconCharacter: Style.iconCircle
                            description: "Keine"
                            fontSolid: false
                            onCommandButtonClicked: channelSelectProxyModel.selectNone()
                        }
                        MyControls.CommandButton {
                            iconCharacter: Style.iconCircleDot
                            fontSolid: false
                            description: "Umkehren"
                            onCommandButtonClicked: channelSelectProxyModel.selectInvert()
                        }
                        MyControls.CommandButton {
                            iconCharacter: "[ ]"
                            description: "Bereich"
                            onCommandButtonClicked: dialogIntervall.open()
                        }
                        Loader { sourceComponent: deleteCommandButton }
                    }
                }
            }
        }//swipeView
        PageIndicator {
            count: swipeView.count
            currentIndex: swipeView.currentIndex
            anchors.left: parent.left
            anchors.top: parent.top
        }
    }

    Component {
        id: deleteCommandButton
        MyControls.CommandButton {
            iconCharacter: Style.iconTrash
            description: "Löschen"
            enabled: channelSelectProxyModel.channels.length > 0
            onCommandButtonClicked: {
                deleteDialog.titleText = "Mehrere Kanäle löschen"
                deleteDialog.text = "Alle ausgewählten Kanäle löschen?"
                deleteDialog.channelIds = channelSelectProxyModel.channels
                deleteDialog.open()
            }
        }
    }

    Menu {
        id: playContextMenu

        property var channel

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

        MyControls.ContextMenuItem {
            isLabel: true
            description: playContextMenu.channel ? playContextMenu.channel.name : ""
        }
        MyControls.ContextMenuItem {
            enabled: streamingAvailable
            description: qsTr("Lokale Wiedergabe")
            iconCharacter: Style.iconMobile
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayLocal
            onMenuItemClicked: {
                var u = streamUrl + "/" + playContextMenu.channel.id + ".ts"
                jniPlayer.playVideo(u)
            }
        }
        MyControls.ContextMenuItem {
            description: "Wiedergabe auf VDR"
            iconCharacter: Style.iconSwitch
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayVdr
            onMenuItemClicked: channelModel.switchToChannel(playContextMenu.channel.id)
        }
    }

    Menu {
        id: contextMenu

        property var channel

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

        MyControls.ContextMenuItem {
            isLabel: true
            description: contextMenu.channel ? contextMenu.channel.name : ""
        }
        MyControls.ContextMenuItem {
            iconCharacter: Style.iconArrowsUpDown
            iconColor: Style.colorListIconMove
            iconFont: Style.faSolid
            description: qsTr("Verschieben")
            onMenuItemClicked: {
                moveDialog.title = qsTr("Kanal ") + contextMenu.channel.number + " (" + contextMenu.channel.name + ") " + qsTr("verschieben an Position")
                moveDialog.fromChannel = contextMenu.channel.id
                contextMenu.close()
                moveDialog.open()
            }
        }
        MyControls.ContextMenuItem {
            iconCharacter: Style.iconEdit
            iconColor: Style.colorListIconEdit
            iconFont: Style.faRegular
            description: qsTr("Bearbeiten")
            onMenuItemClicked: {
                var ch = JSON.parse(JSON.stringify(contextMenu.channel))
                channelEditView = pageStack.push("qrc:/views/subviews/ChannelEditView.qml", { channel: ch })
            }
        }
        MyControls.ContextMenuItem {
            enabled: streamingAvailable
            description: qsTr("Lokale Wiedergabe")
            iconCharacter: Style.iconMobile
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayLocal
            onMenuItemClicked: {
                var u = streamUrl + "/" + contextMenu.channel.id + ".ts"
                jniPlayer.playVideo(u)
            }
        }

        MyControls.ContextMenuItem {
            description: "Wiedergabe auf VDR"
            iconCharacter: Style.iconSwitch
            iconFont: Style.faSolid
            iconColor: Style.colorListIconPlayVdr
            onMenuItemClicked: channelModel.switchTochannel(contextMenu.channel.id)
        }
        MyControls.ContextMenuItem {
            iconCharacter: Style.iconTrash
            iconColor: Style.colorListIconDelete
            iconFont: Style.faRegular
            description: qsTr("Löschen")
            onMenuItemClicked: {
                deleteDialog.text = qsTr("Kanal ") + contextMenu.channel.number + " (" + contextMenu.channel.name + ") " + qsTr("löschen?")
                deleteDialog.channelId = contextMenu.channel.id
                contextMenu.close()
                deleteDialog.open()
            }
        }
    }

    Dialog {
        id: moveDialog
        modal: true
        anchors.centerIn: parent
        property string fromChannel: ""
        onApplied: {
            var from = channelModel.getChannelNumber(fromChannel)
            var to = channelModel.getChannelNumber(channelComboBox.selectedChannel)
            channelModel.moveChannel(from,to)
            close()
        }

        header: ToolBar {
            contentHeight: implicitHeaderHeight
            Label {
                text: moveDialog.title
                font.pointSize: Style.pointSizeStandard
                font.bold: true
                leftPadding: 10
                rightPadding: 10
                verticalAlignment: Qt.AlignVCenter
                height: parent.height
            }

            background: Rectangle {
                color: Style.colorPrimary
            }
        }
        contentItem: ChannelComboBox {
            id: channelComboBox
            channelModel: root.channelModel
            selectedChannel: moveDialog.fromChannel
            onSelectedChannelChanged: {
                console.log("ChannelListPage.qml ChannelComboBox onSelectedChannelChanged firstChannel", moveDialog.fromChannel)
                buttons.standardButton(Dialog.Apply).enabled = moveDialog.fromChannel !== selectedChannel
            }
        }
        footer: DialogButtonBox {
            id: buttons
            standardButtons: Dialog.Cancel | Dialog.Apply
            font.pointSize: Style.pointSizeStandard
        }
        onAboutToShow: {
            buttons.standardButton(Dialog.Apply).enabled = false
        }
    }

    MyMessageDialog {
        id: deleteDialog
        titleText: qsTr("Kanal löschen?")
        property var channelIds: []
        onAccepted: {
            channelModel.deleteChannels(channelIds)
            channelSelectProxyModel.channels = []
        }
    }

    ErrorDialog {
        id: errorDlg
    }

    Dialog {
        id: dialogIntervall
        modal: true
        anchors.centerIn: parent

        header: ToolBar {

            Label {
                text: "Bereich auswählen"
                font.pointSize: Style.pointSizeStandard
                font.bold: true
                leftPadding: 10
                rightPadding: 10
                verticalAlignment: Qt.AlignVCenter
                height: parent.height
            }

            background: Rectangle {
                color: Style.colorPrimary
                implicitHeight: 48 //s. DialogInputText.qml
            }
        }
        ColumnLayout {
            spacing: 10
            RowLayout {
                Label {
                    text: "Von Kanal"
                    font.pointSize: Style.pointSizeStandard
                    Layout.rightMargin: 5
                }
                MyControls.SpinBox {
                    id: fromBox
                    from: 1
                    to: channelModel.rowCount()
                    editable: true
                    value: 1
                    onValueChanged: if (value > toBox.value) toBox.value = value
                }
                Label {
                    text: "bis"
                    font.pointSize: Style.pointSizeStandard
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5
                }
                MyControls.SpinBox {
                    id: toBox
                    from: 1
                    to: channelModel.rowCount()
                    editable: true
                    value: channelModel.rowCount()
                    onValueChanged: if (value < fromBox.value) fromBox.value = value
                }
            }
            Label {
                text: "Die Angaben beziehen sich hier auf die gesamte Liste und nicht auf die gerade ausgewählten Kanäle."
                font.pointSize: Style.pointSizeStandard
                Layout.preferredWidth: parent.width
                wrapMode: Text.WordWrap
            }
        }
        footer: DialogButtonBox {
            standardButtons: Dialog.Cancel | Dialog.Apply
            font.pointSize: Style.pointSizeStandard
        }
        onApplied: {
            channelSelectProxyModel.selectIntervall(fromBox.value,toBox.value)
            close()
        }
    }

    ChannelHelpPopup {
        id: helpPopup
    }
}
