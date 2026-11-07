import QtQuick
import Quickshell
import Quickshell.Wayland
import "../config" as Config
import "../services" as Services

PanelWindow {
    id: root

    property var modelData

    screen: modelData
    visible: Services.UiState.anyOpen

    anchors.left: true
    anchors.right: true
    anchors.top: true
    anchors.bottom: true

    color: "transparent"
    aboveWindows: true
    focusable: false
    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "phantom-click-catcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    readonly property int barStrip: Config.Settings.barHeight + Config.Settings.screenMargin

    mask: Region {
        x: 0
        y: Config.Settings.barPosition === "bottom" ? 0 : root.barStrip
        width: root.width
        height: Math.max(0, root.height - root.barStrip)
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: Services.UiState.dismissAll()
    }
}
