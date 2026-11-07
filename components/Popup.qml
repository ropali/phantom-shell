import QtQuick
import Quickshell
import Quickshell.Wayland
import "../themes"
import "../config" as Config
import "../services" as Services

PopupWindow {
    id: root

    property Item anchorItem: null
    property bool shown: false
    property bool above: Config.Settings.barPosition === "bottom"
    property int popupWidth: 320
    property int padding: Theme.padding
    property int spacing: Theme.spacing.md
    default property alias contentData: contentColumn.data

    visible: shown
    color: "transparent"
    implicitWidth: popupWidth
    implicitHeight: contentColumn.implicitHeight + padding * 2
    grabFocus: false

    anchor.item: root.anchorItem
    anchor.edges: root.above ? Edges.Top : Edges.Bottom
    anchor.gravity: root.above ? Edges.Top : Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX
    anchor.margins.top: root.above ? 0 : 6
    anchor.margins.bottom: root.above ? 6 : 0

    onClosed: root.shown = false
    onShownChanged: root.shown ? Services.UiState.popupOpened() : Services.UiState.popupClosed()

    Connections {
        target: Services.UiState
        function onDismissRequested() {
            root.shown = false;
        }
    }

    BackgroundEffect.blurRegion: Region {
        item: background
        radius: Theme.radius
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Theme.radius
        color: Theme.popupBackground
        border.width: Theme.borderWidth
        border.color: Theme.border

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: root.padding
            spacing: root.spacing
        }
    }
}
